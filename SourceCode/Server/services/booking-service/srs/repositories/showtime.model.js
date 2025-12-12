const mongoose = require("mongoose");

const showtimeSchema = new mongoose.Schema(
  {
    movieId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Movie",
      required: [true, "Movie is required"],
    },
    cinemaHall: {
      type: String,
      required: [true, "Cinema hall is required"],
    },
    startTime: {
      type: Date,
      required: [true, "Start time is required"],
    },
    endTime: {
      type: Date,
      required: [true, "End time is required"],
    },
    price: {
      regular: {
        type: Number,
        required: [true, "Regular seat price is required"],
      },
      vip: {
        type: Number,
        required: [true, "VIP seat price is required"],
      },
      couple: {
        type: Number,
        required: [true, "Couple seat price is required"],
      },
    },
    availableSeats: {
      type: Number,
      required: true,
    },
    status: {
      type: String,
      enum: ["available", "full", "cancelled"],
      default: "available",
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model("Showtime", showtimeSchema);
