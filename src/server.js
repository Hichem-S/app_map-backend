const http = require("http");
const app = require("./app");
const wsService  = require("./services/wsService");
const mqttService = require("./services/mqttService");
const cron = require("node-cron");
const { query } = require("./config/database");
const { sendMail } = require("./services/emailService");
const migrate = require("./config/migrate");
require("dotenv").config();

const PORT = process.env.PORT || 3000;

// Create HTTP server (shared with WebSocket)
const server = http.createServer(app);

// Attach WebSocket to the same HTTP server
wsService.init(server);

// Connect to MQTT broker
mqttService.connect();

// ─── Recurring maintenance cron (daily at 08:00) ─────────────────────────────
cron.schedule("0 8 * * *", async () => {
  try {
    // Find completed recurring tasks whose next interval has arrived
    const due = await query(`
      SELECT m.id, m.product_id, m.created_by, m.assigned_to,
             m.title, m.description, m.priority, m.recurrence_interval_days
      FROM maintenance_tasks m
      WHERE m.recurrence_interval_days IS NOT NULL
        AND m.status = 'done'
        AND m.completed_at + (m.recurrence_interval_days || ' days')::INTERVAL <= NOW()
        AND NOT EXISTS (
          SELECT 1 FROM maintenance_tasks n
          WHERE n.product_id = m.product_id
            AND n.title = m.title
            AND n.status IN ('scheduled','in_progress')
        )
    `);

    for (const t of due.rows) {
      const next = new Date();
      next.setDate(next.getDate() + t.recurrence_interval_days);
      const scheduled = next.toISOString().substring(0, 10);

      await query(
        `INSERT INTO maintenance_tasks
           (product_id, created_by, assigned_to, title, description,
            priority, status, scheduled_date, recurrence_interval_days)
         VALUES ($1,$2,$3,$4,$5,$6,'scheduled',$7,$8)`,
        [t.product_id, t.created_by, t.assigned_to, t.title, t.description,
         t.priority, scheduled, t.recurrence_interval_days]
      );

      // Notify assigned technician
      if (t.assigned_to) {
        wsService.sendToUser(t.assigned_to, {
          type: "maintenance_scheduled",
          title: "Recurring Maintenance Scheduled",
          body: `Task "${t.title}" has been auto-scheduled for ${scheduled}.`,
        });
      }
    }
    if (due.rows.length) console.log(`[cron] Auto-scheduled ${due.rows.length} recurring maintenance task(s)`);
  } catch (err) {
    console.error("[cron] Recurring maintenance error:", err.message);
  }
});

