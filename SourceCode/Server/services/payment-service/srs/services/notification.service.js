const axios = require("axios");

const NOTIFICATION_SERVICE_URL =
  process.env.NOTIFICATION_SERVICE_URL || "http://localhost:3005";
const INTERNAL_API_KEY = process.env.INTERNAL_API_KEY || "internal-secret-key";

/**
 * Gửi thông báo thanh toán thành công
 */
async function notifyPaymentSuccess(paymentData) {
  try {
    await axios.post(
      `${NOTIFICATION_SERVICE_URL}/api/notifications/internal/payment-success`,
      {
        userId: paymentData.userId,
        paymentId: paymentData._id?.toString(),
        bookingId: paymentData.bookingId?.toString(),
        movieTitle: paymentData.movieTitle,
        amount: paymentData.amount,
        paymentMethod: paymentData.paymentMethod,
      },
      {
        headers: {
          "x-api-key": INTERNAL_API_KEY,
          "Content-Type": "application/json",
        },
        timeout: 5000,
      }
    );
    console.log("✅ Payment success notification sent");
  } catch (error) {
    console.error(
      "⚠️ Failed to send payment success notification:",
      error.message
    );
  }
}

/**
 * Gửi thông báo thanh toán thất bại
 */
async function notifyPaymentFailed(paymentData) {
  try {
    await axios.post(
      `${NOTIFICATION_SERVICE_URL}/api/notifications/internal/payment-failed`,
      {
        userId: paymentData.userId,
        bookingId: paymentData.bookingId?.toString(),
        movieTitle: paymentData.movieTitle,
        amount: paymentData.amount,
        reason: paymentData.reason || "Thanh toán không thành công",
      },
      {
        headers: {
          "x-api-key": INTERNAL_API_KEY,
          "Content-Type": "application/json",
        },
        timeout: 5000,
      }
    );
    console.log("✅ Payment failed notification sent");
  } catch (error) {
    console.error(
      "⚠️ Failed to send payment failed notification:",
      error.message
    );
  }
}

module.exports = {
  notifyPaymentSuccess,
  notifyPaymentFailed,
};
