const QRCode = require("qrcode");
const fs = require("fs");
const path = require("path");
const crypto = require("crypto");
const { query } = require("../config/database");
const { generateSKU, validateSKU } = require("../services/skuService");
const wsService = require("../services/wsService");

const QR_DIR = path.join(__dirname, "..", "..", "uploads", "qr");

// Deterministic model barcode: same type + same specs → same barcode always
const _modelBarcode = (categoryId, specsObj) => {
  const sorted = Object.fromEntries(
    Object.entries(specsObj)
      .filter(([, v]) => v !== null && v !== undefined && v !== '')
      .sort(([a], [b]) => a.localeCompare(b))
  );
  const key = `${categoryId}||${JSON.stringify(sorted)}`;
  const hash = crypto.createHash("sha1").update(key).digest("hex").slice(0, 10).toUpperCase();
  return `MDL-${hash}`;
};

// Reusable SELECT columns for products with room/dept JOIN
const PRODUCT_SELECT = `
  p.*,
  c.name  AS category_name,
  r.name  AS room_name,  r.type AS room_type,
  d.id    AS department_id, d.code AS department_code,
  d.name  AS department_name, d.color AS department_color
`;
const PRODUCT_JOINS = `
  LEFT JOIN categories  c ON p.category_id  = c.id
  LEFT JOIN rooms       r ON p.room_id       = r.id
  LEFT JOIN departments d ON r.department_id = d.id
`;

// GET /api/products
const getProducts = async (req, res, next) => {
  try {
    const { search, category_id, type, status, department, room_id, page = 1, limit = 20 } = req.query;
    const offset = (page - 1) * limit;
    const params = [];
    let where = "1=1";
    let idx = 1;

    const typeFilter = type || category_id;
    if (typeFilter) { where += ` AND p.category_id = $${idx++}`; params.push(typeFilter); }
    if (status)     { where += ` AND p.status = $${idx++}`;      params.push(status); }
    if (room_id)    { where += ` AND p.room_id = $${idx++}`;     params.push(room_id); }
    if (department) { where += ` AND d.code = $${idx++}`;        params.push(department); }
    if (search) {
      where += ` AND (p.name ILIKE $${idx} OR p.sku ILIKE $${idx} OR p.barcode ILIKE $${idx})`;
      params.push(`%${search}%`);
      idx++;
    }

    const countResult = await query(
      `SELECT COUNT(*) FROM products p ${PRODUCT_JOINS} WHERE ${where}`,
      params
    );
    const total = Number(countResult.rows[0].count);

    const result = await query(
      `SELECT ${PRODUCT_SELECT} FROM products p ${PRODUCT_JOINS}
       WHERE ${where}
       ORDER BY p.created_at DESC
       LIMIT $${idx} OFFSET $${idx + 1}`,
      [...params, limit, offset]
    );

    res.json({
      success: true,
      data: result.rows,
      meta: { total, page: Number(page), limit: Number(limit), pages: Math.ceil(total / limit) },
    });
  } catch (err) {
    next(err);
  }
};

// GET /api/products/:id
const getProduct = async (req, res, next) => {
  try {
    const result = await query(
      `SELECT ${PRODUCT_SELECT} FROM products p ${PRODUCT_JOINS}
       WHERE p.id = $1`,
      [req.params.id]
    );
    if (!result.rows.length) {
      return res.status(404).json({ success: false, message: "Product not found" });
    }
    res.json({ success: true, data: result.rows[0] });
  } catch (err) {
    next(err);
  }
};

// GET /api/products/scan?id=xxx  (public — no auth required)
const getProductByScan = async (req, res, next) => {
  try {
    const { id } = req.query;
    if (!id) return res.status(400).json({ success: false, message: "id required" });

    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
    if (!uuidRegex.test(id)) {
      return res.status(400).json({ success: false, message: "Invalid product ID" });
    }

    const result = await query(
      `SELECT p.*, c.name AS category_name
       FROM products p
       LEFT JOIN categories c ON p.category_id = c.id
       WHERE p.id = $1`,
      [id]
    );
    if (!result.rows.length) {
      return res.status(404).json({ success: false, message: "Product not found" });
    }
    res.json({ success: true, data: result.rows[0] });
  } catch (err) {
    next(err);
  }
};

