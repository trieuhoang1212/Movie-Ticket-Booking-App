# 🎬 BACKEND DOCUMENTATION - Movie Ticket Booking App

## 📝 Tổng quan

Backend của ứng dụng đặt vé xem phim được xây dựng theo kiến trúc **Microservices**, bao gồm 1 API Gateway (TypeScript) và 5 services độc lập (JavaScript), tất cả được containerized bằng Docker và quản lý qua Docker Compose.

### 🎯 Đặc điểm Microservices:

- ✅ **Loosely Coupled**: Mỗi service hoạt động độc lập
- ✅ **Independently Deployable**: Deploy và scale từng service riêng biệt
- ✅ **Database per Service**: Shared MongoDB nhưng collections riêng
- ✅ **Technology Diversity**: TypeScript (Gateway) + JavaScript (Services)
- ✅ **Service Discovery**: Docker network với container names
- ✅ **Inter-Service Communication**: HTTP REST APIs với internal API key
- ✅ **Containerization**: Docker cho isolation và portability
- ✅ **Health Checks**: Mỗi service có /health endpoint

---

## 🏗️ Kiến trúc hệ thống

```
┌─────────────┐
│   Client    │ (Flutter Mobile App)
│  (Flutter)  │
└──────┬──────┘
       │ HTTP/HTTPS
       ▼
┌─────────────────────────────────┐
│       API Gateway (3000)        │ ◄── TypeScript, Express
│  - Routing                      │
│  - Rate Limiting                │
│  - Caching                      │
│  - Authentication Middleware    │
└────────┬────────────────────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌──────┐ ┌──────┐ ... (5 Services)
```

### Services Architecture:

```
API Gateway (Port 3000)
    ├── Auth Service (Port 3001)
    ├── Booking Service (Port 3002)
    ├── User Service (Port 3003)
    ├── Payment Service (Port 3004)
    └── Notification Service (Port 3005)
         ↓
    MongoDB (Port 27017)
```

---

## 🛠️ Công nghệ sử dụng

### Core Technologies

| Technology         | Version | Mục đích                      |
| ------------------ | ------- | ----------------------------- |
| **Node.js**        | 20+     | Runtime environment           |
| **Express.js**     | 4.18.2  | Web framework                 |
| **TypeScript**     | 5.3.3   | Language (API Gateway)        |
| **JavaScript**     | ES6+    | Language (Services)           |
| **MongoDB**        | 7.0     | NoSQL Database                |
| **Mongoose**       | 8.x     | ODM cho MongoDB               |
| **Docker**         | Latest  | Containerization              |
| **Docker Compose** | Latest  | Multi-container orchestration |

### Authentication & Security

| Package                | Mục đích                                     |
| ---------------------- | -------------------------------------------- |
| **jsonwebtoken**       | JWT authentication                           |
| **bcryptjs**           | Password hashing                             |
| **Firebase Admin SDK** | Firebase authentication & push notifications |
| **Joi**                | Request validation                           |

### Payment Integration

| Package   | Mục đích                          |
| --------- | --------------------------------- |
| **vnpay** | VNPay payment gateway integration |

### Communication & Notifications

| Package                      | Mục đích                         |
| ---------------------------- | -------------------------------- |
| **Socket.IO**                | Real-time notifications          |
| **Firebase Cloud Messaging** | Push notifications               |
| **Axios**                    | Inter-service HTTP communication |

### Documentation & Development

| Package                | Mục đích                          |
| ---------------------- | --------------------------------- |
| **Swagger UI Express** | API documentation                 |
| **swagger-jsdoc**      | Generate Swagger specs from JSDoc |
| **nodemon**            | Development auto-reload           |
| **dotenv**             | Environment variables management  |

### API Gateway Specific

| Package                | Mục đích                        |
| ---------------------- | ------------------------------- |
| **express-http-proxy** | Reverse proxy cho microservices |
| **express-rate-limit** | Rate limiting                   |
| **node-cache**         | In-memory caching               |

---

## 📦 Chi tiết các Services

### 1️⃣ **API Gateway** (Port 3000) - 🚪 Entry Point

**Ngôn ngữ:** TypeScript  
**Framework:** Express.js  
**Pattern:** API Gateway Pattern (Microservices)

#### 🎯 Vai trò chính:

API Gateway đóng vai trò **Single Entry Point** cho toàn bộ backend system, giống như một "cổng ra vào duy nhất" mà client phải đi qua.

#### ⚙️ Chức năng chi tiết:

##### 1. **Authentication Middleware** 🔐

- Xác thực JWT token trước khi forward request đến services
- Verify token signature và expiration
- Extract user information từ token
- Inject user info vào request headers (`__user_info`)
- **Flow:**
  ```
  Request → Check JWT → Valid? → Add user info → Forward
                      ↓ Invalid
                   Return 401 Unauthorized
  ```

##### 2. **Request Routing** 🚦

- **Reverse Proxy Pattern**: Điều hướng request dựa trên URL path
- **Auto-detect environment**: Docker (production) hoặc Localhost (development)
- **Service Mapping (Docker mode):**
  ```typescript
  /api/auth/*          → auth-service:3001
  /api/booking/*       → booking-service:3002
  /api/bookings/*      → booking-service:3002  // Alias
  /api/user/*          → user-service:3003
  /api/payment/*       → payment-service:3004
  /api/notifications/* → notification-service:3005
  ```
