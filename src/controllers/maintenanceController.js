const { query } = require("../config/database");
const wsService = require("../services/wsService");

const BASE_SELECT = `
  SELECT
    m.id, m.title, m.description, m.priority, m.status,
    m.scheduled_date, m.completed_at, m.created_at, m.recurrence_interval_days,
    json_build_object('id', p.id, 'name', p.name, 'sku', p.sku, 'photo_url', p.photo_url) AS product,
    json_build_object('id', c.id, 'name', c.name)                                          AS created_by,
    CASE WHEN m.assigned_to IS NOT NULL
      THEN json_build_object('id', a.id, 'name', a.name) ELSE NULL END                     AS assigned_to
  FROM maintenance_tasks m
  JOIN products p ON p.id = m.product_id
  JOIN users    c ON c.id = m.created_by
  LEFT JOIN users a ON a.id = m.assigned_to
`;

// GET /api/maintenance
const getTasks = async (req, res, next) => {
  try {
    const { status, priority, mine, product_id } = req.query;
    const conditions = [];
    const params     = [];

    if (product_id) {
      params.push(product_id);
      conditions.push(`m.product_id = $${params.length}`);
    }
    if (mine === 'true') {
      params.push(req.user.id);
      conditions.push(`(m.assigned_to = $${params.length} OR m.created_by = $${params.length})`);
    }
    if (status) {
      params.push(status);
      conditions.push(`m.status = $${params.length}`);
    }
    if (priority) {
      params.push(priority);
      conditions.push(`m.priority = $${params.length}`);
    }

    const where   = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
    const orderBy = product_id
      ? 'ORDER BY m.created_at DESC'
      : `ORDER BY CASE m.priority WHEN 'high' THEN 1 WHEN 'medium' THEN 2 ELSE 3 END,
           m.scheduled_date ASC NULLS LAST, m.created_at DESC`;
    const result = await query(
      `${BASE_SELECT} ${where} ${orderBy} LIMIT 100`,
      params
    );
    res.json({ success: true, data: result.rows });
  } catch (err) { next(err); }
};

// POST /api/maintenance
const createTask = async (req, res, next) => {
  try {
    const { product_id, title, description, priority = 'medium', assigned_to, scheduled_date, recurrence_interval_days } = req.body;
    if (!product_id || !title) {
      return res.status(400).json({ success: false, message: 'product_id and title required' });
    }

    const result = await query(
      `INSERT INTO maintenance_tasks
         (product_id, created_by, assigned_to, title, description, priority, scheduled_date, recurrence_interval_days)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING id`,
      [product_id, req.user.id, assigned_to || req.user.id, title, description || null, priority, scheduled_date || null, recurrence_interval_days || null]
    );

    const full = await query(`${BASE_SELECT} WHERE m.id = $1`, [result.rows[0].id]);

    // Update product status to maintenance
    await query(`UPDATE products SET status = 'maintenance', updated_at = NOW() WHERE id = $1`, [product_id]);

    // Notify assigned technician if different from creator
    if (assigned_to && assigned_to !== req.user.id) {
      wsService.sendToUser(assigned_to, { type: 'maintenance_assigned', task: full.rows[0] });
    }

    res.status(201).json({ success: true, data: full.rows[0] });
  } catch (err) { next(err); }
};

// PATCH /api/maintenance/:id/status
const updateStatus = async (req, res, next) => {
  try {
    const { status } = req.body;
    const allowed = ['scheduled', 'in_progress', 'done', 'cancelled'];
    if (!allowed.includes(status)) {
      return res.status(400).json({ success: false, message: `status must be one of: ${allowed.join(', ')}` });
    }

    const completed_at = status === 'done' ? 'NOW()' : 'NULL';
    await query(
      `UPDATE maintenance_tasks SET status = $1, completed_at = ${completed_at} WHERE id = $2`,
      [status, req.params.id]
    );

    const full = await query(`${BASE_SELECT} WHERE m.id = $1`, [req.params.id]);
    if (!full.rows.length) return res.status(404).json({ success: false, message: 'Not found' });

    // When done or cancelled, restore product status to in_stock
    if (status === 'done' || status === 'cancelled') {
      await query(
        `UPDATE products SET status = 'in_stock', updated_at = NOW() WHERE id = $1`,
        [full.rows[0].product.id]
      );
    }

    res.json({ success: true, data: full.rows[0] });
  } catch (err) { next(err); }
};

// DELETE /api/maintenance/:id
const deleteTask = async (req, res, next) => {
  try {
    const task = await query(`SELECT product_id, status FROM maintenance_tasks WHERE id = $1`, [req.params.id]);
    if (!task.rows.length) return res.status(404).json({ success: false, message: 'Not found' });

    await query(`DELETE FROM maintenance_tasks WHERE id = $1`, [req.params.id]);

    if (task.rows[0].status !== 'done') {
      await query(`UPDATE products SET status = 'in_stock', updated_at = NOW() WHERE id = $1`,
        [task.rows[0].product_id]);
    }

    res.json({ success: true });
  } catch (err) { next(err); }
};

// GET /api/maintenance/:id/notes
const getNotes = async (req, res, next) => {
  try {
    const result = await query(
      `SELECT n.id, n.note, n.created_at,
              json_build_object('id', u.id, 'name', u.name, 'role', u.role) AS author
       FROM maintenance_notes n
       JOIN users u ON u.id = n.user_id
       WHERE n.task_id = $1
       ORDER BY n.created_at ASC`,
      [req.params.id]
    );
    res.json({ success: true, data: result.rows });
  } catch (err) { next(err); }
};

// POST /api/maintenance/:id/notes
const addNote = async (req, res, next) => {
  try {
    const { note } = req.body;
    if (!note?.trim()) {
      return res.status(400).json({ success: false, message: 'note is required' });
    }
    const result = await query(
      `INSERT INTO maintenance_notes (task_id, user_id, note)
       VALUES ($1, $2, $3) RETURNING id, note, created_at`,
      [req.params.id, req.user.id, note.trim()]
    );
    const full = await query(
      `SELECT n.id, n.note, n.created_at,
              json_build_object('id', u.id, 'name', u.name, 'role', u.role) AS author
       FROM maintenance_notes n JOIN users u ON u.id = n.user_id WHERE n.id = $1`,
      [result.rows[0].id]
    );
    res.status(201).json({ success: true, data: full.rows[0] });
  } catch (err) { next(err); }
};

module.exports = { getTasks, createTask, updateStatus, deleteTask, getNotes, addNote };
