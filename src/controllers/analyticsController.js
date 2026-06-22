const { query } = require("../config/database");

// GET /api/analytics/dashboard
const getDashboard = async (req, res, next) => {
  try {
    const [statusRes, deptRes, maintMonthRes, topMaintRes, warrantyRes, activityRes] =
      await Promise.all([
        // Products by status
        query(`
          SELECT status, COUNT(*) AS count
          FROM products
          GROUP BY status
          ORDER BY count DESC
        `),

        // Products by department
        query(`
          SELECT d.code, d.name, d.color, COUNT(p.id) AS count
          FROM departments d
          LEFT JOIN rooms r ON r.department_id = d.id
          LEFT JOIN products p ON p.room_id = r.id
          GROUP BY d.id, d.code, d.name, d.color
          ORDER BY count DESC
        `),

        // Maintenance tasks per month — always 6 buckets even if empty
        query(`
          SELECT
            TO_CHAR(m, 'Mon YY') AS month,
            COALESCE(COUNT(mt.id), 0)::int AS total,
            COALESCE(COUNT(mt.id) FILTER (WHERE mt.status = 'done'), 0)::int AS done
          FROM generate_series(
            DATE_TRUNC('month', NOW() - INTERVAL '5 months'),
            DATE_TRUNC('month', NOW()),
            '1 month'
          ) AS m
          LEFT JOIN maintenance_tasks mt ON DATE_TRUNC('month', mt.created_at) = m
          GROUP BY m
          ORDER BY m ASC
        `),

        // Top 5 most maintained products
        query(`
          SELECT p.name, p.sku, COUNT(m.id) AS task_count
          FROM products p
          JOIN maintenance_tasks m ON m.product_id = p.id
          GROUP BY p.id, p.name, p.sku
          ORDER BY task_count DESC
          LIMIT 5
        `),

        // Warranty expiring in next 30 days (column may not exist yet before migration)
        query(`
          SELECT COUNT(*) AS expiring_soon,
                 COUNT(*) FILTER (WHERE warranty_expiry < NOW()) AS expired
          FROM products
          WHERE warranty_expiry IS NOT NULL
            AND warranty_expiry <= NOW() + INTERVAL '30 days'
        `).catch(() => ({ rows: [{ expiring_soon: 0, expired: 0 }] })),

        // Activity last 7 days
        query(`
          SELECT COUNT(*) AS scans_7d
          FROM scan_history
          WHERE scanned_at >= NOW() - INTERVAL '7 days'
        `),
      ]);

    res.json({
      success: true,
      data: {
        by_status:       statusRes.rows.map(r => ({ status: r.status, count: Number(r.count) })),
        by_department:   deptRes.rows.map(r => ({ code: r.code, name: r.name, color: r.color, count: Number(r.count) })),
        maintenance_trend: maintMonthRes.rows.map(r => ({
          month: r.month,
          total: Number(r.total),
          done:  Number(r.done),
        })),
        top_maintained:  topMaintRes.rows.map(r => ({ name: r.name, sku: r.sku, count: Number(r.task_count) })),
        warranty: {
          expiring_soon: Number(warrantyRes.rows[0]?.expiring_soon || 0),
          expired:       Number(warrantyRes.rows[0]?.expired       || 0),
        },
        scans_7d: Number(activityRes.rows[0]?.scans_7d || 0),
      },
    });
  } catch (err) { next(err); }
};

module.exports = { getDashboard };
