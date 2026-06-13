const multer = require("multer");
const path = require("path");
const fs = require("fs");
const { v4: uuidv4 } = require("uuid");

const UPLOAD_DIR = path.join(__dirname, "..", "..", "uploads");
if (!fs.existsSync(UPLOAD_DIR)) fs.mkdirSync(UPLOAD_DIR, { recursive: true });

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, UPLOAD_DIR),
  filename:    (req, file, cb) => {
    // Strip the original extension entirely — extension is re-derived from
    // magic bytes after the file lands on disk, so spoofed extensions are harmless.
    cb(null, `${uuidv4()}`);
  },
});

// Magic-byte signatures for allowed image types
const MAGIC = [
  { mime: "image/jpeg", bytes: [0xFF, 0xD8, 0xFF] },
  { mime: "image/png",  bytes: [0x89, 0x50, 0x4E, 0x47] },
  { mime: "image/webp", bytes: null, check: (b) => b.slice(0,4).toString() === "RIFF" && b.slice(8,12).toString() === "WEBP" },
];

const ALLOWED_MIMES = ["image/jpeg", "image/jpg", "image/png", "image/webp"];

const fileFilter = (req, file, cb) => {
  if (!ALLOWED_MIMES.includes(file.mimetype)) {
    const err = new Error("Only JPEG, PNG, and WebP images are allowed");
    err.status = 400;
    return cb(err, false);
  }
  cb(null, true);
};

const upload = multer({
  storage,
  fileFilter,
  limits: { fileSize: parseInt(process.env.MAX_FILE_SIZE) || 5 * 1024 * 1024 },
});

/**
 * Validates the magic bytes of an already-uploaded file and deletes it if
 * they don't match a known image format. Call this after multer runs.
 */
const validateMagicBytes = (req, res, next) => {
  if (!req.file) return next();

  const filePath = req.file.path;
  const fd = fs.openSync(filePath, "r");
  const buf = Buffer.alloc(12);
  fs.readSync(fd, buf, 0, 12, 0);
  fs.closeSync(fd);

  const valid = MAGIC.some(({ bytes, check }) => {
    if (check) return check(buf);
    return bytes.every((b, i) => buf[i] === b);
  });

  if (!valid) {
    fs.unlinkSync(filePath);
    const err = new Error("Uploaded file is not a valid image");
    err.status = 400;
    return next(err);
  }

  next();
};

module.exports = upload;
module.exports.validateMagicBytes = validateMagicBytes;
