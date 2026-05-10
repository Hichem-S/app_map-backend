const QRCode = require("qrcode");
const fs = require("fs");
const path = require("path");
const { query } = require("../config/database");

const QR_DIR = path.join(__dirname, "..", "..", "uploads", "qr");

// GET /api/departments
const getDepartments = async (req, res, next) => {
  try {
    const result = await query(
      `SELECT d.*,
              COUNT(DISTINCT r.id)                           AS room_count,
              COUNT(p.id)                                    AS product_count
       FROM departments d
       LEFT JOIN rooms r ON r.department_id = d.id
       LEFT JOIN products p ON p.room_id = r.id
       GROUP BY d.id
       ORDER BY d.name`,
      []
    );
    res.json({ success: true, data: result.rows });
  } catch (err) {
    next(err);
  }
};

// GET /api/departments/:id/rooms
const getDepartmentRooms = async (req, res, next) => {
  try {
    const result = await query(
      `SELECT r.*,
              COUNT(p.id)                                                    AS product_count,
              COUNT(p.id) FILTER (WHERE p.status = 'in_stock')              AS in_stock,
              COUNT(p.id) FILTER (WHERE p.status = 'in_maintenance')        AS in_maintenance,
              COUNT(p.id) FILTER (WHERE p.status = 'critical_issue')        AS critical_issue,
              COUNT(p.id) FILTER (WHERE p.status = 'retired')               AS retired
       FROM rooms r
       LEFT JOIN products p ON p.room_id = r.id
       WHERE r.department_id = $1
       GROUP BY r.id
       ORDER BY r.name`,
      [req.params.id]
    );
    res.json({ success: true, data: result.rows });
  } catch (err) {
    next(err);
  }
};

// GET /api/departments/:id/stats
const getDepartmentStats = async (req, res, next) => {
  try {
    const summary = await query(
      `SELECT
         COUNT(p.id)                                                       AS total,
         COUNT(DISTINCT p.room_id) FILTER (WHERE p.room_id IS NOT NULL)   AS rooms_used,
         COUNT(p.id) FILTER (WHERE p.status = 'in_stock')                 AS in_stock,
         COUNT(p.id) FILTER (WHERE p.status = 'in_maintenance')           AS in_maintenance,
         COUNT(p.id) FILTER (WHERE p.status = 'critical_issue')           AS critical_issue,
         COUNT(p.id) FILTER (WHERE p.status = 'retired')                  AS retired
       FROM products p
       JOIN rooms r ON p.room_id = r.id
       WHERE r.department_id = $1`,
      [req.params.id]
    );

    const byRoom = await query(
      `SELECT r.name AS room, COUNT(p.id) AS total
       FROM rooms r
       LEFT JOIN products p ON p.room_id = r.id
       WHERE r.department_id = $1
       GROUP BY r.id, r.name
       ORDER BY r.name`,
      [req.params.id]
    );

    const r = summary.rows[0];
    res.json({
      success: true,
      data: {
        total:          Number(r.total),
        rooms_used:     Number(r.rooms_used),
        in_stock:       Number(r.in_stock),
        in_maintenance: Number(r.in_maintenance),
        critical_issue: Number(r.critical_issue),
        retired:        Number(r.retired),
        by_room: byRoom.rows.map(row => ({
          room: row.room,
          total: Number(row.total),
        })),
      },
    });
  } catch (err) {
    next(err);
  }
};

// GET /api/departments/qr/iset  (public)
const getIsetQR = async (req, res, next) => {
  try {
    const qrFilePath = path.join(QR_DIR, "iset.png");
    if (!fs.existsSync(qrFilePath)) {
      const buf = await QRCode.toBuffer("ISET://institution", { width: 400 });
      fs.writeFileSync(qrFilePath, buf);
    }
    res.set("Content-Type", "image/png");
    res.sendFile(qrFilePath);
  } catch (err) {
    next(err);
  }
};

// GET /api/departments/:id/qr  (public)
const getDeptQR = async (req, res, next) => {
  try {
    const deptRow = await query("SELECT code FROM departments WHERE id = $1", [req.params.id]);
    if (!deptRow.rows.length) {
      return res.status(404).json({ success: false, message: "Department not found" });
    }
    const { code } = deptRow.rows[0];
    const qrFilePath = path.join(QR_DIR, `dept_${code}.png`);
    if (!fs.existsSync(qrFilePath)) {
      const buf = await QRCode.toBuffer(`ISET://dept/${code}`, { width: 400 });
      fs.writeFileSync(qrFilePath, buf);
    }
    res.set("Content-Type", "image/png");
    res.sendFile(qrFilePath);
  } catch (err) {
    next(err);
  }
};

// GET /api/departments/code/:code/qr  (public)
const getDeptQRByCode = async (req, res, next) => {
  try {
    const code = req.params.code.toUpperCase();
    const deptRow = await query("SELECT id FROM departments WHERE code = $1", [code]);
    if (!deptRow.rows.length) {
      return res.status(404).json({ success: false, message: "Department not found" });
    }
    const qrFilePath = path.join(QR_DIR, `dept_${code}.png`);
    if (!fs.existsSync(qrFilePath)) {
      const buf = await QRCode.toBuffer(`ISET://dept/${code}`, { width: 400 });
      fs.writeFileSync(qrFilePath, buf);
    }
    res.set("Content-Type", "image/png");
    res.sendFile(qrFilePath);
  } catch (err) {
    next(err);
  }
};

