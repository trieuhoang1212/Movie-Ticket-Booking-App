const express = require("express");
const router = express.Router();
const vnpayController = require("../controllers/vnpay.controllers");
const { authenticateToken } = require("../middlewares/auth.middleware");
const { validateCreatePayment } = require("../validators/payment.validator");

/**
 * @swagger
 * /api/payments/create:
 *   post:
 *     summary: Tạo URL thanh toán VNPay
 *     tags: [Payment]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - orderId
 *               - amount
 *               - orderInfo
 *             properties:
 *               orderId:
 *                 type: string
 *                 example: "ORDER123456"
 *               amount:
 *                 type: number
 *                 example: 100000
 *               orderInfo:
 *                 type: string
 *                 example: "Thanh toan ve xem phim"
 *               bankCode:
 *                 type: string
 *                 example: "NCB"
 *     responses:
 *       200:
 *         description: URL thanh toán được tạo thành công
 *       401:
 *         description: Unauthorized
 */
router.post(
  "/create",
  authenticateToken,
  validateCreatePayment,
  vnpayController.createPayment
);

/**
 * @swagger
 * /api/payments/vnpay-return:
 *   get:
 *     summary: Callback từ VNPay sau khi thanh toán
 *     tags: [Payment]
 */
router.get("/vnpay-return", vnpayController.vnpayReturn);

/**
 * @swagger
 * /api/payments/vnpay-ipn:
 *   get:
 *     summary: IPN (Instant Payment Notification) từ VNPay
 *     tags: [Payment]
 */
router.get("/vnpay-ipn", vnpayController.vnpayIPN);

module.exports = router;
