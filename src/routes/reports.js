const express = require("express");
const router = express.Router();
const { getRoomFiche, getRoomJournal, getProductMaintenanceReport, getQRSheet, getDeptReport, getBarcodeSheet, getIsetReport } = require("../controllers/reportController");
const { authenticate } = require("../middleware/auth");

router.use(authenticate);

router.get("/rooms/:id/fiche",              getRoomFiche);
router.get("/rooms/:id/journal",            getRoomJournal);
router.get("/products/:id/maintenance",     getProductMaintenanceReport);
router.post("/products/qr-sheet",           getQRSheet);
router.get("/departments/:id",              getDeptReport);
router.post("/products/barcode-sheet",      getBarcodeSheet);
router.get("/iset",                         getIsetReport);

module.exports = router;
