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
  const date = new Date().toISOString().slice(0, 10).replace(/-/g, ""); // 20260428

  const result = await query(
    "SELECT COUNT(*) FROM products WHERE sku LIKE $1",
    [`ISET-${code}-${date}%`]
  );
  const seq = String(Number(result.rows[0].count) + 1).padStart(4, "0");
  return `ISET-${code}-${date}-${seq}`;
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