// POST /api/products
const createProduct = async (req, res, next) => {
  try {
    const {
      name, sku: manualSku, type, barcode,
      description, tags, quantity, price, storage_location, status, specifications,
      department, classroom, room_id,
    } = req.body;

    // SKU: use manual if provided and valid, otherwise auto-generate
    let sku = manualSku?.trim();
    if (sku) {
      const unique = await validateSKU(sku);
      if (!unique) {
        return res.status(409).json({ success: false, message: "SKU already exists" });
      }
    } else {
      sku = await generateSKU(type);
    }

    console.log('[CREATE] req.file =', req.file
      ? { filename: req.file.filename, size: req.file.size, mimetype: req.file.mimetype }
      : 'MISSING — no file received by multer');
    const photoUrl = req.file ? `/uploads/${req.file.filename}` : null;
    console.log('[CREATE] photoUrl =', photoUrl);
    const tagsArray = tags
      ? (Array.isArray(tags) ? tags : JSON.parse(tags))
      : null;
    const specsJson = specifications
      ? (typeof specifications === 'string' ? specifications : JSON.stringify(specifications))
      : null;

    // Auto-assign model barcode: same type + same specs → same barcode
    let resolvedBarcode = barcode?.trim() || null;
    if (!resolvedBarcode && specsJson && type) {
      const specsObj = JSON.parse(specsJson);
      if (Object.keys(specsObj).length > 0) {
        resolvedBarcode = _modelBarcode(type, specsObj);
      }
    }

    const result = await query(
      `INSERT INTO products
         (user_id, category_id, name, sku, barcode, description, tags, quantity, price, storage_location, photo_url, status, specifications, department, classroom, room_id)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16)
       RETURNING *`,
      [
        req.user.id, type || null, name, sku,
        resolvedBarcode, description || null,
        tagsArray ? `{${tagsArray.join(",")}}` : null,
        quantity || 0, price || null, storage_location || null, photoUrl,
        status || 'in_stock',
        specsJson || null,
        department || null, classroom || null, room_id || null,
      ]
    );
    const product = result.rows[0];

    // Generate QR PNG and save to disk
    const qrData = `${process.env.APP_URL}/api/products/scan?id=${product.id}`;
    const qrFilename = `${product.id}.png`;
    const qrFilePath = path.join(QR_DIR, qrFilename);
    const qrImageUrl = `/uploads/qr/${qrFilename}`;

    const qrBuffer = await QRCode.toBuffer(qrData, { width: 300 });
    fs.writeFileSync(qrFilePath, qrBuffer);

    await query(
      "UPDATE products SET qr_data=$1, qr_image_url=$2 WHERE id=$3",
      [qrData, qrImageUrl, product.id]
    );

    // Record activity
    await query(
      "INSERT INTO scan_history (user_id, product_id, action_type) VALUES ($1, $2, 'product_added')",
      [req.user.id, product.id]
    ).catch(() => {});

    res.status(201).json({ success: true, data: { ...product, qr_data: qrData, qr_image_url: qrImageUrl } });
  } catch (err) {
    next(err);
  }
};