- **Service Mapping (Localhost mode):**
  ```typescript
  /api/auth/*          → 127.0.0.1:3001
  /api/booking/*       → 127.0.0.1:3002
  // ... tương tự
  ```
- **Proxy Configuration**: express-http-proxy với userResDecorator
- Path stripping: `/api/auth/login` → service nhận `/login`
- Service discovery through Docker network names

##### 3. **Rate Limiting** ⚡

- Giới hạn số request per IP/user
- Tránh spam, brute force attacks, DDoS
- **Configuration:**
  ```typescript
  - Window: 15 minutes
  - Max requests: 100 per window
  - Response: 429 Too Many Requests
  ```

##### 4. **Response Caching** 💾

- **In-memory caching** với node-cache
- Cache cho endpoints tĩnh:
  - `/api/booking/movies` (TTL: 5 phút)
  - `/api/booking/showtimes` (TTL: 2 phút)
- **Benefits:**
  - Giảm database load
  - Faster response time
  - Better user experience

##### 5. **Request/Response Logging** 📝

- Log tất cả incoming requests
- Log format:
  ```
  [Timestamp] METHOD /path
    User: username/email
    Query: {...}
    Body: {...} (sanitized - no passwords)
  ```
- Giúp debugging và monitoring

##### 6. **Error Handling** 🛡️

- Centralized error handling
- Consistent error response format:
  ```json
  {
    "success": false,
    "error": "Error message",
    "code": "ERROR_CODE",
    "timestamp": "2026-01-21T..."
  }
  ```
- Handle service timeout
- Handle service unavailable

##### 7. **Security Features** 🔒

- **CORS configuration**: Allow Flutter app origin
- **Security headers**: Helmet.js
- **Request sanitization**
- **SSL/TLS support** (production)

#### 🔓 Public Endpoints (không cần authentication):

```typescript
// Authentication endpoints
/api/ahtu / login / api / auth / register / api / auth / firebase -
  login /
    // Public booking data
    api /
    booking /
    movies /
    api /
    bookings /
    movies /
    api /
    booking /
    showtimes /
    // Payment callbacks (VNPay)
    api /
    payment;
/*
/api/payments/*

// Health checks
/health
/api/*/ health;
```

#### 🔐 Protected Endpoints (cần JWT):

Tất cả endpoints khác đều yêu cầu:

```
Authorization: Bearer <JWT_TOKEN>
```

#### 📋 Middleware Pipeline (Thực tế):

```
Incoming Request
  ↓
[1] Express JSON Parser (limit: 10mb)
  ↓
[2] Express URL Encoded Parser
  ↓
[3] Authentication Middleware (requireAuthentication)
    │
    ├─→ Check public endpoints → Skip auth
    ├─→ Verify JWT token
    ├─→ Extract user info
    └─→ Inject __user_info header
  ↓
[4] Logger Middleware
    ├─→ Log timestamp, method, URL
    ├─→ Log user info (if authenticated)
    ├─→ Log query params
    └─→ Log body (sanitized - no passwords)
  ↓
[5] Cache Middleware (caching)
    │
    ├─→ Check if URL is cacheable
    ├─→ If cached → Return cached response
    └─→ If not cached → Continue
  ↓
[6] Proxy to Target Service (express-http-proxy)
    │
    ├─→ Forward request to service
    ├─→ Service processes request
    └─→ Receive response
  ↓
[7] User Response Decorator (userResDecorator)
    │
    ├─→ Check if cacheable endpoint
    └─→ Save response to cache
  ↓
[8] Error Handler Middleware (errorHandler)
    │
    ├─→ AuthenticationError → 401
    └─→ Other errors → 500
  ↓
Response to Client
```

**Note**: Rate limiter hiện đang disabled cho development

#### 🏗️ Cấu trúc code:

```
api-gateway/
├── src/
│   ├── authentication/
│   │   └── authentication.service.ts    # JWT validation logic
│   ├── cache/
│   │   └── cache.service.ts            # Node-cache wrapper
│   ├── config/
│   │   └── service.address.ts          # Service URLs mapping
│   ├── errorHandler/
│   │   ├── errorModel.ts               # Error types
│   │   └── errorHandler.ts             # Error middleware
│   └── gateway.ts                       # Main entry point
├── Dockerfile
├── package.json
└── tsconfig.json
```

#### 🔧 Key Technologies:

| Package                | Version | Purpose                       |
| ---------------------- | ------- | ----------------------------- |
| **express**            | 4.18.2  | Web framework                 |
| **express-http-proxy** | 2.0.0   | Reverse proxy to services     |
| **express-rate-limit** | 7.1.5   | Rate limiting middleware      |
| **node-cache**         | 5.1.2   | In-memory caching             |
| **axios**              | 1.6.2   | HTTP client for health checks |
| **dotenv**             | 16.3.1  | Environment variables         |
| **typescript**         | 5.3.3   | Type safety                   |

#### 📊 Performance Metrics:

- **Average Response Time**: ~50-100ms (without service processing)
- **Cache Hit Rate**: ~60-70% for movies/showtimes
- **Concurrent Connections**: Support 1000+ connections
- **Memory Usage**: ~50-100MB (với cache)

#### 🔄 Service Communication Flow:

