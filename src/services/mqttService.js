const mqtt = require("mqtt");
const { query } = require("../config/database");

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
    // Subscribe to all device topics
    client.subscribe("devices/#", (err) => {
      if (err) console.error("MQTT subscribe error:", err);
      else console.log("📡 Subscribed to devices/#");
    });
  });

  client.on("message", async (topic, message) => {
    try {
      const payload = JSON.parse(message.toString());
      console.log(`📨 MQTT [${topic}]:`, payload);

      // Save message to DB
      await query(
        "INSERT INTO messages (topic, payload) VALUES ($1, $2)",
        [topic, JSON.stringify(payload)]
      );

      // Update device status if topic matches pattern: devices/{deviceId}/status
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