// PUT /api/products/:id
const updateProduct = async (req, res, next) => {
  try {
    const {
      name, sku: manualSku, type, barcode,
      description, tags, quantity, price, storage_location, status, specifications,
      department, classroom, room_id,
    } = req.body;

    const existing = await query(
      "SELECT * FROM products WHERE id=$1",
      [req.params.id]
    );
    if (!existing.rows.length) {
      return res.status(404).json({ success: false, message: "Product not found" });
    }

    if (manualSku && manualSku !== existing.rows[0].sku) {
      const unique = await validateSKU(manualSku, req.params.id);
      if (!unique) {
        return res.status(409).json({ success: false, message: "SKU already exists" });
      }
    }

    const photoUrl = req.file
      ? `/uploads/${req.file.filename}`
      : existing.rows[0].photo_url;

    const tagsArray = tags
      ? (Array.isArray(tags) ? tags : JSON.parse(tags))
      : null;
    const specsJson = specifications
      ? (typeof specifications === 'string' ? specifications : JSON.stringify(specifications))
      : null;

    // Auto-assign model barcode: same type + same specs → same barcode
    const effectiveType = type || existing.rows[0].category_id;
    const effectiveSpecsJson = specsJson ?? (existing.rows[0].specifications
      ? JSON.stringify(existing.rows[0].specifications)
      : null);
    let resolvedBarcode = barcode?.trim() || null;
    if (!resolvedBarcode && effectiveSpecsJson && effectiveType) {
      const specsObj = JSON.parse(effectiveSpecsJson);
      if (Object.keys(specsObj).length > 0) {
        resolvedBarcode = _modelBarcode(effectiveType, specsObj);
      }
    }

    const result = await query(
      `UPDATE products
       SET name=$1, sku=$2, category_id=$3, barcode=$4, description=$5,
           tags=$6, quantity=$7, price=$8, storage_location=$9, photo_url=$10,
           status=$11, specifications=$12, department=$13, classroom=$14,
           room_id=$15, updated_at=NOW()
       WHERE id=$16
       RETURNING *`,
      [
        name, manualSku || existing.rows[0].sku, type || null,
        resolvedBarcode, description || null,
        tagsArray ? `{${tagsArray.join(",")}}` : null,
        quantity ?? existing.rows[0].quantity,
        price ?? existing.rows[0].price,
        storage_location || null, photoUrl,
        status || existing.rows[0].status || 'in_stock',
        specsJson ?? existing.rows[0].specifications ?? null,
        department || existing.rows[0].department || null,
        classroom || existing.rows[0].classroom || null,
        room_id !== undefined ? (room_id || null) : existing.rows[0].room_id,
        req.params.id,
      ]
    );
    res.json({ success: true, data: result.rows[0] });
  } catch (err) {
    next(err);
  }
};

// PATCH /api/products/:id/location
const updateProductLocation = async (req, res, next) => {
  try {
    const { room_id } = req.body;

    if (room_id) {
      const roomCheck = await query("SELECT id FROM rooms WHERE id = $1", [room_id]);
      if (!roomCheck.rows.length) {
        return res.status(400).json({ success: false, message: "Room not found" });
      }
    }

    // Snapshot old room before update
    const before = await query(
      `SELECT p.name AS product_name, r.name AS room_name, d.code AS dept_code
       FROM products p
       LEFT JOIN rooms r ON p.room_id = r.id
       LEFT JOIN departments d ON r.department_id = d.id
       WHERE p.id = $1`,
      [req.params.id]
    );

    await query(
      "UPDATE products SET room_id=$1, last_moved_by=$2, last_moved_at=NOW(), updated_at=NOW() WHERE id=$3",
      [room_id || null, req.user.id, req.params.id]
    );

    // Return full product with room/dept data
    const result = await query(
      `SELECT ${PRODUCT_SELECT} FROM products p ${PRODUCT_JOINS}
       WHERE p.id = $1`,
      [req.params.id]
    );
    if (!result.rows.length) {
      return res.status(404).json({ success: false, message: "Product not found" });
    }

    const prod     = result.rows[0];
    const old      = before.rows[0] || {};
    const moverName = req.user.name || 'Unknown';

    const fromLabel = old.room_name  || '—';
    const toLabel   = prod.room_name || '—';

    const wsPayload = {
      type:        "product_moved",
      productId:   prod.id,
      productName: prod.name,
      fromRoom:    old.room_name         || null,
      fromDept:    old.dept_code         || null,
      toRoom:      prod.room_name        || null,
      toDept:      prod.department_code  || null,
      movedAt:     new Date().toISOString(),
      movedByName: moverName,
    };

    // Self-notification (mover's own record)
    const selfNotif = await query(
      `INSERT INTO notifications
         (user_id, type, title, body, product_id, product_name, from_room, to_room)
       VALUES ($1, 'product_moved', 'Déplacement effectué', $2, $3, $4, $5, $6)
       RETURNING id`,
      [req.user.id, `By ${moverName}`,
       prod.id, prod.name, old.room_name || null, prod.room_name || null]
    );
    wsService.sendToUser(req.user.id, {
      ...wsPayload, notificationId: selfNotif.rows[0].id,
    });

    // Notify every technicien + admin who didn't perform the move
    const recipients = await query(
      `SELECT id FROM users
       WHERE role IN ('technicien', 'admin') AND id != $1 AND is_active = true`,
      [req.user.id]
    );

    for (const r of recipients.rows) {
      const notif = await query(
        `INSERT INTO notifications
           (user_id, type, title, body, product_id, product_name, from_room, to_room)
         VALUES ($1, 'product_moved', 'Item Relocated', $2, $3, $4, $5, $6)
         RETURNING id`,
        [
          r.id,
          `By ${moverName}`,
          prod.id, prod.name, old.room_name || null, prod.room_name || null,
        ]
      ).catch(() => null);

      if (notif) {
        wsService.sendToUser(r.id, {
          ...wsPayload, notificationId: notif.rows[0].id,
        });
      }
    }

    // Record activity
    await query(
      "INSERT INTO scan_history (user_id, product_id, action_type, action_data) VALUES ($1, $2, 'moved', $3)",
      [req.user.id, prod.id, JSON.stringify({ from_room: old.room_name || null, to_room: prod.room_name || null })]
    ).catch(() => {});

    res.json({ success: true, data: prod });
  } catch (err) {
    next(err);
  }
};

