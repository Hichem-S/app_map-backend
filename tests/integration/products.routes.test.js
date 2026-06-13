/**
 * Integration tests for /api/products routes.
 * DB, MQTT, WebSocket all mocked.
 */

jest.mock('../../src/config/database');
jest.mock('../../src/services/mqttService', () => ({ connect: jest.fn(), getClient: jest.fn() }));
jest.mock('../../src/services/wsService',   () => ({ init: jest.fn(), sendToUser: jest.fn(), broadcast: jest.fn() }));
jest.mock('node-cron', () => ({ schedule: jest.fn() }));
jest.mock('nodemailer', () => ({
  createTransport: jest.fn(() => ({ sendMail: jest.fn().mockResolvedValue({}) })),
}));

const request = require('supertest');
const jwt     = require('jsonwebtoken');
const db      = require('../../src/config/database');
const app     = require('../../src/app');

// Helper: generate a real JWT for testing
const makeToken = (role = 'admin') => {
  process.env.JWT_SECRET = 'test-secret';
  return jwt.sign({ id: 'u-001' }, 'test-secret', { expiresIn: '1h' });
};

const ACTIVE_USER = {
  id: 'u-001', name: 'Admin', email: 'admin@iset.tn',
  role: 'admin', avatar: null, is_active: true,
};

const mockAuth = () => {
  db.query.mockResolvedValueOnce({ rows: [ACTIVE_USER] }); // authenticate lookup
};

// ── GET /api/products/scan (public) ──────────────────────────────────────────

describe('GET /api/products/scan – public endpoint', () => {
  test('returns 400 when no id provided', async () => {
    const res = await request(app).get('/api/products/scan');
    expect([400, 404]).toContain(res.status);
  });

  test('returns 404 when product not found', async () => {
    db.query.mockResolvedValueOnce({ rows: [] });
    const res = await request(app).get('/api/products/scan?id=00000000-0000-0000-0000-000000000000');
    expect(res.status).toBe(404);
    expect(res.body.success).toBe(false);
  });

  test('returns product data when found', async () => {
    const uuid = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';
    db.query.mockResolvedValueOnce({
      rows: [{
        id: uuid, name: 'Dell Laptop', sku: 'ISET-PC-20240101-0001',
        status: 'in_stock', quantity: 5,
      }],
    });
    const res = await request(app).get(`/api/products/scan?id=${uuid}`);
    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.name).toBe('Dell Laptop');
  });
});

// ── GET /api/products (requires auth) ────────────────────────────────────────

