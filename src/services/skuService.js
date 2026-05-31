const { query } = require("../config/database");

const CATEGORY_CODES = {
  "Computer":       "PC",
  "Server":         "SRV",
  "Network Device": "NET",
  "Peripheral":     "PER",
  "Printer/Scanner":"PRN",
  "Display":        "DSP",
  "Projector":      "PRJ",
  "Machine Tool":   "MCH",
};

const getCategoryCode = async (categoryId) => {
  if (!categoryId) return "GEN";
  const result = await query("SELECT name FROM categories WHERE id = $1", [categoryId]);
  if (!result.rows.length) return "GEN";
  return CATEGORY_CODES[result.rows[0].name] || "GEN";
};

const generateSKU = async (categoryId) => {
  const code = await getCategoryCode(categoryId);
  const date = new Date().toISOString().slice(0, 10).replace(/-/g, "");
  const prefix = `ISET-${code}-${date}-`;

  // Find the highest sequence already used for this prefix
  const result = await query(
    "SELECT sku FROM products WHERE sku LIKE $1 ORDER BY sku DESC LIMIT 1",
    [`${prefix}%`]
  );

  let seq = 1;
  if (result.rows.length > 0) {
    const last = parseInt(result.rows[0].sku.slice(prefix.length), 10);
    if (!isNaN(last)) seq = last + 1;
  }

  // Loop until we find a slot not taken (handles deletions + concurrent inserts)
  while (true) {
    const sku = `${prefix}${String(seq).padStart(4, "0")}`;
    const check = await query("SELECT id FROM products WHERE sku = $1", [sku]);
    if (check.rows.length === 0) return sku;
    seq++;
  }
};

const validateSKU = async (sku, excludeId = null) => {
  const params = [sku];
  let sql = "SELECT id FROM products WHERE sku = $1";
  if (excludeId) {
    sql += " AND id != $2";
    params.push(excludeId);
  }
  const result = await query(sql, params);
  return result.rows.length === 0;
};

module.exports = { generateSKU, validateSKU };
