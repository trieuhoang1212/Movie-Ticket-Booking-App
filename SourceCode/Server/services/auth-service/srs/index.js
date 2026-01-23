require("dotenv").config();
const express = require("express");
const cors = require("cors");
const connectDB = require("./config/database");
const { initializeFirebase } = require("./config/firebase");
const authRoutes = require("./routes/auth.routes");
const { swaggerUi, swaggerSpec } = require("./config/swagger");

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Swagger Documentation
app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));

// Routes - Gateway already strips /api/auth prefix, so we mount at root
app.use("/", authRoutes);

// Health check endpoint
app.get("/health", (req, res) => {
  res.status(200).json({
    success: true,
    message: "Auth Service is running",
    timestamp: new Date().toISOString(),
  });
});

// Kết nối đến database và khởi động server
const startServer = async () => {
  try {
    await connectDB();
    initializeFirebase(); // Khởi tạo Firebase
    app.listen(PORT, () => {
      console.log(`Auth Service is running on port ${PORT}`);
      console.log(`Environment: ${process.env.NODE_ENV}`);
    });
  } catch (error) {
    console.error("Failed to start server:", error);
    process.exit(1);
  }
};

startServer();
