const express  = require('express');
const router   = express.Router();
const { authenticate, authorize } = require('../middleware/auth');
const { getUnregistered, assignUnregistered } = require('../controllers/iotManagementController');

router.use(authenticate);

// Technicien + admin can view and assign unregistered tags
router.get('/unregistered',          authorize('technicien', 'admin'), getUnregistered);
router.patch('/unregistered/:id/assign', authorize('technicien', 'admin'), assignUnregistered);

module.exports = router;
