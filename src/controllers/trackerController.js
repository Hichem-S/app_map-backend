const { query } = require("../config/database");
const wsService = require("../services/wsService");
const mailer  = require("../services/emailService");

// ISET Mahdia geofence (configurable via env)
const ISET_LAT    = parseFloat(process.env.GEOFENCE_LAT    || "35.5047");
const ISET_LNG    = parseFloat(process.env.GEOFENCE_LNG    || "11.0622");
const ISET_RADIUS = parseFloat(process.env.GEOFENCE_RADIUS || "300");   // metres
const ALERT_COOLDOWN_MS = 60 * 60 * 1000; // 1 hour between repeat alerts

function haversineMeters(lat1, lng1, lat2, lng2) {
  const R = 6371000;
  const toRad = d => (d * Math.PI) / 180;
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const a = Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

// GET /api/trackers
const getTrackers = async (req, res, next) => {
  try {
    const result = await query(
      `SELECT
         p.id, p.name, p.sku, p.status, p.photo_url,
         p.tracker_lat, p.tracker_lng, p.tracker_battery,
         p.tracker_checked_at, p.tracker_active, p.ble_device,
         p.tracker_hashed_key,
         r.id   AS room_id,   r.name AS room_name,
         d.id   AS dept_id,   d.name AS dept_name,
         d.code AS dept_code, d.color AS dept_color,
         c.name AS category_name,
         u.name AS last_mover_name
       FROM products p
       LEFT JOIN rooms       r ON r.id = p.room_id
       LEFT JOIN departments d ON d.id = r.department_id
       LEFT JOIN categories  c ON c.id = p.category_id
       LEFT JOIN users       u ON u.id = p.last_moved_by
       WHERE p.tracker_hashed_key IS NOT NULL OR p.tracker_active = true
       ORDER BY p.tracker_checked_at DESC NULLS LAST, p.name ASC`,
      []
    );
    res.json({ success: true, data: result.rows });
  } catch (err) {
    next(err);
  }
};

// PATCH /api/trackers/:id/check-in
const checkIn = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { lat, lng, battery } = req.body;

    const distanceM = haversineMeters(lat, lng, ISET_LAT, ISET_LNG);
    const outsideZone = distanceM > ISET_RADIUS;

    const prev = await query(
      `SELECT name, sku, tracker_outside_zone, tracker_alert_sent_at FROM products WHERE id = $1`,
      [id]
    );
    if (!prev.rows.length) return res.status(404).json({ success: false, message: "Product not found" });
    const product = prev.rows[0];

    await query(
      `UPDATE products
       SET tracker_lat          = $1,
           tracker_lng          = $2,
           tracker_battery      = $3,
           tracker_checked_at   = NOW(),
           tracker_active       = true,
           tracker_outside_zone = $4,
           tracker_alert_sent_at = CASE WHEN $4 AND ($5::boolean = false OR $6::timestamp IS NULL OR NOW() - $6::timestamp > INTERVAL '1 hour') THEN NOW() ELSE tracker_alert_sent_at END
       WHERE id = $7`,
      [lat, lng, battery !== undefined ? battery : null, outsideZone,
       product.tracker_outside_zone, product.tracker_alert_sent_at, id]
    );

    // Fire alert if newly outside zone (or re-alert after cooldown)
    const wasOutside   = product.tracker_outside_zone;
    const lastAlert    = product.tracker_alert_sent_at ? new Date(product.tracker_alert_sent_at) : null;
    const cooldownOver = !lastAlert || (Date.now() - lastAlert.getTime() > ALERT_COOLDOWN_MS);

    if (outsideZone && (!wasOutside || cooldownOver)) {
      const distKm = (distanceM / 1000).toFixed(2);
      const recipients = await query(
        `SELECT id, email, name FROM users WHERE role = 'admin' AND is_active = true`
      );
      for (const u of recipients.rows) {
        const body = JSON.stringify({
          text: `${product.name} (${product.sku}) is ${distKm} km from ISET — outside the allowed zone.`,
          productId: id,
          productName: product.name,
          distanceKm: distKm,
        });
        await query(
          `INSERT INTO notifications (user_id, type, title, body, product_id, product_name) VALUES ($1, 'tracker_zone_alert', $2, $3, $4, $5)`,
          [u.id, `AirTag out of zone — ${product.name}`, body, id, product.name]
        );
        wsService.sendToUser(u.id, {
          type: "tracker_zone_alert",
          productId: id,
          productName: product.name,
          distanceKm: distKm,
        });
        mailer.sendMail(
          u.email,
          `⚠️ AirTag Alert — ${product.name} left ISET`,
          `<p>Hi ${u.name},</p>
           <p><strong>${product.name}</strong> (${product.sku}) was detected <strong>${distKm} km</strong> from ISET Mahdia — outside the ${ISET_RADIUS}m allowed zone.</p>
           <p>Check the tracker screen in Smart Inventory for the live location.</p>`
        ).catch(() => {});
      }
    }

    res.json({ success: true, outsideZone, distanceMeters: Math.round(distanceM) });
  } catch (err) {
    next(err);
  }
};

