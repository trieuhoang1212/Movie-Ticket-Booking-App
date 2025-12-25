const Notification = require("../repositories/Notification.model");
const UserDevice = require("../repositories/userdevice.model");
const { emitToUser, broadcastToAll } = require("../config/socket");
const { getMessaging } = require("../config/firebase");

class NotificationService {
  // ========== PHIM MỚI RA MẮT ==========
  async notifyNewMovieRelease(movieData) {
    try {
      const { movieId, movieTitle, releaseDate, imageUrl, description } =
        movieData;

      const notificationData = {
        type: "NEW_MOVIE",
        title: "Phim Mới Ra Mắt!",
        message: `"${movieTitle}" đã ra mắt hôm nay. Đặt vé ngay!`,
        data: {
          movieId,
          movieTitle,
          releaseDate,
          imageUrl,
          deepLink: `/movies/${movieId}`,
        },
      };

      // Broadcast tới tất cả users
      broadcastToAll("new_movie", notificationData);

      // Gửi push notification tới tất cả devices
      await this.sendPushToAllUsers(
        notificationData.title,
        notificationData.message,
        notificationData.data
      );

      console.log(`✅ Notified all users about new movie: ${movieTitle}`);
    } catch (error) {
      console.error("❌ Error notifying new movie:", error);
      throw error;
    }
  }

  // ========== ĐẶT VÉ THÀNH CÔNG ==========
  async notifyBookingConfirmed(bookingData) {
    try {
      const {
        userId,
        bookingId,
        movieTitle,
        showtime,
        seats,
        cinema,
        totalAmount,
      } = bookingData;

      const notification = await Notification.create({
        userId,
        type: "BOOKING_CONFIRM",
        title: "Đặt Vé Thành Công",
        message: `Bạn đã đặt vé xem "${movieTitle}" thành công!`,
        data: {
          bookingId,
          movieTitle,
          showtime,
          seats: seats.join(", "),
          cinema,
          deepLink: `/bookings/${bookingId}`,
        },
      });

      // Gửi real-time qua Socket.IO
      emitToUser(userId, "booking_confirmed", {
        id: notification._id,
        type: notification.type,
        title: notification.title,
        message: notification.message,
        data: notification.data,
        createdAt: notification.createdAt,
      });

      // Gửi push notification
      await this.sendPushToUser(
        userId,
        notification.title,
        notification.message,
        notification.data
      );

      console.log(`Booking notification sent to user ${userId}`);
      return notification;
    } catch (error) {
      console.error("❌ Error notifying booking:", error);
      throw error;
    }
  }

  // ========== THANH TOÁN THÀNH CÔNG ==========
  async notifyPaymentSuccess(paymentData) {
    try {
      const {
        userId,
        paymentId,
        bookingId,
        movieTitle,
        amount,
        paymentMethod,
      } = paymentData;

      const notification = await Notification.create({
        userId,
        type: "PAYMENT_SUCCESS",
        title: "Thanh Toán Thành Công",
        message: `Thanh toán ${amount.toLocaleString(
          "vi-VN"
        )}đ cho vé "${movieTitle}" thành công!`,
        data: {
          paymentId,
          bookingId,
          movieTitle,
          amount,
          paymentMethod,
          deepLink: `/payments/${paymentId}`,
        },
      });

      // Real-time notification
      emitToUser(userId, "payment_success", {
        id: notification._id,
        type: notification.type,
        title: notification.title,
        message: notification.message,
        data: notification.data,
        createdAt: notification.createdAt,
      });

      // Push notification
      await this.sendPushToUser(
        userId,
        notification.title,
        notification.message,
        notification.data
      );

      console.log(`Payment success notification sent to user ${userId}`);
      return notification;
    } catch (error) {
      console.error("Error notifying payment:", error);
      throw error;
    }
  }

  // ========== THANH TOÁN THẤT BẠI ==========
  async notifyPaymentFailed(paymentData) {
    try {
      const { userId, bookingId, movieTitle, amount, reason } = paymentData;

      const notification = await Notification.create({
        userId,
        type: "PAYMENT_FAILED",
        title: "❌ Thanh Toán Thất Bại",
        message: `Thanh toán cho vé "${movieTitle}" thất bại. ${
          reason || "Vui lòng thử lại!"
        }`,
        data: {
          bookingId,
          movieTitle,
          amount,
          reason,
          deepLink: `/bookings/${bookingId}`,
        },
      });

      emitToUser(userId, "payment_failed", {
        id: notification._id,
        type: notification.type,
        title: notification.title,
        message: notification.message,
        data: notification.data,
        createdAt: notification.createdAt,
      });

      await this.sendPushToUser(
        userId,
        notification.title,
        notification.message,
        notification.data
      );

      return notification;
    } catch (error) {
      console.error("Error notifying payment failed:", error);
      throw error;
    }
  }

  // ========== NHẮC NHỞ XEM PHIM ==========
  async notifyMovieReminder(reminderData) {
    try {
      const { userId, bookingId, movieTitle, showtime, cinema, seats } =
        reminderData;

      const notification = await Notification.create({
        userId,
        type: "MOVIE_REMINDER",
        title: "Nhắc Nhở Xem Phim",
        message: `Còn 2 giờ nữa đến giờ chiếu "${movieTitle}"!`,
        data: {
          bookingId,
          movieTitle,
          showtime,
          cinema,
          seats: seats.join(", "),
          deepLink: `/bookings/${bookingId}`,
        },
      });

      emitToUser(userId, "movie_reminder", {
        id: notification._id,
        type: notification.type,
        title: notification.title,
        message: notification.message,
        data: notification.data,
        createdAt: notification.createdAt,
      });

      await this.sendPushToUser(
        userId,
        notification.title,
        notification.message,
        notification.data
      );

      return notification;
    } catch (error) {
      console.error("Error sending movie reminder:", error);
      throw error;
    }
  }

