const admin = require("firebase-admin");

/**
 * Middleware xác thực Firebase ID Token
 * Verify token từ Firebase Authentication
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

    // Verify Firebase ID Token
    const decodedToken = await admin.auth().verifyIdToken(token);

    // Gắn user info vào request
    req.user = {
      id: decodedToken.uid,
      email: decodedToken.email,
      name: decodedToken.name || decodedToken.email,
    };

    next();
  } catch (error) {
    console.error("Token verification failed:", error.message);
    return res.status(401).json({
      success: false,
      message: "Invalid or expired token",
      error: error.message,
    });
  }
};

module.exports = { authenticateToken };
