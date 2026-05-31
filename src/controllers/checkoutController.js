const { query }  = require("../config/database");
const wsService  = require("../services/wsService");

const BASE_SELECT = `
  SELECT
    c.id, c.status, c.due_date, c.returned_at, c.notes, c.created_at,
    json_build_object('id', p.id, 'name', p.name, 'sku', p.sku, 'photo_url', p.photo_url) AS product,
    json_build_object('id', u.id, 'name', u.name, 'email', u.email, 'role', u.role)       AS user,
    CASE WHEN c.approved_by IS NOT NULL
      THEN json_build_object('id', a.id, 'name', a.name) ELSE NULL END                    AS approved_by
  FROM checkouts c
  JOIN products p ON p.id = c.product_id
  JOIN users    u ON u.id = c.user_id
  LEFT JOIN users a ON a.id = c.approved_by
`;

// GET /api/checkouts
const getCheckouts = async (req, res, next) => {
  try {
    const { status, mine } = req.query;
    const conditions = [];
    const params     = [];

    if (mine === 'true') {
      params.push(req.user.id);
      conditions.push(`c.user_id = $${params.length}`);
    }
    if (status) {
      params.push(status);
      conditions.push(`c.status = $${params.length}`);
    }

    const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
    const result = await query(`${BASE_SELECT} ${where} ORDER BY c.created_at DESC LIMIT 100`, params);
    res.json({ success: true, data: result.rows });
  } catch (err) { next(err); }
};

// POST /api/checkouts
const requestCheckout = async (req, res, next) => {
  try {
    const { product_id, due_date, notes } = req.body;
    if (!product_id) return res.status(400).json({ success: false, message: 'product_id required' });

    // Check if product already has an active checkout
    const active = await query(
      `SELECT id FROM checkouts WHERE product_id = $1 AND status IN ('pending','approved') LIMIT 1`,
      [product_id]
    );
    if (active.rows.length) {
      return res.status(409).json({ success: false, message: 'This item is already checked out or pending approval' });
    }

    const result = await query(
      `INSERT INTO checkouts (product_id, user_id, due_date, notes)
       VALUES ($1, $2, $3, $4) RETURNING id`,
      [product_id, req.user.id, due_date || null, notes || null]
    );

    const full = await query(`${BASE_SELECT} WHERE c.id = $1`, [result.rows[0].id]);

    // Notify all techniciens/admins
    const staff = await query(`SELECT id FROM users WHERE role IN ('admin','technicien') AND is_active = true`);
    staff.rows.forEach(({ id }) => wsService.sendToUser(id, {
      type: 'checkout_request',
      checkout: full.rows[0],
    }));

    res.status(201).json({ success: true, data: full.rows[0] });
  } catch (err) { next(err); }
};

// PATCH /api/checkouts/:id/approve
const approveCheckout = async (req, res, next) => {
  try {
    await query(
      `UPDATE checkouts SET status = 'approved', approved_by = $1 WHERE id = $2 AND status = 'pending'`,
      [req.user.id, req.params.id]
    );
    const full = await query(`${BASE_SELECT} WHERE c.id = $1`, [req.params.id]);
    if (!full.rows.length) return res.status(404).json({ success: false, message: 'Not found' });

    wsService.sendToUser(full.rows[0].user.id, {
      type: 'checkout_approved',
      checkout: full.rows[0],
    });
    res.json({ success: true, data: full.rows[0] });
  } catch (err) { next(err); }
};

// PATCH /api/checkouts/:id/reject
const rejectCheckout = async (req, res, next) => {
  try {
    await query(
      `UPDATE checkouts SET status = 'rejected', approved_by = $1 WHERE id = $2 AND status = 'pending'`,
      [req.user.id, req.params.id]
    );
    const full = await query(`${BASE_SELECT} WHERE c.id = $1`, [req.params.id]);
    if (!full.rows.length) return res.status(404).json({ success: false, message: 'Not found' });

    wsService.sendToUser(full.rows[0].user.id, { type: 'checkout_rejected', checkout: full.rows[0] });
    res.json({ success: true, data: full.rows[0] });
  } catch (err) { next(err); }
};

// PATCH /api/checkouts/:id/return
const returnCheckout = async (req, res, next) => {
  try {
    await query(
      `UPDATE checkouts SET status = 'returned', returned_at = NOW() WHERE id = $1 AND status = 'approved'`,
      [req.params.id]
    );
    const full = await query(`${BASE_SELECT} WHERE c.id = $1`, [req.params.id]);
    if (!full.rows.length) return res.status(404).json({ success: false, message: 'Not found' });

    wsService.sendToUser(full.rows[0].user.id, { type: 'checkout_returned', checkout: full.rows[0] });
    res.json({ success: true, data: full.rows[0] });
  } catch (err) { next(err); }
};

module.exports = { getCheckouts, requestCheckout, approveCheckout, rejectCheckout, returnCheckout };
