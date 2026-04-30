const errorHandler = (err, req, res, next) => {
  console.error(`[ERROR] ${err.message}`, err.stack);

  // Validation errors
  if (err.name === "ValidationError") {
    return res.status(400).json({ success: false, message: err.message });
  }

  // PostgreSQL unique violation
  if (err.code === "23505") {
    return res.status(409).json({ success: false, message: "Resource already exists" });
  }

  // PostgreSQL foreign key violation
  if (err.code === "23503") {
    return res.status(400).json({ success: false, message: "Referenced resource not found" });
  }

  const status = err.status || err.statusCode || 500;
  const message = status === 500 ? "Internal server error" : err.message;

  res.status(status).json({ success: false, message });
};

const notFound = (req, res) => {
  res.status(404).json({ success: false, message: `Route ${req.originalUrl} not found` });
};

module.exports = { errorHandler, notFound };
