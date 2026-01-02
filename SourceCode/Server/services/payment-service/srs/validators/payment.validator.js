const Joi = require("joi");

const createPaymentSchema = Joi.object({
  orderId: Joi.string().required(),
  amount: Joi.number().min(0).required(),
  orderInfo: Joi.string().required(),
  bankCode: Joi.string().optional(),
});

const validateCreatePayment = (req, res, next) => {
  const { error } = createPaymentSchema.validate(req.body);

  if (error) {
    return res.status(400).json({
      success: false,
      message: error.details[0].message,
    });
  }

  next();
};

module.exports = { validateCreatePayment };
