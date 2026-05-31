const PDFDocument = require("pdfkit");
const { query } = require("../config/database");

const STATUS_LABELS = {
  in_stock:       "En stock",
  operational:    "Opérationnel",
  in_maintenance: "Maintenance",
  critical_issue: "Défectueux",
  retired:        "Réformé",
  lost:           "Perdu",
};

const TYPE_LABELS = {
  laboratory:  "Laboratoire",
  classroom:   "Salle de cours",
  office:      "Bureau",
  storage:     "Stockage",
  workshop:    "Atelier",
  server_room: "Salle Serveurs",
};

const ACTION_LABELS = {
  scan:          "Scan QR équipement",
  product_added: "Ajout équipement",
  dept_qr:       "Scan département",
};

// ─── helpers ──────────────────────────────────────────────────────────────────

function formatDate(d) {
  if (!d) return "—";
  return new Date(d).toLocaleString("fr-FR", {
    day: "2-digit", month: "2-digit", year: "numeric",
    hour: "2-digit", minute: "2-digit",
  });
}

function drawPageHeader(doc, title, subtitle, dateStr) {
  // Blue top bar
  doc.rect(0, 0, doc.page.width, 70).fill("#1A2340");

  doc.fontSize(20).fillColor("#FFFFFF")
     .text("ISET MAHDIA", 50, 15, { lineBreak: false });
  doc.fontSize(10).fillColor("#94A3B8")
     .text("Système de gestion d'inventaire", 50, 40);

  doc.fontSize(11).fillColor("#FFFFFF")
     .text(dateStr, 0, 25, { align: "right", width: doc.page.width - 50 });

  // Title block
  doc.rect(50, 90, doc.page.width - 100, 50).fill("#F1F5F9");
  doc.fontSize(16).fillColor("#1A2340")
     .text(title, 60, 100, { lineBreak: false });
  doc.fontSize(10).fillColor("#64748B")
     .text(subtitle, 60, 122);

  doc.y = 160;
}

function drawInfoRow(doc, label, value) {
  const y = doc.y;
  doc.fontSize(9).fillColor("#64748B").text(label, 50, y, { continued: false, lineBreak: false, width: 130 });
  doc.fontSize(9).fillColor("#1A2340").text(value || "—", 185, y, { lineBreak: false });
  doc.y = y + 16;
}

function drawSectionTitle(doc, text) {
  doc.moveDown(0.5);
  const y = doc.y;
  doc.rect(50, y, doc.page.width - 100, 22).fill("#1A2340");
  doc.fontSize(10).fillColor("#FFFFFF").text(text, 58, y + 6);
  doc.y = y + 30;
}

// Draw a single table row; returns new y position
function drawTableRow(doc, y, row, colDefs, isHeader) {
  const rowH = isHeader ? 22 : 18;
  const bg = isHeader ? "#1A2340" : (row._even ? "#F8FAFC" : "#FFFFFF");

  doc.rect(50, y, doc.page.width - 100, rowH).fill(bg);

  // cell borders
  doc.rect(50, y, doc.page.width - 100, rowH).stroke("#E2E8F0");

  let x = 50;
  colDefs.forEach(({ width, key, align }) => {
    const text = isHeader ? key : (row[key] ?? "—");
    doc.fontSize(isHeader ? 9 : 8)
       .fillColor(isHeader ? "#FFFFFF" : "#1A2340")
       .text(String(text), x + 4, y + (isHeader ? 7 : 5), {
         width: width - 8,
         lineBreak: false,
         align: align || "left",
       });
    x += width;
  });

  return y + rowH;
}

function drawTable(doc, colDefs, rows) {
  let y = doc.y;
  const pageBottom = doc.page.height - 80;

  y = drawTableRow(doc, y, null, colDefs.map(c => ({ ...c, key: c.header })), true);

  rows.forEach((row, i) => {
    if (y + 18 > pageBottom) {
      doc.addPage();
      y = 50;
      y = drawTableRow(doc, y, null, colDefs.map(c => ({ ...c, key: c.header })), true);
    }
    y = drawTableRow(doc, y, { ...row, _even: i % 2 === 0 }, colDefs, false);
  });

  doc.y = y + 10;
}

