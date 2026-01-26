const Booking = require("../repositories/booking.model");
const Showtime = require("../repositories/showtime.model");
const Seat = require("../repositories/seat.model");
const Movie = require("../repositories/movie.model");
const { notifyBookingConfirmed } = require("../services/notification.service");
const fcmService = require("../services/fcm.service");

// Tạo booking mới
exports.createBooking = async (req, res) => {
  try {
    console.log("Creating booking:", { body: req.body, user: req.user });

    const { showtimeId, seatIds } = req.body;
    const userId = req.user.id; // Từ JWT middleware

    console.log("Finding showtime:", showtimeId);
    // Kiểm tra showtime
    const showtime = await Showtime.findById(showtimeId).populate("movieId");
    console.log(
      "Showtime result:",
      showtime ? `Found (${showtime._id})` : "Not found"
    );
    if (!showtime) {
      return res.status(404).json({
        success: false,
        message: "Showtime not found",
      });
    }

    // Kiểm tra ghế có available không
    console.log("Finding seats:", { showtimeId, seatIds });
    const seats = await Seat.find({
      _id: { $in: seatIds },
      showtimeId: showtimeId,
      status: "available",
    });
    console.log(`Found ${seats.length}/${seatIds.length} available seats`);

    if (seats.length !== seatIds.length) {
      console.log("Some seats not available");
      return res.status(400).json({
        success: false,
        message: "Some seats are not available",
      });
    }

    // Tính tổng tiền
    console.log("Calculating total...");
    let totalAmount = 0;
    const bookingSeats = seats.map((seat) => {
      const price = showtime.price[seat.type];
      console.log(`  ${seat.seatNumber} (${seat.type}): ${price}`);
      totalAmount += price;
      return {
        seatId: seat._id,
        seatNumber: seat.seatNumber,
        type: seat.type,
        price: price,
      };
    });

    // Tạo booking code
    const bookingCode = `BK${Date.now()}${Math.floor(Math.random() * 1000)
      .toString()
      .padStart(3, "0")}`;

    // Tạo booking
    console.log("Saving booking:", {
      userId,
      showtimeId,
      totalAmount,
      seatsCount: bookingSeats.length,
      bookingCode,
    });
    console.log(
      "Booking seats type:",
      typeof bookingSeats,
      Array.isArray(bookingSeats)
    );
    console.log("Booking seats:", JSON.stringify(bookingSeats, null, 2));
    const booking = new Booking({
      userId,
      showtimeId,
      seats: bookingSeats,
      totalAmount,
      bookingCode,
      status: "pending",
      paymentStatus: "pending",
    });

    await booking.save();
    console.log("Booking saved:", booking._id);

    // Cập nhật trạng thái ghế
    console.log("Updating seat status...");
    await Seat.updateMany(
      { _id: { $in: seatIds } },
      {
        status: "reserved",
        reservedBy: userId,
        reservedUntil: new Date(Date.now() + 10 * 60 * 1000),
      }
    );
    console.log("Seats updated");

    // Populate booking để lấy thông tin đầy đủ
    console.log("Populating booking...");
    const populatedBooking = await booking.populate({
      path: "showtimeId",
      populate: { path: "movieId" },
    });
    console.log("Booking populated");

    // Gửi thông báo đặt vé thành công (async, không chờ để không làm chậm response)
    console.log("Sending notification...");
    notifyBookingConfirmed({
      userId,
      _id: booking._id,
      movieTitle:
        populatedBooking.showtimeId?.movieId?.title || "Unknown Movie",
      showtime: populatedBooking.showtimeId?.startTime || new Date(),
      seats: bookingSeats,
      cinema: populatedBooking.showtimeId?.cinemaHall || "Cinema",
      totalAmount,
    }).catch((err) =>
      console.error("Failed to send booking notification:", err.message)
    );
    console.log("Notification sent (async)");

    res.status(201).json({
      success: true,
      message: "Booking created successfully",
      data: {
        booking: populatedBooking,
      },
    });
  } catch (error) {
    console.error("Error creating booking:", error);
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

    // Transform để match Flutter model
    const transformedBookings = bookings.map((booking) => {
      const showtime = booking.showtimeId;
      const movie = showtime?.movieId;

      return {
        _id: booking._id,
        userId: booking.userId,
        showtime: {
          movieId: movie?._id,
          movieTitle: movie?.title || "Unknown Movie",
          moviePoster: movie?.posterUrl || "",
          theaterName: showtime?.cinema || "Unknown Theater",
          roomName: showtime?.room || "Unknown Room",
          startTime: showtime?.startTime,
          endTime: showtime?.endTime,
          screenType: showtime?.screenType || "2D",
        },
        seats: (booking.seats || []).map((seat) => ({
          seatId: seat.seatId,
          seatNumber: seat.seatNumber,
          type: seat.type,
          price: seat.price,
        })),
        totalAmount: booking.totalAmount,
        status: booking.status,
        paymentMethod: booking.paymentMethod,
        paymentStatus: booking.paymentStatus,
        bookingCode: booking.bookingCode,
        qrCode: booking.qrCode,
        createdAt: booking.createdAt,
        updatedAt: booking.updatedAt,
      };
    });

    res.status(200).json({
      success: true,
      data: { bookings: transformedBookings },
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

    const booking = await Booking.findOne({ _id: id, userId })
      .populate("showtimeId")
      .populate({
        path: "showtimeId",
        populate: { path: "movieId" },
      });

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

    // Lưu thông tin để gửi notification
    const movieTitle = booking.showtimeId?.movieId?.title || "Phim";
    const bookingCode = booking.bookingCode;

    // Cập nhật trạng thái booking
    booking.status = "cancelled";
    await booking.save();

    // Trả lại ghế
    const seatIds = booking.seats.map((s) => s.seatId);
    await Seat.updateMany(
      { _id: { $in: seatIds } },
      { status: "available", $unset: { reservedBy: "", reservedUntil: "" } }
    );

    // Gửi push notification
    try {
      await fcmService.sendNotificationToUser(
        userId,
        "Vé đã bị hủy",
        `Vé "${movieTitle}" (${bookingCode}) đã bị hủy thành công.`,
        {
          type: "BOOKING_CANCELLED",
          bookingCode,
          movieTitle,
        }
      );
      console.log("Cancel notification sent");
    } catch (notifError) {
      console.error("Failed to send notification:", notifError.message);
    }

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

// Xóa booking (chỉ cho vé đã hoàn thành hoặc đã hủy)
exports.deleteBooking = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const booking = await Booking.findOne({ _id: id, userId })
      .populate("showtimeId")
      .populate({
        path: "showtimeId",
        populate: { path: "movieId" },
      });

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: "Booking not found",
      });
    }

    // Chỉ cho phép xóa vé đã hoàn thành hoặc đã hủy
    if (booking.status !== "completed" && booking.status !== "cancelled") {
      return res.status(400).json({
        success: false,
        message: "Can only delete completed or cancelled bookings",
      });
    }

    // Lưu thông tin để gửi notification
    const movieTitle = booking.showtimeId?.movieId?.title || "Phim";
    const bookingCode = booking.bookingCode;
    const showtimeDate = booking.showtimeId?.showtime;

    // Xóa booking khỏi database
    await Booking.deleteOne({ _id: id });

    // Gửi push notification
    try {
      await fcmService.sendBookingDeletedNotification(userId, {
        movieTitle,
        bookingCode,
        showtimeDate,
      });
      console.log("Delete notification sent");
    } catch (notifError) {
      console.error("Failed to send notification:", notifError.message);
      // Không block response nếu notification fail
    }

    res.status(200).json({
      success: true,
      message: "Booking deleted successfully",
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
    const { status, isHot } = req.query;
    const filter = {};

    if (status) filter.status = status;
    if (isHot !== undefined) filter.isHot = isHot === "true";

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

// Lấy chi tiết 1 phim
exports.getMovieById = async (req, res) => {
  try {
    const { id } = req.params;
    const movie = await Movie.findById(id);

    if (!movie) {
      return res.status(404).json({
        success: false,
        message: "Movie not found",
      });
    }

    res.status(200).json({
      success: true,
      data: { movie },
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
      .populate("movieId", "title posterUrl") // Only populate title and posterUrl
      .sort({ startTime: 1 })
      .limit(50) // Limit to 50 showtimes to prevent large responses
      .lean(); // Convert to plain JS objects for better performance

    res.status(200).json({
      success: true,
      data: { showtimes },
    });
  } catch (error) {
    console.error("Error in getShowtimesByMovie:", error);
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
