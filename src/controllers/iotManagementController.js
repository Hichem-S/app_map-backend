const { query }    = require('../config/database');
const wsService    = require('../services/wsService');

// GET /api/iot/unregistered
// Returns all unresolved unregistered scans (most recent first, deduped by uid)
const getUnregistered = async (req, res, next) => {
  try {
    const result = await query(`
      SELECT DISTINCT ON (uid)
        id, uid, scan_type, room_id, room_name, reader_id, scanned_at
      FROM unregistered_scans
      WHERE resolved = FALSE
      ORDER BY uid, scanned_at DESC
    `);
    res.json({ success: true, data: result.rows });
  } catch (err) {
    next(err);
  }
};

// PATCH /api/iot/unregistered/:id/assign
// Technicien assigns the tag to a product — sets rfid_tag or ble_device depending on scan_type
const assignUnregistered = async (req, res, next) => {
  try {
    const { product_id } = req.body;
    if (!product_id) {
      return res.status(400).json({ success: false, message: 'product_id required' });
    }

    // Fetch the unregistered scan
    const scanRes = await query(
      'SELECT * FROM unregistered_scans WHERE id = $1 AND resolved = FALSE',
      [req.params.id]
    );
    if (!scanRes.rows.length) {
      return res.status(404).json({ success: false, message: 'Scan not found or already resolved' });
    }
    const scan = scanRes.rows[0];

    const tagField = scan.scan_type === 'ble' ? 'ble_device' : 'rfid_tag';

    // Check the tag isn't already taken by another product
    const conflict = await query(
      `SELECT id, name FROM products WHERE ${tagField} = $1 AND id <> $2 LIMIT 1`,
      [scan.uid, product_id]
    );
    if (conflict.rows.length) {
      return res.status(409).json({
        success: false,
        message: `Tag "${scan.uid}" is already assigned to "${conflict.rows[0].name}"`,
      });
    }

    // Assign the tag + move product to the room where it was scanned
    const productRes = await query(
      `UPDATE products
       SET ${tagField} = $1, room_id = $2, updated_at = NOW()
       WHERE id = $3
       RETURNING id, name, sku, rfid_tag, ble_device, room_id`,
      [scan.uid, scan.room_id, product_id]
    );
    if (!productRes.rows.length) {
      return res.status(404).json({ success: false, message: 'Product not found' });
    }

    // Mark all scans of this uid as resolved
    await query(
      `UPDATE unregistered_scans
       SET resolved = TRUE, resolved_by = $1, resolved_at = NOW(), product_id = $2
       WHERE uid = $3`,
      [req.user.id, product_id, scan.uid]
    );

    // Broadcast so live feed updates in real time
    wsService.broadcast({
      type:        'tag_assigned',
      uid:         scan.uid,
      product_id,
      product_name: productRes.rows[0].name,
      room_name:   scan.room_name,
      assigned_by: req.user.name,
      timestamp:   new Date().toISOString(),
    });

    res.json({ success: true, data: productRes.rows[0] });
  } catch (err) {
    next(err);
  }
};

module.exports = { getUnregistered, assignUnregistered };
