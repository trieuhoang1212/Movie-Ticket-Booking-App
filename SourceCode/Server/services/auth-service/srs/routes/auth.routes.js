const express = require("express");
const router = express.Router();
const authController = require("../controllers/auth.controller");
const {
  validateRegister,
  validateLogin,
} = require("../middlewares/validate.middleware");

// POST /api/auth/register - Đăng ký user mới
router.post("/register", validateRegister, authController.register);

// POST /api/auth/login - Đăng nhập
router.post("/login", validateLogin, authController.login);

// POST /api/auth/verify - Xác thực token
router.post("/verify", authController.verifyToken);

// GET /api/auth/profile - Lấy thông tin user từ token
router.get("/profile", authController.getProfile);

module.exports = router;