// ─── GET /api/reports/rooms/:id/fiche ─────────────────────────────────────────
const getRoomFiche = async (req, res, next) => {
  try {
    const roomRes = await query(
      `SELECT r.*, d.name AS dept_name, d.code AS dept_code
       FROM rooms r JOIN departments d ON d.id = r.department_id
       WHERE r.id = $1`,
      [req.params.id]
    );
    if (!roomRes.rows.length)
      return res.status(404).json({ success: false, message: "Room not found" });

    const room = roomRes.rows[0];

    const prodRes = await query(
      `SELECT p.name, p.sku, p.barcode, p.status, p.quantity,
              c.name AS category_name
       FROM products p
       LEFT JOIN categories c ON c.id = p.category_id
       WHERE p.room_id = $1 AND p.user_id = $2
       ORDER BY p.name`,
      [req.params.id, req.user.id]
    );
    const products = prodRes.rows;

    // Stats
    const stats = { total: products.length, in_stock: 0, operational: 0, in_maintenance: 0, critical_issue: 0, retired: 0, lost: 0 };
    products.forEach(p => { if (stats[p.status] !== undefined) stats[p.status]++; });

    const dateStr = formatDate(new Date());
    const safe = room.name.replace(/[^a-zA-Z0-9]/g, "_");

    res.setHeader("Content-Type", "application/pdf");
    res.setHeader("Content-Disposition", `attachment; filename="fiche_${safe}.pdf"`);

    const doc = new PDFDocument({ margin: 50, size: "A4" });
    doc.pipe(res);

    // ── Page 1 ──
    drawPageHeader(
      doc,
      "FICHE D'INVENTAIRE",
      `${room.dept_code} — ${room.dept_name}  ·  ${room.name}`,
      dateStr
    );

    // Room info
    drawSectionTitle(doc, "INFORMATIONS DE LA SALLE");
    drawInfoRow(doc, "Département :", `${room.dept_code} — ${room.dept_name}`);
    drawInfoRow(doc, "Salle :", room.name);
    drawInfoRow(doc, "Code salle :", room.room_code);
    drawInfoRow(doc, "Type :", TYPE_LABELS[room.type] || room.type);
    drawInfoRow(doc, "Bloc :", room.bloc);
    drawInfoRow(doc, "Étage :", room.floor);
    drawInfoRow(doc, "Capacité :", room.capacity ? `${room.capacity} personnes` : null);
    drawInfoRow(doc, "Nombre d'équipements :", String(stats.total));

    // Summary
    doc.moveDown(0.5);
    drawSectionTitle(doc, "RÉSUMÉ PAR STATUT");

    const statW = (doc.page.width - 100) / 4;
    const statData = [
      { label: "Opérationnel", value: stats.in_stock,       color: "#16A34A", bg: "#DCFCE7" },
      { label: "Maintenance",  value: stats.in_maintenance,  color: "#D97706", bg: "#FEF9C3" },
      { label: "Défectueux",   value: stats.critical_issue,  color: "#DC2626", bg: "#FFE4E4" },
      { label: "Réformé",      value: stats.retired,          color: "#6B7280", bg: "#F3F4F6" },
    ];
    const sy = doc.y;
    statData.forEach((s, i) => {
      const x = 50 + i * statW;
      doc.rect(x + 2, sy, statW - 4, 40).fill(s.bg);
      doc.fontSize(20).fillColor(s.color).text(String(s.value), x + 2, sy + 5, { width: statW - 4, align: "center" });
      doc.fontSize(8).fillColor(s.color).text(s.label, x + 2, sy + 27, { width: statW - 4, align: "center" });
    });
    doc.y = sy + 52;

    // Products table
    drawSectionTitle(doc, "LISTE DES ÉQUIPEMENTS");

    const tableW = doc.page.width - 100;
    const colDefs = [
      { header: "N°",          key: "num",      width: 30, align: "center" },
      { header: "Désignation", key: "name",      width: Math.round(tableW * 0.30) },
      { header: "Référence",   key: "sku",       width: Math.round(tableW * 0.18) },
      { header: "Code-barres", key: "barcode",   width: Math.round(tableW * 0.17) },
      { header: "Catégorie",   key: "category",  width: Math.round(tableW * 0.18) },
      { header: "Statut",      key: "status",    width: Math.round(tableW * 0.13) },
    ];
    // Adjust last col to fill exactly
    const usedW = colDefs.reduce((s, c) => s + c.width, 0);
    colDefs[colDefs.length - 1].width += tableW - usedW;

    const tableRows = products.map((p, i) => ({
      num:      i + 1,
      name:     p.name,
      sku:      p.sku,
      barcode:  p.barcode || "—",
      category: p.category_name || "—",
      status:   STATUS_LABELS[p.status] || p.status,
    }));

    if (tableRows.length === 0) {
      doc.fontSize(10).fillColor("#94A3B8").text("Aucun équipement dans cette salle.", 50, doc.y + 10, { align: "center" });
    } else {
      drawTable(doc, colDefs, tableRows);
    }

    // Footer
    const pageCount = doc.bufferedPageRange().count;
    for (let i = 0; i < pageCount; i++) {
      doc.switchToPage(i);
      doc.fontSize(8).fillColor("#94A3B8")
         .text(`Page ${i + 1} / ${pageCount}  —  Généré le ${dateStr}  —  ISET Mahdia`,
               50, doc.page.height - 40, { align: "center", width: doc.page.width - 100 });
    }

    doc.end();
  } catch (err) {
    next(err);
  }
};

