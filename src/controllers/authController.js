const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const crypto = require("crypto");
const nodemailer = require("nodemailer");
const { OAuth2Client } = require("google-auth-library");
const { query } = require("../config/database");

const mailer = nodemailer.createTransport({
  host: process.env.SMTP_HOST || "smtp.gmail.com",
  port: parseInt(process.env.SMTP_PORT || "587"),
  secure: false,
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});

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

const isMailConfigured = () => {
  const user = process.env.SMTP_USER || '';
  const pass = process.env.SMTP_PASS || '';
  return user.length > 0 &&
         pass.length > 0 &&
         !user.includes('YOUR_GMAIL') &&
         !pass.includes('xxxx');
};

const sendVerificationOtp = async (userId, email, name) => {
  const otp = Math.floor(100000 + Math.random() * 900000).toString();
  const tokenHash = hashToken(otp);

  await query("DELETE FROM email_verification_tokens WHERE user_id = $1", [userId]);
  await query(
    "INSERT INTO email_verification_tokens (user_id, token_hash, expires_at) VALUES ($1, $2, NOW() + INTERVAL '24 hours')",
    [userId, tokenHash]
  );

  let emailSent = false;
  if (isMailConfigured()) {
    const fromAddr = process.env.SMTP_FROM || process.env.SMTP_USER;
    try {
      await mailer.sendMail({
        from: `"Smart Inventory ISET" <${fromAddr}>`,
        to: email,
        subject: "Verify your email address",
        html: `
          <div style="font-family:sans-serif;max-width:480px;margin:auto">
            <h2 style="color:#4F46E5">Verify your email</h2>
            <p>Hi ${name},</p>
            <p>Use the code below to verify your Smart Inventory account. It expires in <strong>24 hours</strong>.</p>
            <div style="font-size:36px;font-weight:bold;letter-spacing:8px;text-align:center;
                        background:#F1F5F9;padding:20px;border-radius:12px;color:#0F172A;margin:24px 0">
              ${otp}
            </div>
            <p style="color:#94A3B8;font-size:13px">If you did not create this account, ignore this email.</p>
          </div>
        `,
      });
      emailSent = true;
    } catch (mailErr) {
      console.error("Verification mail failed:", mailErr.message);
    }
  }

  if (!emailSent) {
    console.log(`\n========================================`);
    console.log(`[OTP] Email: ${email}`);
    console.log(`[OTP] Code:  ${otp}`);
    console.log(`========================================\n`);
  }

  return null;
};

