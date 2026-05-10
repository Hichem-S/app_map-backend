const express = require("express");
const router = express.Router();
const {
  getProducts, getProduct, getProductByScan,
  createProduct, updateProduct, updateProductStatus, updateProductLocation, deleteProduct,
  getProductQR, getCategories,
  addScanHistory, getScanHistory, getStats,
  checkBarcode, getDeptStats, getMoveLog,
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
router.get("/dept-stats", getDeptStats);
router.get("/barcode-check", checkBarcode);
router.get("/move-log", getMoveLog);
router.get("/scan-history", getScanHistory);
router.post("/scan-history", addScanHistory);

router.get("/", getProducts);
router.post("/", upload.single("photo"), createProduct);
router.get("/:id", getProduct);
router.put("/:id", upload.single("photo"), updateProduct);
router.patch("/:id/status", updateProductStatus);
router.patch("/:id/location", updateProductLocation);
router.delete("/:id", deleteProduct);
router.get("/:id/qr", getProductQR);

module.exports = router;