```
Client (Flutter App)
       ↓
   [Ngrok/Direct URL]
       ↓
API Gateway :3000
       ↓
 ┌─────┴─────┬──────────┬──────────┬──────────┐
 ↓           ↓          ↓          ↓          ↓
Auth:3001  Booking   User     Payment    Notification
          :3002     :3003     :3004        :3005
 ↓           ↓          ↓          ↓          ↓
       MongoDB :27017
```

#### 🚀 Advantages của API Gateway Pattern:

✅ **Single Entry Point**: Client chỉ cần biết 1 URL  
✅ **Security**: Centralized authentication & authorization  
✅ **Load Balancing**: Có thể distribute requests  
✅ **Caching**: Reduce backend load  
✅ **Monitoring**: Centralized logging & metrics  
✅ **Version Control**: API versioning dễ dàng  
✅ **Rate Limiting**: Protect services from overload  
✅ **Service Independence**: Services không expose trực tiếp

#### ⚠️ Considerations:

- Single point of failure (cần load balancer cho production)
- Potential bottleneck nếu không optimize
- Additional network hop (latency tăng nhẹ)

#### 🔧 Configuration Example:

```typescript
// Service addresses mapping
const ContextPathMap = new Map<string, string>([
  ["/api/auth", "http://auth-service:3001"],
  ["/api/booking", "http://booking-service:3002"],
  ["/api/bookings", "http://booking-service:3002"],
  ["/api/user", "http://user-service:3003"],
  ["/api/payment", "http://payment-service:3004"],
  ["/api/notifications", "http://notification-service:3005"],
]);

// Rate limiter config
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: "Too many requests from this IP",
});

// Cache config
const cache = new NodeCache({
  stdTTL: 300, // 5 minutes default
  checkperiod: 60, // cleanup every 60 seconds
});
```

---

### 2️⃣ **Auth Service** (Port 3001)

**Ngôn ngữ:** JavaScript  
**Database:** MongoDB

#### Chức năng:

- ✅ **Đăng ký tài khoản** (email/password)
- ✅ **Đăng nhập** (email/password)
- ✅ **Firebase Login** (Google/Facebook)
- ✅ **JWT Token Management**
  - Generate access token
  - Token verification
  - Token refresh
- ✅ **FCM Token Management**
  - Lưu device token cho push notifications
  - Update/delete FCM tokens
- ✅ **Password Management**
  - Change password
  - Forgot password
  - Reset password
- ✅ **Profile Management**
  - Get user profile
  - Update user profile

#### API Endpoints:

```javascript
POST / api / auth / register; // Đăng ký
POST / api / auth / login; // Đăng nhập
POST / api / auth / firebase - login; // Login với Firebase
POST / api / auth / refresh - token; // Refresh JWT token
GET / api / auth / profile; // Lấy thông tin user
PUT / api / auth / profile; // Cập nhật profile
POST / api / auth / change - password; // Đổi password
POST / api / auth / forgot - password; // Quên password
POST / api / auth / reset - password; // Reset password
POST / api / auth / fcm - token; // Lưu FCM token
DELETE / api / auth / fcm - token; // Xóa FCM token
GET / health; // Health check
```

#### Technologies:

- **bcryptjs**: Hash password
- **jsonwebtoken**: Generate & verify JWT
- **Firebase Admin SDK**: Verify Firebase tokens
- **Joi**: Request validation
- **Swagger**: API documentation

#### Models:

```javascript
User {
  name: String,
  email: String (unique),
  password: String (hashed),
  role: String (user/admin),
  fcmTokens: [String],
  createdAt: Date,
  updatedAt: Date
}
```

---

### 3️⃣ **Booking Service** (Port 3002)

**Ngôn ngữ:** JavaScript  
**Database:** MongoDB

#### Chức năng:

- 🎬 **Movie Management**
  - Lấy danh sách phim
  - Lấy chi tiết phim
  - Lọc phim theo thể loại, ngày chiếu
- 🎞️ **Showtime Management**
  - Lấy lịch chiếu theo phim
  - Lấy suất chiếu theo rạp
- 💺 **Seat Selection**
  - Lấy danh sách ghế theo suất chiếu
  - Kiểm tra ghế còn trống
  - Lock ghế khi đang chọn (temporary hold)
- 🎫 **Booking Management**
  - Tạo booking mới
  - Lấy danh sách booking của user
  - Chi tiết booking
  - Hủy booking
  - Xóa booking
- 🔄 **Internal Communication**
  - Nhận thông báo từ Payment Service
  - Gửi notification qua Notification Service
  - Update booking status

#### API Endpoints:

```javascript
// Movies
GET    /api/bookings/movies                    // Danh sách phim
GET    /api/bookings/movies/:id                // Chi tiết phim
GET    /api/bookings/movies/:id/showtimes      // Lịch chiếu theo phim

// Showtimes & Seats
GET    /api/bookings/showtimes/:id/seats       // Danh sách ghế

// Bookings
POST   /api/bookings                           // Tạo booking
GET    /api/bookings/my-bookings               // Booking của tôi
GET    /api/bookings/:id                       // Chi tiết booking
PUT    /api/bookings/:id/cancel                // Hủy booking
DELETE /api/bookings/:id                       // Xóa booking

// Internal APIs (từ Payment Service)
POST   /api/bookings/internal/confirm          // Confirm booking
POST   /api/bookings/internal/cancel           // Cancel booking
```

