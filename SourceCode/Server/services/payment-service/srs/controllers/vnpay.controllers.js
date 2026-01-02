const vnpayService = require("../services/vnpay.service");
const axios = require("axios");

class PaymentController {
  /**
   * Tạo URL thanh toán
   */
  async createPayment(req, res) {
    try {
      const { orderId, amount, orderInfo, bankCode } = req.body;
      const ipAddr =
        req.headers["x-forwarded-for"] ||
        req.connection.remoteAddress ||
        req.socket.remoteAddress ||
        "127.0.0.1";

      // Làm sạch IP address (bỏ ::ffff: prefix nếu có)
      const cleanIpAddr = ipAddr.replace("::ffff:", "");

      const paymentUrl = vnpayService.createPaymentUrl(
        orderId,
        amount,
        orderInfo,
        cleanIpAddr,
        "vn",
        bankCode || ""
      );

      res.json({
        success: true,
        paymentUrl,
        message: "Payment URL created successfully",
      });
    } catch (error) {
      console.error("Create payment error:", error);
      res.status(500).json({
        success: false,
        message: error.message,
      });
    }
  }

  /**
   * Xử lý callback từ VNPay
   */
  async vnpayReturn(req, res) {
    try {
      const verify = vnpayService.verifyReturnUrl(req.query);

      if (!verify.isVerified) {
        return res.redirect(
          `${
            process.env.CLIENT_URL || "http://localhost:3000"
          }/payment/failed?message=Invalid signature`
        );
      }

      if (verify.isSuccess) {
        // Gọi sang booking service để cập nhật trạng thái
        try {
          await axios.post(
            `${process.env.BOOKING_SERVICE_URL}/api/bookings/update-payment-status`,
            {
              orderId: verify.vnp_TxnRef,
              status: "paid",
              transactionNo: verify.vnp_TransactionNo,
              amount: verify.vnp_Amount / 100,
              payDate: verify.vnp_PayDate,
            },
            {
              headers: {
                "x-api-key": process.env.INTERNAL_API_KEY,
              },
            }
          );
        } catch (error) {
          console.error("Update booking status error:", error.message);
        }

        res.redirect(
          `${
            process.env.CLIENT_URL || "http://localhost:3000"
          }/payment/success?orderId=${verify.vnp_TxnRef}`
        );
      } else {
        res.redirect(
          `${
            process.env.CLIENT_URL || "http://localhost:3000"
          }/payment/failed?orderId=${verify.vnp_TxnRef}&code=${
            verify.vnp_ResponseCode
          }`
        );
      }
    } catch (error) {
      console.error("VNPay return error:", error);
      res.redirect(
        `${process.env.CLIENT_URL || "http://localhost:3000"}/payment/error`
      );
    }
  }

  /**
   * Xử lý IPN từ VNPay
   */
  async vnpayIPN(req, res) {
    try {
      const verify = vnpayService.verifyIpnCall(req.query);

      if (!verify.isVerified) {
        return res.json({ RspCode: "97", Message: "Invalid signature" });
      }

      if (verify.isSuccess) {
        // Cập nhật trạng thái đơn hàng trong database
        try {
          await axios.post(
            `${process.env.BOOKING_SERVICE_URL}/api/bookings/update-payment-status`,
            {
              orderId: verify.vnp_TxnRef,
              status: "paid",
              transactionNo: verify.vnp_TransactionNo,
              amount: verify.vnp_Amount / 100,
            },
            {
              headers: {
                "x-api-key": process.env.INTERNAL_API_KEY,
              },
            }
          );

          return res.json({ RspCode: "00", Message: "Confirm Success" });
        } catch (error) {
          console.error("Update payment status error:", error.message);
          return res.json({ RspCode: "99", Message: "Unknown error" });
        }
      } else {
        return res.json({
          RspCode: "00",
          Message: "Confirm Success (Failed payment)",
        });
      }
    } catch (error) {
      console.error("VNPay IPN error:", error);
      res.json({ RspCode: "99", Message: "Unknown error" });
    }
  }
}

module.exports = new PaymentController();