// ─── GET /api/reports/rooms/:id/journal ───────────────────────────────────────
const getRoomJournal = async (req, res, next) => {
  try {
    const roomRes = await query(
      `SELECT r.*, d.name AS dept_name, d.code AS dept_code
       FROM rooms r JOIN departments d ON d.id = r.department_id
       WHERE r.id = $1`,
      [req.params.id]
    );
    if (!roomRes.rows.length)
      return res.status(404).json({ success: false, message: "Room not found" });

    const room = roomRes.rows[0];

    // Scan history for products currently in this room
    const histRes = await query(
      `SELECT sh.scanned_at, sh.action_type,
              p.name AS product_name, p.sku,
              u.name AS user_name
       FROM scan_history sh
       JOIN products p ON p.id = sh.product_id
       JOIN users u ON u.id = sh.user_id
       WHERE p.room_id = $1 AND p.user_id = $2
       ORDER BY sh.scanned_at DESC
       LIMIT 500`,
      [req.params.id, req.user.id]
    );

    // Also include products added to this room (even if no scan)
    const prodRes = await query(
      `SELECT p.name, p.sku, p.created_at, p.updated_at, p.status,
              c.name AS category_name
       FROM products p
       LEFT JOIN categories c ON c.id = p.category_id
       WHERE p.room_id = $1 AND p.user_id = $2
       ORDER BY p.created_at DESC`,
      [req.params.id, req.user.id]
    );

    const history = histRes.rows;
    const dateStr = formatDate(new Date());
    const safe = room.name.replace(/[^a-zA-Z0-9]/g, "_");

    res.setHeader("Content-Type", "application/pdf");
    res.setHeader("Content-Disposition", `attachment; filename="journal_${safe}.pdf"`);

    const doc = new PDFDocument({ margin: 50, size: "A4" });
    doc.pipe(res);

    drawPageHeader(
      doc,
      "JOURNAL DE TRAÇABILITÉ",
      `${room.dept_code} — ${room.dept_name}  ·  ${room.name}`,
      dateStr
    );

    // Room summary
    drawSectionTitle(doc, "SALLE");
    drawInfoRow(doc, "Département :", `${room.dept_code} — ${room.dept_name}`);
    drawInfoRow(doc, "Salle :", room.name);
    drawInfoRow(doc, "Type :", TYPE_LABELS[room.type] || room.type);
    drawInfoRow(doc, "Équipements :", String(prodRes.rows.length));

    // Equipment in room
    doc.moveDown(0.3);
    drawSectionTitle(doc, "ÉQUIPEMENTS ACTUELS DANS CETTE SALLE");

    const tableW = doc.page.width - 100;
    const eqColDefs = [
      { header: "N°",          key: "num",      width: 30, align: "center" },
      { header: "Désignation", key: "name",      width: Math.round(tableW * 0.33) },
      { header: "Référence",   key: "sku",       width: Math.round(tableW * 0.20) },
      { header: "Catégorie",   key: "category",  width: Math.round(tableW * 0.22) },
      { header: "Statut",      key: "status",    width: Math.round(tableW * 0.16) },
    ];
    const usedW2 = eqColDefs.reduce((s, c) => s + c.width, 0);
    eqColDefs[eqColDefs.length - 1].width += tableW - usedW2;

    const eqRows = prodRes.rows.map((p, i) => ({
      num:      i + 1,
      name:     p.name,
      sku:      p.sku,
      category: p.category_name || "—",
      status:   STATUS_LABELS[p.status] || p.status,
    }));

    if (eqRows.length === 0) {
      doc.fontSize(10).fillColor("#94A3B8").text("Aucun équipement.", 50, doc.y + 6);
    } else {
      drawTable(doc, eqColDefs, eqRows);
    }

    // Activity log
    doc.moveDown(0.3);
    drawSectionTitle(doc, `JOURNAL D'ACTIVITÉ (${history.length} événement${history.length !== 1 ? "s" : ""})`);

    if (history.length === 0) {
      doc.fontSize(10).fillColor("#94A3B8")
         .text("Aucun événement enregistré pour cette salle.", 50, doc.y + 10, { align: "center" });
    } else {
      const logColDefs = [
        { header: "Date & heure",  key: "date",    width: Math.round(tableW * 0.26) },
        { header: "Équipement",    key: "product", width: Math.round(tableW * 0.30) },
        { header: "Action",        key: "action",  width: Math.round(tableW * 0.27) },
        { header: "Utilisateur",   key: "user",    width: Math.round(tableW * 0.17) },
      ];
      const usedW3 = logColDefs.reduce((s, c) => s + c.width, 0);
      logColDefs[logColDefs.length - 1].width += tableW - usedW3;

      const logRows = history.map((h) => ({
        date:    formatDate(h.scanned_at),
        product: `${h.product_name} (${h.sku})`,
        action:  ACTION_LABELS[h.action_type] || h.action_type,
        user:    h.user_name,
      }));

      drawTable(doc, logColDefs, logRows);
    }

    // Footer on every page
    const pageCount = doc.bufferedPageRange().count;
    for (let i = 0; i < pageCount; i++) {
      doc.switchToPage(i);
      doc.fontSize(8).fillColor("#94A3B8")
         .text(`Page ${i + 1} / ${pageCount}  —  Généré le ${dateStr}  —  ISET Mahdia`,
               50, doc.page.height - 40, { align: "center", width: doc.page.width - 100 });
    }

    doc.end();
  } catch (err) {
    next(err);
  }
};

module.exports = { getRoomFiche, getRoomJournal };
