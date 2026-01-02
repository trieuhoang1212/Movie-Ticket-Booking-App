const Joi = require("joi");

// Schema để validate đăng ký
const registerSchema = Joi.object({
  email: Joi.string().email().required().messages({
    "string.email": "email is not valid",
    "any.required": "email is required",
  }),
  name: Joi.string().required().messages({
    "any.required": "name is required",
  }),
  password: Joi.string().min(6).required().messages({
    "string.min": "Password must be at least 6 characters long",
    "any.required": "password is required",
  }),
});

// Schema cho login
const loginSchema = Joi.object({
  email: Joi.string().email().required().messages({
    "string.email": "email is not valid",
    "any.required": "email is required",
  }),
  password: Joi.string().required().messages({
    "any.required": "password is required",
  }),
});

// Middleware để validate request body
const validate = (schema) => {
  return (req, res, next) => {
    const { error } = schema.validate(req.body, { abortEarly: false });

    if (error) {
      const errors = error.details.map((detail) => detail.message);
      return res.status(400).json({
        success: false,
        message: "Validation error",
        errors: errors,
      });
    }

    next();
  };
};
module.exports = {
  validateRegister: validate(registerSchema),
  validateLogin: validate(loginSchema),
};
