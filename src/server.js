const http = require("http");
const app = require("./app");
const wsService = require("./services/wsService");
const mqttService = require("./services/mqttService");
require("dotenv").config();

const PORT = process.env.PORT || 3000;

// Create HTTP server (shared with WebSocket)
const server = http.createServer(app);

// Attach WebSocket to the same HTTP server
wsService.init(server);

// Connect to MQTT broker
mqttService.connect();

// Start server
server.listen(PORT, () => {
  console.log(`
  ╔═══════════════════════════════════════╗
  ║     Flutter Backend Server Started    ║
  ╠═══════════════════════════════════════╣
  ║  HTTP  : http://localhost:${PORT}        ║
  ║  WS    : ws://localhost:${PORT}          ║
  ║  MQTT  : ${process.env.MQTT_BROKER_URL || "mqtt://localhost:1883"}  ║
  ╚═══════════════════════════════════════╝
  `);
});

// Graceful shutdown
process.on("SIGTERM", () => {
  console.log("SIGTERM received. Shutting down gracefully...");
  server.close(() => {
    console.log("Server closed");
    process.exit(0);
  });
});

process.on("unhandledRejection", (err) => {
  console.error("Unhandled rejection:", err);
});
