const express  = require("express");
const router   = express.Router();
const { authenticate } = require("../middleware/auth");
const { queryAI }      = require("../controllers/aiController");

router.use(authenticate);
router.post("/query", queryAI);

module.exports = router;
