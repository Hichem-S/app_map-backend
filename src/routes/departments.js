const express = require("express");
const router = express.Router();
const { getDepartments, getDepartmentRooms, getDepartmentStats, getIsetQR, getDeptQR, getDeptQRByCode, getRoomQR, getDepartmentRoomsByCode, updateRoom, getMapData, getRoom } = require("../controllers/departmentController");
const { authenticate } = require("../middleware/auth");

// Public — QR images (no auth, needed for Image.network in Flutter)
router.get("/qr/iset", getIsetQR);
router.get("/rooms/:id/qr", getRoomQR);
router.get("/code/:code/qr", getDeptQRByCode);
router.get("/:id/qr", getDeptQR);

router.use(authenticate);

router.get("/", getDepartments);
router.get("/map-data", getMapData);
router.get("/rooms/:id", getRoom);
router.get("/code/:code/rooms", getDepartmentRoomsByCode);
router.get("/:id/rooms", getDepartmentRooms);
router.get("/:id/stats", getDepartmentStats);
router.patch("/rooms/:id", updateRoom);

module.exports = router;
