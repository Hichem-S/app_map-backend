const { query } = require("../config/database");
const wsService = require("../services/wsService");

const BASE_SELECT = `
  SELECT
    t.id, t.status, t.notes, t.created_at, t.resolved_at,
    json_build_object('id', p.id, 'name', p.name, 'sku', p.sku, 'photo_url', p.photo_url) AS product,
    json_build_object('id', ru.id, 'name', ru.name, 'role', ru.role) AS requested_by,
    CASE WHEN t.resolved_by IS NOT NULL
      THEN json_build_object('id', rv.id, 'name', rv.name) ELSE NULL END AS resolved_by,
    CASE WHEN t.from_room_id IS NOT NULL
      THEN json_build_object('id', fr.id, 'name', fr.name) ELSE NULL END AS from_room,
    CASE WHEN t.to_room_id IS NOT NULL
      THEN json_build_object('id', tr.id, 'name', tr.name) ELSE NULL END AS to_room
  FROM transfer_requests t
  JOIN products p  ON p.id  = t.product_id
  JOIN users ru    ON ru.id = t.requested_by
  LEFT JOIN users rv    ON rv.id = t.resolved_by
  LEFT JOIN rooms fr    ON fr.id = t.from_room_id
  LEFT JOIN rooms tr    ON tr.id = t.to_room_id
`;

// GET /api/transfers
const getTransfers = async (req, res, next) => {
  try {
    const { status, mine } = req.query;
    const conditions = [], params = [];

    if (mine === 'true') {
      params.push(req.user.id);
      conditions.push(`t.requested_by = $${params.length}`);
    }
    if (status) {
      params.push(status);
      conditions.push(`t.status = $${params.length}`);
    }

    const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
    const result = await query(
      `${BASE_SELECT} ${where} ORDER BY t.created_at DESC LIMIT 100`, params
    );
    res.json({ success: true, data: result.rows });
  } catch (err) { next(err); }
};

// POST /api/transfers
const createTransfer = async (req, res, next) => {
  try {
    const { product_id, to_room_id, notes } = req.body;
    if (!product_id || !to_room_id) {
      return res.status(400).json({ success: false, message: 'product_id and to_room_id required' });
    }

    const prod = await query(
      `SELECT id, name, room_id FROM products WHERE id = $1`, [product_id]
    );
    if (!prod.rows.length) return res.status(404).json({ success: false, message: 'Product not found' });

    const ins = await query(
      `INSERT INTO transfer_requests (product_id, requested_by, from_room_id, to_room_id, notes)
       VALUES ($1,$2,$3,$4,$5) RETURNING id`,
      [product_id, req.user.id, prod.rows[0].room_id || null, to_room_id, notes || null]
    );

    const full = await query(`${BASE_SELECT} WHERE t.id = $1`, [ins.rows[0].id]);

    // Notify all staff
    const staff = await query(
      `SELECT id FROM users WHERE role IN ('admin','technicien') AND is_active = true`
    );
    for (const s of staff.rows) {
      await query(
        `INSERT INTO notifications (user_id, type, title, body, product_id, product_name)
         VALUES ($1,'transfer_request','Transfer Request',$2,$3,$4)`,
        [s.id, `${req.user.name} requested to move ${prod.rows[0].name}`,
         product_id, prod.rows[0].name]
      ).catch(() => {});
      wsService.sendToUser(s.id, {
        type: 'transfer_request',
        title: 'Transfer Request',
        body: `${req.user.name} requested to move ${prod.rows[0].name}`,
        productId: product_id, productName: prod.rows[0].name,
      });
    }

    res.status(201).json({ success: true, data: full.rows[0] });
  } catch (err) { next(err); }
};

// PATCH /api/transfers/:id/approve
const approveTransfer = async (req, res, next) => {
  try {
    const t = await query(`SELECT * FROM transfer_requests WHERE id = $1`, [req.params.id]);
    if (!t.rows.length) return res.status(404).json({ success: false, message: 'Not found' });
    if (t.rows[0].status !== 'pending') {
      return res.status(400).json({ success: false, message: 'Already resolved' });
    }

    await query(
      `UPDATE transfer_requests SET status='approved', resolved_by=$1, resolved_at=NOW() WHERE id=$2`,
      [req.user.id, req.params.id]
    );
    // Actually move the product
    await query(
      `UPDATE products SET room_id=$1, last_moved_by=$2, last_moved_at=NOW(), updated_at=NOW() WHERE id=$3`,
      [t.rows[0].to_room_id, req.user.id, t.rows[0].product_id]
    );

    const full = await query(`${BASE_SELECT} WHERE t.id = $1`, [req.params.id]);
    const prod = full.rows[0]?.product;

    // Notify requester
    await query(
      `INSERT INTO notifications (user_id, type, title, body, product_id, product_name)
       VALUES ($1,'transfer_approved','Transfer Approved',$2,$3,$4)`,
      [t.rows[0].requested_by,
       `Your request to move ${prod?.name} was approved`,
       t.rows[0].product_id, prod?.name]
    ).catch(() => {});
    wsService.sendToUser(t.rows[0].requested_by, {
      type: 'transfer_approved', title: 'Transfer Approved',
      body: `Your request to move ${prod?.name} was approved`,
      productId: t.rows[0].product_id, productName: prod?.name,
    });

    res.json({ success: true, data: full.rows[0] });
  } catch (err) { next(err); }
};

// PATCH /api/transfers/:id/reject
const rejectTransfer = async (req, res, next) => {
  try {
    const t = await query(`SELECT * FROM transfer_requests WHERE id = $1`, [req.params.id]);
    if (!t.rows.length) return res.status(404).json({ success: false, message: 'Not found' });
    if (t.rows[0].status !== 'pending') {
      return res.status(400).json({ success: false, message: 'Already resolved' });
    }

    await query(
      `UPDATE transfer_requests SET status='rejected', resolved_by=$1, resolved_at=NOW() WHERE id=$2`,
      [req.user.id, req.params.id]
    );

    const full = await query(`${BASE_SELECT} WHERE t.id = $1`, [req.params.id]);
    const prod = full.rows[0]?.product;

    wsService.sendToUser(t.rows[0].requested_by, {
      type: 'transfer_rejected', title: 'Transfer Rejected',
      body: `Your request to move ${prod?.name} was rejected`,
      productId: t.rows[0].product_id, productName: prod?.name,
    });

    res.json({ success: true, data: full.rows[0] });
  } catch (err) { next(err); }
};

module.exports = { getTransfers, createTransfer, approveTransfer, rejectTransfer };
