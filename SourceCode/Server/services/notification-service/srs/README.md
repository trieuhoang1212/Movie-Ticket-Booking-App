# Notification Service

Service quản lý thông báo real-time cho hệ thống đặt vé xem phim. Sử dụng **Socket.IO** cho thông báo real-time và **Firebase Cloud Messaging** cho push notifications.

## 📋 Tính năng

- ✅ Thông báo real-time qua Socket.IO
- ✅ Push notification qua Firebase Cloud Messaging
- ✅ Thông báo phim mới ra mắt
- ✅ Thông báo đặt vé thành công
- ✅ Thông báo thanh toán (thành công/thất bại)
- ✅ Nhắc nhở xem phim
- ✅ Quản lý FCM tokens
- ✅ Đánh dấu đã đọc/chưa đọc
- ✅ Swagger API documentation

## 🚀 Cài đặt

### 1. Cài đặt dependencies

```bash
cd srs
npm install
```

### 2. Cấu hình môi trường

Tạo file `.env` trong thư mục `srs/`:

```env
PORT=3005
NODE_ENV=development

# MongoDB
MONGODB_URI=mongodb://localhost:27017/booking_ticket_movie

# JWT
JWT_SECRET=your-super-secret-jwt-key
JWT_REFRESH_SECRET=your-super-secret-refresh-key
JWT_EXPIRES_IN=7d

# Firebase
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_PRIVATE_KEY_ID=your-private-key-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nyour-private-key\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk@your-project.iam.gserviceaccount.com

# Internal API Key (cho communication giữa các services)
INTERNAL_API_KEY=internal-secret-key
```

### 3. Chạy service

**Development:**

```bash
npm run dev
```

**Production:**

```bash
npm start
```

**Docker:**

```bash
docker-compose up notification-service
```

## 📡 API Endpoints

### Public APIs (Cần JWT Authentication)

#### Lấy danh sách notifications

```http
GET /api/notifications
Authorization: Bearer <token>
Query: ?page=1&limit=20
```

#### Lấy số lượng chưa đọc

```http
GET /api/notifications/unread-count
Authorization: Bearer <token>
```

#### Đánh dấu đã đọc

```http
PATCH /api/notifications/:id/read
Authorization: Bearer <token>
```

#### Đánh dấu tất cả đã đọc

```http
PATCH /api/notifications/read-all
Authorization: Bearer <token>
```

#### Xóa notification

```http
DELETE /api/notifications/:id
Authorization: Bearer <token>
```

#### Đăng ký FCM Token

```http
POST /api/notifications/register-token
Authorization: Bearer <token>
Content-Type: application/json

{
  "fcmToken": "string",
  "deviceInfo": {
    "deviceType": "ANDROID" | "IOS" | "WEB",
    "model": "string",
    "osVersion": "string",
    "appVersion": "string"
  }
}
```

### Internal APIs (Chỉ cho services khác)

**Headers:** `x-api-key: internal-secret-key`

#### Thông báo phim mới

```http
POST /api/notifications/internal/new-movie
x-api-key: internal-secret-key

{
  "movieId": "string",
  "movieTitle": "string",
  "releaseDate": "2024-01-01",
  "imageUrl": "string",
  "description": "string"
}
```

#### Thông báo đặt vé

```http
POST /api/notifications/internal/booking-confirmed
x-api-key: internal-secret-key

{
  "userId": "string",
  "bookingId": "string",
  "movieTitle": "string",
  "showtime": "2024-01-01T19:00:00Z",
  "seats": ["A1", "A2"],
  "cinema": "CGV Vincom",
  "totalAmount": 200000
}
```

#### Thông báo thanh toán thành công

```http
POST /api/notifications/internal/payment-success
x-api-key: internal-secret-key

{
  "userId": "string",
  "paymentId": "string",
  "bookingId": "string",
  "movieTitle": "string",
  "amount": 200000,
  "paymentMethod": "VNPay"
}
```

#### Thông báo thanh toán thất bại

```http
POST /api/notifications/internal/payment-failed
x-api-key: internal-secret-key

{
  "userId": "string",
  "bookingId": "string",
  "movieTitle": "string",
  "amount": 200000,
  "reason": "Insufficient balance"
}
```

#### Nhắc nhở xem phim

```http
POST /api/notifications/internal/movie-reminder
x-api-key: internal-secret-key

{
  "userId": "string",
  "bookingId": "string",
  "movieTitle": "string",
  "showtime": "2024-01-01T19:00:00Z",
  "cinema": "CGV Vincom",
  "seats": ["A1", "A2"]
}
```

## 🔌 Socket.IO Events

### Client → Server

#### Kết nối

```javascript
const socket = io("http://localhost:3005", {
  auth: {
    token: "your-jwt-token",
  },
});
```

#### Đăng ký FCM Token

