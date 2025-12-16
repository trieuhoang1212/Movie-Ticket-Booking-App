const express = require("express");
const router = express.Router();
const bookingController = require("../controllers/booking.controller");
const { validateCreateBooking } = require("../middlewares/validate.middleware");
const { authenticateToken } = require("../middlewares/auth.middleware");

/**
 * @swagger
 * tags:
 *   name: Bookings
 *   description: Booking management APIs
 */

/**
 * @swagger
 * /api/bookings:
 *   post:
 *     summary: Create a new booking
 *     tags: [Bookings]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - showtimeId
 *               - seatIds
 *             properties:
 *               showtimeId:
 *                 type: string
 *                 example: "507f1f77bcf86cd799439011"
 *               seatIds:
 *                 type: array
 *                 items:
 *                   type: string
 *                 example: ["507f1f77bcf86cd799439012", "507f1f77bcf86cd799439013"]
 *     responses:
 *       201:
 *         description: Booking created successfully
 *       400:
 *         description: Invalid input or seats not available
 *       401:
 *         description: Unauthorized
 */
router.post(
  "/",
  authenticateToken,
  validateCreateBooking,
  bookingController.createBooking
);

/**
 * @swagger
 * /api/bookings/my-bookings:
 *   get:
 *     summary: Get all bookings of current user
 *     tags: [Bookings]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of user bookings
 *       401:
 *         description: Unauthorized
 */
router.get("/my-bookings", authenticateToken, bookingController.getMyBookings);

/**
 * @swagger
 * /api/bookings/{id}:
 *   get:
 *     summary: Get booking details by ID
 *     tags: [Bookings]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Booking details
 *       404:
 *         description: Booking not found
 */
router.get("/:id", authenticateToken, bookingController.getBookingById);

/**
 * @swagger
 * /api/bookings/{id}/cancel:
 *   post:
 *     summary: Cancel a booking
 *     tags: [Bookings]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Booking cancelled successfully
 *       400:
 *         description: Cannot cancel booking
 *       404:
 *         description: Booking not found
 */
router.post("/:id/cancel", authenticateToken, bookingController.cancelBooking);

/**
 * @swagger
 * /api/bookings/movies:
 *   get:
 *     summary: Get all movies
 *     tags: [Bookings]
 *     parameters:
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *           enum: [now_showing, coming_soon, ended]
 *     responses:
 *       200:
 *         description: List of movies
 */
router.get("/movies", bookingController.getMovies);

/**
 * @swagger
 * /api/bookings/movies/{movieId}/showtimes:
 *   get:
 *     summary: Get showtimes by movie ID
 *     tags: [Bookings]
 *     parameters:
 *       - in: path
 *         name: movieId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: List of showtimes
 */
router.get("/movies/:movieId/showtimes", bookingController.getShowtimesByMovie);

/**
 * @swagger
 * /api/bookings/showtimes/{showtimeId}/seats:
 *   get:
 *     summary: Get seats by showtime ID
 *     tags: [Bookings]
 *     parameters:
 *       - in: path
 *         name: showtimeId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: List of seats
 */
router.get(
  "/showtimes/:showtimeId/seats",
  bookingController.getSeatsByShowtime
);

module.exports = router;
