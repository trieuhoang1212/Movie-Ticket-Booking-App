const mongoose = require("mongoose");

const bookingSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: [true, "User is required"],
    },
    showtimeId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Showtime",
      required: [true, "Showtime is required"],
    },
    seats: [
      {
        seatId: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "Seat",
          required: true,
        },
        seatNumber: String,
        type: String,
        price: Number,
      },
    ],
    totalAmount: {
      type: Number,
      required: [true, "Total amount is required"],
    },
    bookingCode: {
      type: String,
      unique: true,
      required: true,
    },
    status: {
      type: String,
      enum: ["pending", "confirmed", "cancelled", "completed"],
      default: "pending",
    },
    paymentStatus: {
      type: String,
      enum: ["pending", "paid", "refunded"],
      default: "pending",
    },
    paymentMethod: {
      type: String,
      enum: ["cash", "vnpay", "momo"],
    },
    qrCode: {
      type: String, // QR code để check-in
    },
  },
  {
    timestamps: true,
  }
);

// Generate booking code tự động
bookingSchema.pre("save", function (next) {
  if (!this.bookingCode) {
    this.bookingCode = `BK${Date.now()}${Math.floor(Math.random() * 1000)}`;
  }
  next();
});

module.exports = mongoose.model("Booking", bookingSchema);
