const mongoose = require("mongoose");

const seatSchema = new mongoose.Schema(
  {
    showtimeId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Showtime",
      required: [true, "Showtime is required"],
    },
    seatNumber: {
      type: String,
      required: [true, "Seat number is required"],
    },
    row: {
      type: String,
      required: [true, "Row is required"],
    },
    type: {
      type: String,
      enum: ["regular", "vip", "couple"],
      default: "regular",
    },
    status: {
      type: String,
      enum: ["available", "reserved", "booked"],
      default: "available",
    },
    reservedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
    },
    reservedUntil: {
      type: Date, // Ghế được giữ trong 10 phút
    },
  },
  {
    timestamps: true,
  }
);

// Index để tìm ghế nhanh
seatSchema.index({ showtimeId: 1, status: 1 });

module.exports = mongoose.model("Seat", seatSchema);
