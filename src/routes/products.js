const express = require("express");
const router = express.Router();
const {
  getProducts, getProduct, getProductByScan,
  createProduct, updateProduct, deleteProduct,
  getProductQR, getCategories,
  addScanHistory, getScanHistory, getStats,
} = require("../controllers/productController");
const { authenticate } = require("../middleware/auth");
const upload = require("../middleware/upload");

// Public — called after QR scan (no auth needed)
router.get("/scan", getProductByScan);

// Categories
router.get("/categories", authenticate, getCategories);

// All product routes require auth
router.use(authenticate);

router.get("/stats", getStats);
router.get("/scan-history", getScanHistory);
router.post("/scan-history", addScanHistory);

router.get("/", getProducts);
router.post("/", upload.single("photo"), createProduct);
router.get("/:id", getProduct);
router.put("/:id", upload.single("photo"), updateProduct);
router.delete("/:id", deleteProduct);
router.get("/:id/qr", getProductQR);

module.exports = router;
