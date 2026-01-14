const axios = require("axios");
const mongoose = require("mongoose");

/**
 * Middleware xác thực - Development Mode
 * Tạo hoặc sử dụng user test có ObjectId hợp lệ
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

    // DEVELOPMENT MODE: Sử dụng ObjectId hợp lệ cho test user
    console.log("⚠️  Development mode: Using test user with valid ObjectId");

    // Tạo một ObjectId cố định cho dev user (luôn giống nhau mỗi lần)
    const devUserId = "507f1f77bcf86cd799439011"; // Valid MongoDB ObjectId

    req.user = {
      id: devUserId,
      email: "dev@example.com",
      name: "Dev User",
    };
    return next();

    /* PRODUCTION MODE: Uncomment code này khi deploy
    try {
      // Verify token với auth-service
      const response = await axios.post(
        `${process.env.AUTH_SERVICE_URL}/api/auth/verify`,
        {},
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );

      if (response.data.success) {
        req.user = {
          id: response.data.data.user._id,
          email: response.data.data.user.email,
          name: response.data.data.user.name,
        };
        return next();
      } else {
        return res.status(401).json({
          success: false,
          message: "Invalid token",
        });
      }
    } catch (error) {
      return res.status(401).json({
        success: false,
        message: "Token verification failed",
      });
    }
    */
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: "Invalid or expired token",
    });
  }
};

module.exports = { authenticateToken };