#### Technologies:

- **Mongoose**: MongoDB ODM
- **Axios**: HTTP client (gọi Notification Service)
- **Joi**: Validation
- **Firebase Admin**: Authentication verification

#### Models:

```javascript
Movie {
  title: String,
  description: String,
  genre: [String],
  duration: Number,
  rating: Number,
  releaseDate: Date,
  posterUrl: String,
  trailerUrl: String
}

Showtime {
  movieId: ObjectId,
  cinemaId: ObjectId,
  roomId: ObjectId,
  startTime: Date,
  endTime: Date,
  price: Number
}

Seat {
  showtimeId: ObjectId,
  row: String,
  number: Number,
  type: String (standard/vip),
  status: String (available/booked/locked),
  price: Number
}

Booking {
  userId: ObjectId,
  showtimeId: ObjectId,
  seats: [ObjectId],
  totalPrice: Number,
  status: String (pending/confirmed/cancelled),
  bookingCode: String,
  paymentId: ObjectId,
  createdAt: Date
}
```

---

### 4️⃣ **Payment Service** (Port 3004)

**Ngôn ngữ:** JavaScript  
**Database:** MongoDB

#### Chức năng:

- 💳 **VNPay Integration**
  - Tạo payment URL
  - Xử lý callback từ VNPay
  - Verify payment signature
- 💰 **Payment Processing**
  - Tạo payment request
  - Kiểm tra trạng thái thanh toán
  - Refund (hoàn tiền)
- 🔄 **Booking Integration**
  - Confirm booking sau khi thanh toán thành công
  - Cancel booking nếu thanh toán thất bại
- 📢 **Notification Integration**
  - Gửi thông báo thanh toán thành công/thất bại
  - Email confirmation

#### API Endpoints:

```javascript
POST   /api/payment/create           // Tạo payment URL
GET    /api/payment/vnpay-return     // Callback từ VNPay (user redirect)
GET    /api/payment/vnpay-ipn        // IPN callback từ VNPay (server-to-server)
GET    /api/payment/:id              // Chi tiết payment
POST   /api/payment/:id/refund       // Hoàn tiền
GET    /health                       // Health check
```

#### VNPay Integration Flow:

```
1. User tạo booking → Booking Service
2. User nhấn thanh toán → Payment Service
3. Payment Service tạo VNPay URL
4. User redirect đến VNPay
5. User thanh toán trên VNPay
6. VNPay redirect về /vnpay-return
7. VNPay gọi IPN webhook /vnpay-ipn
8. Payment Service verify signature
9. Update payment status
10. Gọi Booking Service confirm/cancel
11. Gọi Notification Service gửi thông báo
```

#### Technologies:

- **vnpay**: VNPay SDK
- **Axios**: Inter-service communication
- **Joi**: Validation
- **Swagger**: API docs

#### Environment Variables:

```env
VNP_TMN_CODE=DEMOV210              # VNPay merchant code
VNP_HASH_SECRET=***                # VNPay hash secret
VNP_URL=https://sandbox.vnpayment.vn/paymentv2/vpcpay.html
VNP_RETURN_URL=http://10.0.2.2:3000/api/payment/vnpay-return
VNP_IPN_URL=http://payment-service:3004/api/payment/vnpay-ipn
```

#### Models:

```javascript
Payment {
  userId: ObjectId,
  bookingId: ObjectId,
  amount: Number,
  method: String (vnpay),
  status: String (pending/success/failed/refunded),
  vnpayTransactionId: String,
  vnpayResponseCode: String,
  vnpayBankCode: String,
  vnpayCardType: String,
  metadata: Object,
  createdAt: Date,
  updatedAt: Date
}
```

---

### 5️⃣ **Notification Service** (Port 3005)

**Ngôn ngữ:** JavaScript  
**Database:** MongoDB

#### Chức năng:

- 🔔 **Real-time Notifications**
  - Socket.IO connection
  - Broadcast notifications
- 📱 **Push Notifications**
  - Firebase Cloud Messaging
  - Send to specific users
  - Send to multiple users
- 📧 **Notification Types**
  - Phim mới ra mắt
  - Booking thành công
  - Thanh toán thành công/thất bại
  - Nhắc nhở xem phim
  - Khuyến mãi
- 📜 **Notification Management**
  - Lấy danh sách notifications
  - Đánh dấu đã đọc/chưa đọc
  - Đếm số notification chưa đọc
  - Xóa notification
- 🔐 **FCM Token Management**
  - Lưu/cập nhật device tokens
  - Xóa tokens khi logout

#### API Endpoints:

**Public APIs (cần JWT authentication):**

```javascript
GET    /api/notifications                    // Lấy danh sách
GET    /api/notifications/unread-count       // Số lượng chưa đọc
PATCH  /api/notifications/:id/read           // Đánh dấu đã đọc
PATCH  /api/notifications/mark-all-read      // Đánh dấu tất cả đã đọc
DELETE /api/notifications/:id                // Xóa notification
POST   /api/notifications/test               // Test gửi notification
```

**Internal APIs (chỉ các services khác gọi):**

```javascript
POST   /api/notifications/internal/new-movie        // Phim mới
POST   /api/notifications/internal/booking-success  // Đặt vé thành công
POST   /api/notifications/internal/payment-success  // Thanh toán thành công
POST   /api/notifications/internal/payment-failed   // Thanh toán thất bại
POST   /api/notifications/internal/movie-reminder   // Nhắc nhở xem phim
```

