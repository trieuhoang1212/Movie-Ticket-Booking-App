const { admin } = require("../config/firebase");
const axios = require("axios");

/**
 * Service gửi FCM push notifications
 */
class FCMService {
  /**
   * Lấy FCM token của user từ auth-service
   */
  async getUserFCMToken(userId) {
    try {
      const response = await axios.get(
        `http://auth-service:3001/users/${userId}/fcm-token`
      );
      return response.data.data?.fcmToken || null;
    } catch (error) {
      console.error("❌ Error getting FCM token:", error.message);
      return null;
    }
  }

  /**
   * Gửi push notification tới user
   */
  async sendNotificationToUser(userId, title, body, data = {}) {
    try {
      // Lấy FCM token từ auth-service
      const fcmToken = await this.getUserFCMToken(userId);

      if (!fcmToken) {
        console.log(`⚠️ No FCM token found for user ${userId}`);
        return { success: false, reason: "No FCM token" };
      }

      // Tạo message
      const message = {
        token: fcmToken,
        notification: {
          title,
          body,
        },
        data: {
          ...data,
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
        android: {
          priority: "high",
          notification: {
            sound: "default",
            channelId: "booking_notifications",
          },
        },
      };

      // Gửi qua Firebase Admin SDK
      const response = await admin.messaging().send(message);

      console.log(`✅ Notification sent to user ${userId}:`, response);
      return { success: true, messageId: response };
    } catch (error) {
      console.error("❌ Error sending FCM notification:", error.message);

      // Nếu token không hợp lệ, có thể xóa khỏi database
      if (
        error.code === "messaging/invalid-registration-token" ||
        error.code === "messaging/registration-token-not-registered"
      ) {
        console.log(`🗑️ Invalid token for user ${userId}, should clean up`);
        // TODO: Call auth-service to delete invalid token
      }

      return { success: false, error: error.message };
    }
  }

  /**
   * Gửi notification khi booking bị xóa
   */
  async sendBookingDeletedNotification(userId, bookingData) {
    const { movieTitle, bookingCode, showtimeDate } = bookingData;

    return this.sendNotificationToUser(
      userId,
      "🗑️ Vé đã bị xóa",
      `Vé "${movieTitle}" (${bookingCode}) đã bị xóa khỏi danh sách.`,
      {
        type: "BOOKING_DELETED",
        bookingCode,
        movieTitle,
        showtimeDate: showtimeDate?.toString() || "",
      }
    );
  }

  /**
   * Gửi notification khi booking được tạo
   */
  async sendBookingCreatedNotification(userId, bookingData) {
    const { movieTitle, bookingCode, seats, totalAmount } = bookingData;

    return this.sendNotificationToUser(
      userId,
      "✅ Đặt vé thành công!",
      `Bạn đã đặt ${
        seats.length
      } ghế xem "${movieTitle}". Tổng: ${totalAmount.toLocaleString()}đ`,
      {
        type: "BOOKING_CREATED",
        bookingCode,
        movieTitle,
        totalAmount: totalAmount.toString(),
      }
    );
  }

  /**
   * Gửi notification khi login thành công
   */
  async sendLoginNotification(userId, userName) {
    return this.sendNotificationToUser(
      userId,
      "👋 Chào mừng trở lại!",
      `Xin chào ${userName}, bạn đã đăng nhập thành công.`,
      {
        type: "LOGIN_SUCCESS",
      }
    );
  }
}

module.exports = new FCMService();