// POST /api/auth/register
const register = async (req, res, next) => {
  try {
    const { name, email, password, role } = req.body;
    const allowedRoles = ['magazinier', 'technicien'];
    const userRole = allowedRoles.includes(role) ? role : 'technicien';

    const exists = await query("SELECT id FROM users WHERE email = $1", [email]);
    if (exists.rows.length) {
      return res.status(409).json({ success: false, message: "Email already in use" });
    }

    const hashed = await bcrypt.hash(password, 12);
    const result = await query(
      "INSERT INTO users (name, email, password, role, email_verified) VALUES ($1, $2, $3, $4, false) RETURNING id, name, email, role",
      [name, email, hashed, userRole]
    );

    const user = result.rows[0];
    await sendVerificationOtp(user.id, email, name);

    res.status(201).json({ success: true, requiresVerification: true, email });
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

    if (!user.email_verified) {
      await sendVerificationOtp(user.id, user.email, user.name);
      return res.status(403).json({
        success: false,
        needsVerification: true,
        email: user.email,
        message: "Please verify your email. A new code has been sent.",
      });
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

// POST /api/auth/verify-email
const verifyEmail = async (req, res, next) => {
  try {
    const { email, otp } = req.body;

    const userRes = await query(
      "SELECT id, name, email, role, avatar, phone FROM users WHERE email = $1 AND is_active = true AND google_id IS NULL",
      [email]
    );
    if (!userRes.rows.length) {
      return res.status(400).json({ success: false, message: "Invalid code." });
    }

    const user = userRes.rows[0];
    const tokenHash = hashToken(otp);

    const tokenRes = await query(
      `SELECT id FROM email_verification_tokens
       WHERE user_id = $1 AND token_hash = $2 AND expires_at > NOW()`,
      [user.id, tokenHash]
    );
    if (!tokenRes.rows.length) {
      return res.status(400).json({ success: false, message: "Invalid or expired code." });
    }

    await query("UPDATE users SET email_verified = true, updated_at = NOW() WHERE id = $1", [user.id]);
    await query("DELETE FROM email_verification_tokens WHERE user_id = $1", [user.id]);

    const { accessToken, refreshToken } = generateTokens(user.id);
    await storeRefreshToken(user.id, refreshToken);

    res.json({ success: true, data: { user, accessToken, refreshToken } });
  } catch (err) {
    next(err);
  }
};

// POST /api/auth/resend-verification
const resendVerification = async (req, res, next) => {
  try {
    const { email } = req.body;

    const userRes = await query(
      "SELECT id, name FROM users WHERE email = $1 AND is_active = true AND email_verified = false AND google_id IS NULL",
      [email]
    );
    if (!userRes.rows.length) {
      return res.json({ success: true, message: "If that account exists and is unverified, a code was sent." });
    }

    const user = userRes.rows[0];
    await sendVerificationOtp(user.id, email, user.name);
    res.json({ success: true, message: "Verification code resent." });
  } catch (err) {
    next(err);
  }
};

// POST /api/auth/forgot-password
const forgotPassword = async (req, res, next) => {
  try {
    const { email } = req.body;

    const result = await query(
      "SELECT id, name FROM users WHERE email = $1 AND is_active = true AND google_id IS NULL",
      [email]
    );
    // Always return 200 to prevent email enumeration
    if (!result.rows.length) {
      return res.json({ success: true, message: "If that email exists, an OTP has been sent." });
    }

    const user = result.rows[0];
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const tokenHash = hashToken(otp);

    await query("DELETE FROM password_reset_tokens WHERE user_id = $1", [user.id]);
    await query(
      "INSERT INTO password_reset_tokens (user_id, token_hash, expires_at) VALUES ($1, $2, NOW() + INTERVAL '15 minutes')",
      [user.id, tokenHash]
    );

    let resetEmailSent = false;
    if (isMailConfigured()) {
      const fromAddr = process.env.SMTP_FROM || process.env.SMTP_USER;
      try {
        await mailer.sendMail({
          from: `"Smart Inventory ISET" <${fromAddr}>`,
          to: email,
          subject: "Your password reset code",
          html: `
            <div style="font-family:sans-serif;max-width:480px;margin:auto">
              <h2 style="color:#4F46E5">Reset your password</h2>
              <p>Hi ${user.name},</p>
              <p>Use the code below to reset your Smart Inventory password. It expires in <strong>15 minutes</strong>.</p>
              <div style="font-size:36px;font-weight:bold;letter-spacing:8px;text-align:center;
                          background:#F1F5F9;padding:20px;border-radius:12px;color:#0F172A;margin:24px 0">
                ${otp}
              </div>
              <p style="color:#94A3B8;font-size:13px">If you did not request this, ignore this email.</p>
            </div>
          `,
        });
        resetEmailSent = true;
      } catch (mailErr) {
        console.error("Mail send failed:", mailErr.message);
      }
    }

    if (!resetEmailSent) {
      console.log(`[DEV] Password reset OTP for ${email}: ${otp}`);
    }

    res.json({ success: true, message: "If that email exists, an OTP has been sent." });
  } catch (err) {
    next(err);
  }
};

// POST /api/auth/reset-password
const resetPassword = async (req, res, next) => {
  try {
    const { email, otp, newPassword } = req.body;

    const userRes = await query(
      "SELECT id FROM users WHERE email = $1 AND is_active = true AND google_id IS NULL",
      [email]
    );
    if (!userRes.rows.length) {
      return res.status(400).json({ success: false, message: "Invalid or expired code." });
    }

    const userId = userRes.rows[0].id;
    const tokenHash = hashToken(otp);

    const tokenRes = await query(
      `SELECT id FROM password_reset_tokens
       WHERE user_id = $1 AND token_hash = $2 AND expires_at > NOW() AND used = false`,
      [userId, tokenHash]
    );
    if (!tokenRes.rows.length) {
      return res.status(400).json({ success: false, message: "Invalid or expired code." });
    }

    const hashed = await bcrypt.hash(newPassword, 12);
    await query("UPDATE users SET password = $1, updated_at = NOW() WHERE id = $2", [hashed, userId]);
    await query("UPDATE password_reset_tokens SET used = true WHERE id = $1", [tokenRes.rows[0].id]);
    // Clean up all reset tokens for this user
    await query("DELETE FROM password_reset_tokens WHERE user_id = $1", [userId]);
    // Invalidate all refresh tokens
    await query("DELETE FROM refresh_tokens WHERE user_id = $1", [userId]);

    res.json({ success: true, message: "Password updated successfully." });
  } catch (err) {
    next(err);
  }
};

// DELETE /api/auth/users/:id  (admin only)
const deleteUser = async (req, res, next) => {
  try {
    const { id } = req.params;
    if (id === req.user.id) {
      return res.status(400).json({ success: false, message: "You cannot delete your own account" });
    }
    const result = await query("DELETE FROM users WHERE id = $1 RETURNING id", [id]);
    if (!result.rows.length) {
      return res.status(404).json({ success: false, message: "User not found" });
    }
    res.json({ success: true, message: "User deleted" });
  } catch (err) {
    next(err);
  }
};

// GET /api/auth/users  (admin only)
const listUsers = async (req, res, next) => {
  try {
    const result = await query(
      "SELECT id, name, email, role, avatar, is_active, created_at FROM users ORDER BY created_at DESC"
    );
    res.json({ success: true, data: result.rows });
  } catch (err) {
    next(err);
  }
};

// PATCH /api/auth/users/:id/role  (admin only)
const updateUserRole = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { role } = req.body;
    const allowed = ['admin', 'magazinier', 'technicien'];
    if (!allowed.includes(role)) {
      return res.status(400).json({ success: false, message: 'Invalid role' });
    }
    const result = await query(
      "UPDATE users SET role = $1, updated_at = NOW() WHERE id = $2 RETURNING id, name, email, role, is_active",
      [role, id]
    );
    if (!result.rows.length) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    res.json({ success: true, data: result.rows[0] });
  } catch (err) {
    next(err);
  }
};

// PATCH /api/auth/users/:id/status  (admin only)
const toggleUserStatus = async (req, res, next) => {
  try {
    const { id } = req.params;
    const result = await query(
      "UPDATE users SET is_active = NOT is_active, updated_at = NOW() WHERE id = $1 RETURNING id, name, email, role, is_active",
      [id]
    );
    if (!result.rows.length) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    res.json({ success: true, data: result.rows[0] });
  } catch (err) {
    next(err);
  }
};

// POST /api/auth/users  (admin only — creates user without email verification)
const adminCreateUser = async (req, res, next) => {
  try {
    const { name, email, password, role } = req.body;
    const allowedRoles = ['admin', 'magazinier', 'technicien'];
    if (!name || !email || !password) {
      return res.status(400).json({ success: false, message: 'Name, email and password are required' });
    }
    if (password.length < 6) {
      return res.status(400).json({ success: false, message: 'Password must be at least 6 characters' });
    }
    const userRole = allowedRoles.includes(role) ? role : 'technicien';

    const exists = await query("SELECT id FROM users WHERE email = $1", [email]);
    if (exists.rows.length) {
      return res.status(409).json({ success: false, message: 'Email already in use' });
    }

    const hashed = await bcrypt.hash(password, 12);
    const result = await query(
      "INSERT INTO users (name, email, password, role, email_verified, is_active) VALUES ($1, $2, $3, $4, true, true) RETURNING id, name, email, role, is_active, created_at",
      [name, email.toLowerCase(), hashed, userRole]
    );

    res.status(201).json({ success: true, data: result.rows[0] });
  } catch (err) {
    next(err);
  }
};

module.exports = { register, login, googleAuth, refresh, logout, me, updateProfile, forgotPassword, resetPassword, verifyEmail, resendVerification, listUsers, updateUserRole, toggleUserStatus, deleteUser, adminCreateUser };
