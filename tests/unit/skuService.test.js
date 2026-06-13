jest.mock('../../src/config/database');

const db = require('../../src/config/database');
const { generateSKU, validateSKU } = require('../../src/services/skuService');

// getCategoryCode(null) returns 'GEN' immediately — NO DB call.
// getCategoryCode(id)   calls DB once to look up the category name.
//
// generateSKU always makes:
//   [0 or 1] calls for getCategoryCode
//   1        call  to find the last existing SKU for the prefix
//   1+       calls to check uniqueness (one per attempted sequence number)

const todayStr = new Date().toISOString().slice(0, 10).replace(/-/g, '');

// ── generateSKU ───────────────────────────────────────────────────────────────

describe('generateSKU', () => {
  test('generates a GEN sku when no categoryId given', async () => {
    // null categoryId → no DB call for getCategoryCode
    db.query
      .mockResolvedValueOnce({ rows: [] })  // last sku query → none found
      .mockResolvedValueOnce({ rows: [] }); // uniqueness check → free
    const sku = await generateSKU(null);
    expect(sku).toMatch(/^ISET-GEN-\d{8}-\d{4}$/);
  });

  test('generates a PC sku for Computer category', async () => {
    // has categoryId → getCategoryCode queries DB once
    db.query
      .mockResolvedValueOnce({ rows: [{ name: 'Computer' }] }) // getCategoryCode
      .mockResolvedValueOnce({ rows: [] })                     // last sku → none
      .mockResolvedValueOnce({ rows: [] });                    // uniqueness → free
    const sku = await generateSKU('cat-001');
    expect(sku).toMatch(/^ISET-PC-\d{8}-\d{4}$/);
  });

  test('generates SRV for Server category', async () => {
    db.query
      .mockResolvedValueOnce({ rows: [{ name: 'Server' }] })
      .mockResolvedValueOnce({ rows: [] })
      .mockResolvedValueOnce({ rows: [] });
    const sku = await generateSKU('cat-002');
    expect(sku).toMatch(/^ISET-SRV-/);
  });

  test('starts from 0001 when no prior SKU exists', async () => {
    db.query
      .mockResolvedValueOnce({ rows: [] })  // last sku query → none
      .mockResolvedValueOnce({ rows: [] }); // uniqueness check → free
    const sku = await generateSKU(null);
    expect(sku.endsWith('-0001')).toBe(true);
  });

  test('increments sequence from the last existing SKU', async () => {
    const prefix = `ISET-GEN-${todayStr}-`;
    db.query
      .mockResolvedValueOnce({ rows: [{ sku: `${prefix}0005` }] }) // last sku → 0005
      .mockResolvedValueOnce({ rows: [] });                         // 0006 uniqueness → free
    const sku = await generateSKU(null);
    expect(sku.endsWith('-0006')).toBe(true);
  });

  test('skips already-taken sequence numbers', async () => {
    const prefix = `ISET-GEN-${todayStr}-`;
    db.query
      .mockResolvedValueOnce({ rows: [{ sku: `${prefix}0003` }] }) // last sku → try 0004
      .mockResolvedValueOnce({ rows: [{ id: 'x' }] })               // 0004 taken
      .mockResolvedValueOnce({ rows: [] });                          // 0005 free
    const sku = await generateSKU(null);
    expect(sku.endsWith('-0005')).toBe(true);
  });

  test('pads sequence to 4 digits', async () => {
    db.query
      .mockResolvedValueOnce({ rows: [] })
      .mockResolvedValueOnce({ rows: [] });
    const sku = await generateSKU(null);
    const seq = sku.split('-').pop();
    expect(seq).toHaveLength(4);
    expect(seq).toMatch(/^\d{4}$/);
  });

  test('uses GEN when category name is not in mapping', async () => {
    db.query
      .mockResolvedValueOnce({ rows: [{ name: 'Unknown Category' }] }) // getCategoryCode
      .mockResolvedValueOnce({ rows: [] })
      .mockResolvedValueOnce({ rows: [] });
    const sku = await generateSKU('cat-999');
    expect(sku).toMatch(/^ISET-GEN-/);
  });

  test('uses GEN when category id not found in DB', async () => {
    db.query
      .mockResolvedValueOnce({ rows: [] }) // getCategoryCode → no rows → GEN
      .mockResolvedValueOnce({ rows: [] })
      .mockResolvedValueOnce({ rows: [] });
    const sku = await generateSKU('cat-missing');
    expect(sku).toMatch(/^ISET-GEN-/);
  });

  test('includes today date in SKU', async () => {
    db.query
      .mockResolvedValueOnce({ rows: [] })
      .mockResolvedValueOnce({ rows: [] });
    const sku = await generateSKU(null);
    expect(sku).toContain(todayStr);
  });
});

// ── validateSKU ───────────────────────────────────────────────────────────────

describe('validateSKU', () => {
  test('returns true when SKU does not exist', async () => {
    db.query.mockResolvedValueOnce({ rows: [] });
    const valid = await validateSKU('ISET-PC-20240101-0001');
    expect(valid).toBe(true);
  });

  test('returns false when SKU already exists', async () => {
    db.query.mockResolvedValueOnce({ rows: [{ id: 'p-001' }] });
    const valid = await validateSKU('ISET-PC-20240101-0001');
    expect(valid).toBe(false);
  });

  test('returns true when SKU belongs to the excluded product (update scenario)', async () => {
    db.query.mockResolvedValueOnce({ rows: [] }); // AND id != excludeId → no rows
    const valid = await validateSKU('ISET-PC-20240101-0001', 'p-001');
    expect(valid).toBe(true);
  });

  test('passes excludeId as second SQL parameter', async () => {
    db.query.mockResolvedValueOnce({ rows: [] });
    await validateSKU('ISET-PC-20240101-0001', 'p-001');
    const [, params] = db.query.mock.calls[0];
    expect(params).toEqual(['ISET-PC-20240101-0001', 'p-001']);
  });

  test('does not include excludeId when not provided', async () => {
    db.query.mockResolvedValueOnce({ rows: [] });
    await validateSKU('ISET-PC-20240101-0001');
    const [, params] = db.query.mock.calls[0];
    expect(params).toEqual(['ISET-PC-20240101-0001']);
  });
});
