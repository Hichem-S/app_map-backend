const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const crypto = require("crypto");
const { OAuth2Client } = require("google-auth-library");
const { query } = require("../config/database");

const googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

const hashToken = (token) =>
  crypto.createHash("sha256").update(token).digest("hex");

const generateTokens = (userId) => {
  const accessToken = jwt.sign({ id: userId }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || "7d",
  });
  const refreshToken = jwt.sign({ id: userId }, process.env.JWT_REFRESH_SECRET, {
    expiresIn: "30d",
  });
  return { accessToken, refreshToken };
};

const storeRefreshToken = async (userId, refreshToken) => {
  await query(
    "INSERT INTO refresh_tokens (user_id, token, expires_at) VALUES ($1, $2, NOW() + INTERVAL '30 days')",
    [userId, hashToken(refreshToken)]
  );
};

// POST /api/auth/register
const register = async (req, res, next) => {
  try {
    const { name, email, password } = req.body;

    const exists = await query("SELECT id FROM users WHERE email = $1", [email]);
    if (exists.rows.length) {
      return res.status(409).json({ success: false, message: "Email already in use" });
    }

    const hashed = await bcrypt.hash(password, 12);
    const result = await query(
      "INSERT INTO users (name, email, password) VALUES ($1, $2, $3) RETURNING id, name, email, role",
      [name, email, hashed]
    );

    const user = result.rows[0];
    const { accessToken, refreshToken } = generateTokens(user.id);
    await storeRefreshToken(user.id, refreshToken);

    res.status(201).json({ success: true, data: { user, accessToken, refreshToken } });
  } catch (err) {
    next(err);
  }
};

// POST /api/auth/login
const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    const result = await query(
      "SELECT * FROM users WHERE email = $1 AND is_active = true AND google_id IS NULL",
      [email]
    );
    if (!result.rows.length) {
      return res.status(401).json({ success: false, message: "Invalid credentials" });
    }

    const user = result.rows[0];
    const valid = await bcrypt.compare(password, user.password);
    if (!valid) {
      return res.status(401).json({ success: false, message: "Invalid credentials" });
    }

    const { accessToken, refreshToken } = generateTokens(user.id);
    await storeRefreshToken(user.id, refreshToken);

    const { password: _, ...userData } = user;
    res.json({ success: true, data: { user: userData, accessToken, refreshToken } });
  } catch (err) {
    next(err);
  }
};

// POST /api/auth/google
const googleAuth = async (req, res, next) => {
  try {
    const { idToken } = req.body;
    if (!idToken) {
      return res.status(400).json({ success: false, message: "idToken required" });
    }

    const ticket = await googleClient.verifyIdToken({
      idToken,
      audience: process.env.GOOGLE_CLIENT_ID,
    });
    const { sub: googleId, email, name, picture } = ticket.getPayload();

    let result = await query(
      "SELECT * FROM users WHERE google_id = $1 OR (email = $2 AND google_id IS NULL)",
      [googleId, email]
    );
    let user = result.rows[0];

    if (!user) {
      result = await query(
        `INSERT INTO users (name, email, google_id, avatar, is_active, email_verified)
         VALUES ($1, $2, $3, $4, true, true) RETURNING *`,
        [name, email, googleId, picture]
      );
      user = result.rows[0];
    } else if (!user.google_id) {
      await query(
        "UPDATE users SET google_id=$1, avatar=$2, email_verified=true WHERE id=$3",
        [googleId, picture, user.id]
      );
      user.google_id = googleId;
      user.avatar = picture;
    }

    if (!user.is_active) {
      return res.status(403).json({ success: false, message: "Account deactivated" });
    }

    const { accessToken, refreshToken } = generateTokens(user.id);
    await storeRefreshToken(user.id, refreshToken);

    const { password: _, ...userData } = user;
    res.json({ success: true, data: { user: userData, accessToken, refreshToken } });
  } catch (err) {
    next(err);
  }
};

// POST /api/auth/refresh
const refresh = async (req, res, next) => {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) {
      return res.status(400).json({ success: false, message: "Refresh token required" });
    }

    const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);

    const stored = await query(
      "SELECT * FROM refresh_tokens WHERE token = $1 AND user_id = $2 AND expires_at > NOW()",
      [hashToken(refreshToken), decoded.id]
    );
    if (!stored.rows.length) {
      return res.status(401).json({ success: false, message: "Invalid or expired refresh token" });
    }

    const tokens = generateTokens(decoded.id);

    await query("DELETE FROM refresh_tokens WHERE token = $1", [hashToken(refreshToken)]);
    await storeRefreshToken(decoded.id, tokens.refreshToken);

    res.json({ success: true, data: tokens });
  } catch (err) {
    next(err);
  }
};

// POST /api/auth/logout
const logout = async (req, res, next) => {
  try {
    const { refreshToken } = req.body;
    if (refreshToken) {
      await query("DELETE FROM refresh_tokens WHERE token = $1", [hashToken(refreshToken)]);
    }
    res.json({ success: true, message: "Logged out successfully" });
  } catch (err) {
    next(err);
  }
};

// GET /api/auth/me
const me = async (req, res) => {
  res.json({ success: true, data: req.user });
};

// PUT /api/auth/profile
const updateProfile = async (req, res, next) => {
  try {
    const { name, phone } = req.body;
    const avatarUrl = req.file ? `/uploads/${req.file.filename}` : undefined;

    const fields = [];
    const values = [];
    let idx = 1;

    if (name) { fields.push(`name=$${idx++}`); values.push(name); }
    if (phone !== undefined) { fields.push(`phone=$${idx++}`); values.push(phone); }
    if (avatarUrl) { fields.push(`avatar=$${idx++}`); values.push(avatarUrl); }
    fields.push(`updated_at=NOW()`);
    values.push(req.user.id);

    const result = await query(
      `UPDATE users SET ${fields.join(",")} WHERE id=$${idx} RETURNING id, name, email, role, avatar, phone`,
      values
    );
    res.json({ success: true, data: result.rows[0] });
  } catch (err) {
    next(err);
  }
};

module.exports = { register, login, googleAuth, refresh, logout, me, updateProfile };
