const express = require("express");
const router = express.Router();
const bookingController = require("../controllers/booking.controller");
const { validateCreateBooking } = require("../middlewares/validate.middleware");
const { authenticateToken } = require("../middlewares/auth.middleware");

/**
 * @swagger
 * tags:
 * - name: Bookings
 * description: Booking management APIs
 */

// ==========================================
// 1. PUBLIC ROUTES (Specific routes first)
// ==========================================

/**
 * @swagger
 * /api/bookings/movies:
 * get:
 * summary: Get all movies
 * tags: [Bookings]
 * responses:
 * 200:
 * description: List of movies
 */
router.get("/movies", bookingController.getMovies);

/**
 * @swagger
 * /api/bookings/movies/{movieId}/showtimes:
 * get:
 * summary: Get showtimes by movie ID
 * tags: [Bookings]
 * parameters:
 * - in: path
 * name: movieId
 * required: true
 * schema:
 * type: string
 * responses:
 * 200:
 * description: List of showtimes
 */
router.get("/movies/:movieId/showtimes", bookingController.getShowtimesByMovie);

/**
 * @swagger
 * /api/bookings/movies/{id}:
 * get:
 * summary: Get movie by ID
 * tags: [Bookings]
 * parameters:
 * - in: path
 * name: id
 * required: true
 * schema:
 * type: string
 * responses:
 * 200:
 * description: Movie details
 */
router.get("/movies/:id", bookingController.getMovieById);

/**
 * @swagger
 * /api/bookings/showtimes/{showtimeId}/seats:
 * get:
 * summary: Get seats by showtime ID
 * tags: [Bookings]
 * parameters:
 * - in: path
 * name: showtimeId
 * required: true
 * schema:
 * type: string
 * responses:
 * 200:
 * description: List of seats
 */
router.get(
  "/showtimes/:showtimeId/seats",
  bookingController.getSeatsByShowtime
);

// ==========================================
// 2. PRIVATE ROUTES (Specific routes first)
// ==========================================

/**
 * @swagger
 * /api/bookings/my-bookings:
 * get:
 * summary: Get all bookings of current user
 * tags: [Bookings]
 * security:
 * - bearerAuth: []
 * responses:
 * 200:
 * description: List of user bookings
 */
router.get("/my-bookings", authenticateToken, bookingController.getMyBookings);

/**
 * @swagger
 * /api/bookings:
 * post:
 * summary: Create a new booking
 * tags: [Bookings]
 * security:
 * - bearerAuth: []
 * requestBody:
 * required: true
 * content:
 * application/json:
 * schema:
 * type: object
 * properties:
 * showtimeId:
 * type: string
 * seatIds:
 * type: array
 * items:
 * type: string
 * responses:
 * 201:
 * description: Booking created
 */
router.post(
  "/",
  authenticateToken,
  validateCreateBooking,
  bookingController.createBooking
);

/**
 * @swagger
 * /api/bookings/{id}/cancel:
 * post:
 * summary: Cancel a booking
 * tags: [Bookings]
 * security:
 * - bearerAuth: []
 * parameters:
 * - in: path
 * name: id
 * required: true
 * schema:
 * type: string
 * responses:
 * 200:
 * description: Cancelled
 */
router.post("/:id/cancel", authenticateToken, bookingController.cancelBooking);

/**
 * @swagger
 * /api/bookings/{id}:
 * delete:
 * summary: Delete a booking (only completed or cancelled)
 * tags: [Bookings]
 * security:
 * - bearerAuth: []
 * parameters:
 * - in: path
 * name: id
 * required: true
 * schema:
 * type: string
 * responses:
 * 200:
 * description: Deleted
 */
router.delete("/:id", authenticateToken, bookingController.deleteBooking);

/**
 * @swagger
 * /api/bookings/{id}:
 * get:
 * summary: Get booking details by ID
 * tags: [Bookings]
 * security:
 * - bearerAuth: []
 * parameters:
 * - in: path
 * name: id
 * required: true
 * schema:
 * type: string
 * responses:
 * 200:
 * description: Success
 */
router.get("/:id", authenticateToken, bookingController.getBookingById);

module.exports = router;
