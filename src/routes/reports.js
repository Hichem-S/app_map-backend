const express = require("express");
const router = express.Router();
const { getRoomFiche, getRoomJournal } = require("../controllers/reportController");
const { authenticate } = require("../middleware/auth");

router.use(authenticate);

router.get("/rooms/:id/fiche",   getRoomFiche);
router.get("/rooms/:id/journal", getRoomJournal);

module.exports = router;