  // ========== GỬI PUSH NOTIFICATION CHO 1 USER ==========
  async sendPushToUser(userId, title, message, data = {}) {
    try {
      // Lấy tất cả devices active của user
      const devices = await UserDevice.find({ userId, isActive: true });

      if (devices.length === 0) {
        console.log(`No active devices for user ${userId}`);
        return;
      }

      const messaging = getMessaging();
      const tokens = devices.map((d) => d.fcmToken);

      const payload = {
        notification: {
          title,
          body: message,
        },
        data: {
          ...data,
          type: data.type || "NOTIFICATION",
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
      };

      // Gửi đến nhiều devices
      const response = await messaging.sendEachForMulticast({
        tokens,
        ...payload,
      });

      console.log(
        `Push sent to ${response.successCount}/${tokens.length} devices`
      );

      // Xóa tokens không hợp lệ
      if (response.failureCount > 0) {
        const failedTokens = [];
        response.responses.forEach((resp, idx) => {
          if (!resp.success) {
            failedTokens.push(tokens[idx]);
          }
        });

        await UserDevice.updateMany(
          { fcmToken: { $in: failedTokens } },
          { isActive: false }
        );
      }

      return response;
    } catch (error) {
      console.error("❌ Error sending push to user:", error);
    }
  }

  // ========== GỬI PUSH NOTIFICATION CHO TẤT CẢ USERS ==========
  async sendPushToAllUsers(title, message, data = {}) {
    try {
      const devices = await UserDevice.find({ isActive: true }).limit(500);
      const tokens = devices.map((d) => d.fcmToken);

      if (tokens.length === 0) {
        console.log("No active devices found");
        return;
      }

      const messaging = getMessaging();
      const payload = {
        notification: {
          title,
          body: message,
        },
        data: {
          ...data,
          type: data.type || "NOTIFICATION",
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
      };

      const response = await messaging.sendEachForMulticast({
        tokens,
        ...payload,
      });

      console.log(
        `📱 Broadcast push sent to ${response.successCount}/${tokens.length} devices`
      );
      return response;
    } catch (error) {
      console.error("Error broadcasting push:", error);
    }
  }

  // ========== LẤY DANH SÁCH NOTIFICATIONS ==========
  async getUserNotifications(userId, page = 1, limit = 20) {
    try {
      const skip = (page - 1) * limit;

      const notifications = await Notification.find({ userId })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .lean();

      const total = await Notification.countDocuments({ userId });
      const unreadCount = await Notification.countDocuments({
        userId,
        isRead: false,
      });

      return {
        notifications,
        pagination: {
          page,
          limit,
          total,
          totalPages: Math.ceil(total / limit),
        },
        unreadCount,
      };
    } catch (error) {
      console.error("❌ Error getting notifications:", error);
      throw error;
    }
  }

  // ========== ĐÁNH DẤU ĐÃ ĐỌC ==========
  async markAsRead(notificationId, userId) {
    try {
      const notification = await Notification.findOneAndUpdate(
        { _id: notificationId, userId },
        { isRead: true, readAt: new Date() },
        { new: true }
      );

      if (notification) {
        emitToUser(userId, "notification_read", { notificationId });
      }

      return notification;
    } catch (error) {
      console.error("Error marking as read:", error);
      throw error;
    }
  }

  // ========== ĐÁNH DẤU TẤT CẢ ĐÃ ĐỌC ==========
  async markAllAsRead(userId) {
    try {
      const result = await Notification.updateMany(
        { userId, isRead: false },
        { isRead: true, readAt: new Date() }
      );

      emitToUser(userId, "all_notifications_read", {});
      return result;
    } catch (error) {
      console.error("Error marking all as read:", error);
      throw error;
    }
  }

  // ========== ĐĂNG KÝ FCM TOKEN ==========
  async registerFCMToken(userId, fcmToken, deviceInfo) {
    try {
      const device = await UserDevice.findOneAndUpdate(
        { fcmToken },
        {
          userId,
          fcmToken,
          deviceType: deviceInfo.deviceType || "ANDROID",
          deviceInfo: {
            model: deviceInfo.model,
            osVersion: deviceInfo.osVersion,
            appVersion: deviceInfo.appVersion,
          },
          isActive: true,
          lastUsedAt: new Date(),
        },
        { upsert: true, new: true }
      );

      console.log(`FCM Token registered for user ${userId}`);
      return device;
    } catch (error) {
      console.error("Error registering FCM token:", error);
      throw error;
    }
  }

  // ========== XÓA NOTIFICATION ==========
  async deleteNotification(notificationId, userId) {
    try {
      await Notification.findOneAndDelete({ _id: notificationId, userId });
      emitToUser(userId, "notification_deleted", { notificationId });
    } catch (error) {
      console.error("❌ Error deleting notification:", error);
      throw error;
    }
  }

  // ========== LẤY SỐ LƯỢNG CHƯA ĐỌC ==========
  async getUnreadCount(userId) {
    try {
      const count = await Notification.countDocuments({
        userId,
        isRead: false,
      });
      return count;
    } catch (error) {
      console.error("❌ Error getting unread count:", error);
      throw error;
    }
  }
}

module.exports = new NotificationService();
