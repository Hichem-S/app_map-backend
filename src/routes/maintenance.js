const express  = require("express");
const router   = express.Router();
const { authenticate, authorize } = require("../middleware/auth");
const { getTasks, createTask, updateStatus, deleteTask, getNotes, addNote } = require("../controllers/maintenanceController");

router.use(authenticate);

router.get("/",              getTasks);
router.post("/",             authorize("technicien","admin"), createTask);
router.patch("/:id/status",  authorize("technicien","admin"), updateStatus);
router.delete("/:id",        authorize("technicien","admin"), deleteTask);
router.get("/:id/notes",     getNotes);
router.post("/:id/notes",    authorize("technicien","admin"), addNote);

module.exports = router;
