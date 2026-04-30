const QRCode = require("qrcode");
const { query } = require("../config/database");
const { generateSKU, validateSKU } = require("../services/skuService");

// GET /api/products
const getProducts = async (req, res, next) => {
  try {
    const { search, category_id, page = 1, limit = 20 } = req.query;
    const offset = (page - 1) * limit;
    const params = [req.user.id];
    let where = "p.user_id = $1";
    let idx = 2;

    if (category_id) {
      where += ` AND p.category_id = $${idx++}`;
      params.push(category_id);
    }
    if (search) {
      where += ` AND (p.name ILIKE $${idx} OR p.sku ILIKE $${idx} OR p.barcode ILIKE $${idx})`;
      params.push(`%${search}%`);
      idx++;
    }

    const countResult = await query(
      `SELECT COUNT(*) FROM products p WHERE ${where}`,
      params
    );
    const total = Number(countResult.rows[0].count);

    const result = await query(
      `SELECT p.*, c.name AS category_name
       FROM products p
       LEFT JOIN categories c ON p.category_id = c.id
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
      `SELECT p.*, c.name AS category_name
       FROM products p
       LEFT JOIN categories c ON p.category_id = c.id
       WHERE p.id = $1 AND p.user_id = $2`,
      [req.params.id, req.user.id]
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
      description, tags, quantity, price, storage_location,
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

    const photoUrl = req.file ? `/uploads/${req.file.filename}` : null;
    const tagsArray = tags
      ? (Array.isArray(tags) ? tags : JSON.parse(tags))
      : null;

    const result = await query(
      `INSERT INTO products
         (user_id, category_id, name, sku, barcode, description, tags, quantity, price, storage_location, photo_url)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
       RETURNING *`,
      [
        req.user.id, type || null, name, sku,
        barcode || null, description || null,
        tagsArray ? `{${tagsArray.join(",")}}` : null,
        quantity || 0, price || null, storage_location || null, photoUrl,
      ]
    );
    const product = result.rows[0];

    // Generate QR pointing to the public scan endpoint
    const qrData = `${process.env.APP_URL}/api/products/scan?id=${product.id}`;
    await query("UPDATE products SET qr_data=$1 WHERE id=$2", [qrData, product.id]);

    res.status(201).json({ success: true, data: { ...product, qr_data: qrData } });
  } catch (err) {
    next(err);
  }
};

// PUT /api/products/:id
const updateProduct = async (req, res, next) => {
  try {
    const {
      name, sku: manualSku, type, barcode,
      description, tags, quantity, price, storage_location,
    } = req.body;

    const existing = await query(
      "SELECT * FROM products WHERE id=$1 AND user_id=$2",
      [req.params.id, req.user.id]
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

    const result = await query(
      `UPDATE products
       SET name=$1, sku=$2, category_id=$3, barcode=$4, description=$5,
           tags=$6, quantity=$7, price=$8, storage_location=$9, photo_url=$10,
           updated_at=NOW()
       WHERE id=$11 AND user_id=$12
       RETURNING *`,
      [
        name, manualSku || existing.rows[0].sku, type || null,
        barcode || null, description || null,
        tagsArray ? `{${tagsArray.join(",")}}` : null,
        quantity ?? existing.rows[0].quantity,
        price ?? existing.rows[0].price,
        storage_location || null, photoUrl,
        req.params.id, req.user.id,
      ]
    );
    res.json({ success: true, data: result.rows[0] });
  } catch (err) {
    next(err);
  }
};

// DELETE /api/products/:id
const deleteProduct = async (req, res, next) => {
  try {
    const result = await query(
      "DELETE FROM products WHERE id=$1 AND user_id=$2 RETURNING id",
      [req.params.id, req.user.id]
    );
    if (!result.rows.length) {
      return res.status(404).json({ success: false, message: "Product not found" });
    }
    res.json({ success: true, message: "Product deleted" });
  } catch (err) {
    next(err);
  }
};

// GET /api/products/:id/qr  — returns QR as PNG image
const getProductQR = async (req, res, next) => {
  try {
    const result = await query(
      "SELECT qr_data FROM products WHERE id=$1 AND user_id=$2",
      [req.params.id, req.user.id]
    );
    if (!result.rows.length) {
      return res.status(404).json({ success: false, message: "Product not found" });
    }
    const qrBuffer = await QRCode.toBuffer(result.rows[0].qr_data, { width: 300 });
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
           COUNT(*)                                              AS total_products,
           COUNT(*) FILTER (WHERE quantity = 0)                 AS out_of_stock,
           COUNT(*) FILTER (WHERE quantity > 0 AND quantity <= 5) AS low_stock,
           COUNT(DISTINCT category_id) FILTER (WHERE category_id IS NOT NULL) AS categories_used,
           COALESCE(SUM(price * quantity), 0)                   AS total_value
         FROM products WHERE user_id = $1`,
        [userId]
      ),
      query('SELECT COUNT(*) FROM scan_history WHERE user_id = $1', [userId]),
    ]);

    const r = products.rows[0];
    res.json({
      success: true,
      data: {
        total_products:   Number(r.total_products),
        out_of_stock:     Number(r.out_of_stock),
        low_stock:        Number(r.low_stock),
        categories_used:  Number(r.categories_used),
        total_value:      parseFloat(Number(r.total_value).toFixed(2)),
        total_scans:      Number(scans.rows[0].count),
      },
    });
  } catch (err) {
    next(err);
  }
};

// POST /api/products/scan-history  — record a scan
const addScanHistory = async (req, res, next) => {
  try {
    const { product_id } = req.body;
    if (!product_id) return res.status(400).json({ success: false, message: "product_id required" });

    await query(
      "INSERT INTO scan_history (user_id, product_id) VALUES ($1, $2)",
      [req.user.id, product_id]
    );
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
};

// GET /api/products/scan-history  — get recent scans for this user
const getScanHistory = async (req, res, next) => {
  try {
    const result = await query(
      `SELECT sh.id, sh.scanned_at,
              p.id AS product_id, p.name, p.sku, p.photo_url,
              c.name AS category_name
       FROM scan_history sh
       JOIN products p ON sh.product_id = p.id
       LEFT JOIN categories c ON p.category_id = c.id
       WHERE sh.user_id = $1
       ORDER BY sh.scanned_at DESC
       LIMIT 20`,
      [req.user.id]
    );
    res.json({ success: true, data: result.rows });
  } catch (err) {
    next(err);
  }
};

module.exports = {
  getProducts, getProduct, getProductByScan,
  createProduct, updateProduct, deleteProduct,
  getProductQR, getCategories,
  addScanHistory, getScanHistory, getStats,
};
