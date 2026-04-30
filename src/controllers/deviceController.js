const { query } = require("../config/database");

// GET /api/devices
const getDevices = async (req, res, next) => {
  try {
    const result = await query(
      "SELECT * FROM devices WHERE user_id = $1 ORDER BY created_at DESC",
      [req.user.id]
    );
    res.json({ success: true, data: result.rows });
  } catch (err) {
    next(err);
  }
};

// GET /api/devices/:id
const getDevice = async (req, res, next) => {
  try {
    const result = await query(
      "SELECT * FROM devices WHERE id = $1 AND user_id = $2",
      [req.params.id, req.user.id]
    );
    if (!result.rows.length) {
      return res.status(404).json({ success: false, message: "Device not found" });
    }
    res.json({ success: true, data: result.rows[0] });
  } catch (err) {
    next(err);
  }
};

// POST /api/devices
const createDevice = async (req, res, next) => {
  try {
    const { name, device_type, mqtt_topic, metadata } = req.body;
    const result = await query(
      `INSERT INTO devices (user_id, name, device_type, mqtt_topic, metadata)
       VALUES ($1, $2, $3, $4, $5) RETURNING *`,
      [req.user.id, name, device_type, mqtt_topic, metadata ? JSON.stringify(metadata) : null]
    );
    res.status(201).json({ success: true, data: result.rows[0] });
  } catch (err) {
    next(err);
  }
};

// PUT /api/devices/:id
const updateDevice = async (req, res, next) => {
  try {
    const { name, device_type, mqtt_topic, metadata } = req.body;
    const result = await query(
      `UPDATE devices SET name=$1, device_type=$2, mqtt_topic=$3, metadata=$4, updated_at=NOW()
       WHERE id=$5 AND user_id=$6 RETURNING *`,
      [name, device_type, mqtt_topic, metadata ? JSON.stringify(metadata) : null, req.params.id, req.user.id]
    );
    if (!result.rows.length) {
      return res.status(404).json({ success: false, message: "Device not found" });
    }
    res.json({ success: true, data: result.rows[0] });
  } catch (err) {
    next(err);
  }
};

// DELETE /api/devices/:id
const deleteDevice = async (req, res, next) => {
  try {
    const result = await query(
      "DELETE FROM devices WHERE id = $1 AND user_id = $2 RETURNING id",
      [req.params.id, req.user.id]
    );
    if (!result.rows.length) {
      return res.status(404).json({ success: false, message: "Device not found" });
    }
    res.json({ success: true, message: "Device deleted" });
  } catch (err) {
    next(err);
  }
};

module.exports = { getDevices, getDevice, createDevice, updateDevice, deleteDevice };