#### Socket.IO Events:

```javascript
// Client → Server
"connect"; // Kết nối
"authenticate"; // Xác thực với JWT
"disconnect"; // Ngắt kết nối

// Server → Client
"notification"; // Notification mới
"authenticated"; // Xác thực thành công
"error"; // Lỗi
```

#### Technologies:

- **Socket.IO**: Real-time WebSocket
- **Firebase Admin SDK**: Push notifications
- **Express**: HTTP API
- **Mongoose**: MongoDB ODM

#### Models:

```javascript
Notification {
  userId: ObjectId,
  title: String,
  message: String,
  type: String (new_movie/booking/payment/reminder/promotion),
  data: Object,          // Additional data (movieId, bookingId, etc.)
  isRead: Boolean,
  createdAt: Date
}
```

---

### 6️⃣ **User Service** (Port 3003)

**Ngôn ngữ:** JavaScript  
**Database:** MongoDB

#### Chức năng:

- 👤 **User Profile Management**
  - Lấy thông tin user
  - Cập nhật profile
  - Upload avatar
- 📊 **User Statistics**
  - Số lượng booking
  - Tổng chi tiêu
  - Phim đã xem
- 🎯 **User Preferences**
  - Thể loại phim yêu thích
  - Rạp yêu thích
  - Cài đặt thông báo

#### Trạng thái hiện tại:

⚠️ **User Service chưa có routes được implement**. Hiện tại các chức năng user được xử lý trực tiếp trong Auth Service.

---

## 🔗 Liên kết Frontend - Backend

### 🎯 **Tổng quan luồng kết nối**

```
Flutter App (Client)
       ↓
   [Ngrok Tunnel]
       ↓
API Gateway :3000 (TypeScript)
       │
       ├─→ Verify JWT Token
       ├─→ Log Request
       ├─→ Check Cache
       └─→ Proxy to Service
              ↓
   ┌──────────┴──────────┐
   ↓                     ↓
Services (JavaScript)   MongoDB
   ↓
Return Response
   ↓
API Gateway
   ↓
Save to Cache (if applicable)
   ↓
Return to Flutter App
```

### 1. **API Configuration** (Flutter)

File: `SourceCode/Client/lib/core/config/api_config.dart`

```dart
class ApiConfig {
  static const String baseUrl = 'https://animally-nonseismic-hadlee.ngrok-free.dev';
  static const String paymentBaseUrl = 'https://animally-nonseismic-hadlee.ngrok-free.dev';

  static const String authEndpoint = '/api/auth';
  static const String bookingEndpoint = '/api/bookings';
  static const String movieEndpoint = '/api/booking/movies';
  static const String paymentEndpoint = '/api/payments';
}
```

**Cách hoạt động:**

- Flutter gọi: `${baseUrl}${authEndpoint}/login` = `https://.../api/auth/login`
- Ngrok tunnel forward đến: `http://localhost:3000/api/auth/login`
- API Gateway nhận và proxy đến: `auth-service:3001/login`

### 2. **Authentication Flow** - Chi tiết Logic

#### **Register Flow:**

```
Flutter App
  ↓ POST /api/auth/register
  │ Body: { name, email, password }
  ↓
API Gateway
  ↓ Check: Public endpoint → Skip JWT check
  ↓ Proxy to auth-service:3001/register
  ↓
Auth Service (auth.controller.js)
  ↓
[1] Check if email exists
    const existingUser = await User.findOne({ email });
    if (existingUser) return 409 "Email already in use"
  ↓
[2] Create new user (password auto-hashed by mongoose middleware)
    const user = new User({ name, email, password });
    await user.save();
  ↓
[3] Generate JWT Tokens
    const token = jwt.sign({ id: user._id }, JWT_SECRET, { expiresIn: '7d' });
    const refreshToken = jwt.sign({ id: user._id }, JWT_SECRET, { expiresIn: '7d' });
  ↓
[4] Return Response
    {
      success: true,
      data: {
        user: { id, name, email, role },
        token,        // JWT for authentication
        refreshToken  // For refreshing expired tokens
      }
    }
  ↓
Flutter App
  ↓
[5] Save to SecureStorage
    await storage.write('token', token);
    await storage.write('refreshToken', refreshToken);
    await storage.write('user', jsonEncode(user));
```

#### **Login Flow:**

```
Flutter App
  ↓ POST /api/auth/login
  │ Body: { email, password }
  ↓
API Gateway
  ↓ Public endpoint → Forward
  ↓
Auth Service
  ↓
[1] Find user by email
    const user = await User.findOne({ email });
    if (!user) return 401 "Invalid email or password"
  ↓
[2] Compare password (using bcrypt)
    const isPasswordValid = await user.comparePassword(password);
    // comparePassword() method in User model:
    // UserSchema.methods.comparePassword = function(candidatePassword) {
    //   return bcrypt.compare(candidatePassword, this.password);
    // };
  ↓
[3] Generate tokens & return
    Same as register flow
```

#### **Protected Request Flow:**

