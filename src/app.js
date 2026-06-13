const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const morgan = require("morgan");
const rateLimit = require("express-rate-limit");
const path = require("path");
require("dotenv").config();

const authRoutes = require("./routes/auth");
const deviceRoutes = require("./routes/devices");
const productRoutes = require("./routes/products");
const departmentRoutes = require("./routes/departments");
const reportRoutes = require("./routes/reports");
const notificationRoutes = require("./routes/notifications");
const trackerRoutes = require("./routes/trackers");
const iotRoutes     = require("./routes/iot");
const messageRoutes = require("./routes/messages");
const aiRoutes         = require("./routes/ai");
const checkoutRoutes   = require("./routes/checkouts");
const maintenanceRoutes = require("./routes/maintenance");
const analyticsRoutes   = require("./routes/analytics");
const transferRoutes    = require("./routes/transfers");
const { errorHandler, notFound } = require("./middleware/errorHandler");

const app = express();

// ── Security headers ──────────────────────────────────────────────────────────
app.use(helmet({
  crossOriginResourcePolicy: { policy: "same-site" },
}));

// ── CORS ──────────────────────────────────────────────────────────────────────
// Production: set CORS_ORIGIN to your app domain. Never leave as * in prod.
app.use(
  cors({
    origin: true,
    methods: ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization"],
    credentials: true,
  })
);

// ── Static file serving (uploads) ────────────────────────────────────────────
// Served before rate limiter so image loads don't consume API quota.
// nosniff + attachment headers prevent browser execution of uploaded content.
app.use("/uploads", (req, res, next) => {
  res.setHeader("X-Content-Type-Options", "nosniff");
  res.setHeader("Content-Disposition", "attachment");
  next();
}, express.static(path.join(__dirname, "..", "uploads")));

// ── Rate limiting ─────────────────────────────────────────────────────────────
// General API limit
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 300,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: "Too many requests, please try again later." },
});

// Strict limit for auth endpoints (brute-force protection)
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: "Too many auth attempts, please try again later." },
});

app.use("/api/auth/login",           authLimiter);
app.use("/api/auth/register",        authLimiter);
app.use("/api/auth/forgot-password", authLimiter);
app.use("/api/auth/reset-password",  authLimiter);
app.use("/api/auth/verify-email",    authLimiter);
app.use(apiLimiter);

// ── Body parsing ──────────────────────────────────────────────────────────────
// 1mb is sufficient for JSON payloads; file uploads go through multer instead
app.use(express.json({ limit: "1mb" }));
app.use(express.urlencoded({ extended: true, limit: "1mb" }));

// ── Logging ───────────────────────────────────────────────────────────────────
app.use(morgan(process.env.NODE_ENV === "production" ? "combined" : "dev"));

// ── Health check ──────────────────────────────────────────────────────────────
app.get("/health", (req, res) => {
  res.json({
    success: true,
    status: "ok",
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });
});

// ── API Routes ────────────────────────────────────────────────────────────────
app.use("/api/auth", authRoutes);
app.use("/api/devices", deviceRoutes);
app.use("/api/products", productRoutes);
app.use("/api/departments", departmentRoutes);
app.use("/api/reports", reportRoutes);
app.use("/api/notifications", notificationRoutes);
app.use("/api/trackers", trackerRoutes);
app.use("/api/iot",      iotRoutes);
app.use("/api/messages", messageRoutes);
app.use("/api/ai",          aiRoutes);
app.use("/api/checkouts",   checkoutRoutes);
app.use("/api/maintenance", maintenanceRoutes);
app.use("/api/analytics",  analyticsRoutes);
app.use("/api/transfers",  transferRoutes);

// ── Error handlers ────────────────────────────────────────────────────────────
app.use(notFound);
app.use(errorHandler);

module.exports = app;
