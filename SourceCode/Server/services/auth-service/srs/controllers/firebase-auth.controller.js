const User = require("../repositories/user.model");
const { admin } = require("../config/firebase");

/**
 * Gửi push notification login
 */
async function sendLoginNotification(userId, userName, fcmToken) {
  try {
    if (!fcmToken) return;

    const message = {
      token: fcmToken,
      notification: {
        title: "👋 Chào mừng trở lại!",
        body: `Xin chào ${userName}, bạn đã đăng nhập thành công.`,
      },
      data: {
        type: "LOGIN_SUCCESS",
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
    };

    await admin.messaging().send(message);
    console.log("✅ Login notification sent");
  } catch (error) {
    console.error("⚠️ Failed to send login notification:", error.message);
  }
}

/**
 * Xác thực/Tạo user từ Firebase Auth
 * Endpoint này được gọi sau khi user đăng nhập thành công với Firebase
 */
exports.firebaseAuth = async (req, res) => {
  try {
    // Lấy Firebase ID token từ header
    const authHeader = req.headers["authorization"];
    const token = authHeader && authHeader.split(" ")[1];

    if (!token) {
      return res.status(401).json({
        success: false,
        message: "Access token is required",
      });
    }

    // Verify Firebase token
    const decodedToken = await admin.auth().verifyIdToken(token);
    console.log("📱 Firebase Auth - Token verified for:", decodedToken.email);

    // Tìm hoặc tạo user trong database
    let user = await User.findOne({ email: decodedToken.email });

    if (!user) {
      // Tạo user mới nếu chưa tồn tại
      console.log("📝 Creating new user:", decodedToken.email);
      user = new User({
        name: decodedToken.name || decodedToken.email.split("@")[0],
        email: decodedToken.email,
        password: "FIREBASE_USER_" + Math.random().toString(36), // Password ngẫu nhiên (không dùng)
        role: "user",
      });
      await user.save();
      console.log("✅ User created successfully");
    } else {
      console.log("✅ User already exists:", user.email);
    }

    // Gửi notification đăng nhập (nếu có FCM token)
    if (user.fcmToken) {
      await sendLoginNotification(user._id, user.name, user.fcmToken);
    }

    // Trả về thông tin user
    res.status(200).json({
      success: true,
      message: "Firebase authentication successful",
      data: {
        user: {
          id: user._id,
          name: user.name,
          email: user.email,
          role: user.role,
        },
      },
    });
  } catch (error) {
    console.error("❌ Firebase auth error:", error.message);
    res.status(500).json({
      success: false,
      message: "Authentication failed",
      error: error.message,
    });
  }
};
