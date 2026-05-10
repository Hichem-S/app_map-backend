const multer = require("multer");
const path = require("path");
const fs = require("fs");
const { v4: uuidv4 } = require("uuid");

// Always resolve uploads/ relative to the project root, not process.cwd()
const UPLOAD_DIR = path.join(__dirname, "..", "..", "uploads");
if (!fs.existsSync(UPLOAD_DIR)) fs.mkdirSync(UPLOAD_DIR, { recursive: true });

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, UPLOAD_DIR);
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase();
    cb(null, `${uuidv4()}${ext}`);
  },
});

const ALLOWED_IMAGE_MIMES = ["image/jpeg", "image/jpg", "image/png", "image/webp"];

const fileFilter = (req, file, cb) => {
  if (ALLOWED_IMAGE_MIMES.includes(file.mimetype)) {
    cb(null, true);
  } else {
    const err = new Error("Only JPEG, PNG, and WebP images are allowed");
    err.status = 400;
    cb(err, false);
  }
};

const upload = multer({
  storage,
  fileFilter,
  limits: { fileSize: parseInt(process.env.MAX_FILE_SIZE) || 5 * 1024 * 1024 },
});

module.exports = upload;
