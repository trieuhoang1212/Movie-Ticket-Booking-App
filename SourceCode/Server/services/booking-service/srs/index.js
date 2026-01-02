require("dotenv").config();
const express = require("express");
const cors = require("cors");
const connectDB = require("./config/database");
const bookingRoutes = require("./routes/booking.routes");


const app = express();
const PORT = process.env.PORT || 3002;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Swagger Documentation
// app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));

// Routes
app.use("/", bookingRoutes);

// Health check endpoint
app.get("/health", (req, res) => {
  res.status(200).json({
    success: true,
    message: "Booking Service is running",
    timestamp: new Date().toISOString(),
  });
});

// Kết nối đến database và khởi động server
const startServer = async () => {
  try {
    await connectDB();
    app.listen(PORT, () => {
      console.log(`Booking Service is running on port ${PORT}`);
      // console.log(`Swagger Docs: http://localhost:${PORT}/api-docs`);
    });
  } catch (error) {
    console.error("Failed to start server:", error);
    process.exit(1);
  }
};

startServer();
