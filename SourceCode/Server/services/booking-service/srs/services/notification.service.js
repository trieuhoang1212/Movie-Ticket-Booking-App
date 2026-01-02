const axios = require("axios");

const NOTIFICATION_SERVICE_URL =
  process.env.NOTIFICATION_SERVICE_URL || "http://localhost:3005";
const INTERNAL_API_KEY = process.env.INTERNAL_API_KEY || "internal-secret-key";

/**
 * Gửi thông báo đặt vé thành công
 */
async function notifyBookingConfirmed(bookingData) {
  try {
    await axios.post(
      `${NOTIFICATION_SERVICE_URL}/api/notifications/internal/booking-confirmed`,
      {
        userId: bookingData.userId,
        bookingId: bookingData._id.toString(),
        movieTitle: bookingData.movieTitle,
        showtime: bookingData.showtime,
        seats: bookingData.seats.map((s) => s.seatNumber),
        cinema: bookingData.cinema,
        totalAmount: bookingData.totalAmount,
      },
      {
        headers: {
          "x-api-key": INTERNAL_API_KEY,
          "Content-Type": "application/json",
        },
        timeout: 5000,
      }
    );
    console.log("✅ Booking notification sent");
  } catch (error) {
    console.error("⚠️ Failed to send booking notification:", error.message);
    // Không throw error để không ảnh hưởng flow chính
  }
}

module.exports = {
  notifyBookingConfirmed,
};
