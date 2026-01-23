const mongoose = require("mongoose");

const notificationSchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      required: true,
      index: true,
    },
    type: {
      type: String,
      enum: [
        "NEW_MOVIE",
        "BOOKING_CONFIRM",
        "PAYMENT_SUCCESS",
        "PAYMENT_FAILED",
        "MOVIE_REMINDER",
        "PROMOTION",
        "SYSTEM",
      ],
      required: true,
    },
    title: {
      type: String,
      required: true,
    },
    message: {
      type: String,
      required: true,
    },
    data: {
      movieId: String,
      movieTitle: String,
      bookingId: String,
      paymentId: String,
      amount: Number,
      showtime: Date,
      imageUrl: String,
      deepLink: String,
    },
    isRead: {
      type: Boolean,
      default: false,
    },
    readAt: {
      type: Date,
    },
    sentVia: {
      socket: { type: Boolean, default: false },
      push: { type: Boolean, default: false },
    },
  },
  {
    timestamps: true,
  }
);

notificationSchema.index({ userId: 1, createdAt: -1 });
notificationSchema.index({ userId: 1, isRead: 1 });
notificationSchema.index({ type: 1, createdAt: -1 });

module.exports = mongoose.model("Notification", notificationSchema);
