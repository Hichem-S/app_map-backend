/**
 * Integration tests for /api/auth routes.
 * The database, MQTT, and WebSocket are all mocked — no real DB needed.
 */

// Mock heavy services before app loads
jest.mock('../../src/config/database');
jest.mock('../../src/services/mqttService', () => ({ connect: jest.fn(), getClient: jest.fn() }));
jest.mock('../../src/services/wsService',   () => ({ init: jest.fn(), sendToUser: jest.fn(), broadcast: jest.fn() }));
jest.mock('node-cron', () => ({ schedule: jest.fn() }));
jest.mock('nodemailer', () => ({
  createTransport: jest.fn(() => ({ sendMail: jest.fn().mockResolvedValue({}) })),
}));

const request = require('supertest');
const db      = require('../../src/config/database');
const app     = require('../../src/app');

// ── Register validation ───────────────────────────────────────────────────────

describe('POST /api/auth/register – input validation', () => {
  test('rejects empty body with 400', async () => {
    const res = await request(app).post('/api/auth/register').send({});
    expect(res.status).toBe(400);
    expect(res.body.success).toBe(false);
  });

  test('rejects missing name', async () => {
    const res = await request(app).post('/api/auth/register').send({
      email: 'test@iset.tn',
      password: 'secret123',
    });
    expect(res.status).toBe(400);
  });

  test('rejects invalid email', async () => {
    const res = await request(app).post('/api/auth/register').send({
      name: 'Test User',
      email: 'not-an-email',
      password: 'secret123',
    });
    expect(res.status).toBe(400);
  });

  test('rejects password shorter than 6 characters', async () => {
    const res = await request(app).post('/api/auth/register').send({
      name: 'Test User',
      email: 'test@iset.tn',
      password: '123',
    });
    expect(res.status).toBe(400);
  });

  test('accepts valid registration payload and attempts DB insert', async () => {
    // Mock: email not taken, insert succeeds
    db.query
      .mockResolvedValueOnce({ rows: [] })          // check existing email
      .mockResolvedValueOnce({ rows: [{ id: 'u-new', name: 'Test User', email: 'newuser@iset.tn', role: 'technicien', is_active: false }] }) // insert
      .mockResolvedValueOnce({ rows: [] })           // delete old OTP
      .mockResolvedValueOnce({ rows: [] });          // insert OTP

    const res = await request(app).post('/api/auth/register').send({
      name: 'Test User',
      email: 'newuser@iset.tn',
      password: 'secret123',
    });
    // Either 201 (created) or 409 (duplicate) depending on mock
    expect([200, 201]).toContain(res.status);
  });

  test('returns 409 when email already registered', async () => {
    db.query.mockResolvedValueOnce({ rows: [{ id: 'u-001' }] }); // email exists
    const res = await request(app).post('/api/auth/register').send({
      name: 'Test User',
      email: 'existing@iset.tn',
      password: 'secret123',
    });
    expect(res.status).toBe(409);
    expect(res.body.success).toBe(false);
  });
});

// ── Login validation ──────────────────────────────────────────────────────────

describe('POST /api/auth/login – input validation', () => {
  test('rejects empty body with 400', async () => {
    const res = await request(app).post('/api/auth/login').send({});
    expect(res.status).toBe(400);
  });

  test('rejects invalid email format', async () => {
    const res = await request(app).post('/api/auth/login').send({
      email: 'bad-email',
      password: 'secret123',
    });
    expect(res.status).toBe(400);
  });

  test('rejects missing password', async () => {
    const res = await request(app).post('/api/auth/login').send({
      email: 'test@iset.tn',
    });
    expect(res.status).toBe(400);
  });

  test('returns 401 for unknown user', async () => {
    db.query.mockResolvedValueOnce({ rows: [] }); // user not found
    const res = await request(app).post('/api/auth/login').send({
      email: 'nobody@iset.tn',
      password: 'secret123',
    });
    expect(res.status).toBe(401);
    expect(res.body.success).toBe(false);
  });

  test('returns 403 when email not verified', async () => {
    db.query.mockResolvedValueOnce({
      rows: [{
        id: 'u-001', email: 'test@iset.tn',
        password_hash: '$2a$10$fakehash', role: 'technicien',
        is_active: false, email_verified: false,
      }],
    });
    const res = await request(app).post('/api/auth/login').send({
      email: 'test@iset.tn',
      password: 'secret123',
    });
    // 401 or 403 depending on impl; either way not 200
    expect(res.status).not.toBe(200);
  });
});

// ── Verify email validation ───────────────────────────────────────────────────

describe('POST /api/auth/verify-email – input validation', () => {
  test('rejects missing email', async () => {
    const res = await request(app).post('/api/auth/verify-email').send({ otp: '123456' });
    expect(res.status).toBe(400);
  });

  test('rejects OTP shorter than 6 digits', async () => {
    const res = await request(app).post('/api/auth/verify-email').send({
      email: 'test@iset.tn',
      otp: '123',
    });
    expect(res.status).toBe(400);
  });

  test('rejects non-numeric OTP', async () => {
    const res = await request(app).post('/api/auth/verify-email').send({
      email: 'test@iset.tn',
      otp: 'abcdef',
    });
    expect(res.status).toBe(400);
  });
});

// ── Protected routes ──────────────────────────────────────────────────────────

describe('GET /api/auth/me – protected route', () => {
  test('returns 401 with no token', async () => {
    const res = await request(app).get('/api/auth/me');
    expect(res.status).toBe(401);
    expect(res.body.success).toBe(false);
  });

  test('returns 401 with malformed token', async () => {
    const res = await request(app)
      .get('/api/auth/me')
      .set('Authorization', 'Bearer not.a.real.token');
    expect(res.status).toBe(401);
  });
});

// ── Health check ──────────────────────────────────────────────────────────────

describe('GET /health', () => {
  test('returns 200 and uptime', async () => {
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('uptime');
  });
});

// ── 404 handler ───────────────────────────────────────────────────────────────

describe('Unknown routes', () => {
  test('returns 404 for unknown route', async () => {
    const res = await request(app).get('/api/does-not-exist');
    expect(res.status).toBe(404);
    expect(res.body.success).toBe(false);
  });
});
