const Joi = require("joi");

// Validate tạo booking
const validateCreateBooking = (req, res, next) => {
  const schema = Joi.object({
    showtimeId: Joi.string().required(),
    seatIds: Joi.array().items(Joi.string()).min(1).required(),
  });

  const { error } = schema.validate(req.body);
  if (error) {
    return res.status(400).json({
      success: false,
      message: error.details[0].message,
    });
  }
  next();
};

module.exports = {
  validateCreateBooking,
};