```
Flutter App
  ↓ GET /api/bookings/my-bookings
  │ Headers: { Authorization: "Bearer <token>" }
  ↓
API Gateway (authentication middleware)
  ↓
[1] Extract token from header
    let jwtToken = req.header("authorization");
    jwtToken = jwtToken?.split(" ")[1];
  ↓
[2] Verify token (currently commented out - just passes through)
    // TODO: Should verify with Auth Service
    // For now: trusts all tokens
  ↓
[3] Forward to target service
    Proxy to booking-service:3002/my-bookings
  ↓
Booking Service (auth middleware)
  ↓
[4] Verify JWT token again
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded; // { id: userId }
  ↓
[5] Find user's bookings
    const bookings = await Booking.find({ userId: req.user.id });
  ↓
[6] Return data
```

### 3. **Booking Flow** - Chi tiết Code Logic

#### **Complete Booking Process với Code:**

```javascript
// ============================================
// BƯỚC 1: LẤY DANH SÁCH PHIM
// ============================================
// Flutter: GET /api/booking/movies
// → API Gateway (check cache first)
// → booking-service:3002/movies

exports.getMovies = async (req, res) => {
  const movies = await Movie.find()
    .select('title posterUrl genre rating duration releaseDate')
    .sort({ releaseDate: -1 });

  return res.json({
    success: true,
    data: movies
  });
};

// ============================================
// BƯỚC 2: XEM CHI TIẾT PHIM & CHỌN SUẤT CHIẾU
// ============================================
// Flutter: GET /api/booking/movies/:id/showtimes

exports.getShowtimesByMovie = async (req, res) => {
  const { movieId } = req.params;

  const showtimes = await Showtime.find({ movieId })
    .populate('cinemaId')
    .populate('roomId')
    .sort({ startTime: 1 });

  return res.json({
    success: true,
    data: showtimes
  });
};

// ============================================
// BƯỚC 3: CHỌN GHẾ
// ============================================
// Flutter: GET /api/bookings/showtimes/:id/seats

exports.getSeatsByShowtime = async (req, res) => {
  const { showtimeId } = req.params;

  const seats = await Seat.find({ showtimeId })
    .select('seatNumber row type status price')
    .sort({ row: 1, seatNumber: 1 });

  // Format: [
  //   { _id, seatNumber: 'A1', row: 'A', type: 'standard', status: 'available', price: 50000 },
  //   { _id, seatNumber: 'A2', row: 'A', type: 'vip', status: 'booked', price: 80000 }
  // ]

  return res.json({
    success: true,
    data: seats
  });
};

// ============================================
// BƯỚC 4: TẠO BOOKING
// ============================================
// Flutter: POST /api/bookings
// Body: { showtimeId, seatIds: ['id1', 'id2'] }
// Headers: { Authorization: "Bearer <token>" }

exports.createBooking = async (req, res) => {
  const { showtimeId, seatIds } = req.body;
  const userId = req.user.id; // Từ JWT middleware

  console.log("📝 Creating booking:", { userId, showtimeId, seatIds });

  // [1] Kiểm tra showtime exists
  const showtime = await Showtime.findById(showtimeId).populate('movieId');
  if (!showtime) {
    return res.status(404).json({ message: "Showtime not found" });
  }

  // [2] Kiểm tra ghế available
  const seats = await Seat.find({
    _id: { $in: seatIds },
    showtimeId: showtimeId,
    status: 'available'  // CHỈ lấy ghế available
  });

  if (seats.length !== seatIds.length) {
    return res.status(400).json({
      message: "Some seats are not available"
    });
  }

  // [3] Tính tổng tiền
  let totalAmount = 0;
  const bookingSeats = seats.map(seat => {
    const price = showtime.price[seat.type]; // { standard: 50000, vip: 80000 }
    totalAmount += price;
    return {
      seatId: seat._id,
      seatNumber: seat.seatNumber,
      type: seat.type,
      price: price
    };
  });

  // [4] Tạo booking code
  const bookingCode = `BK${Date.now()}${Math.floor(Math.random() * 1000)}`;

  // [5] Lưu booking vào database
  const booking = new Booking({
    userId,
    showtimeId,
    seats: bookingSeats,
    totalAmount,
    bookingCode,
    status: 'pending',           // pending → confirmed (sau khi thanh toán)
    paymentStatus: 'pending'     // pending → paid
  });
  await booking.save();

  // [6] Cập nhật trạng thái ghế
  await Seat.updateMany(
    { _id: { $in: seatIds } },
    { status: 'reserved', bookingId: booking._id }
  );

  // [7] Populate data để trả về đầy đủ
  const populatedBooking = await Booking.findById(booking._id)
    .populate({
      path: 'showtimeId',
      populate: [
        { path: 'movieId', select: 'title posterUrl' },
        { path: 'cinemaId', select: 'name location' }
      ]
    });

  // [8] Return response
  return res.status(201).json({
    success: true,
    message: "Booking created successfully",
    data: populatedBooking
  });
};

// ============================================
// BƯỚC 5: THANH TOÁN
// ============================================
// Flutter: POST /api/payment/create
// Body: { orderId: bookingId, amount, orderInfo }

// payment-service/controllers/vnpay.controllers.js
async createPayment(req, res) {
  const { orderId, amount, orderInfo, bankCode } = req.body;
  const ipAddr = req.connection.remoteAddress || '127.0.0.1';

  // [1] Tạo VNPay payment URL
  const paymentUrl = vnpayService.createPaymentUrl(
    orderId,      // booking._id
    amount,       // booking.totalAmount
    orderInfo,    // "Thanh toan ve xem phim"
    ipAddr,
    'vn',
    bankCode || ''
  );

  // VNPay URL example:
  // https://sandbox.vnpayment.vn/paymentv2/vpcpay.html?
  //   vnp_TmnCode=DEMOV210&
  //   vnp_Amount=10000000&  (100,000 VND * 100)
  //   vnp_TxnRef=BK123456&
  //   vnp_OrderInfo=...&
  //   vnp_SecureHash=ABC123...

  return res.json({
    success: true,
    paymentUrl,  // Flutter mở URL này trong WebView/Browser
  });
}

// [2] User thanh toán trên VNPay
//     VNPay redirect về: /api/payment/vnpay-return?vnp_ResponseCode=00&...

async vnpayReturn(req, res) {
  // [3] Verify VNPay signature
  const verify = vnpayService.verifyReturnUrl(req.query);

  if (!verify.isVerified) {
    return res.redirect('/payment/failed?message=Invalid signature');
  }

  if (verify.isSuccess) {
    // [4] Gọi Booking Service cập nhật status
    await axios.post(
      'http://booking-service:3002/api/bookings/update-payment-status',
      {
        orderId: verify.vnp_TxnRef,  // bookingId
        status: 'paid',
        transactionNo: verify.vnp_TransactionNo,
        amount: verify.vnp_Amount / 100,
      },
      {
        headers: { 'x-api-key': INTERNAL_API_KEY }
      }
    );

    // [5] Redirect user về success page
    res.redirect('/payment/success?orderId=' + verify.vnp_TxnRef);
  }
}

// ============================================
// BƯỚC 6: NOTIFICATION
// ============================================
// Sau khi payment success, Booking Service gọi Notification Service

// booking-service/services/notification.service.js
async function notifyBookingConfirmed(bookingData) {
  await axios.post(
    'http://notification-service:3005/api/notifications/internal/booking-confirmed',
    {
      userId: bookingData.userId,
      bookingId: bookingData._id.toString(),
      movieTitle: bookingData.movieTitle,
      showtime: bookingData.showtime,
      seats: bookingData.seats.map(s => s.seatNumber),
      totalAmount: bookingData.totalAmount
    },
    {
      headers: {
        'x-api-key': INTERNAL_API_KEY,
      }
    }
  );
}

// notification-service xử lý:
// 1. Lưu notification vào database
// 2. Gửi push notification qua FCM
// 3. Emit Socket.IO event cho real-time update
```

