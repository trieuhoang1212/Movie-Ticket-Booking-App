const User = require("../repositories/user.model");

// Lưu FCM token
exports.saveFCMToken = async (req, res) => {
  try {
    console.log("📱 Received FCM token save request");
    console.log("User:", req.user);
    console.log("Body:", req.body);

    const userId = req.user.id; // Lấy từ JWT middleware
    const { fcmToken } = req.body;

    if (!fcmToken) {
      console.log("❌ FCM token is missing");
      return res.status(400).json({
        success: false,
        message: "FCM token is required",
      });
    }

    console.log(`💾 Saving FCM token for user ${userId}`);

    // Cập nhật FCM token cho user
    await User.findByIdAndUpdate(userId, { fcmToken });

    console.log("✅ FCM token saved successfully");

    res.status(200).json({
      success: true,
      message: "FCM token saved successfully",
    });
  } catch (error) {
    console.error("❌ Error saving FCM token:", error);
    res.status(500).json({
      success: false,
      message: "Server error",
      error: error.message,
    });
  }
};

// Xóa FCM token (khi logout)
exports.deleteFCMToken = async (req, res) => {
  try {
    const userId = req.user.id;

    await User.findByIdAndUpdate(userId, { fcmToken: null });

    res.status(200).json({
      success: true,
      message: "FCM token deleted successfully",
    });
  } catch (error) {
    console.error("Error deleting FCM token:", error);
    res.status(500).json({
      success: false,
      message: "Server error",
      error: error.message,
    });
  }
};

// Lấy FCM token của user (để gửi notification)
exports.getFCMToken = async (userId) => {
  try {
    const user = await User.findById(userId).select("fcmToken");
    return user?.fcmToken || null;
  } catch (error) {
    console.error("Error getting FCM token:", error);
    return null;
  }
};