// PATCH /api/products/:id/status
const updateProductStatus = async (req, res, next) => {
  try {
    const { status } = req.body;
    const allowed = ['in_stock', 'in_maintenance', 'critical_issue', 'retired'];
    if (!status || !allowed.includes(status)) {
      return res.status(400).json({ success: false, message: `status must be one of: ${allowed.join(', ')}` });
    }

    const before = await query("SELECT status FROM products WHERE id=$1", [req.params.id]);
    const oldStatus = before.rows[0]?.status || null;

    const result = await query(
      `UPDATE products SET status=$1, updated_at=NOW()
       WHERE id=$2 RETURNING *`,
      [status, req.params.id]
    );
    if (!result.rows.length) {
      return res.status(404).json({ success: false, message: "Product not found" });
    }

    // Record activity
    await query(
      "INSERT INTO scan_history (user_id, product_id, action_type, action_data) VALUES ($1, $2, 'status_changed', $3)",
      [req.user.id, req.params.id, JSON.stringify({ old_status: oldStatus, new_status: status })]
    ).catch(() => {});

    res.json({ success: true, data: result.rows[0] });
  } catch (err) {
    next(err);
  }
};

// DELETE /api/products/:id
const deleteProduct = async (req, res, next) => {
  try {
    const result = await query(
      "DELETE FROM products WHERE id=$1 RETURNING id",
      [req.params.id]
    );
    if (!result.rows.length) {
      return res.status(404).json({ success: false, message: "Product not found" });
    }
    res.json({ success: true, message: "Product deleted" });
  } catch (err) {
    next(err);
  }
};

// GET /api/products/:id/qr  — serves saved QR PNG, regenerates if missing
const getProductQR = async (req, res, next) => {
  try {
    const result = await query(
      "SELECT qr_data, qr_image_url FROM products WHERE id=$1",
      [req.params.id]
    );
    if (!result.rows.length) {
      return res.status(404).json({ success: false, message: "Product not found" });
    }

    const { qr_data, qr_image_url } = result.rows[0];

    // Serve saved file if it exists
    if (qr_image_url) {
      const filePath = path.join(__dirname, "..", "..", qr_image_url);
      if (fs.existsSync(filePath)) {
        return res.sendFile(filePath);
      }
    }

    // Fallback: regenerate and save for next time
    const qrBuffer = await QRCode.toBuffer(qr_data, { width: 300 });
    const qrFilename = `${req.params.id}.png`;
    const qrFilePath = path.join(QR_DIR, qrFilename);
    const newQrImageUrl = `/uploads/qr/${qrFilename}`;
    fs.writeFileSync(qrFilePath, qrBuffer);
    await query("UPDATE products SET qr_image_url=$1 WHERE id=$2", [newQrImageUrl, req.params.id]);

    res.set("Content-Type", "image/png");
    res.send(qrBuffer);
  } catch (err) {
    next(err);
  }
};