### 4. **Real-time Notifications**

```dart
// Flutter - Socket.IO Client
import 'package:socket_io_client/socket_io_client.dart' as IO;

IO.Socket socket = IO.io('http://10.0.2.2:3005', <String, dynamic>{
  'transports': ['websocket'],
  'auth': {'token': 'JWT_TOKEN'}
});

socket.on('notification', (data) {
  // Handle notification
  print('New notification: ${data['title']}');
});
```

### 5. **Push Notifications**

```
Firebase Cloud Messaging Flow:
1. Flutter app khởi động
2. Lấy FCM token từ Firebase
3. Gửi token lên server:
   POST /api/auth/fcm-token
   Body: { fcmToken: "..." }
4. Server lưu token vào database
5. Khi có event (booking, payment):
   → Notification Service lấy FCM tokens
   → Gửi push notification qua Firebase
   → Flutter app nhận notification
```

---

## 🐳 Docker & Deployment

### Docker Compose Services:

```yaml
services:
  mongodb: # Database
  auth-service: # Port 3001
  booking-service: # Port 3002
  user-service: # Port 3003
  payment-service: # Port 3004
  notification-service: # Port 3005
  api-gateway: # Port 3000
```

### Network Architecture:

- Tất cả services trong cùng network: `movie-booking-network`
- Services giao tiếp với nhau qua internal hostnames
- Chỉ API Gateway expose ra ngoài (port 3000)

### Environment Variables:

Mỗi service có file `.env`:

```env
PORT=300X
NODE_ENV=production
MONGODB_URI=mongodb://admin:admin123@mongodb:27017/booking_ticket_movie?authSource=admin
JWT_SECRET=your-super-secret-jwt-key-change-in-production
FIREBASE_PROJECT_ID=***
FIREBASE_PRIVATE_KEY=***
FIREBASE_CLIENT_EMAIL=***
INTERNAL_API_KEY=internal-secret-key
```

### Deployment Commands:

```bash
# Build và chạy tất cả services
cd SourceCode/Server
docker-compose up -d --build

# Xem logs
docker-compose logs -f [service-name]

# Stop services
docker-compose down

# Stop và xóa volumes
docker-compose down -v
```

---

## 🔒 Security Features

### 1. **Authentication & Authorization**

- ✅ JWT tokens (7 days expiration)
- ✅ Refresh token mechanism
- ✅ Firebase authentication support
- ✅ Password hashing với bcrypt
- ✅ Role-based access control (user/admin)

### 2. **API Security**

- ✅ CORS configuration
- ✅ Rate limiting (API Gateway)
- ✅ Request validation (Joi)
- ✅ Internal API key cho inter-service communication

### 3. **Data Security**

- ✅ MongoDB authentication
- ✅ Environment variables cho sensitive data
- ✅ `.env` files trong `.gitignore`
- ✅ Docker secrets cho production

