const express = require("express");
const router = express.Router();
const notificationController = require("../controllers/notification.controller");
const {
  authenticateToken,
  authenticateInternal,
} = require("../middlewares/auth.middleware");

// ========== PUBLIC ROUTES (cần authentication) ==========

/**
 * @swagger
 * /api/notifications:
 *   get:
 *     summary: Lấy danh sách notifications
 *     tags: [Notifications]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           default: 1
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 20
 *     responses:
 *       200:
 *         description: Success
 *       401:
 *         description: Unauthorized
 */
router.get("/", authenticateToken, notificationController.getNotifications);

/**
 * @swagger
 * /api/notifications/unread-count:
 *   get:
 *     summary: Lấy số lượng notifications chưa đọc
 *     tags: [Notifications]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Success
 */
router.get(
  "/unread-count",
  authenticateToken,
  notificationController.getUnreadCount
);

/**
 * @swagger
 * /api/notifications/{id}/read:
 *   patch:
 *     summary: Đánh dấu notification đã đọc
 *     tags: [Notifications]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Success
 */
router.patch("/:id/read", authenticateToken, notificationController.markAsRead);

/**
 * @swagger
 * /api/notifications/read-all:
 *   patch:
 *     summary: Đánh dấu tất cả đã đọc
 *     tags: [Notifications]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Success
 */
router.patch(
  "/read-all",
  authenticateToken,
  notificationController.markAllAsRead
);

/**
 * @swagger
 * /api/notifications/{id}:
 *   delete:
 *     summary: Xóa notification
 *     tags: [Notifications]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Success
 */
router.delete(
  "/:id",
  authenticateToken,
  notificationController.deleteNotification
);

/**
 * @swagger
 * /api/notifications/register-token:
 *   post:
 *     summary: Đăng ký FCM token
 *     tags: [Notifications]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               fcmToken:
 *                 type: string
 *               deviceInfo:
 *                 type: object
 *     responses:
 *       200:
 *         description: Success
 */
router.post(
  "/register-token",
  authenticateToken,
  notificationController.registerFCMToken
);

// ========== INTERNAL ROUTES (chỉ cho các services khác gọi) ==========

/**
 * @swagger
 * /api/notifications/internal/create:
 *   post:
 *     summary: Tạo notification (Internal API)
 *     tags: [Internal]
 *     security:
 *       - apiKey: []
 *     responses:
 *       200:
 *         description: Success
 */
router.post(
  "/internal/create",
  authenticateInternal,
  notificationController.createNotification
);

/**
 * @swagger
 * /api/notifications/internal/new-movie:
 *   post:
 *     summary: Thông báo phim mới ra mắt (Internal)
 *     tags: [Internal]
 *     security:
 *       - apiKey: []
 *     responses:
 *       200:
 *         description: Success
 */
router.post(
  "/internal/new-movie",
  authenticateInternal,
  notificationController.notifyNewMovie
);

/**
 * @swagger
 * /api/notifications/internal/booking-confirmed:
 *   post:
 *     summary: Thông báo đặt vé thành công (Internal)
 *     tags: [Internal]
 *     security:
 *       - apiKey: []
 *     responses:
 *       200:
 *         description: Success
 */
router.post(
  "/internal/booking-confirmed",
  authenticateInternal,
  notificationController.notifyBooking
);

/**
 * @swagger
 * /api/notifications/internal/payment-success:
 *   post:
 *     summary: Thông báo thanh toán thành công (Internal)
 *     tags: [Internal]
 *     security:
 *       - apiKey: []
 *     responses:
 *       200:
 *         description: Success
 */
router.post(
  "/internal/payment-success",
  authenticateInternal,
  notificationController.notifyPaymentSuccess
);

/**
 * @swagger
 * /api/notifications/internal/payment-failed:
 *   post:
 *     summary: Thông báo thanh toán thất bại (Internal)
 *     tags: [Internal]
 *     security:
 *       - apiKey: []
 *     responses:
 *       200:
 *         description: Success
 */
router.post(
  "/internal/payment-failed",
  authenticateInternal,
  notificationController.notifyPaymentFailed
);

/**
 * @swagger
 * /api/notifications/internal/movie-reminder:
 *   post:
 *     summary: Nhắc nhở xem phim (Internal)
 *     tags: [Internal]
 *     security:
 *       - apiKey: []
 *     responses:
 *       200:
 *         description: Success
 */
router.post(
  "/internal/movie-reminder",
  authenticateInternal,
  notificationController.notifyMovieReminder
);

module.exports = router;