// GET /api/categories
const getCategories = async (req, res, next) => {
  try {
    const result = await query(
      "SELECT * FROM categories ORDER BY name ASC"
    );
    res.json({ success: true, data: result.rows });
  } catch (err) {
    next(err);
  }
};

// GET /api/products/stats
const getStats = async (req, res, next) => {
  try {
    const userId = req.user.id;

    const [products, scans] = await Promise.all([
      query(
        `SELECT
           COUNT(*)                                                    AS total_products,
           COUNT(*) FILTER (WHERE quantity = 0)                        AS out_of_stock,
           COUNT(*) FILTER (WHERE quantity > 0 AND quantity <= 5)      AS low_stock,
           COUNT(DISTINCT category_id) FILTER (WHERE category_id IS NOT NULL) AS categories_used,
           COALESCE(SUM(price * quantity), 0)                          AS total_value,
           COUNT(*) FILTER (WHERE status = 'in_stock')                 AS status_in_stock,
           COUNT(*) FILTER (WHERE status = 'in_maintenance')           AS status_in_maintenance,
           COUNT(*) FILTER (WHERE status = 'critical_issue')           AS status_critical_issue,
           COUNT(*) FILTER (WHERE status = 'retired')                  AS status_retired
         FROM products`,
        []
      ),
      query('SELECT COUNT(*) FROM scan_history WHERE user_id = $1', [userId]),
    ]);

    const r = products.rows[0];
    res.json({
      success: true,
      data: {
        total_products:        Number(r.total_products),
        out_of_stock:          Number(r.out_of_stock),
        low_stock:             Number(r.low_stock),
        categories_used:       Number(r.categories_used),
        total_value:           parseFloat(Number(r.total_value).toFixed(2)),
        total_scans:           Number(scans.rows[0].count),
        status_in_stock:       Number(r.status_in_stock),
        status_in_maintenance: Number(r.status_in_maintenance),
        status_critical_issue: Number(r.status_critical_issue),
        status_retired:        Number(r.status_retired),
      },
    });
  } catch (err) {
    next(err);
  }
};

