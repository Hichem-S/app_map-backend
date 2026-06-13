const WebSocket = require("ws");
const jwt = require("jsonwebtoken");
const { query } = require("../config/database");

let wss = null;
const clients = new Map();     // userId -> Set of ws connections
const onlineUsers = new Set(); // userId strings currently connected

// How long an unauthenticated connection may stay open before being closed
const AUTH_TIMEOUT_MS = 5000;

const init = (server) => {
  wss = new WebSocket.Server({ server });

  wss.on("connection", (ws) => {
    console.log("🔌 WebSocket client connected");

    // Close unauthenticated connections after timeout
    const authTimeout = setTimeout(() => {
      if (!ws.userId) {
        ws.send(JSON.stringify({ type: "error", message: "Authentication timeout" }));
        ws.close();
      }
    }, AUTH_TIMEOUT_MS);

    ws.on("message", (data) => {
      let msg;
      try {
        msg = JSON.parse(data);
      } catch {
        ws.send(JSON.stringify({ type: "error", message: "Invalid JSON" }));
        return;
      }

      // First message must be auth
      if (!ws.userId) {
        if (msg.type !== "auth" || !msg.token) {
          ws.send(JSON.stringify({ type: "error", message: "Send auth message first" }));
          return;
        }
        _authenticate(ws, msg.token, authTimeout);
        return;
      }

      handleClientMessage(ws, msg);
    });

    ws.on("close", () => {
      clearTimeout(authTimeout);
      if (ws.userId) {
        const userConns = clients.get(ws.userId);
        if (userConns) {
          userConns.delete(ws);
          if (userConns.size === 0) {
            clients.delete(ws.userId);
            onlineUsers.delete(ws.userId);
            query("UPDATE users SET last_seen = NOW() WHERE id = $1", [ws.userId]).catch(() => {});
            broadcast({ type: "user_offline", user_id: ws.userId });
          }
        }
      }
      console.log("🔌 WebSocket client disconnected");
    });

    ws.on("error", (err) => console.error("WS error:", err));
  });

  console.log("✅ WebSocket server attached");
  return wss;
};

const _authenticate = (ws, token, authTimeout) => {
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    clearTimeout(authTimeout);

    ws.userId = decoded.id;
    if (!clients.has(decoded.id)) clients.set(decoded.id, new Set());
    clients.get(decoded.id).add(ws);

    const wasOffline = !onlineUsers.has(decoded.id);
    onlineUsers.add(decoded.id);
    if (wasOffline) {
      broadcast({ type: "user_online", user_id: decoded.id }, decoded.id);
    }

    ws.send(JSON.stringify({ type: "connected", message: "Authenticated successfully" }));
    console.log(`✅ WS authenticated: user ${decoded.id}`);
  } catch {
    ws.send(JSON.stringify({ type: "error", message: "Invalid token" }));
    ws.close();
  }
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

const sendToUser = (userId, data) => {
  const userClients = clients.get(userId);
  if (!userClients) return;
  const message = JSON.stringify(data);
  userClients.forEach((ws) => {
    if (ws.readyState === WebSocket.OPEN) ws.send(message);
  });
};

const broadcast = (data, excludeUserId = null) => {
  const message = JSON.stringify(data);
  wss.clients.forEach((ws) => {
    if (ws.readyState === WebSocket.OPEN && ws.userId !== excludeUserId) {
      ws.send(message);
    }
  });
};

const isOnline = (userId) => onlineUsers.has(userId);
const getOnlineUsers = () => [...onlineUsers];

module.exports = { init, sendToUser, broadcast, isOnline, getOnlineUsers };