describe('GET /api/products – requires auth', () => {
  test('returns 401 with no token', async () => {
    const res = await request(app).get('/api/products');
    expect(res.status).toBe(401);
  });

  test('returns 401 with invalid token', async () => {
    const res = await request(app)
      .get('/api/products')
      .set('Authorization', 'Bearer fake.token.here');
    expect(res.status).toBe(401);
  });

  test('returns 200 with valid token and empty products list', async () => {
    process.env.JWT_SECRET = 'test-secret';
    mockAuth();
    db.query
      .mockResolvedValueOnce({ rows: [{ count: '0' }] })   // COUNT query
      .mockResolvedValueOnce({ rows: [] });                  // SELECT query

    const res = await request(app)
      .get('/api/products')
      .set('Authorization', `Bearer ${makeToken()}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(Array.isArray(res.body.data)).toBe(true);
  });

  test('returns paginated meta', async () => {
    process.env.JWT_SECRET = 'test-secret';
    mockAuth();
    db.query
      .mockResolvedValueOnce({ rows: [{ count: '42' }] })
      .mockResolvedValueOnce({ rows: [] });

    const res = await request(app)
      .get('/api/products?page=2&limit=10')
      .set('Authorization', `Bearer ${makeToken()}`);

    expect(res.status).toBe(200);
    expect(res.body.meta).toMatchObject({ total: 42, page: 2, limit: 10, pages: 5 });
  });

  test('returns products list with data', async () => {
    process.env.JWT_SECRET = 'test-secret';
    mockAuth();
    const products = [
      { id: 'p-001', name: 'Dell Laptop', status: 'in_stock' },
      { id: 'p-002', name: 'HP Printer',  status: 'in_stock' },
    ];
    db.query
      .mockResolvedValueOnce({ rows: [{ count: '2' }] })
      .mockResolvedValueOnce({ rows: products });

    const res = await request(app)
      .get('/api/products')
      .set('Authorization', `Bearer ${makeToken()}`);

    expect(res.body.data).toHaveLength(2);
    expect(res.body.data[0].name).toBe('Dell Laptop');
  });
});

// ── GET /api/products/categories ─────────────────────────────────────────────

describe('GET /api/products/categories', () => {
  test('returns 401 without auth', async () => {
    const res = await request(app).get('/api/products/categories');
    expect(res.status).toBe(401);
  });

  test('returns categories list with valid token', async () => {
    process.env.JWT_SECRET = 'test-secret';
    mockAuth();
    db.query.mockResolvedValueOnce({
      rows: [
        { id: 'c-001', name: 'Computer' },
        { id: 'c-002', name: 'Printer/Scanner' },
      ],
    });

    const res = await request(app)
      .get('/api/products/categories')
      .set('Authorization', `Bearer ${makeToken()}`);

    expect(res.status).toBe(200);
    expect(res.body.data.length).toBeGreaterThan(0);
  });
});

// ── GET /api/products/stats ───────────────────────────────────────────────────

describe('GET /api/products/stats', () => {
  test('returns 401 without auth', async () => {
    const res = await request(app).get('/api/products/stats');
    expect(res.status).toBe(401);
  });

  test('returns stats object with valid token', async () => {
    process.env.JWT_SECRET = 'test-secret';
    mockAuth();
    db.query
      .mockResolvedValueOnce({ rows: [{ total: '50', total_value: '25000' }] })  // totals
      .mockResolvedValueOnce({ rows: [{ status: 'in_stock', count: '40' }] })    // by status
      .mockResolvedValueOnce({ rows: [{ name: 'Computer', count: '20' }] });     // by category

    const res = await request(app)
      .get('/api/products/stats')
      .set('Authorization', `Bearer ${makeToken()}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
  });
});

// ── GET /api/products/:id ─────────────────────────────────────────────────────

describe('GET /api/products/:id', () => {
  test('returns 401 without auth', async () => {
    const res = await request(app).get('/api/products/p-001');
    expect(res.status).toBe(401);
  });

  test('returns 404 for non-existent product', async () => {
    process.env.JWT_SECRET = 'test-secret';
    mockAuth();
    db.query.mockResolvedValueOnce({ rows: [] });

    const res = await request(app)
      .get('/api/products/nonexistent-id')
      .set('Authorization', `Bearer ${makeToken()}`);

    expect(res.status).toBe(404);
  });

  test('returns product when found', async () => {
    process.env.JWT_SECRET = 'test-secret';
    mockAuth();
    db.query.mockResolvedValueOnce({
      rows: [{ id: 'p-001', name: 'Dell Laptop', sku: 'ISET-PC-20240101-0001', status: 'in_stock' }],
    });

    const res = await request(app)
      .get('/api/products/p-001')
      .set('Authorization', `Bearer ${makeToken()}`);

    expect(res.status).toBe(200);
    expect(res.body.data.name).toBe('Dell Laptop');
  });
});

// ── GET /api/products/warranty-alerts ────────────────────────────────────────

describe('GET /api/products/warranty-alerts', () => {
  test('returns 401 without auth', async () => {
    const res = await request(app).get('/api/products/warranty-alerts');
    expect(res.status).toBe(401);
  });

  test('returns list with valid token', async () => {
    process.env.JWT_SECRET = 'test-secret';
    mockAuth();
    db.query.mockResolvedValueOnce({ rows: [] });

    const res = await request(app)
      .get('/api/products/warranty-alerts')
      .set('Authorization', `Bearer ${makeToken()}`);

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
  });
});
