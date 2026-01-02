const jwt = require("jsonwebtoken");

/**
 * Middleware xác thực JWT Token
 */
const authenticateToken = (req, res, next) => {
  try {
    const authHeader = req.headers["authorization"];
    const token = authHeader && authHeader.split(" ")[1];

    if (!token) {
      return res.status(401).json({
        success: false,
        message: "Access token is required",
      });
    }

    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
      if (err) {
        return res.status(403).json({
          success: false,
          message: "Invalid or expired token",
        });
      }

      req.user = user;
      next();
    });
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: "Authentication failed",
    });
  }
};

/**
 * Middleware kiểm tra internal API key
 */
const verifyInternalApiKey = (req, res, next) => {
  const apiKey = req.headers["x-api-key"];

  if (!apiKey || apiKey !== process.env.INTERNAL_API_KEY) {
    return res.status(403).json({
      success: false,
      message: "Forbidden: Invalid API key",
    });
  }

  next();
};

module.exports = { authenticateToken, verifyInternalApiKey };
