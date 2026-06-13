// Mock dependencies before requiring the module
jest.mock('jsonwebtoken');
jest.mock('../../src/config/database');

const jwt    = require('jsonwebtoken');
const db     = require('../../src/config/database');
const { authenticate, authorize } = require('../../src/middleware/auth');

const mockRes = () => {
  const res = {};
  res.status = jest.fn().mockReturnValue(res);
  res.json   = jest.fn().mockReturnValue(res);
  return res;
};
const mockNext = jest.fn();

const ACTIVE_USER = { id: 'u-001', name: 'Test', email: 't@t.tn', role: 'admin', is_active: true };

// ── authenticate ─────────────────────────────────────────────────────────────

describe('authenticate middleware', () => {
  test('rejects request with no Authorization header', async () => {
    const req = { headers: {} };
    const res = mockRes();
    await authenticate(req, res, mockNext);
    expect(res.status).toHaveBeenCalledWith(401);
    expect(res.json).toHaveBeenCalledWith({ success: false, message: 'No token provided' });
    expect(mockNext).not.toHaveBeenCalled();
  });

  test('rejects header that does not start with Bearer', async () => {
    const req = { headers: { authorization: 'Basic abc123' } };
    const res = mockRes();
    await authenticate(req, res, mockNext);
    expect(res.status).toHaveBeenCalledWith(401);
    expect(mockNext).not.toHaveBeenCalled();
  });

  test('rejects expired token', async () => {
    jwt.verify.mockImplementation(() => { throw Object.assign(new Error('expired'), { name: 'TokenExpiredError' }); });
    const req = { headers: { authorization: 'Bearer expired.token' } };
    const res = mockRes();
    await authenticate(req, res, mockNext);
    expect(res.status).toHaveBeenCalledWith(401);
    expect(res.json).toHaveBeenCalledWith({ success: false, message: 'Token expired' });
  });

  test('rejects invalid (tampered) token', async () => {
    jwt.verify.mockImplementation(() => { throw new Error('invalid signature'); });
    const req = { headers: { authorization: 'Bearer bad.token' } };
    const res = mockRes();
    await authenticate(req, res, mockNext);
    expect(res.status).toHaveBeenCalledWith(401);
    expect(res.json).toHaveBeenCalledWith({ success: false, message: 'Invalid token' });
  });

  test('rejects token for non-existent user', async () => {
    jwt.verify.mockReturnValue({ id: 'u-999' });
    db.query.mockResolvedValue({ rows: [] });
    const req = { headers: { authorization: 'Bearer valid.token' } };
    const res = mockRes();
    await authenticate(req, res, mockNext);
    expect(res.status).toHaveBeenCalledWith(401);
    expect(res.json).toHaveBeenCalledWith({ success: false, message: 'User not found or inactive' });
  });

  test('rejects token for inactive user', async () => {
    jwt.verify.mockReturnValue({ id: 'u-001' });
    db.query.mockResolvedValue({ rows: [{ ...ACTIVE_USER, is_active: false }] });
    const req = { headers: { authorization: 'Bearer valid.token' } };
    const res = mockRes();
    await authenticate(req, res, mockNext);
    expect(res.status).toHaveBeenCalledWith(401);
    expect(res.json).toHaveBeenCalledWith({ success: false, message: 'User not found or inactive' });
  });

  test('accepts valid token for active user and calls next()', async () => {
    jwt.verify.mockReturnValue({ id: 'u-001' });
    db.query.mockResolvedValue({ rows: [ACTIVE_USER] });
    const req = { headers: { authorization: 'Bearer good.token' } };
    const res = mockRes();
    await authenticate(req, res, mockNext);
    expect(mockNext).toHaveBeenCalled();
    expect(req.user).toEqual(ACTIVE_USER);
    expect(res.status).not.toHaveBeenCalled();
  });

  test('attaches full user object to req.user', async () => {
    jwt.verify.mockReturnValue({ id: 'u-001' });
    db.query.mockResolvedValue({ rows: [ACTIVE_USER] });
    const req = { headers: { authorization: 'Bearer good.token' } };
    await authenticate(req, mockRes(), mockNext);
    expect(req.user.role).toBe('admin');
    expect(req.user.email).toBe('t@t.tn');
  });
});

// ── authorize ─────────────────────────────────────────────────────────────────

describe('authorize middleware', () => {
  const makeReq = (role) => ({ user: { role } });

  test('calls next() when role is in allowed list', () => {
    const middleware = authorize('admin', 'technicien');
    const res = mockRes();
    middleware(makeReq('admin'), res, mockNext);
    expect(mockNext).toHaveBeenCalled();
    expect(res.status).not.toHaveBeenCalled();
  });

  test('calls next() for second role in allowed list', () => {
    const middleware = authorize('admin', 'technicien');
    middleware(makeReq('technicien'), mockRes(), mockNext);
    expect(mockNext).toHaveBeenCalled();
  });

  test('returns 403 when role is not allowed', () => {
    const middleware = authorize('admin');
    const res = mockRes();
    middleware(makeReq('magazinier'), res, mockNext);
    expect(res.status).toHaveBeenCalledWith(403);
    expect(res.json).toHaveBeenCalledWith({ success: false, message: 'Access denied' });
    expect(mockNext).not.toHaveBeenCalled();
  });

  test('returns 403 for technicien on admin-only route', () => {
    const middleware = authorize('admin');
    const res = mockRes();
    middleware(makeReq('technicien'), res, mockNext);
    expect(res.status).toHaveBeenCalledWith(403);
  });

  test('returns 403 for magazinier on map route (admin+tech only)', () => {
    const middleware = authorize('admin', 'technicien');
    const res = mockRes();
    middleware(makeReq('magazinier'), res, mockNext);
    expect(res.status).toHaveBeenCalledWith(403);
  });

  test('returns 403 when no roles are specified', () => {
    const middleware = authorize();
    const res = mockRes();
    middleware(makeReq('admin'), res, mockNext);
    expect(res.status).toHaveBeenCalledWith(403);
  });

  test('allows single role list with that role', () => {
    const middleware = authorize('magazinier');
    middleware(makeReq('magazinier'), mockRes(), mockNext);
    expect(mockNext).toHaveBeenCalled();
  });
});
