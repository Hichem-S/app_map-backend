const WebSocket = require("ws");
const jwt = require("jsonwebtoken");

let wss = null;
const clients = new Map(); // userId -> Set of ws connections

const init = (server) => {
  wss = new WebSocket.Server({ server });

  wss.on("connection", (ws, req) => {
    console.log("🔌 WebSocket client connected");

    // Authenticate via query param: ?token=...
    const url = new URL(req.url, "http://localhost");
    const token = url.searchParams.get("token");

    if (token) {
      try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        ws.userId = decoded.id;

        if (!clients.has(decoded.id)) {
          clients.set(decoded.id, new Set());
        }
        clients.get(decoded.id).add(ws);

        ws.send(JSON.stringify({ type: "connected", message: "Authenticated successfully" }));
        console.log(`✅ WS authenticated: user ${decoded.id}`);
      } catch {
        ws.send(JSON.stringify({ type: "error", message: "Invalid token" }));
        ws.close();
        return;
      }
    } else {
      ws.send(JSON.stringify({ type: "warning", message: "No token - unauthenticated connection" }));
    }

    ws.on("message", (data) => {
      try {
        const msg = JSON.parse(data);
        console.log("WS message:", msg);
        // Handle client messages here
        handleClientMessage(ws, msg);
      } catch {
        ws.send(JSON.stringify({ type: "error", message: "Invalid JSON" }));
      }
    });

    ws.on("close", () => {
      if (ws.userId && clients.has(ws.userId)) {
        clients.get(ws.userId).delete(ws);
        if (clients.get(ws.userId).size === 0) {
          clients.delete(ws.userId);
        }
      }
      console.log("🔌 WebSocket client disconnected");
    });

    ws.on("error", (err) => console.error("WS error:", err));
  });

  console.log(`✅ WebSocket server attached`);
  return wss;
};

const handleClientMessage = (ws, msg) => {
  switch (msg.type) {
    case "ping":
      ws.send(JSON.stringify({ type: "pong" }));
      break;
    default:
      ws.send(JSON.stringify({ type: "echo", data: msg }));
  }
};

// Send to a specific user
const sendToUser = (userId, data) => {
  const userClients = clients.get(userId);
  if (!userClients) return;
  const message = JSON.stringify(data);
  userClients.forEach((ws) => {
    if (ws.readyState === WebSocket.OPEN) {
      ws.send(message);
    }
  });
};

// Broadcast to all connected clients
const broadcast = (data, excludeUserId = null) => {
  const message = JSON.stringify(data);
  wss.clients.forEach((ws) => {
    if (ws.readyState === WebSocket.OPEN && ws.userId !== excludeUserId) {
      ws.send(message);
    }
  });
};

module.exports = { init, sendToUser, broadcast };
