const Groq   = require("groq-sdk");
const { query } = require("../config/database");

let _groq = null;
const getGroq = () => {
  if (!_groq) _groq = new Groq({ apiKey: process.env.GROQ_API_KEY });
  return _groq;
};

async function askGroq(prompt) {
  const res = await getGroq().chat.completions.create({
    model:    "llama-3.1-8b-instant",
    messages: [{ role: "user", content: prompt }],
    temperature: 0.1,
  });
  return res.choices[0].message.content.trim();
}

const SCHEMA = `
PostgreSQL database schema for Smart Inventory Management at ISET Mahdia:

departments(id UUID, name TEXT, code TEXT, color TEXT)

rooms(id UUID, name TEXT, type TEXT, room_code TEXT, department_id UUID → departments.id)

products(
  id UUID, name TEXT, sku TEXT, barcode TEXT,
  status TEXT  -- values: 'in_stock', 'maintenance', 'critical', 'retired'
  quantity INT, price NUMERIC,
  room_id UUID → rooms.id,
  rfid_tag TEXT, ble_device TEXT,
  created_at TIMESTAMP, updated_at TIMESTAMP, last_moved_at TIMESTAMP
)

users(id UUID, name TEXT, email TEXT, role TEXT, is_active BOOL, last_seen TIMESTAMP)
  -- role values: 'admin', 'technicien', 'user'

scan_history(id UUID, product_id UUID → products.id, action_type TEXT, action_data JSONB, created_at TIMESTAMP)

unregistered_scans(id UUID, uid TEXT, scan_type TEXT, room_id UUID, room_name TEXT, reader_id TEXT, resolved BOOL, scanned_at TIMESTAMP)

notifications(id UUID, user_id UUID, type TEXT, title TEXT, body TEXT, product_id UUID, from_room TEXT, to_room TEXT, is_read BOOL, created_at TIMESTAMP)
`;

const SYSTEM_PROMPT = `You are an AI assistant for a Smart Inventory Management System at ISET Mahdia.
You help staff query inventory data using natural language.

Database schema:
${SCHEMA}

Rules:
- Generate ONLY SELECT queries. Never INSERT, UPDATE, DELETE, DROP, or modify data.
- Always JOIN properly when crossing tables.
- Add LIMIT 100 to prevent large results.
- "items" or "equipment" refers to the products table.
- Return ONLY this JSON format, nothing else:
{
  "sql": "SELECT ...",
  "explanation": "one sentence describing what the query finds"
}
- If the question cannot be answered with this schema, return:
{
  "sql": null,
  "explanation": "Cannot answer: [reason]"
}`;

const queryAI = async (req, res, next) => {
  try {
    const { question } = req.body;
    if (!question?.trim()) {
      return res.status(400).json({ success: false, message: "question required" });
    }

    // ── Step 1: Generate SQL ─────────────────────────────────────────────────
    const rawText = await askGroq(`${SYSTEM_PROMPT}\n\nQuestion: ${question}`);

    let parsed;
    try {
      const jsonMatch = rawText.match(/\{[\s\S]*\}/);
      parsed = JSON.parse(jsonMatch?.[0] ?? rawText);
    } catch {
      return res.json({
        success: true,
        data: { answer: "I couldn't process that question. Please try rephrasing.", sql: null, rows: [], row_count: 0 },
      });
    }

    if (!parsed.sql) {
      return res.json({
        success: true,
        data: { answer: parsed.explanation, sql: null, rows: [], row_count: 0 },
      });
    }

    // Safety: allow only SELECT
    if (!parsed.sql.trim().toUpperCase().startsWith("SELECT")) {
      return res.json({
        success: true,
        data: { answer: "I can only answer read-only questions about the inventory.", sql: null, rows: [], row_count: 0 },
      });
    }

    // ── Step 2: Execute SQL ──────────────────────────────────────────────────
    let rows = [];
    let execError = null;
    try {
      const result = await query(parsed.sql);
      rows = result.rows;
    } catch (err) {
      execError = err.message;
      console.error("AI SQL execution error:", err.message);
    }

    // ── Step 3: Format answer in natural language ────────────────────────────
    const formatPrompt = execError
      ? `The user asked: "${question}"\nThe SQL query failed: ${execError}\nExplain briefly what went wrong in simple terms.`
      : rows.length === 0
      ? `The user asked: "${question}"\nThe query returned no results. Give a short friendly answer.`
      : `The user asked: "${question}"\nThe query returned ${rows.length} result(s): ${JSON.stringify(rows.slice(0, 20))}\nGive a concise friendly answer in 1-3 sentences summarizing the data.`;

    const answer = await askGroq(formatPrompt);

    res.json({
      success: true,
      data: {
        answer,
        sql:       parsed.sql,
        rows:      rows.slice(0, 50),
        row_count: rows.length,
      },
    });
  } catch (err) {
    next(err);
  }
};

module.exports = { queryAI };