// POST /api/products/scan-history  — record a product scan/addition or department QR view
const addScanHistory = async (req, res, next) => {
  try {
    const { product_id, department_code, department_name, action_type } = req.body;
    if (!product_id && !department_code) {
      return res.status(400).json({ success: false, message: "product_id or department_code required" });
    }
    if (product_id) {
      const type = action_type || 'scan';
      await query(
        "INSERT INTO scan_history (user_id, product_id, action_type) VALUES ($1, $2, $3)",
        [req.user.id, product_id, type]
      );
    } else {
      await query(
        "INSERT INTO scan_history (user_id, department_code, department_name, action_type) VALUES ($1, $2, $3, $4)",
        [req.user.id, department_code, department_name || department_code, 'dept_qr']
      );
    }
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
};

// GET /api/products/scan-history  — get recent activity across all users
const getScanHistory = async (req, res, next) => {
  try {
    const result = await query(
      `SELECT sh.id, sh.scanned_at,
              sh.action_type                        AS type,
              sh.product_id,
              sh.action_data,
              COALESCE(p.name, sh.department_name)  AS name,
              p.sku,
              p.photo_url,
              COALESCE(c.name, 'Département')       AS category_name,
              sh.department_code,
              u.name                                AS user_name,
              u.role                                AS user_role
       FROM scan_history sh
       LEFT JOIN products    p ON sh.product_id  = p.id
       LEFT JOIN categories  c ON p.category_id  = c.id
       LEFT JOIN users       u ON sh.user_id     = u.id
       ORDER BY sh.scanned_at DESC
       LIMIT 30`,
      []
    );
    res.json({ success: true, data: result.rows });
  } catch (err) {
    next(err);
  }
};

// GET /api/products/dept-stats?department=I  (department code)
const getDeptStats = async (req, res, next) => {
  try {
    const { department } = req.query;
    if (!department) return res.status(400).json({ success: false, message: "department required" });

    const deptRow = await query("SELECT id FROM departments WHERE code = $1", [department]);
    if (!deptRow.rows.length) {
      return res.status(404).json({ success: false, message: "Department not found" });
    }
    const deptId = deptRow.rows[0].id;

    const result = await query(
      `SELECT
         COUNT(p.id)                                                        AS total,
         COUNT(DISTINCT p.room_id) FILTER (WHERE p.room_id IS NOT NULL)    AS rooms_used,
         COUNT(p.id) FILTER (WHERE p.status = 'in_stock')                  AS in_stock,
         COUNT(p.id) FILTER (WHERE p.status = 'in_maintenance')            AS in_maintenance,
         COUNT(p.id) FILTER (WHERE p.status = 'critical_issue')            AS critical_issue,
         COUNT(p.id) FILTER (WHERE p.status = 'retired')                   AS retired
       FROM products p
       JOIN rooms r ON p.room_id = r.id
       WHERE r.department_id = $1`,
      [deptId]
    );

    const byRoom = await query(
      `SELECT r.name AS room, COUNT(p.id) AS total
       FROM rooms r
       LEFT JOIN products p ON p.room_id = r.id
       WHERE r.department_id = $1
       GROUP BY r.id, r.name
       ORDER BY r.name`,
      [deptId]
    );

    const r = result.rows[0];
    res.json({
      success: true,
      data: {
        total:          Number(r.total),
        rooms_used:     Number(r.rooms_used),
        in_stock:       Number(r.in_stock),
        in_maintenance: Number(r.in_maintenance),
        critical_issue: Number(r.critical_issue),
        retired:        Number(r.retired),
        by_room: byRoom.rows.map(row => ({ room: row.room, total: Number(row.total) })),
      },
    });
  } catch (err) {
    next(err);
  }
};

// GET /api/products/barcode-check?barcode=xxx
const checkBarcode = async (req, res, next) => {
  try {
    const { barcode } = req.query;
    if (!barcode) return res.status(400).json({ success: false, message: "barcode required" });

    const result = await query(
      `SELECT p.*, c.name AS category_name
       FROM products p
       LEFT JOIN categories c ON p.category_id = c.id
       WHERE p.barcode = $1
       ORDER BY p.created_at DESC
       LIMIT 1`,
      [barcode]
    );

    res.json({
      success: true,
      exists: result.rows.length > 0,
      data: result.rows[0] || null,
    });
  } catch (err) {
    next(err);
  }
};

// GET /api/products/move-log
const getMoveLog = async (req, res, next) => {
  try {
    const result = await query(
      `SELECT
         p.id, p.name, p.sku, p.status,
         p.last_moved_at,
         r.id   AS room_id,   r.name AS room_name,
         d.id   AS dept_id,   d.name AS dept_name,
         d.code AS dept_code, d.color AS dept_color,
         u.name AS moved_by_name, u.role AS moved_by_role
       FROM products p
       LEFT JOIN rooms r ON r.id = p.room_id
       LEFT JOIN departments d ON d.id = r.department_id
       LEFT JOIN users u ON u.id = p.last_moved_by
       WHERE p.last_moved_at IS NOT NULL
       ORDER BY p.last_moved_at DESC`,
      []
    );
    res.json({ success: true, data: result.rows });
  } catch (err) {
    next(err);
  }
};

module.exports = {
  getProducts, getProduct, getProductByScan,
  createProduct, updateProduct, updateProductStatus, updateProductLocation, deleteProduct,
  getProductQR, getCategories, getMoveLog,
  addScanHistory, getScanHistory, getStats,
  checkBarcode, getDeptStats,
};
