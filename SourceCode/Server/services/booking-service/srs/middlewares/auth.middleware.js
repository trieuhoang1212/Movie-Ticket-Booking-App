const axios = require("axios");

/**
 * Middleware xác thực JWT Token
 * Gọi sang Auth Service để verify token
 */
const authenticateToken = async (req, res, next) => {
  try {
    const authHeader = req.headers["authorization"];
    const token = authHeader && authHeader.split(" ")[1];

    if (!token) {
      return res.status(401).json({
        success: false,
        message: "Access token is required",
      });
    }

    // Gọi sang Auth Service để verify token
    const authServiceUrl =
      process.env.AUTH_SERVICE_URL || "http://auth-service:3001";
    const response = await axios.post(
      `${authServiceUrl}/api/auth/verify`,
      {},
      {
        headers: { Authorization: `Bearer ${token}` },
      }
    );

    if (response.data.success) {
      req.user = response.data.data.user;
      next();
    } else {
      return res.status(401).json({
        success: false,
        message: "Invalid token",
      });
    }
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: "Invalid or expired token",
    });
  }
};

module.exports = { authenticateToken };
