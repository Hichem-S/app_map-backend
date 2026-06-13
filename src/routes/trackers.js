const express = require("express");
const router = express.Router();
const { getTrackers, checkIn, pingDevice, toggleTracker, linkTracker, unlinkTracker } = require("../controllers/trackerController");
const { authenticate, authorize } = require("../middleware/auth");

router.get(   "/",              authenticate, authorize("admin", "technicien"), getTrackers);
router.patch( "/:id/check-in", authenticate, authorize("admin", "technicien"), checkIn);
router.post(  "/:id/ping",     authenticate, authorize("admin", "technicien"), pingDevice);
router.patch( "/:id/toggle",   authenticate, authorize("admin", "technicien"), toggleTracker);
router.patch( "/:id/link",     authenticate, authorize("admin", "technicien"), linkTracker);
router.delete("/:id/link",     authenticate, authorize("admin", "technicien"), unlinkTracker);

module.exports = router;