// PATCH /api/departments/rooms/:id  (authenticated)
const updateRoom = async (req, res, next) => {
  try {
    const { name, type, room_code, bloc, floor, capacity } = req.body;
    const result = await query(
      `UPDATE rooms
       SET name      = COALESCE($1, name),
           type      = COALESCE($2, type),
           room_code = $3,
           bloc      = $4,
           floor     = $5,
           capacity  = $6
       WHERE id = $7
       RETURNING *`,
      [name, type, room_code ?? null, bloc ?? null, floor ?? null, capacity ?? null, req.params.id]
    );
    if (!result.rows.length) {
      return res.status(404).json({ success: false, message: "Room not found" });
    }
    res.json({ success: true, data: result.rows[0] });
  } catch (err) {
    next(err);
  }
};

// GET /api/departments/rooms/:id/qr  (public)
const getRoomQR = async (req, res, next) => {
  try {
    const roomRow = await query(
      "SELECT r.id, r.name, d.code AS dept_code FROM rooms r JOIN departments d ON d.id = r.department_id WHERE r.id = $1",
      [req.params.id]
    );
    if (!roomRow.rows.length) {
      return res.status(404).json({ success: false, message: "Room not found" });
    }
    const { id, name, dept_code } = roomRow.rows[0];
    const safe = name.replace(/[^a-zA-Z0-9_-]/g, "_");
    const qrFilePath = path.join(QR_DIR, `room_${dept_code}_${safe}_${id}.png`);
    if (!fs.existsSync(qrFilePath)) {
      const buf = await QRCode.toBuffer(`ISET://room/${id}`, { width: 400 });
      fs.writeFileSync(qrFilePath, buf);
    }
    res.set("Content-Type", "image/png");
    res.sendFile(qrFilePath);
  } catch (err) {
    next(err);
  }
};

// GET /api/departments/code/:code/rooms  (authenticated)
const getDepartmentRoomsByCode = async (req, res, next) => {
  try {
    const code = req.params.code.toUpperCase();
    const deptRow = await query("SELECT id FROM departments WHERE code = $1", [code]);
    if (!deptRow.rows.length) {
      return res.status(404).json({ success: false, message: "Department not found" });
    }
    const result = await query(
      `SELECT r.*,
              COUNT(p.id)                                                    AS product_count,
              COUNT(p.id) FILTER (WHERE p.status = 'in_stock')              AS in_stock,
              COUNT(p.id) FILTER (WHERE p.status = 'in_maintenance')        AS in_maintenance,
              COUNT(p.id) FILTER (WHERE p.status = 'critical_issue')        AS critical_issue,
              COUNT(p.id) FILTER (WHERE p.status = 'retired')               AS retired
       FROM rooms r
       LEFT JOIN products p ON p.room_id = r.id
       WHERE r.department_id = $1
       GROUP BY r.id
       ORDER BY r.name`,
      [deptRow.rows[0].id]
    );
    res.json({ success: true, data: result.rows });
  } catch (err) {
    next(err);
  }
};

// GET /api/departments/map-data
const getMapData = async (req, res, next) => {
  try {
    const depts = await query(
      `SELECT id, code, name, color FROM departments ORDER BY code`,
      []
    );

    const rooms = await query(
      `SELECT
         r.id, r.name, r.type, r.department_id,
         COUNT(p.id)                                                    AS product_count,
         COUNT(p.id) FILTER (WHERE p.status = 'in_stock')              AS in_stock,
         COUNT(p.id) FILTER (WHERE p.status = 'in_maintenance')        AS in_maintenance,
         COUNT(p.id) FILTER (WHERE p.status = 'critical_issue')        AS critical_issue
       FROM rooms r
       LEFT JOIN products p ON p.room_id = r.id
       GROUP BY r.id
       ORDER BY r.department_id, r.name`,
      []
    );

    // Fetch individual product markers with last-mover info
    const prods = await query(
      `SELECT p.id, p.name, p.sku, p.status, p.room_id,
              p.last_moved_at,
              u.name AS moved_by_name, u.role AS moved_by_role
       FROM products p
       LEFT JOIN users u ON u.id = p.last_moved_by
       WHERE p.room_id IS NOT NULL
       ORDER BY p.room_id, p.name`,
      []
    );

    const prodsByRoom = {};
    for (const p of prods.rows) {
      if (!prodsByRoom[p.room_id]) prodsByRoom[p.room_id] = [];
      prodsByRoom[p.room_id].push({
        id:             p.id,
        name:           p.name,
        sku:            p.sku || '',
        status:         p.status,
        moved_by_name:  p.moved_by_name  || null,
        moved_by_role:  p.moved_by_role  || null,
        last_moved_at:  p.last_moved_at  ? p.last_moved_at.toISOString() : null,
      });
    }

    const roomsByDept = {};
    for (const r of rooms.rows) {
      if (!roomsByDept[r.department_id]) roomsByDept[r.department_id] = [];
      roomsByDept[r.department_id].push({
        id:             r.id,
        name:           r.name,
        type:           r.type,
        product_count:  Number(r.product_count),
        in_stock:       Number(r.in_stock),
        in_maintenance: Number(r.in_maintenance),
        critical_issue: Number(r.critical_issue),
        products:       prodsByRoom[r.id] || [],
      });
    }

    const data = depts.rows.map(d => ({
      id:    d.id,
      code:  d.code,
      name:  d.name,
      color: d.color,
      rooms: roomsByDept[d.id] || [],
    }));

    res.json({ success: true, data });
  } catch (err) {
    next(err);
  }
};

module.exports = { getDepartments, getDepartmentRooms, getDepartmentStats, getIsetQR, getDeptQR, getDeptQRByCode, getRoomQR, getDepartmentRoomsByCode, updateRoom, getMapData };
