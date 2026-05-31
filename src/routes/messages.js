const express  = require("express");
const router   = express.Router();
const { authenticate } = require("../middleware/auth");
const {
  getUsers, getConversations, createConversation,
  getMessages, sendMessage, markAsRead,
} = require("../controllers/messageController");

router.use(authenticate);

router.get("/users",                         getUsers);
router.get("/conversations",                 getConversations);
router.post("/conversations",                createConversation);
router.get("/conversations/:id",             getMessages);
router.post("/conversations/:id",            sendMessage);
router.patch("/conversations/:id/read",      markAsRead);

module.exports = router;
