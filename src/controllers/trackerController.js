const { query } = require("../config/database");
const wsService = require("../services/wsService");

// GET /api/trackers
const getTrackers = async (req, res, next) => {
  try {
    const result = await query(
      `SELECT
         p.id, p.name, p.sku, p.status, p.photo_url,
         p.tracker_lat, p.tracker_lng, p.tracker_battery,
         p.tracker_checked_at, p.tracker_active,
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
       WHERE p.tracker_active = true OR p.room_id IS NOT NULL
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

    await query(
      `UPDATE products
       SET tracker_lat        = $1,
           tracker_lng        = $2,
           tracker_battery    = $3,
           tracker_checked_at = NOW(),
           tracker_active     = true
       WHERE id = $4`,
      [lat, lng, battery !== undefined ? battery : null, id]
    );

    res.json({ success: true });
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

module.exports = { getTrackers, checkIn, pingDevice, toggleTracker };
