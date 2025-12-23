const express = require("express");
const router = express.Router();
const notificationController = require("../controllers/notification.controller");
const {
  authenticateToken,
  authenticateInternal,
} = require("../middlewares/auth.middleware");

// ========== PUBLIC ROUTES (cần authentication) ==========
// Lấy danh sách notifications của user
router.get("/", authenticateToken, notificationController.getNotifications);

// Lấy số lượng notifications chưa đọc
router.get(
  "/unread-count",
  authenticateToken,
  notificationController.getUnreadCount
);

// Đánh dấu notification đã đọc
router.patch("/:id/read", authenticateToken, notificationController.markAsRead);

// Đánh dấu tất cả đã đọc
router.patch(
  "/read-all",
  authenticateToken,
  notificationController.markAllAsRead
);

// Xóa notification
router.delete(
  "/:id",
  authenticateToken,
  notificationController.deleteNotification
);

// Đăng ký FCM token
router.post(
  "/register-token",
  authenticateToken,
  notificationController.registerFCMToken
);

// ========== INTERNAL ROUTES (chỉ cho các services khác gọi) ==========
// Tạo notification chung
router.post(
  "/internal/create",
  authenticateInternal,
  notificationController.createNotification
);

// Thông báo phim mới ra mắt
router.post(
  "/internal/new-movie",
  authenticateInternal,
  notificationController.notifyNewMovie
);

// Thông báo đặt vé thành công
router.post(
  "/internal/booking-confirmed",
  authenticateInternal,
  notificationController.notifyBooking
);

// Thông báo thanh toán thành công
router.post(
  "/internal/payment-success",
  authenticateInternal,
  notificationController.notifyPaymentSuccess
);

// Thông báo thanh toán thất bại
router.post(
  "/internal/payment-failed",
  authenticateInternal,
  notificationController.notifyPaymentFailed
);

// Nhắc nhở xem phim
router.post(
  "/internal/movie-reminder",
  authenticateInternal,
  notificationController.notifyMovieReminder
);

module.exports = router;
