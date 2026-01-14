const jwt = require("jsonwebtoken");
const User = require("../repositories/user.model");
const { admin } = require("../config/firebase");

/**
 * Middleware xác thực Firebase ID Token
 * Dùng để verify Firebase token từ client
 */
const authenticateFirebaseToken = async (req, res, next) => {
  try {
    // Lấy token từ header Authorization: Bearer <token>
    const authHeader = req.headers["authorization"];
    const token = authHeader && authHeader.split(" ")[1];

    if (!token) {
      return res.status(401).json({
        success: false,
        message: "Access token is required",
      });
    }

    // Verify Firebase ID token
    const decodedToken = await admin.auth().verifyIdToken(token);
    console.log("📱 Firebase token verified for:", decodedToken.email);

    // Tìm user từ email (Firebase token chứa email của user)
    const user = await User.findOne({ email: decodedToken.email }).select(
      "-password"
    );
    if (!user) {
      console.log("❌ User not found in database:", decodedToken.email);
      return res.status(401).json({
        success: false,
        message: "User not found",
      });
    }

    console.log("✅ User found:", user.email);
    // Gắn user vào request để dùng ở các controller
    req.user = user;
    req.firebaseUser = decodedToken;
    next();
  } catch (error) {
    console.error("❌ Firebase token verification error:", error.message);
    return res.status(401).json({
      success: false,
      message: "Invalid token",
    });
  }
};

/**
 * Middleware xác thực JWT Token
 * Dùng để protect các route cần đăng nhập
 */
const authenticateToken = async (req, res, next) => {
  try {
    // Lấy token từ header Authorization: Bearer <token>
    const authHeader = req.headers["authorization"];
    const token = authHeader && authHeader.split(" ")[1];

    if (!token) {
      return res.status(401).json({
        success: false,
        message: "Access token is required",
      });
    }

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Tìm user từ token
    const user = await User.findById(decoded.id).select("-password");
    if (!user) {
      return res.status(401).json({
        success: false,
        message: "User not found",
      });
    }

    // Gắn user vào request để dùng ở các controller
    req.user = user;
    next();
  } catch (error) {
    if (error.name === "JsonWebTokenError") {
      return res.status(401).json({
        success: false,
        message: "Invalid token",
      });
    }
    if (error.name === "TokenExpiredError") {
      return res.status(401).json({
        success: false,
        message: "Token expired",
      });
    }
    return res.status(500).json({
      success: false,
      message: "Server error",
      error: error.message,
    });
  }
};

/**
 * Middleware kiểm tra role
 * Dùng để phân quyền admin/user
 */
const authorizeRole = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: "Unauthorized",
      });
    }

    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: "You do not have permission to access this resource",
      });
    }

    next();
  };
};

module.exports = {
  authenticateToken,
  authenticateFirebaseToken,
  authorizeRole,
};