### 4. **Payment Security**

- ✅ VNPay signature verification
- ✅ HTTPS for payment callbacks
- ✅ IPN webhook verification

---

## 📊 Database Schema

### MongoDB Collections:

```javascript
users               // Auth Service
├── _id
├── name
├── email (unique)
├── password (hashed)
├── role
├── fcmTokens: []
├── createdAt
└── updatedAt

movies              // Booking Service
├── _id
├── title
├── description
├── genre: []
├── duration
├── rating
├── releaseDate
├── posterUrl
└── trailerUrl

showtimes           // Booking Service
├── _id
├── movieId
├── cinemaId
├── roomId
├── startTime
├── endTime
└── price

seats               // Booking Service
├── _id
├── showtimeId
├── row
├── number
├── type
├── status
└── price

bookings            // Booking Service
├── _id
├── userId
├── showtimeId
├── seats: []
├── totalPrice
├── status
├── bookingCode
├── paymentId
└── createdAt

payments            // Payment Service
├── _id
├── userId
├── bookingId
├── amount
├── method
├── status
├── vnpayTransactionId
└── createdAt

notifications       // Notification Service
├── _id
├── userId
├── title
├── message
├── type
├── data: {}
├── isRead
└── createdAt
```

---

## 🔄 Inter-Service Communication

### Communication Patterns:

#### 1. **HTTP REST APIs**

```javascript
// Payment Service → Booking Service
axios.post(
  "http://booking-service:3002/api/bookings/internal/confirm",
  {
    bookingId: "...",
    paymentId: "...",
  },
  {
    headers: {
      "X-Internal-API-Key": process.env.INTERNAL_API_KEY,
    },
  },
);
```

#### 2. **Internal API Key Verification**

```javascript
// Middleware kiểm tra internal calls
const verifyInternalKey = (req, res, next) => {
  const apiKey = req.headers["x-internal-api-key"];
  if (apiKey !== process.env.INTERNAL_API_KEY) {
    return res.status(403).json({ error: "Forbidden" });
  }
  next();
};
```

#### 3. **Service Dependencies**

```
Payment Service
├── Depends on: Booking Service
└── Depends on: Notification Service

Booking Service
└── Depends on: Notification Service

Auth Service
└── Standalone (không depend vào service khác)
```

---

## 📝 API Documentation

Mỗi service có Swagger UI riêng:

- **Auth Service**: http://localhost:3001/api-docs
- **Booking Service**: http://localhost:3002/api-docs
- **Payment Service**: http://localhost:3004/api-docs
- **Notification Service**: http://localhost:3005/api-docs
- **API Gateway Health**: http://localhost:3000/health

---

## 🧪 Testing & Development

### Development Mode:

```bash
# Chạy từng service riêng
cd services/auth-service/srs
npm run dev

# Hoặc chạy tất cả với Docker
docker-compose up --build
```

### Health Check Endpoints:

```javascript
GET /health   // Mỗi service đều có
Response: {
  success: true,
  message: "Service is running",
  timestamp: "2026-01-21T..."
}
```

### Logs:

```bash
# Xem logs tất cả services
docker-compose logs -f

# Xem logs 1 service
docker-compose logs -f auth-service

# Xem 100 dòng cuối
docker-compose logs --tail=100 booking-service
```

---

## 🚀 Features Đã Implement

### ✅ Core Features:

- [x] User registration & login
- [x] Firebase authentication (Google/Facebook)
- [x] JWT token management
- [x] Movie listing & details
- [x] Showtime management
- [x] Seat selection & booking
- [x] VNPay payment integration
- [x] Real-time notifications (Socket.IO)
- [x] Push notifications (FCM)
- [x] Booking history
- [x] Cancel booking
- [x] API Gateway với routing & caching
- [x] Swagger documentation
- [x] Docker containerization
- [x] Health checks
- [x] MongoDB integration

### ⚠️ Limitations:

- User Service chưa có routes (đang xử lý trong Auth Service)
- Chưa có email notification (chỉ có push notification)
- Chưa có admin panel
- Chưa có refund automation

---

## 🔮 Potential Improvements

### 1. **Scalability**

- Implement Redis cho distributed caching
- Message queue (RabbitMQ/Kafka) thay vì HTTP calls
- Load balancer cho multiple instances
- Database replication & sharding

### 2. **Features**

- Email notifications
- SMS notifications
- QR code cho vé
- Admin dashboard
- Analytics & reporting
- Review & rating system
- Loyalty points program
- Discount codes & vouchers

### 3. **DevOps**

- CI/CD pipeline (GitHub Actions)
- Kubernetes deployment
- Monitoring (Prometheus, Grafana)
- Logging aggregation (ELK Stack)
- APM (Application Performance Monitoring)

### 4. **Security**

- API rate limiting per user
- 2FA authentication
- Input sanitization
- SQL injection prevention (đã có với Mongoose)
- HTTPS enforcement
- Security headers

---

## 📞 Liên hệ & Support

- **Repository**: https://github.com/trieuhoang1212/Movie-Ticket-Booking-App
- **Current Branch**: Merge_test
- **Pull Request**: #3 - Merge test

---

## 📄 License

MIT License - Xem file LICENSE để biết thêm chi tiết.

---

**Tài liệu này được tạo tự động bởi GitHub Copilot vào ngày 21/01/2026**