// ─── Monthly summary email (1st of month at 07:00) ───────────────────────────
cron.schedule("0 7 1 * *", async () => {
  try {
    const [stats, topMaint, newProducts, retiredProducts] = await Promise.all([
      query(`
        SELECT
          COUNT(*)                                              AS total,
          COALESCE(SUM(price * quantity), 0)                   AS total_value,
          COUNT(*) FILTER (WHERE status = 'critical_issue')    AS critical,
          COUNT(*) FILTER (WHERE status = 'lost')              AS lost,
          COUNT(*) FILTER (WHERE status = 'retired')           AS retired_total
        FROM products
      `),
      query(`
        SELECT p.name, p.sku, COUNT(m.id) AS cnt
        FROM maintenance_tasks m
        JOIN products p ON p.id = m.product_id
        WHERE m.created_at >= NOW() - INTERVAL '1 month'
        GROUP BY p.id, p.name, p.sku
        ORDER BY cnt DESC LIMIT 5
      `),
      query(`SELECT COUNT(*) AS cnt FROM products WHERE created_at >= NOW() - INTERVAL '1 month'`),
      query(`SELECT COUNT(*) AS cnt FROM products WHERE status = 'retired' AND updated_at >= NOW() - INTERVAL '1 month'`),
    ]);

    const s          = stats.rows[0];
    const month      = new Date().toLocaleString("fr-FR", { month: "long", year: "numeric" });
    const totalValue = parseFloat(s.total_value).toFixed(2);

    const topRows = topMaint.rows.map((r, i) =>
      `<tr style="background:${i%2===0?'#F8FAFC':'#fff'}">
         <td style="padding:8px 12px">${r.name}</td>
         <td style="padding:8px 12px;color:#64748B">${r.sku}</td>
         <td style="padding:8px 12px;text-align:center;font-weight:700;color:#4F46E5">${r.cnt}</td>
       </tr>`
    ).join('');

    const html = `
      <div style="font-family:sans-serif;max-width:600px;margin:auto">
        <div style="background:#1A2340;padding:24px 32px;border-radius:12px 12px 0 0">
          <h1 style="color:#fff;margin:0;font-size:20px">ISET Mahdia — Rapport Mensuel</h1>
          <p style="color:#94A3B8;margin:6px 0 0">${month}</p>
        </div>
        <div style="background:#fff;padding:24px 32px;border:1px solid #E2E8F0">
          <h2 style="color:#1A2340;font-size:16px">Résumé de l'inventaire</h2>
          <table style="width:100%;border-collapse:collapse">
            <tr><td style="padding:8px 0;color:#64748B">Total équipements</td><td style="font-weight:700;color:#1A2340">${s.total}</td></tr>
            <tr><td style="padding:8px 0;color:#64748B">Valeur totale</td><td style="font-weight:700;color:#1A2340">${totalValue} TND</td></tr>
            <tr><td style="padding:8px 0;color:#64748B">Ajoutés ce mois</td><td style="font-weight:700;color:#22C55E">${newProducts.rows[0].cnt}</td></tr>
            <tr><td style="padding:8px 0;color:#64748B">Réformés ce mois</td><td style="font-weight:700;color:#6B7280">${retiredProducts.rows[0].cnt}</td></tr>
            <tr><td style="padding:8px 0;color:#64748B">Problèmes critiques</td><td style="font-weight:700;color:#EF4444">${s.critical}</td></tr>
            <tr><td style="padding:8px 0;color:#64748B">Perdus</td><td style="font-weight:700;color:#8B5CF6">${s.lost}</td></tr>
          </table>
          ${topMaint.rows.length > 0 ? `
          <h2 style="color:#1A2340;font-size:16px;margin-top:24px">Top équipements en maintenance</h2>
          <table style="width:100%;border-collapse:collapse;border:1px solid #E2E8F0;border-radius:8px">
            <thead><tr style="background:#1A2340">
              <th style="padding:10px 12px;color:#fff;text-align:left">Équipement</th>
              <th style="padding:10px 12px;color:#fff;text-align:left">Référence</th>
              <th style="padding:10px 12px;color:#fff;text-align:center">Interventions</th>
            </tr></thead>
            <tbody>${topRows}</tbody>
          </table>` : ''}
        </div>
        <div style="background:#F8FAFC;padding:16px 32px;border:1px solid #E2E8F0;border-top:none;border-radius:0 0 12px 12px;text-align:center">
          <p style="color:#94A3B8;font-size:12px;margin:0">Généré automatiquement par Smart Inventory · ISET Mahdia</p>
        </div>
      </div>`;

    const admins = await query(`SELECT email, name FROM users WHERE role = 'admin' AND is_active = true`);
    for (const admin of admins.rows) {
      await sendMail(admin.email, `Rapport mensuel Smart Inventory — ${month}`, html)
        .catch(e => console.error(`[cron] Email failed for ${admin.email}:`, e.message));
    }
    console.log(`[cron] Monthly summary sent to ${admins.rows.length} admin(s)`);
  } catch (err) {
    console.error("[cron] Monthly summary error:", err.message);
  }
});

// Auto-free port if already in use (happens on nodemon restart)
server.on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.error(`❌ Port ${PORT} in use — kill it with: Get-NetTCPConnection -LocalPort ${PORT} -State Listen | Select-Object -ExpandProperty OwningProcess | ForEach-Object { Stop-Process -Id $_ -Force }`);
    process.exit(1);
  }
});

// Run migrations then start server
migrate().then(() => {
  server.listen(PORT, () => {
    console.log(`
  ╔═══════════════════════════════════════╗
  ║     Flutter Backend Server Started    ║
  ╠═══════════════════════════════════════╣
  ║  HTTP  : http://localhost:${PORT}        ║
  ║  WS    : ws://localhost:${PORT}          ║
  ║  MQTT  : ${process.env.MQTT_BROKER_URL || "mqtt://localhost:1883"}  ║
  ╚═══════════════════════════════════════╝
    `);
  });
}).catch(err => {
  console.error("❌ Startup migration failed:", err);
  process.exit(1);
});

// Graceful shutdown — release port before nodemon restarts
const _shutdown = () => server.close(() => process.exit(0));
process.on('SIGTERM', _shutdown);
process.on('SIGINT',  _shutdown);

process.on("unhandledRejection", (err) => {
  console.error("Unhandled rejection:", err);
});
