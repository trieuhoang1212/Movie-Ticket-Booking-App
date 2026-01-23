const socketIO = require("socket.io");
const jwt = require("jsonwebtoken");

let io;

const initializeSocket = (server) => {
  io = socketIO(server, {
    cors: {
      origin: "*",
      methods: ["GET", "POST"],
      credentials: true,
    },
    transports: ["websocket", "polling"],
  });

  // Middleware xác thực Socket
  io.use((socket, next) => {
    try {
      const token =
        socket.handshake.auth.token ||
        socket.handshake.headers.authorization?.split(" ")[1];

      if (!token) {
        return next(new Error("Authentication error: Token required"));
      }

      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      socket.userId = decoded.userId;
      socket.user = decoded;
      next();
    } catch (error) {
      next(new Error("Authentication error: Invalid token"));
    }
  });

  io.on("connection", (socket) => {
    console.log(`✅ User connected: ${socket.userId}`);

    socket.join(`user_${socket.userId}`);

    // Gửi thông báo kết nối thành công
    socket.emit("connected", {
      message: "Connected to notification service",
      userId: socket.userId,
    });

    // Lắng nghe yêu cầu đăng ký FCM token
    socket.on("register_fcm_token", (data) => {
      console.log(
        `📱 FCM Token registered for user ${socket.userId}:`,
        data.fcmToken
      );
    });

    // Đánh dấu notification đã đọc real-time
    socket.on("mark_read", (notificationId) => {
      console.log(
        `✓ Notification ${notificationId} marked as read by user ${socket.userId}`
      );
    });

    socket.on("disconnect", () => {
      console.log(`❌ User disconnected: ${socket.userId}`);
    });

    socket.on("error", (error) => {
      console.error(`Socket error for user ${socket.userId}:`, error);
    });
  });

  console.log("Socket.IO initialized successfully");
  return io;
};

const getIO = () => {
  if (!io) {
    throw new Error("Socket.io not initialized!");
  }
  return io;
};

// Emit notification tới user cụ thể
const emitToUser = (userId, event, data) => {
  if (io) {
    io.to(`user_${userId}`).emit(event, data);
  }
};

// Broadcast tới tất cả users
const broadcastToAll = (event, data) => {
  if (io) {
    io.emit(event, data);
  }
};

module.exports = { initializeSocket, getIO, emitToUser, broadcastToAll };
