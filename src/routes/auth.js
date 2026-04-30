const express = require("express");
const router = express.Router();
const { register, login, googleAuth, refresh, logout, me, updateProfile } = require("../controllers/authController");
const { authenticate } = require("../middleware/auth");
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
router.post("/refresh", refresh);
router.post("/logout", logout);
router.get("/me", authenticate, me);
router.put("/profile", authenticate, upload.single("avatar"), updateProfile);

module.exports = router;
