const notificationService = require("../services/notification.services");

class NotificationController {
  // ========== LẤY DANH SÁCH NOTIFICATIONS ==========
  async getNotifications(req, res) {
    try {
      const userId = req.user.userId;
      const { page = 1, limit = 20 } = req.query;

      const result = await notificationService.getUserNotifications(
        userId,
        parseInt(page),
        parseInt(limit)
      );

      res.status(200).json({
        success: true,
        data: result,
      });
    } catch (error) {
      console.error("Error getting notifications:", error);
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }

  // ========== TẠO NOTIFICATION (Internal API) ==========
  async createNotification(req, res) {
    try {
      const notification = await notificationService.createNotification(
        req.body
      );

      res.status(201).json({
        success: true,
        data: notification,
      });
    } catch (error) {
      console.error("Error creating notification:", error);
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }

  // ========== THÔNG BÁO PHIM MỚI ==========
  async notifyNewMovie(req, res) {
    try {
      await notificationService.notifyNewMovieRelease(req.body);

      res.status(200).json({
        success: true,
        message: "New movie notification sent successfully",
      });
    } catch (error) {
      console.error("Error notifying new movie:", error);
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }

  // ========== THÔNG BÁO ĐẶT VÉ ==========
  async notifyBooking(req, res) {
    try {
      const notification = await notificationService.notifyBookingConfirmed(
        req.body
      );

      res.status(200).json({
        success: true,
        data: notification,
      });
    } catch (error) {
      console.error("Error notifying booking:", error);
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }

  // ========== THÔNG BÁO THANH TOÁN THÀNH CÔNG ==========
  async notifyPaymentSuccess(req, res) {
    try {
      const notification = await notificationService.notifyPaymentSuccess(
        req.body
      );

      res.status(200).json({
        success: true,
        data: notification,
      });
    } catch (error) {
      console.error("Error notifying payment success:", error);
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }

  // ========== THÔNG BÁO THANH TOÁN THẤT BẠI ==========
  async notifyPaymentFailed(req, res) {
    try {
      const notification = await notificationService.notifyPaymentFailed(
        req.body
      );

      res.status(200).json({
        success: true,
        data: notification,
      });
    } catch (error) {
      console.error("Error notifying payment failed:", error);
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }

  // ========== NHẮC NHỞ XEM PHIM ==========
  async notifyMovieReminder(req, res) {
    try {
      const notification = await notificationService.notifyMovieReminder(
        req.body
      );

      res.status(200).json({
        success: true,
        data: notification,
      });
    } catch (error) {
      console.error("Error sending movie reminder:", error);
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }

  // ========== ĐÁNH DẤU ĐÃ ĐỌC ==========
  async markAsRead(req, res) {
    try {
      const userId = req.user.userId;
      const { id } = req.params;

      const notification = await notificationService.markAsRead(id, userId);

      if (!notification) {
        return res.status(404).json({
          success: false,
          message: "Notification not found",
        });
      }

      res.status(200).json({
        success: true,
        data: notification,
      });
    } catch (error) {
      console.error("Error marking notification as read:", error);
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }

  // ========== ĐÁNH DẤU TẤT CẢ ĐÃ ĐỌC ==========
  async markAllAsRead(req, res) {
    try {
      const userId = req.user.userId;
      const result = await notificationService.markAllAsRead(userId);

      res.status(200).json({
        success: true,
        data: result,
        message: "All notifications marked as read",
      });
    } catch (error) {
      console.error("Error marking all as read:", error);
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }

  // ========== XÓA NOTIFICATION ==========
  async deleteNotification(req, res) {
    try {
      const userId = req.user.userId;
      const { id } = req.params;

      await notificationService.deleteNotification(id, userId);

      res.status(200).json({
        success: true,
        message: "Notification deleted successfully",
      });
    } catch (error) {
      console.error("Error deleting notification:", error);
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }

  // ========== ĐĂNG KÝ FCM TOKEN ==========
  async registerFCMToken(req, res) {
    try {
      const userId = req.user.userId;
      const { fcmToken, deviceInfo } = req.body;

      if (!fcmToken) {
        return res.status(400).json({
          success: false,
          message: "FCM token is required",
        });
      }

      const device = await notificationService.registerFCMToken(
        userId,
        fcmToken,
        deviceInfo || {}
      );

      res.status(200).json({
        success: true,
        data: device,
        message: "FCM token registered successfully",
      });
    } catch (error) {
      console.error("Error registering FCM token:", error);
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }

  // ========== LẤY SỐ LƯỢNG CHƯA ĐỌC ==========
  async getUnreadCount(req, res) {
    try {
      const userId = req.user.userId;
      const count = await notificationService.getUnreadCount(userId);

      res.status(200).json({
        success: true,
        data: { count },
      });
    } catch (error) {
      console.error("Error getting unread count:", error);
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }
}

module.exports = new NotificationController();
