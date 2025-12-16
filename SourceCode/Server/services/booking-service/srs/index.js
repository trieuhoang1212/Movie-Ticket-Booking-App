require("dotenv").config();
const express = require("express");
const cors = require("cors");
const admin = require("firebase-admin");
const connectDB = require("./config/database");
const bookingRoutes = require("./routes/booking.routes");
const { swaggerUi, swaggerSpec } = require("./config/swagger");

// Initialize Firebase Admin
try {
  admin.initializeApp({
    credential: admin.credential.cert({
      projectId: process.env.FIREBASE_PROJECT_ID,
      privateKeyId: process.env.FIREBASE_PRIVATE_KEY_ID,
      privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, "\n"),
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
    }),
  });
  console.log("✅ Firebase Admin initialized successfully");
} catch (error) {
  console.error("❌ Firebase initialization error:", error.message);
}

const app = express();
const PORT = process.env.PORT || 3002;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Swagger Documentation
app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));

// Routes
app.use("/api/bookings", bookingRoutes);

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
      console.log(`Environment: ${process.env.NODE_ENV}`);
      console.log(`Swagger Docs: http://localhost:${PORT}/api-docs`);
    });
  } catch (error) {
    console.error("Failed to start server:", error);
    process.exit(1);
  }
};

startServer();
