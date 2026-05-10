const express = require("express");
const router = express.Router();
const { getTrackers, checkIn, pingDevice, toggleTracker } = require("../controllers/trackerController");
const { authenticate, authorize } = require("../middleware/auth");

router.get(   "/",              authenticate, authorize("admin", "technicien"), getTrackers);
router.patch( "/:id/check-in", authenticate, authorize("admin", "technicien"), checkIn);
router.post(  "/:id/ping",     authenticate, authorize("admin", "technicien"), pingDevice);
router.patch( "/:id/toggle",   authenticate, authorize("admin", "technicien"), toggleTracker);

module.exports = router;
