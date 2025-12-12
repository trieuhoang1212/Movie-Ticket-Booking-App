const Booking = require("../repositories/booking.model");
const Showtime = require("../repositories/showtime.model");
const Seat = require("../repositories/seat.model");
const Movie = require("../repositories/movie.model");

// Tạo booking mới
exports.createBooking = async (req, res) => {
  try {
    const { showtimeId, seatIds } = req.body;
    const userId = req.user.id; // Từ JWT middleware

    // Kiểm tra showtime
    const showtime = await Showtime.findById(showtimeId).populate("movieId");
    if (!showtime) {
      return res.status(404).json({
        success: false,
        message: "Showtime not found",
      });
    }

    // Kiểm tra ghế có available không
    const seats = await Seat.find({
      _id: { $in: seatIds },
      showtimeId: showtimeId,
      status: "available",
    });

    if (seats.length !== seatIds.length) {
      return res.status(400).json({
        success: false,
        message: "Some seats are not available",
      });
    }

    // Tính tổng tiền
    let totalAmount = 0;
    const bookingSeats = seats.map((seat) => {
      const price = showtime.price[seat.type];
      totalAmount += price;
      return {
        seatId: seat._id,
        seatNumber: seat.seatNumber,
        type: seat.type,
        price: price,
      };
    });

    // Tạo booking
    const booking = new Booking({
      userId,
      showtimeId,
      seats: bookingSeats,
      totalAmount,
      status: "pending",
    });

    await booking.save();

    // Cập nhật trạng thái ghế
    await Seat.updateMany(
      { _id: { $in: seatIds } },
      {
        status: "reserved",
        reservedBy: userId,
        reservedUntil: new Date(Date.now() + 10 * 60 * 1000),
      }
    );

    res.status(201).json({
      success: true,
      message: "Booking created successfully",
      data: {
        booking: await booking.populate("showtimeId"),
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server error",
      error: error.message,
    });
  }
};

// Lấy danh sách booking của user
exports.getMyBookings = async (req, res) => {
  try {
    const userId = req.user.id;

    const bookings = await Booking.find({ userId })
      .populate({
        path: "showtimeId",
        populate: { path: "movieId" },
      })
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      data: { bookings },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server error",
      error: error.message,
    });
  }
};

// Lấy chi tiết booking
exports.getBookingById = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const booking = await Booking.findOne({ _id: id, userId })
      .populate({
        path: "showtimeId",
        populate: { path: "movieId" },
      })
      .populate("seats.seatId");

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: "Booking not found",
      });
    }

    res.status(200).json({
      success: true,
      data: { booking },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server error",
      error: error.message,
    });
  }
};

// Hủy booking
exports.cancelBooking = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const booking = await Booking.findOne({ _id: id, userId });

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: "Booking not found",
      });
    }

    if (booking.status === "completed" || booking.status === "cancelled") {
      return res.status(400).json({
        success: false,
        message: "Cannot cancel this booking",
      });
    }

    // Cập nhật trạng thái booking
    booking.status = "cancelled";
    await booking.save();

    // Trả lại ghế
    const seatIds = booking.seats.map((s) => s.seatId);
    await Seat.updateMany(
      { _id: { $in: seatIds } },
      { status: "available", $unset: { reservedBy: "", reservedUntil: "" } }
    );

    res.status(200).json({
      success: true,
      message: "Booking cancelled successfully",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server error",
      error: error.message,
    });
  }
};

// Lấy danh sách phim
exports.getMovies = async (req, res) => {
  try {
    const { status } = req.query;
    const filter = status ? { status } : {};

    const movies = await Movie.find(filter).sort({ releaseDate: -1 });

    res.status(200).json({
      success: true,
      data: { movies },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server error",
      error: error.message,
    });
  }
};

// Lấy suất chiếu theo phim
exports.getShowtimesByMovie = async (req, res) => {
  try {
    const { movieId } = req.params;

    const showtimes = await Showtime.find({
      movieId,
      status: "available",
      startTime: { $gte: new Date() },
    })
      .populate("movieId")
      .sort({ startTime: 1 });

    res.status(200).json({
      success: true,
      data: { showtimes },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server error",
      error: error.message,
    });
  }
};

// Lấy danh sách ghế theo showtime
exports.getSeatsByShowtime = async (req, res) => {
  try {
    const { showtimeId } = req.params;

    const seats = await Seat.find({ showtimeId }).sort({
      row: 1,
      seatNumber: 1,
    });

    res.status(200).json({
      success: true,
      data: { seats },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server error",
      error: error.message,
    });
  }
};
