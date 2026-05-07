const express = require("express");
const router = express.Router();
const { register, login, googleAuth, refresh, logout, me, updateProfile, forgotPassword, resetPassword, verifyEmail, resendVerification, listUsers, updateUserRole, toggleUserStatus, deleteUser } = require("../controllers/authController");
const { authenticate, authorize } = require("../middleware/auth");
const upload = require("../middleware/upload");
const { body } = require("express-validator");
const validate = require("../middleware/validate");

router.post(
  "/register",
  [
    body("name").trim().notEmpty().withMessage("Name is required"),
    body("email").isEmail().normalizeEmail().withMessage("Valid email required"),
    body("password").isLength({ min: 6 }).withMessage("Password must be at least 6 characters"),
  ],
  validate,
  register
);

router.post(
  "/login",
  [
    body("email").isEmail().normalizeEmail(),
    body("password").notEmpty(),
  ],
  validate,
  login
);

router.post("/google", googleAuth);

router.post(
  "/verify-email",
  [
    body("email").isEmail().normalizeEmail(),
    body("otp").isLength({ min: 6, max: 6 }).isNumeric().withMessage("OTP must be 6 digits"),
  ],
  validate,
  verifyEmail
);

router.post(
  "/resend-verification",
  [body("email").isEmail().normalizeEmail()],
  validate,
  resendVerification
);
router.post("/refresh", refresh);
router.post("/logout", logout);
router.get("/me", authenticate, me);
router.put("/profile", authenticate, upload.single("avatar"), updateProfile);
router.get("/users", authenticate, authorize("admin"), listUsers);
router.patch("/users/:id/role", authenticate, authorize("admin"), updateUserRole);
router.patch("/users/:id/status", authenticate, authorize("admin"), toggleUserStatus);
router.delete("/users/:id", authenticate, authorize("admin"), deleteUser);

router.post(
  "/forgot-password",
  [body("email").isEmail().normalizeEmail().withMessage("Valid email required")],
  validate,
  forgotPassword
);

router.post(
  "/reset-password",
  [
    body("email").isEmail().normalizeEmail(),
    body("otp").isLength({ min: 6, max: 6 }).isNumeric().withMessage("OTP must be 6 digits"),
    body("newPassword").isLength({ min: 6 }).withMessage("Password must be at least 6 characters"),
  ],
  validate,
  resetPassword
);

module.exports = router;