```javascript
socket.emit("register_fcm_token", {
  fcmToken: "your-fcm-token",
});
```

#### Đánh dấu đã đọc

```javascript
socket.emit("mark_read", notificationId);
```

### Server → Client

#### Kết nối thành công

```javascript
socket.on("connected", (data) => {
  console.log(data.message); // "Connected to notification service"
});
```

#### Nhận notification mới

```javascript
socket.on("notification", (notification) => {
  console.log("New notification:", notification);
  /*
  {
    id: "...",
    type: "BOOKING_CONFIRM",
    title: "Đặt Vé Thành Công",
    message: "Bạn đã đặt vé...",
    data: {...},
    createdAt: "2024-01-01T..."
  }
  */
});
```

#### Events theo loại

```javascript
// Phim mới
socket.on('new_movie', (data) => { ... });

// Đặt vé thành công
socket.on('booking_confirmed', (data) => { ... });

// Thanh toán thành công
socket.on('payment_success', (data) => { ... });

// Thanh toán thất bại
socket.on('payment_failed', (data) => { ... });

// Nhắc nhở xem phim
socket.on('movie_reminder', (data) => { ... });

// Notification đã đọc
socket.on('notification_read', (data) => { ... });

// Tất cả đã đọc
socket.on('all_notifications_read', () => { ... });

// Notification đã xóa
socket.on('notification_deleted', (data) => { ... });
```

## 📊 Database Models

### Notification

```javascript
{
  userId: String,
  type: "NEW_MOVIE" | "BOOKING_CONFIRM" | "PAYMENT_SUCCESS" | "PAYMENT_FAILED" | "MOVIE_REMINDER" | "PROMOTION" | "SYSTEM",
  title: String,
  message: String,
  data: {
    movieId: String,
    movieTitle: String,
    bookingId: String,
    paymentId: String,
    amount: Number,
    showtime: Date,
    imageUrl: String,
    deepLink: String
  },
  isRead: Boolean,
  readAt: Date,
  sentVia: {
    socket: Boolean,
    push: Boolean
  },
  createdAt: Date,
  updatedAt: Date
}
```

### UserDevice

```javascript
{
  userId: String,
  fcmToken: String,
  deviceType: "ANDROID" | "IOS" | "WEB",
  deviceInfo: {
    model: String,
    osVersion: String,
    appVersion: String
  },
  isActive: Boolean,
  lastUsedAt: Date,
  createdAt: Date,
  updatedAt: Date
}
```

## 🔥 Firebase Setup

1. Tạo Firebase project tại [Firebase Console](https://console.firebase.google.com/)
2. Vào **Project Settings** → **Service Accounts**
3. Click **Generate New Private Key**
4. Copy thông tin vào file `.env`

## 📚 Documentation

Swagger API documentation có sẵn tại: `http://localhost:3005/api-docs`

## 🧪 Testing

### Test với cURL

```bash
# Gửi thông báo phim mới
curl -X POST http://localhost:3005/api/notifications/internal/new-movie \
  -H "x-api-key: internal-secret-key" \
  -H "Content-Type: application/json" \
  -d '{
    "movieId": "123",
    "movieTitle": "Avatar 3",
    "releaseDate": "2024-12-25",
    "imageUrl": "https://example.com/avatar3.jpg"
  }'
```

### Test Socket.IO với JavaScript

```javascript
import io from "socket.io-client";

const socket = io("http://localhost:3005", {
  auth: { token: "your-jwt-token" },
});

socket.on("connect", () => {
  console.log("Connected to notification service");
});

socket.on("notification", (notification) => {
  console.log("Received:", notification);
  // Show notification to user
});
```

## 🐳 Docker

Build image:

```bash
docker build -t notification-service .
```

Run container:

```bash
docker run -p 3005:3005 --env-file .env notification-service
```

## 📝 Environment Variables

| Variable                | Description               | Required           |
| ----------------------- | ------------------------- | ------------------ |
| PORT                    | Service port              | No (default: 3005) |
| MONGODB_URI             | MongoDB connection string | Yes                |
| JWT_SECRET              | JWT secret key            | Yes                |
| FIREBASE_PROJECT_ID     | Firebase project ID       | Yes                |
| FIREBASE_PRIVATE_KEY_ID | Firebase private key ID   | Yes                |
| FIREBASE_PRIVATE_KEY    | Firebase private key      | Yes                |
| FIREBASE_CLIENT_EMAIL   | Firebase client email     | Yes                |
| INTERNAL_API_KEY        | Internal API key          | No                 |

## 🔐 Security

- JWT authentication cho user APIs
- API key authentication cho internal APIs
- Socket.IO authentication middleware
- CORS configuration
- Input validation với Joi

## 📞 Support

Để được hỗ trợ, vui lòng liên hệ team backend.