// POST /api/trackers/:id/ping
const pingDevice = async (req, res, next) => {
  try {
    const { id } = req.params;

    const productResult = await query(
      `SELECT name, sku FROM products WHERE id = $1`,
      [id]
    );

    if (!productResult.rows.length) {
      return res.status(404).json({ success: false, message: "Product not found" });
    }

    const { name: productName, sku } = productResult.rows[0];

    const usersResult = await query(
      `SELECT id FROM users WHERE is_active = true AND role IN ('admin', 'technicien')`,
      []
    );

    for (const user of usersResult.rows) {
      wsService.sendToUser(user.id, {
        type: "tracker_ping",
        productId: id,
        productName,
        sku,
        pingBy: req.user.name,
      });
    }

    res.json({ success: true });
  } catch (err) {
    next(err);
  }
};

// PATCH /api/trackers/:id/toggle
const toggleTracker = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { active } = req.body;

    await query(
      `UPDATE products SET tracker_active = $1 WHERE id = $2`,
      [active, id]
    );

    res.json({ success: true });
  } catch (err) {
    next(err);
  }
};

// PATCH /api/trackers/:id/link  { hashed_key, ble_mac? }
const linkTracker = async (req, res, next) => {
  try {
    const { hashed_key, ble_mac } = req.body;
    if (!hashed_key) {
      return res.status(400).json({ success: false, message: 'hashed_key required' });
    }

    // Ensure the key isn't already linked to another product
    const conflict = await query(
      `SELECT id, name FROM products WHERE tracker_hashed_key = $1 AND id <> $2 LIMIT 1`,
      [hashed_key, req.params.id]
    );
    if (conflict.rows.length) {
      return res.status(409).json({
        success: false,
        message: `Key already linked to "${conflict.rows[0].name}"`,
      });
    }

    const updates = ['tracker_hashed_key = $1', 'tracker_active = true', 'updated_at = NOW()'];
    const params  = [hashed_key];

    if (ble_mac) {
      params.push(ble_mac.toLowerCase());
      updates.push(`ble_device = $${params.length}`);
    }

    params.push(req.params.id);
    const result = await query(
      `UPDATE products SET ${updates.join(', ')} WHERE id = $${params.length}
       RETURNING id, name, sku, tracker_hashed_key, ble_device, tracker_active`,
      params
    );

    if (!result.rows.length) {
      return res.status(404).json({ success: false, message: 'Product not found' });
    }
    res.json({ success: true, data: result.rows[0] });
  } catch (err) {
    next(err);
  }
};

// DELETE /api/trackers/:id/link
const unlinkTracker = async (req, res, next) => {
  try {
    await query(
      `UPDATE products
       SET tracker_hashed_key = NULL,
           tracker_active      = false,
           tracker_lat         = NULL,
           tracker_lng         = NULL,
           tracker_battery     = NULL,
           tracker_checked_at  = NULL,
           updated_at          = NOW()
       WHERE id = $1`,
      [req.params.id]
    );
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
};

module.exports = { getTrackers, checkIn, pingDevice, toggleTracker, linkTracker, unlinkTracker };
