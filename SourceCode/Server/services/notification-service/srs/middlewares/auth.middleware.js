const jwt = require("jsonwebtoken");

// Middleware xác thực JWT token
const authenticateToken = (req, res, next) => {
  try {
    const authHeader = req.headers["authorization"];
    const token = authHeader && authHeader.split(" ")[1]; // Bearer TOKEN

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
    console.error("Authentication error:", error);
    res.status(500).json({
      success: false,
      message: "Authentication failed",
    });
  }
};

// Middleware xác thực Internal API (giữa các services)
const authenticateInternal = (req, res, next) => {
  try {
    const apiKey = req.headers["x-api-key"];
    const internalKey = process.env.INTERNAL_API_KEY || "internal-secret-key";

    if (apiKey !== internalKey) {
      return res.status(403).json({
        success: false,
        message: "Invalid API key",
      });
    }

    next();
  } catch (error) {
    console.error("Internal authentication error:", error);
    res.status(500).json({
      success: false,
      message: "Authentication failed",
    });
  }
};

module.exports = {
  authenticateToken,
  authenticateInternal,
};
