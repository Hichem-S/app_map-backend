const express  = require('express');
const router   = express.Router();
const { authenticate, authorize } = require('../middleware/auth');
const { getUnregistered, assignUnregistered, getScanHistory } = require('../controllers/iotManagementController');

router.use(authenticate);

// Technicien + admin can view and assign unregistered tags
router.get('/unregistered',              authorize('technicien', 'admin'), getUnregistered);
router.patch('/unregistered/:id/assign', authorize('technicien', 'admin'), assignUnregistered);
router.get('/scan-history',              authorize('technicien', 'admin'), getScanHistory);

module.exports = router;
