const express  = require("express");
const router   = express.Router();
const { authenticate, authorize } = require("../middleware/auth");
const {
  getCheckouts, requestCheckout,
  approveCheckout, rejectCheckout, returnCheckout,
} = require("../controllers/checkoutController");

router.use(authenticate);

router.get("/",              getCheckouts);
router.post("/",             requestCheckout);
router.patch("/:id/approve", authorize("technicien","admin"), approveCheckout);
router.patch("/:id/reject",  authorize("technicien","admin"), rejectCheckout);
router.patch("/:id/return",  authorize("technicien","admin"), returnCheckout);

module.exports = router;
