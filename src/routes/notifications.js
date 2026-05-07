const express = require("express");
const router = express.Router();
const { authenticate } = require("../middleware/auth");
const {
  getNotifications,
  markRead,
  markAllRead,
  deleteNotification,
  clearAll,
} = require("../controllers/notificationController");

router.use(authenticate);

router.get("/", getNotifications);
router.patch("/read-all", markAllRead);   // must be before /:id
router.patch("/:id/read", markRead);
router.delete("/", clearAll);             // must be before /:id
router.delete("/:id", deleteNotification);

module.exports = router;
