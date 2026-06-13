const PDFDocument = require("pdfkit");
const QRCode = require("qrcode");
const bwip   = require("bwip-js");
const fs = require("fs");
const path = require("path");
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

// ─── GET /api/reports/products/:id/maintenance ────────────────────────────────
const getProductMaintenanceReport = async (req, res, next) => {
  try {
    const prodRes = await query(
      `SELECT p.name, p.sku, p.status, p.barcode,
              c.name AS category_name,
              r.name AS room_name,
              d.code AS dept_code, d.name AS dept_name
       FROM products p
       LEFT JOIN categories c ON c.id = p.category_id
       LEFT JOIN rooms r ON r.id = p.room_id
       LEFT JOIN departments d ON d.id = r.department_id
       WHERE p.id = $1`,
      [req.params.id]
    );
    if (!prodRes.rows.length)
      return res.status(404).json({ success: false, message: "Product not found" });

    const product = prodRes.rows[0];

    const taskRes = await query(
      `SELECT m.title, m.description, m.priority, m.status,
              m.scheduled_date, m.completed_at, m.created_at,
              c.name AS created_by_name,
              a.name AS assigned_to_name
       FROM maintenance_tasks m
       JOIN users c ON c.id = m.created_by
       LEFT JOIN users a ON a.id = m.assigned_to
       WHERE m.product_id = $1
       ORDER BY m.created_at DESC`,
      [req.params.id]
    );
    const tasks = taskRes.rows;

    const PRIORITY_LABELS = { high: "Haute", medium: "Moyenne", low: "Basse" };
    const STATUS_LABELS_MAINT = {
      scheduled:   "Planifiée",
      in_progress: "En cours",
      done:        "Terminée",
      cancelled:   "Annulée",
    };

    const dateStr = formatDate(new Date());
    const safe = product.name.replace(/[^a-zA-Z0-9]/g, "_");

    res.setHeader("Content-Type", "application/pdf");
    res.setHeader("Content-Disposition", `attachment; filename="maintenance_${safe}.pdf"`);

    const doc = new PDFDocument({ margin: 50, size: "A4", bufferPages: true });
    doc.pipe(res);

    drawPageHeader(
      doc,
      "RAPPORT DE MAINTENANCE",
      `${product.sku}  ·  ${product.name}`,
      dateStr
    );

    // Product info
    drawSectionTitle(doc, "INFORMATIONS DE L'ÉQUIPEMENT");
    drawInfoRow(doc, "Désignation :",  product.name);
    drawInfoRow(doc, "Référence :",    product.sku);
    drawInfoRow(doc, "Code-barres :",  product.barcode || "—");
    drawInfoRow(doc, "Catégorie :",    product.category_name || "—");
    drawInfoRow(doc, "Statut actuel :", STATUS_LABELS[product.status] || product.status);
    drawInfoRow(doc, "Emplacement :",
      product.room_name
        ? `${product.dept_code || ""} — ${product.room_name}`
        : "Non placé");

    // Summary stats
    const total    = tasks.length;
    const done     = tasks.filter(t => t.status === "done").length;
    const ongoing  = tasks.filter(t => t.status === "in_progress" || t.status === "scheduled").length;
    const cancelled = tasks.filter(t => t.status === "cancelled").length;

    doc.moveDown(0.5);
    drawSectionTitle(doc, "RÉSUMÉ");

    const statW2 = (doc.page.width - 100) / 4;
    const statData2 = [
      { label: "Total",     value: total,     color: "#4F46E5", bg: "#EEF2FF" },
      { label: "Terminées", value: done,       color: "#16A34A", bg: "#DCFCE7" },
      { label: "En cours",  value: ongoing,    color: "#D97706", bg: "#FEF9C3" },
      { label: "Annulées",  value: cancelled,  color: "#6B7280", bg: "#F3F4F6" },
    ];
    const sy2 = doc.y;
    statData2.forEach((s, i) => {
      const x = 50 + i * statW2;
      doc.rect(x + 2, sy2, statW2 - 4, 40).fill(s.bg);
      doc.fontSize(20).fillColor(s.color).text(String(s.value), x + 2, sy2 + 5, { width: statW2 - 4, align: "center" });
      doc.fontSize(8).fillColor(s.color).text(s.label, x + 2, sy2 + 27, { width: statW2 - 4, align: "center" });
    });
    doc.y = sy2 + 52;

    // Tasks table
    doc.moveDown(0.3);
    drawSectionTitle(doc, `HISTORIQUE DES INTERVENTIONS (${total})`);

    if (tasks.length === 0) {
      doc.fontSize(10).fillColor("#94A3B8")
         .text("Aucune intervention enregistrée pour cet équipement.", 50, doc.y + 10, { align: "center" });
    } else {
      const tableW2 = doc.page.width - 100;
      const colDefs2 = [
        { header: "N°",           key: "num",        width: 28,  align: "center" },
        { header: "Intitulé",     key: "title",      width: Math.round(tableW2 * 0.24) },
        { header: "Statut",       key: "status",     width: Math.round(tableW2 * 0.12) },
        { header: "Priorité",     key: "priority",   width: Math.round(tableW2 * 0.11) },
        { header: "Technicien",   key: "technician", width: Math.round(tableW2 * 0.17) },
        { header: "Planifiée",    key: "scheduled",  width: Math.round(tableW2 * 0.14) },
        { header: "Terminée",     key: "completed",  width: Math.round(tableW2 * 0.14) },
      ];
      const usedW4 = colDefs2.reduce((s, c) => s + c.width, 0);
      colDefs2[colDefs2.length - 1].width += tableW2 - usedW4;

      const taskRows = tasks.map((t, i) => ({
        num:        i + 1,
        title:      t.title,
        status:     STATUS_LABELS_MAINT[t.status] || t.status,
        priority:   PRIORITY_LABELS[t.priority] || t.priority,
        technician: t.assigned_to_name || "—",
        scheduled:  t.scheduled_date ? formatDate(t.scheduled_date).substring(0, 10) : "—",
        completed:  t.completed_at   ? formatDate(t.completed_at).substring(0, 10)   : "—",
      }));

      drawTable(doc, colDefs2, taskRows);

      // Description notes for tasks that have them
      const withDesc = tasks.filter(t => t.description);
      if (withDesc.length > 0) {
        doc.moveDown(0.3);
        drawSectionTitle(doc, "NOTES DE MAINTENANCE");
        withDesc.forEach((t, i) => {
          const y = doc.y;
          if (y + 40 > doc.page.height - 80) doc.addPage();
          doc.fontSize(9).fillColor("#1A2340")
             .text(`${i + 1}. ${t.title}`, 50, doc.y, { continued: false });
          doc.fontSize(8).fillColor("#64748B")
             .text(t.description, 65, doc.y, { width: doc.page.width - 115 });
          doc.moveDown(0.4);
        });
      }
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

// ─── POST /api/reports/products/qr-sheet ─────────────────────────────────────
const getQRSheet = async (req, res, next) => {
  try {
    const { productIds } = req.body;
    if (!Array.isArray(productIds) || productIds.length === 0) {
      return res.status(400).json({ success: false, message: 'productIds array required' });
    }

    const placeholders = productIds.map((_, i) => `$${i + 1}`).join(',');
    const prodRes = await query(
      `SELECT p.id, p.name, p.sku, p.qr_data, p.qr_image_url
       FROM products p WHERE p.id IN (${placeholders})`,
      productIds
    );

    const dateStr = formatDate(new Date());
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', 'attachment; filename="qr_sheet.pdf"');

    const doc = new PDFDocument({ margin: 30, size: 'A4', bufferPages: true });
    doc.pipe(res);

    const pageW  = doc.page.width;
    const cols   = 3;
    const cellW  = (pageW - 60) / cols;
    const cellH  = 150;
    const qrSize = 90;

    // Header
    doc.rect(0, 0, pageW, 50).fill('#1A2340');
    doc.fontSize(16).fillColor('#FFFFFF').text('QR CODE SHEET', 30, 16, { lineBreak: false });
    doc.fontSize(9).fillColor('#94A3B8').text(dateStr, 0, 19, { align: 'right', width: pageW - 30 });

    let x = 30, y = 65;

    for (let i = 0; i < prodRes.rows.length; i++) {
      const prod = prodRes.rows[i];

      // Page break
      if (y + cellH > doc.page.height - 40) {
        doc.addPage();
        x = 30; y = 30;
      }

      // Cell border
      doc.rect(x, y, cellW - 8, cellH - 8)
         .stroke('#E2E8F0');

      // QR image
      try {
        const QR_DIR = path.join(__dirname, '..', '..', 'uploads', 'qr');
        const qrFile = path.join(QR_DIR, `${prod.id}.png`);
        let qrBuf;
        if (fs.existsSync(qrFile)) {
          qrBuf = fs.readFileSync(qrFile);
        } else if (prod.qr_data) {
          qrBuf = await QRCode.toBuffer(prod.qr_data, { width: 200 });
        }
        if (qrBuf) {
          doc.image(qrBuf, x + (cellW - 8 - qrSize) / 2, y + 6, { width: qrSize, height: qrSize });
        }
      } catch (_) {}

      // Labels
      doc.fontSize(8).fillColor('#1A2340')
         .text(prod.name, x + 4, y + qrSize + 12, { width: cellW - 16, align: 'center', lineBreak: false });
      doc.fontSize(7).fillColor('#64748B')
         .text(prod.sku, x + 4, y + qrSize + 24, { width: cellW - 16, align: 'center' });

      // Advance position
      x += cellW;
      if ((i + 1) % cols === 0) { x = 30; y += cellH; }
    }

    // Footer
    const pageCount = doc.bufferedPageRange().count;
    for (let i = 0; i < pageCount; i++) {
      doc.switchToPage(i);
      doc.fontSize(7).fillColor('#94A3B8')
         .text(`Page ${i + 1} / ${pageCount}  —  ISET Mahdia  —  ${dateStr}`,
               30, doc.page.height - 25, { align: 'center', width: pageW - 60 });
    }

    doc.end();
  } catch (err) { next(err); }
};

// ─── GET /api/reports/departments/:id ────────────────────────────────────────
const getDeptReport = async (req, res, next) => {
  try {
    const deptRes = await query(
      `SELECT * FROM departments WHERE id = $1`, [req.params.id]
    );
    if (!deptRes.rows.length)
      return res.status(404).json({ success: false, message: 'Department not found' });
    const dept = deptRes.rows[0];

    const roomsRes = await query(
      `SELECT r.*, COUNT(p.id) AS product_count
       FROM rooms r
       LEFT JOIN products p ON p.room_id = r.id
       WHERE r.department_id = $1
       GROUP BY r.id ORDER BY r.name`,
      [dept.id]
    );

    const prodsRes = await query(
      `SELECT p.name, p.sku, p.barcode, p.status, p.quantity,
              c.name AS category_name, r.name AS room_name
       FROM products p
       LEFT JOIN categories c ON c.id = p.category_id
       LEFT JOIN rooms r ON r.id = p.room_id
       WHERE r.department_id = $1
       ORDER BY r.name, p.name`,
      [dept.id]
    );

    const products = prodsRes.rows;
    const rooms    = roomsRes.rows;
    const stats = { total: products.length, in_stock: 0, in_maintenance: 0, critical_issue: 0, retired: 0 };
    products.forEach(p => { if (stats[p.status] !== undefined) stats[p.status]++; });

    const dateStr = formatDate(new Date());
    const safe    = dept.name.replace(/[^a-zA-Z0-9]/g, '_');

    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename="dept_${safe}.pdf"`);

    const doc = new PDFDocument({ margin: 50, size: 'A4', bufferPages: true });
    doc.pipe(res);

    drawPageHeader(doc, `DÉPARTEMENT ${dept.code}`, dept.name, dateStr);

    // Summary stats
    drawSectionTitle(doc, 'RÉSUMÉ');
    const statW = (doc.page.width - 100) / 4;
    const statData = [
      { label: 'Total',       value: stats.total,          color: '#4F46E5', bg: '#EEF2FF' },
      { label: 'En stock',    value: stats.in_stock,       color: '#16A34A', bg: '#DCFCE7' },
      { label: 'Maintenance', value: stats.in_maintenance, color: '#D97706', bg: '#FEF9C3' },
      { label: 'Défectueux',  value: stats.critical_issue, color: '#DC2626', bg: '#FFE4E4' },
    ];
    const sy = doc.y;
    statData.forEach((s, i) => {
      const x = 50 + i * statW;
      doc.rect(x + 2, sy, statW - 4, 40).fill(s.bg);
      doc.fontSize(20).fillColor(s.color).text(String(s.value), x + 2, sy + 5, { width: statW - 4, align: 'center' });
      doc.fontSize(8).fillColor(s.color).text(s.label, x + 2, sy + 27, { width: statW - 4, align: 'center' });
    });
    doc.y = sy + 52;

    // Rooms summary
    doc.moveDown(0.3);
    drawSectionTitle(doc, `SALLES (${rooms.length})`);
    const tableW = doc.page.width - 100;
    drawTable(doc,
      [
        { header: 'Salle',        key: 'name',    width: Math.round(tableW * 0.40) },
        { header: 'Type',         key: 'type',    width: Math.round(tableW * 0.25) },
        { header: 'Équipements',  key: 'count',   width: Math.round(tableW * 0.20), align: 'center' },
        { header: 'Capacité',     key: 'cap',     width: Math.round(tableW * 0.15), align: 'center' },
      ],
      rooms.map(r => ({
        name:  r.name,
        type:  r.type || '—',
        count: String(r.product_count),
        cap:   r.capacity ? String(r.capacity) : '—',
      }))
    );

    // Full product table
    doc.moveDown(0.3);
    drawSectionTitle(doc, `LISTE DES ÉQUIPEMENTS (${products.length})`);
    const colDefs = [
      { header: 'N°',         key: 'num',      width: 28,  align: 'center' },
      { header: 'Désignation',key: 'name',     width: Math.round(tableW * 0.28) },
      { header: 'Référence',  key: 'sku',      width: Math.round(tableW * 0.18) },
      { header: 'Salle',      key: 'room',     width: Math.round(tableW * 0.18) },
      { header: 'Catégorie',  key: 'category', width: Math.round(tableW * 0.18) },
      { header: 'Statut',     key: 'status',   width: Math.round(tableW * 0.14) },
    ];
    const usedW = colDefs.reduce((s, c) => s + c.width, 0);
    colDefs[colDefs.length - 1].width += tableW - usedW;

    drawTable(doc, colDefs, products.map((p, i) => ({
      num:      i + 1,
      name:     p.name,
      sku:      p.sku,
      room:     p.room_name || '—',
      category: p.category_name || '—',
      status:   STATUS_LABELS[p.status] || p.status,
    })));

    // Footer
    const pageCount = doc.bufferedPageRange().count;
    for (let i = 0; i < pageCount; i++) {
      doc.switchToPage(i);
      doc.fontSize(8).fillColor('#94A3B8')
         .text(`Page ${i + 1} / ${pageCount}  —  ${dateStr}  —  ISET Mahdia`,
               50, doc.page.height - 40, { align: 'center', width: doc.page.width - 100 });
    }
    doc.end();
  } catch (err) { next(err); }
};

// ─── POST /api/reports/products/barcode-sheet ─────────────────────────────────
const getBarcodeSheet = async (req, res, next) => {
  try {
    const { productIds } = req.body;
    if (!Array.isArray(productIds) || productIds.length === 0) {
      return res.status(400).json({ success: false, message: 'productIds array required' });
    }

    const placeholders = productIds.map((_, i) => `$${i + 1}`).join(',');
    const prodRes = await query(
      `SELECT p.id, p.name, p.sku, p.barcode FROM products p WHERE p.id IN (${placeholders})`,
      productIds
    );

    const dateStr = formatDate(new Date());
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', 'attachment; filename="barcode_labels.pdf"');

    const doc    = new PDFDocument({ margin: 20, size: 'A4', bufferPages: true });
    doc.pipe(res);

    const pageW   = doc.page.width;
    const cols    = 3;
    const labelW  = (pageW - 40) / cols;
    const labelH  = 90;
    const padX    = 8;
    let x = 20, y = 20;

    // Header
    doc.rect(0, 0, pageW, 36).fill('#1A2340');
    doc.fontSize(13).fillColor('#FFFFFF')
       .text('BARCODE LABEL SHEET — ISET MAHDIA', 20, 10, { lineBreak: false });
    doc.fontSize(8).fillColor('#94A3B8')
       .text(dateStr, 0, 13, { align: 'right', width: pageW - 20 });
    y = 46;

    for (let i = 0; i < prodRes.rows.length; i++) {
      const prod = prodRes.rows[i];
      const codeText = prod.barcode || prod.sku;

      // Page break
      if (y + labelH > doc.page.height - 20) {
        doc.addPage();
        x = 20; y = 20;
      }

      // Label border
      doc.rect(x + 2, y, labelW - 4, labelH - 4).stroke('#E2E8F0');

      // Generate Code128 barcode PNG
      try {
        const barBuf = await bwip.toBuffer({
          bcid:        'code128',
          text:        codeText,
          scale:       2,
          height:      14,
          includetext: false,
        });
        const barW = Math.min(labelW - 20, 120);
        doc.image(barBuf, x + (labelW - barW) / 2, y + 6, { width: barW });
      } catch (_) {}

      // Labels
      doc.fontSize(7).fillColor('#64748B')
         .text(codeText, x + padX, y + 50, { width: labelW - padX * 2, align: 'center' });
      doc.fontSize(8).fillColor('#1A2340')
         .text(prod.name, x + padX, y + 62, {
           width: labelW - padX * 2, align: 'center', lineBreak: false });

      // Advance position
      x += labelW;
      if ((i + 1) % cols === 0) { x = 20; y += labelH; }
    }

    // Footer on every page
    const pageCount = doc.bufferedPageRange().count;
    for (let i = 0; i < pageCount; i++) {
      doc.switchToPage(i);
      doc.fontSize(7).fillColor('#94A3B8')
         .text(`Page ${i + 1} / ${pageCount}  —  ISET Mahdia`,
               20, doc.page.height - 20, { align: 'center', width: pageW - 40 });
    }

    doc.end();
  } catch (err) { next(err); }
};

// ─── GET /api/reports/iset ────────────────────────────────────────────────────
const getIsetReport = async (req, res, next) => {
  try {
    const [deptsRes, prodsRes, maintRes, transferRes] = await Promise.all([
      query(`
        SELECT d.id, d.name, d.code,
               COUNT(DISTINCT r.id)  AS room_count,
               COUNT(DISTINCT p.id)  AS product_count
        FROM departments d
        LEFT JOIN rooms r ON r.department_id = d.id
        LEFT JOIN products p ON p.room_id = r.id
        GROUP BY d.id ORDER BY d.name
      `),
      query(`
        SELECT p.name, p.sku, p.barcode, p.status, p.quantity, p.price,
               c.name  AS category_name,
               r.name  AS room_name,
               d.name  AS dept_name,
               d.code  AS dept_code
        FROM products p
        LEFT JOIN categories c ON c.id = p.category_id
        LEFT JOIN rooms r ON r.id = p.room_id
        LEFT JOIN departments d ON d.id = r.department_id
        ORDER BY d.name, r.name, p.name
      `),
      query(`
        SELECT
          COUNT(*)                                            AS total,
          COUNT(*) FILTER (WHERE status = 'scheduled')       AS scheduled,
          COUNT(*) FILTER (WHERE status = 'in_progress')     AS in_progress,
          COUNT(*) FILTER (WHERE status = 'done')            AS done,
          COUNT(*) FILTER (WHERE status = 'cancelled')       AS cancelled
        FROM maintenance_tasks
      `),
      query(`
        SELECT COUNT(*) AS total FROM transfers
      `).catch(() => ({ rows: [{ total: 0 }] })),
    ]);

    const products = prodsRes.rows;
    const depts    = deptsRes.rows;
    const maint    = maintRes.rows[0];

    const globalStats = {
      total:          products.length,
      in_stock:       products.filter(p => p.status === 'in_stock').length,
      operational:    products.filter(p => p.status === 'operational').length,
      in_maintenance: products.filter(p => p.status === 'in_maintenance').length,
      critical_issue: products.filter(p => p.status === 'critical_issue').length,
      retired:        products.filter(p => p.status === 'retired').length,
      lost:           products.filter(p => p.status === 'lost').length,
      total_value:    products.reduce((s, p) => s + (parseFloat(p.price) || 0) * (parseInt(p.quantity) || 1), 0),
    };

    const dateStr = formatDate(new Date());
    const month   = new Date().toLocaleString('en-GB', { month: 'long', year: 'numeric' });

    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename="iset_mahdia_report_${new Date().toISOString().substring(0,10)}.pdf"`);

    const doc = new PDFDocument({ margin: 50, size: 'A4', bufferPages: true });
    doc.pipe(res);

    const pageW  = doc.page.width;
    const tableW = pageW - 100;

    // ── Cover page ──────────────────────────────────────────────────────────────
    doc.rect(0, 0, pageW, doc.page.height).fill('#1A2340');

    doc.fontSize(28).fillColor('#FFFFFF')
       .text('ISET MAHDIA', 50, 200, { align: 'center', width: pageW - 100 });
    doc.fontSize(14).fillColor('#94A3B8')
       .text('Institut Supérieur des Études Technologiques', 50, 238, { align: 'center', width: pageW - 100 });

    doc.moveDown(3);
    doc.rect(100, doc.y, pageW - 200, 2).fill('#4F46E5');
    doc.moveDown(1.5);

    doc.fontSize(22).fillColor('#FFFFFF')
       .text('GLOBAL INVENTORY REPORT', 50, doc.y, { align: 'center', width: pageW - 100 });
    doc.moveDown(1);
    doc.fontSize(12).fillColor('#94A3B8')
       .text(month, 50, doc.y, { align: 'center', width: pageW - 100 });
    doc.moveDown(0.5);
    doc.fontSize(10).fillColor('#64748B')
       .text(`Generated on ${dateStr}`, 50, doc.y, { align: 'center', width: pageW - 100 });

    // Key numbers on cover
    doc.moveDown(3);
    const boxY  = doc.y;
    const boxW  = (pageW - 100) / 4;
    const boxes = [
      { label: 'Departments', value: depts.length,          color: '#818CF8' },
      { label: 'Equipment',   value: globalStats.total,     color: '#34D399' },
      { label: 'Critical',    value: globalStats.critical_issue, color: '#F87171' },
      { label: 'Total Value', value: `${globalStats.total_value.toFixed(0)} TND`, color: '#FBBF24' },
    ];
    boxes.forEach((b, i) => {
      const bx = 50 + i * boxW;
      doc.rect(bx + 4, boxY, boxW - 8, 70).fill('#243054');
      doc.fontSize(24).fillColor(b.color)
         .text(String(b.value), bx + 4, boxY + 10, { width: boxW - 8, align: 'center' });
      doc.fontSize(9).fillColor('#94A3B8')
         .text(b.label, bx + 4, boxY + 42, { width: boxW - 8, align: 'center' });
    });

    // ── Page 2: Global stats ─────────────────────────────────────────────────────
    doc.addPage();
    drawPageHeader(doc, 'GLOBAL INVENTORY OVERVIEW', 'All departments — ISET Mahdia', dateStr);

    drawSectionTitle(doc, 'EQUIPMENT STATUS BREAKDOWN');
    const statW = tableW / 6;
    const statItems = [
      { label: 'In Stock',     value: globalStats.in_stock,       color: '#16A34A', bg: '#DCFCE7' },
      { label: 'Operational',  value: globalStats.operational,    color: '#2563EB', bg: '#DBEAFE' },
      { label: 'Maintenance',  value: globalStats.in_maintenance, color: '#D97706', bg: '#FEF9C3' },
      { label: 'Critical',     value: globalStats.critical_issue, color: '#DC2626', bg: '#FFE4E4' },
      { label: 'Retired',      value: globalStats.retired,        color: '#6B7280', bg: '#F3F4F6' },
      { label: 'Lost',         value: globalStats.lost,           color: '#7C3AED', bg: '#EDE9FE' },
    ];
    const sy = doc.y;
    statItems.forEach((s, i) => {
      const x = 50 + i * statW;
      doc.rect(x + 2, sy, statW - 4, 44).fill(s.bg);
      doc.fontSize(22).fillColor(s.color).text(String(s.value), x + 2, sy + 5, { width: statW - 4, align: 'center' });
      doc.fontSize(7.5).fillColor(s.color).text(s.label, x + 2, sy + 30, { width: statW - 4, align: 'center' });
    });
    doc.y = sy + 56;

    // Total value banner
    doc.moveDown(0.4);
    const bannerY = doc.y;
    doc.rect(50, bannerY, tableW, 32).fill('#1A2340');
    doc.fontSize(11).fillColor('#FFFFFF')
       .text('Total Inventory Value', 60, bannerY + 9, { lineBreak: false });
    doc.fontSize(13).fillColor('#FBBF24')
       .text(`${globalStats.total_value.toFixed(2)} TND`, 0, bannerY + 8,
             { align: 'right', width: pageW - 60 });
    doc.y = bannerY + 44;

    // Maintenance summary
    doc.moveDown(0.4);
    drawSectionTitle(doc, 'MAINTENANCE SUMMARY');
    const mStatW = tableW / 4;
    const mStats = [
      { label: 'Scheduled',   value: maint.scheduled,   color: '#2563EB', bg: '#DBEAFE' },
      { label: 'In Progress', value: maint.in_progress, color: '#D97706', bg: '#FEF9C3' },
      { label: 'Done',        value: maint.done,        color: '#16A34A', bg: '#DCFCE7' },
      { label: 'Cancelled',   value: maint.cancelled,   color: '#6B7280', bg: '#F3F4F6' },
    ];
    const msy = doc.y;
    mStats.forEach((s, i) => {
      const x = 50 + i * mStatW;
      doc.rect(x + 2, msy, mStatW - 4, 44).fill(s.bg);
      doc.fontSize(22).fillColor(s.color).text(String(s.value), x + 2, msy + 5, { width: mStatW - 4, align: 'center' });
      doc.fontSize(8).fillColor(s.color).text(s.label, x + 2, msy + 30, { width: mStatW - 4, align: 'center' });
    });
    doc.y = msy + 56;

    // Departments summary table
    doc.moveDown(0.4);
    drawSectionTitle(doc, `DEPARTMENTS (${depts.length})`);
    drawTable(doc,
      [
        { header: 'Code',       key: 'code',    width: 60 },
        { header: 'Department', key: 'name',    width: Math.round(tableW * 0.45) },
        { header: 'Rooms',      key: 'rooms',   width: Math.round(tableW * 0.18), align: 'center' },
        { header: 'Equipment',  key: 'equip',   width: Math.round(tableW * 0.22), align: 'center' },
      ],
      depts.map(d => ({
        code:  d.code,
        name:  d.name,
        rooms: String(d.room_count),
        equip: String(d.product_count),
      }))
    );

    // ── Page 3+: Full equipment list grouped by department ───────────────────────
    doc.addPage();
    drawPageHeader(doc, 'FULL EQUIPMENT LIST', `${globalStats.total} items — grouped by department`, dateStr);

    const colDefs = [
      { header: 'N°',         key: 'num',      width: 28,  align: 'center' },
      { header: 'Name',       key: 'name',     width: Math.round(tableW * 0.26) },
      { header: 'SKU',        key: 'sku',      width: Math.round(tableW * 0.16) },
      { header: 'Room',       key: 'room',     width: Math.round(tableW * 0.16) },
      { header: 'Category',   key: 'category', width: Math.round(tableW * 0.17) },
      { header: 'Status',     key: 'status',   width: Math.round(tableW * 0.13) },
    ];
    const usedW = colDefs.reduce((s, c) => s + c.width, 0);
    colDefs[colDefs.length - 1].width += tableW - usedW;

    // Group products by department
    const byDept = {};
    products.forEach(p => {
      const key = p.dept_name || 'Unassigned';
      if (!byDept[key]) byDept[key] = [];
      byDept[key].push(p);
    });

    Object.entries(byDept).forEach(([deptName, items]) => {
      // Section header per department
      if (doc.y + 40 > doc.page.height - 80) doc.addPage();
      doc.moveDown(0.3);
      const dhY = doc.y;
      doc.rect(50, dhY, tableW, 24).fill('#4F46E5');
      doc.fontSize(10).fillColor('#FFFFFF')
         .text(`${deptName}  (${items.length} items)`, 58, dhY + 7);
      doc.y = dhY + 32;

      drawTable(doc, colDefs, items.map((p, i) => ({
        num:      i + 1,
        name:     p.name,
        sku:      p.sku,
        room:     p.room_name || '—',
        category: p.category_name || '—',
        status:   STATUS_LABELS[p.status] || p.status,
      })));
    });

    // ── Footer on every page ─────────────────────────────────────────────────────
    const pageCount = doc.bufferedPageRange().count;
    for (let i = 0; i < pageCount; i++) {
      doc.switchToPage(i);
      if (i === 0) continue; // cover page has no footer
      doc.fontSize(8).fillColor('#94A3B8')
         .text(`Page ${i} / ${pageCount - 1}  —  Generated ${dateStr}  —  ISET Mahdia`,
               50, doc.page.height - 40, { align: 'center', width: pageW - 100 });
    }

    doc.end();
  } catch (err) { next(err); }
};

module.exports = { getRoomFiche, getRoomJournal, getProductMaintenanceReport, getQRSheet, getDeptReport, getBarcodeSheet, getIsetReport };
