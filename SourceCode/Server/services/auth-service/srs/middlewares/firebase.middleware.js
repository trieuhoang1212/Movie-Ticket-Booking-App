const { admin } = require("../config/firebase");

/**
 * Middleware xác thực Firebase ID Token
 * Dùng khi frontend login bằng Firebase
 */
const verifyFirebaseToken = async (req, res, next) => {
  try {
    const authHeader = req.headers["authorization"];
    const token = authHeader && authHeader.split(" ")[1];

    if (!token) {
      return res.status(401).json({
        success: false,
        message: "Firebase token is required",
      });
    }

    // Verify Firebase ID Token
    const decodedToken = await admin.auth().verifyIdToken(token);

    // Gắn Firebase user vào request
    req.firebaseUser = {
      uid: decodedToken.uid,
      email: decodedToken.email,
      name: decodedToken.name,
      picture: decodedToken.picture,
    };

    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: "Invalid Firebase token",
      error: error.message,
    });
  }
};

module.exports = { verifyFirebaseToken };
