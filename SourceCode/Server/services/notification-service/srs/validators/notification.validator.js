const Joi = require("joi");

// Validator cho đăng ký FCM token
const registerFCMTokenSchema = Joi.object({
  fcmToken: Joi.string().required().messages({
    "string.empty": "FCM token is required",
    "any.required": "FCM token is required",
  }),
  deviceInfo: Joi.object({
    deviceType: Joi.string().valid("ANDROID", "IOS", "WEB").default("ANDROID"),
    model: Joi.string().allow(""),
    osVersion: Joi.string().allow(""),
    appVersion: Joi.string().allow(""),
  }).optional(),
});

// Validator cho thông báo phim mới
const newMovieSchema = Joi.object({
  movieId: Joi.string().required(),
  movieTitle: Joi.string().required(),
  releaseDate: Joi.date().required(),
  imageUrl: Joi.string().uri().optional(),
  description: Joi.string().optional(),
});

// Validator cho thông báo đặt vé
const bookingNotificationSchema = Joi.object({
  userId: Joi.string().required(),
  bookingId: Joi.string().required(),
  movieTitle: Joi.string().required(),
  showtime: Joi.date().required(),
  seats: Joi.array().items(Joi.string()).required(),
  cinema: Joi.string().required(),
  totalAmount: Joi.number().required(),
});

// Validator cho thông báo thanh toán
const paymentNotificationSchema = Joi.object({
  userId: Joi.string().required(),
  paymentId: Joi.string().optional(),
  bookingId: Joi.string().required(),
  movieTitle: Joi.string().required(),
  amount: Joi.number().required(),
  paymentMethod: Joi.string().optional(),
  reason: Joi.string().optional(),
});

// Validator cho nhắc nhở xem phim
const movieReminderSchema = Joi.object({
  userId: Joi.string().required(),
  bookingId: Joi.string().required(),
  movieTitle: Joi.string().required(),
  showtime: Joi.date().required(),
  cinema: Joi.string().required(),
  seats: Joi.array().items(Joi.string()).required(),
});

// Middleware validator
const validate = (schema) => {
  return (req, res, next) => {
    const { error } = schema.validate(req.body, { abortEarly: false });

    if (error) {
      const errors = error.details.map((detail) => detail.message);
      return res.status(400).json({
        success: false,
        message: "Validation error",
        errors,
      });
    }

    next();
  };
};

module.exports = {
  validate,
  registerFCMTokenSchema,
  newMovieSchema,
  bookingNotificationSchema,
  paymentNotificationSchema,
  movieReminderSchema,
};
