/**
 * IoT scan event handler.
 * Called by mqttService when inventory/rfid or inventory/ble messages arrive.
 */

const { query } = require("../config/database");
const wsService = require("../services/wsService");

// ── shared helpers ───────────────────────────────────────────────────────────

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

async function resolveRoom(room_id, reader_id) {
  // Primary: look up by UUID
  if (UUID_RE.test(room_id)) {
    const r = await query("SELECT id, name FROM rooms WHERE id = $1", [room_id]);
    if (r.rows[0]) return r.rows[0];
  }
  // Fallback: match room_code or room name suffix from reader_id
  // e.g. "esp32_labo_iot1" → try room_code "LIOT1" or name suffix "iot1"
  if (reader_id) {
    const m = reader_id.match(/[_-]([A-Za-z0-9]+)$/);
    if (m) {
      const code = m[1];
      const r = await query(
        `SELECT id, name FROM rooms
         WHERE room_code ILIKE $1 OR name ILIKE $2
         LIMIT 1`,
        [code, `%${code}`]
      );
      if (r.rows[0]) {
        console.log(`ℹ️  Resolved room via reader_id "${reader_id}" → "${r.rows[0].name}"`);
        return r.rows[0];
      }
    }
  }
  return null;
}

async function notifyAllUsers(product, fromRoom, toRoom, scanType) {
  const users = await query("SELECT id FROM users WHERE is_active = true");
  const title = `Product ${scanType.toUpperCase()} Detected`;
  const body  = `${product.name} found in ${toRoom}${fromRoom && fromRoom !== toRoom ? ` (was in ${fromRoom})` : ""}`;

  for (const u of users.rows) {
    await query(
      `INSERT INTO notifications
         (user_id, type, title, body, product_id, product_name, from_room, to_room)
       VALUES ($1, 'product_moved', $2, $3, $4, $5, $6, $7)`,
      [u.id, title, body, product.id, product.name, fromRoom || null, toRoom]
    );
  }
}

function broadcastScan({ scanType, product, uid_or_mac, rssi, roomId, roomName, fromRoom, readerId }) {
  wsService.broadcast({
    type:         "iot_scan",
    scan_type:    scanType,
    product_id:   product.id,
    product_name: product.name,
    uid_or_mac,
    rssi:         rssi || null,
    room_id:      roomId,
    room_name:    roomName,
    from_room:    fromRoom || null,
    reader_id:    readerId,
    timestamp:    new Date().toISOString(),
  });
}

async function processScan({ scanType, lookupField, lookupValue, rssi, room_id, reader_id }) {
  // ── 1. Resolve the room ──────────────────────────────────────────────────
  const room = await resolveRoom(room_id, reader_id);
  if (!room) {
    console.warn(`IoT ${scanType}: cannot resolve room (room_id="${room_id}", reader_id="${reader_id}") — ignored`);
    return;
  }

  // ── 2. Find the product ──────────────────────────────────────────────────
  const pRes = await query(
    `SELECT p.id, p.name, p.sku, p.room_id,
            r.name AS current_room_name
     FROM products p
     LEFT JOIN rooms r ON r.id = p.room_id
     WHERE p.${lookupField} = $1
     LIMIT 1`,
    [lookupValue]
  );

  if (pRes.rows.length === 0) {
    // Log for technician to assign later — only if no unresolved entry exists yet
    const existing = await query(
      `SELECT id FROM unregistered_scans WHERE uid = $1 AND resolved = FALSE LIMIT 1`,
      [lookupValue]
    ).catch(() => ({ rows: [] }));
    if (!existing.rows.length) {
      await query(
        `INSERT INTO unregistered_scans (uid, scan_type, room_id, room_name, reader_id)
         VALUES ($1, $2, $3, $4, $5)`,
        [lookupValue, scanType, room.id, room.name, reader_id]
      ).catch(() => {});
    }
    console.warn(`IoT ${scanType}: unregistered tag "${lookupValue}" in ${room.name} — queued for assignment`);
    wsService.broadcast({
      type:       'unregistered_scan',
      scan_type:  scanType,
      uid:        lookupValue,
      room_id:    room.id,
      room_name:  room.name,
      reader_id,
      timestamp:  new Date().toISOString(),
    });
    return;
  }

  const product  = pRes.rows[0];
  const fromRoom = product.current_room_name || null;
  const toRoom   = room.name;
  const moved    = product.room_id !== room.id;

  // ── 3. Log to scan_history (always) ────────────────────────────────────
  await query(
    `INSERT INTO scan_history (product_id, action_type, action_data)
     VALUES ($1, 'iot_scan', $2)`,
    [
      product.id,
      JSON.stringify({
        scan_type:  scanType,
        identifier: lookupValue,
        rssi:       rssi || null,
        reader_id,
        room_id,
        room_name:  toRoom,
        from_room:  fromRoom,
        moved,
      }),
    ]
  );

  // ── 4. Update room if changed ───────────────────────────────────────────
  if (moved) {
    await query(
      `UPDATE products
       SET room_id = $1, last_moved_at = NOW(), updated_at = NOW()
       WHERE id = $2`,
      [room.id, product.id]
    );

    // ── 5. Notify + broadcast only on actual move ─────────────────────────
    await notifyAllUsers(product, fromRoom, toRoom, scanType);
    broadcastScan({
      scanType, product,
      uid_or_mac: lookupValue, rssi,
      roomId: room.id, roomName: toRoom,
      fromRoom, readerId: reader_id,
    });

    console.log(`✅ IoT ${scanType}: "${product.name}" moved ${fromRoom || "?"} → ${toRoom}`);
  } else {
    console.log(`ℹ️  IoT ${scanType}: "${product.name}" still in ${toRoom} — no location change`);
  }
}

// ── Public handlers ──────────────────────────────────────────────────────────

const handleRfidScan = async ({ uid, room_id, reader_id }) => {
  if (!uid || !room_id) return;
  await processScan({
    scanType:     "rfid",
    lookupField:  "rfid_tag",
    lookupValue:  uid,
    rssi:         null,
    room_id,
    reader_id,
  });
};

const handleBleScan = async ({ mac, fingerprint, rssi, room_id, reader_id }) => {
  if (!room_id) return;
  // Apple Find My accessories rotate their MAC; use the stable payload fingerprint instead
  const lookupValue = (fingerprint && fingerprint.startsWith("FINDMY:")) ? fingerprint : mac;
  if (!lookupValue) return;
  await processScan({
    scanType:     "ble",
    lookupField:  "ble_device",
    lookupValue,
    rssi,
    room_id,
    reader_id,
  });
};

module.exports = { handleRfidScan, handleBleScan };
