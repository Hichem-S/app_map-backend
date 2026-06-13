const express = require("express");
const router  = express.Router();
const { authenticate, authorize } = require("../middleware/auth");
const { getTransfers, createTransfer, approveTransfer, rejectTransfer } = require("../controllers/transferController");

router.use(authenticate);

router.get("/",               getTransfers);
router.post("/",              createTransfer);
router.patch("/:id/approve",  authorize("admin","technicien"), approveTransfer);
router.patch("/:id/reject",   authorize("admin","technicien"), rejectTransfer);

module.exports = router;
