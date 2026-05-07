/**
 * Generate QR codes for ISET institution + all departments.
 * Run once: node src/scripts/generate-qr.js
 */

const QRCode = require("qrcode");
const fs = require("fs");
const path = require("path");
const { query } = require("../config/database");
require("dotenv").config();

const QR_DIR = path.join(__dirname, "..", "..", "uploads", "qr");

const generate = async () => {
  if (!fs.existsSync(QR_DIR)) fs.mkdirSync(QR_DIR, { recursive: true });

  // ── ISET institution QR ──────────────────────────────────────────────────────
  const isetPath = path.join(QR_DIR, "iset.png");
  const isetBuf  = await QRCode.toBuffer("ISET://institution", { width: 400 });
  fs.writeFileSync(isetPath, isetBuf);
  console.log("✅  ISET QR  →", isetPath);

  // ── Department QRs ───────────────────────────────────────────────────────────
  const { rows } = await query("SELECT id, code, name FROM departments ORDER BY code");

  for (const dept of rows) {
    const qrData  = `ISET://dept/${dept.code}`;
    const filePath = path.join(QR_DIR, `dept_${dept.code}.png`);
    const buf = await QRCode.toBuffer(qrData, { width: 400 });
    fs.writeFileSync(filePath, buf);
    console.log(`✅  Dept ${dept.code} (${dept.name})  →  ${filePath}`);
  }

  console.log("\n🎉  All QR codes generated.");
  process.exit(0);
};

generate().catch((err) => {
  console.error("❌ Error:", err.message);
  process.exit(1);
});
