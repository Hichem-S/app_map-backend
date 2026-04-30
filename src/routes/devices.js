const express = require("express");
const router = express.Router();
const { getDevices, getDevice, createDevice, updateDevice, deleteDevice } = require("../controllers/deviceController");
const { authenticate } = require("../middleware/auth");

router.use(authenticate); // all device routes require auth

router.get("/", getDevices);
router.get("/:id", getDevice);
router.post("/", createDevice);
router.put("/:id", updateDevice);
router.delete("/:id", deleteDevice);

module.exports = router;
