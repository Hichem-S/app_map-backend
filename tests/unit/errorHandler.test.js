const { errorHandler, notFound } = require('../../src/middleware/errorHandler');

// helpers to build mock req/res/next
const mockReq = (url = '/api/test') => ({ originalUrl: url });
const mockRes = () => {
  const res = {};
  res.status = jest.fn().mockReturnValue(res);
  res.json   = jest.fn().mockReturnValue(res);
  return res;
};
const mockNext = jest.fn();

describe('errorHandler middleware', () => {
  test('returns 400 for ValidationError', () => {
    const err = Object.assign(new Error('Name is required'), { name: 'ValidationError' });
    const res = mockRes();
    errorHandler(err, mockReq(), res, mockNext);
    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith({ success: false, message: 'Name is required' });
  });

  test('returns 409 for PostgreSQL unique violation (code 23505)', () => {
    const err = Object.assign(new Error('duplicate key'), { code: '23505' });
    const res = mockRes();
    errorHandler(err, mockReq(), res, mockNext);
    expect(res.status).toHaveBeenCalledWith(409);
    expect(res.json).toHaveBeenCalledWith({ success: false, message: 'Resource already exists' });
  });

  test('returns 400 for PostgreSQL foreign key violation (code 23503)', () => {
    const err = Object.assign(new Error('fk violation'), { code: '23503' });
    const res = mockRes();
    errorHandler(err, mockReq(), res, mockNext);
    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith({ success: false, message: 'Referenced resource not found' });
  });

  test('uses err.status when set', () => {
    const err = Object.assign(new Error('Not found'), { status: 404 });
    const res = mockRes();
    errorHandler(err, mockReq(), res, mockNext);
    expect(res.status).toHaveBeenCalledWith(404);
    expect(res.json).toHaveBeenCalledWith({ success: false, message: 'Not found' });
  });

  test('uses err.statusCode when set', () => {
    const err = Object.assign(new Error('Bad request'), { statusCode: 400 });
    const res = mockRes();
    errorHandler(err, mockReq(), res, mockNext);
    expect(res.status).toHaveBeenCalledWith(400);
  });

  test('returns 500 with generic message for unhandled errors', () => {
    const err = new Error('DB crashed');
    const res = mockRes();
    errorHandler(err, mockReq(), res, mockNext);
    expect(res.status).toHaveBeenCalledWith(500);
    expect(res.json).toHaveBeenCalledWith({ success: false, message: 'Internal server error' });
  });

  test('does not leak internal error message on 500', () => {
    const err = new Error('secret db password in error');
    const res = mockRes();
    errorHandler(err, mockReq(), res, mockNext);
    const body = res.json.mock.calls[0][0];
    expect(body.message).not.toContain('secret db password');
  });

  test('ValidationError takes priority over generic handler', () => {
    const err = Object.assign(new Error('invalid'), { name: 'ValidationError', status: 500 });
    const res = mockRes();
    errorHandler(err, mockReq(), res, mockNext);
    expect(res.status).toHaveBeenCalledWith(400);
  });
});

describe('notFound middleware', () => {
  test('returns 404 with route info', () => {
    const res = mockRes();
    notFound(mockReq('/api/unknown'), res);
    expect(res.status).toHaveBeenCalledWith(404);
    expect(res.json).toHaveBeenCalledWith({
      success: false,
      message: 'Route /api/unknown not found',
    });
  });

  test('includes the original URL in the message', () => {
    const res = mockRes();
    notFound(mockReq('/api/foo/bar'), res);
    const body = res.json.mock.calls[0][0];
    expect(body.message).toContain('/api/foo/bar');
  });

  test('success is false', () => {
    const res = mockRes();
    notFound(mockReq('/x'), res);
    expect(res.json.mock.calls[0][0].success).toBe(false);
  });
});
