const express = require("express");
const router = express.Router();
const {
  getProducts, getProduct, getProductByScan, getProductByRfid,
  createProduct, updateProduct, updateProductStatus, updateProductLocation, deleteProduct,
  getProductQR, getCategories,
  addScanHistory, getScanHistory, getStats,
  checkBarcode, getDeptStats, getMoveLog, assignRfidTag,
  getWarrantyAlerts, importProducts, exportProducts, getProductActivity, getProductHealth,
  bleLookup,
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
router.get("/rfid-scan", getProductByRfid);
router.get("/move-log", getMoveLog);
router.get("/scan-history", getScanHistory);
router.post("/scan-history", addScanHistory);
router.get("/warranty-alerts", getWarrantyAlerts);
router.get("/export",          exportProducts);
router.post("/import",         importProducts);
router.post("/ble-lookup",     bleLookup);

router.get("/", getProducts);
router.post("/", upload.single("photo"), createProduct);
router.get("/:id", getProduct);
router.put("/:id", upload.single("photo"), updateProduct);
router.patch("/:id/status", updateProductStatus);
router.patch("/:id/location", updateProductLocation);
router.patch("/:id/rfid", assignRfidTag);
const { authorize } = require("../middleware/auth");
router.delete("/:id", authorize("magazinier"), deleteProduct);
router.get("/:id/qr",       getProductQR);
router.get("/:id/activity", getProductActivity);
router.get("/:id/health",   getProductHealth);

module.exports = router;
