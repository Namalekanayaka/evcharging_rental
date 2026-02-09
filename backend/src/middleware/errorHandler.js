export const errorHandler = (err, req, res, next) => {
  err.statusCode = err.statusCode || 500;
  err.message = err.message || "Internal Server Error";

  // Wrong MongoDB ID error
  if (err.name === "CastError") {
    const message = `Resource not found. Invalid: ${err.path}`;
    err.statusCode = 400;
    err.message = message;
  }

  // JWT error
  if (err.name === "JsonWebTokenError") {
    const message = "JSON Web Token is invalid, try again";
    err.statusCode = 400;
    err.message = message;
  }

  // JWT expired error
  if (err.name === "TokenExpiredError") {
    const message = "JSON Web Token is expired, try again";
    err.statusCode = 400;
    err.message = message;
  }

  // Duplicate key error
  if (err.code === 23505) {
    const message = "Duplicate field value entered";
    err.statusCode = 400;
    err.message = message;
  }

  res.status(err.statusCode).json({
    success: false,
    error: {
      statusCode: err.statusCode,
      message: err.message,
      ...(process.env.NODE_ENV === "development" && { stack: err.stack }),
    },
  });
};

export default errorHandler;
