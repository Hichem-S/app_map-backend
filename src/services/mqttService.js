const mqtt = require("mqtt");
const { query } = require("../config/database");
// Lazy-require to avoid circular dependency at module load time
const getIotController = () => require("../controllers/iotController");

let client = null;

const connect = () => {
  const url = process.env.MQTT_BROKER_URL || "mqtt://localhost:1883";

  const options = {
    clientId: `flutter_backend_${Math.random().toString(16).slice(3)}`,
    clean: true,
    reconnectPeriod: 5000,
  };

  if (process.env.MQTT_USERNAME) {
    options.username = process.env.MQTT_USERNAME;
    options.password = process.env.MQTT_PASSWORD;
  }

  client = mqtt.connect(url, options);

  client.on("connect", () => {
    console.log("✅ MQTT connected to", url);

    // Generic device topics
    client.subscribe("devices/#", (err) => {
      if (err) console.error("MQTT subscribe error:", err);
      else console.log("📡 Subscribed to devices/#");
    });

    // IoT inventory topics
    client.subscribe("inventory/rfid", (err) => {
      if (!err) console.log("📡 Subscribed to inventory/rfid");
    });
    client.subscribe("inventory/ble", (err) => {
      if (!err) console.log("📡 Subscribed to inventory/ble");
    });
    client.subscribe("inventory/devices/#", (err) => {
      if (!err) console.log("📡 Subscribed to inventory/devices/#");
    });
  });

  client.on("message", async (topic, message) => {
    let payload;
    try {
      payload = JSON.parse(message.toString());
    } catch {
      // non-JSON message — ignore
      return;
    }

    console.log(`📨 MQTT [${topic}]:`, payload);

    // ── Persist raw message ───────────────────────────────────────────────
    try {
      await query(
        "INSERT INTO messages (topic, payload) VALUES ($1, $2)",
        [topic, JSON.stringify(payload)]
      );
    } catch (err) {
      console.error("MQTT persist error:", err.message);
    }

    // ── Route by topic ────────────────────────────────────────────────────
    try {
      const { handleRfidScan, handleBleScan } = getIotController();

      if (topic === "inventory/rfid") {
        await handleRfidScan(payload);
        return;
      }

      if (topic === "inventory/ble") {
        await handleBleScan(payload);
        return;
      }

      // inventory/devices/{readerId}/status — update device table + push BLE MAC list on connect
      const invParts = topic.split("/");
      if (invParts[0] === "inventory" && invParts[1] === "devices" && invParts[3] === "status") {
        const readerId = invParts[2];
        await query(
          "UPDATE devices SET status = $1, last_seen = NOW() WHERE mqtt_topic LIKE $2",
          [payload.status || "online", `%${readerId}%`]
        );

        // When a reader comes online, push all known BLE MACs so it can filter scans
        if (payload.status === "online") {
          const macsRes = await query(
            `SELECT ble_device FROM products
             WHERE ble_device IS NOT NULL AND tracker_active = true`
          );
          const macs = macsRes.rows.map((r) => r.ble_device.toLowerCase());
          const configTopic = `inventory/devices/${readerId}/config`;
          publish(configTopic, { ble_macs: macs });
          console.log(`📡 Pushed ${macs.length} BLE MAC(s) to ${configTopic}`);
        }
        return;
      }

      // devices/{deviceId}/status — legacy
      const parts = topic.split("/");
      if (parts.length === 3 && parts[0] === "devices" && parts[2] === "status") {
        const deviceId = parts[1];
        await query(
          "UPDATE devices SET status = $1, last_seen = NOW() WHERE mqtt_topic LIKE $2",
          [payload.status || "online", `%${deviceId}%`]
        );
      }
    } catch (err) {
      console.error("MQTT message handling error:", err);
    }
  });

  client.on("error", (err) => console.error("MQTT error:", err));
  client.on("offline", () => console.log("⚠️  MQTT offline"));
  client.on("reconnect", () => console.log("🔄 MQTT reconnecting..."));

  return client;
};

const publish = (topic, message) => {
  if (!client || !client.connected) {
    console.warn("MQTT not connected");
    return false;
  }
  client.publish(topic, JSON.stringify(message));
  return true;
};

const getClient = () => client;

module.exports = { connect, publish, getClient };
