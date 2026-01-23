# 📁 BACKEND SERVER - CHI TIẾT TÍNH NĂNG TỪNG FILE

## 📋 Mục Lục

- [Tổng quan cấu trúc](#tổng-quan-cấu-trúc)
- [Root Level Files](#root-level-files)
- [API Gateway](#api-gateway)
- [Auth Service](#auth-service)
- [Booking Service](#booking-service)
- [User Service](#user-service)
- [Payment Service](#payment-service)
- [Notification Service](#notification-service)

---

## Tổng Quan Cấu Trúc

```
Server/
├── 📄 Root Files (Configuration)
├── 🚪 api-gateway/ (API Gateway - TypeScript)
└── 🔧 services/
    ├── auth-service/
    ├── booking-service/
    ├── user-service/
    ├── payment-service/
    └── notification-service/
```

---

## Root Level Files

### 📄 `docker-compose.yml`

**Chức năng:** Orchestration file cho Docker containers

- Định nghĩa 6 services: MongoDB, API Gateway, Auth, Booking, User, Payment, Notification
- Cấu hình network bridge `movie-booking-network`
- Thiết lập health checks cho từng service
- Quản lý volumes cho MongoDB data persistence
- Port mapping: Gateway (3000), Services (3001-3005), MongoDB (27017)

**Công nghệ:** Docker Compose v3.8

---

### 📄 `package.json`

**Chức năng:** Root dependencies cho toàn bộ backend
**Dependencies:**

- `bcryptjs` - Password hashing
- `dotenv` - Environment variables
- `firebase-admin` - Firebase SDK
- `mongoose` - MongoDB ODM
- `vnpay` - Payment gateway integration
- `swagger-ui-express` - API documentation

---

### 📄 `.env`

**Chức năng:** Environment variables configuration

- MongoDB connection string
- JWT secret keys
- Firebase configuration
- VNPay credentials
- Service ports
- Internal API keys

---

### 📄 `README.md`

**Chức năng:** Documentation tổng quan về backend

- Hướng dẫn cài đặt và chạy
- Mô tả kiến trúc microservices
- API endpoints overview

---

## API Gateway

**Ngôn ngữ:** TypeScript  
**Port:** 3000  
**Mục đích:** Reverse proxy và authentication gateway cho tất cả services

### 📂 `src/`

#### 📄 `gateway.ts`

**Chức năng:** Main entry point của API Gateway

- Khởi tạo Express server trên port 3000
- Cấu hình middleware pipeline:
  1. JSON body parser
  2. CORS configuration
  3. Authentication service
  4. Logger middleware
  5. Cache middleware (check cache)
  6. HTTP Proxy routing
  7. Cache middleware (save response)
  8. Error handler
- Route tất cả requests đến microservices tương ứng
- Health check endpoint `/health`

**Dependencies:** express, express-http-proxy, dotenv

---

### 📂 `src/authentication/`

#### 📄 `authentication.service.ts`

**Chức năng:** JWT Token validation middleware

- Verify JWT tokens từ request headers
- Decode user information từ token
- Attach `userId` vào request object
- Skip authentication cho public endpoints:
  - `/auth/login`
  - `/auth/register`
  - `/auth/firebase`
  - `/payment/vnpay_return`
- Trả về 401 Unauthorized nếu token không hợp lệ

**Flow:**

1. Extract token từ `Authorization: Bearer <token>`
2. Verify token với JWT secret
3. Decode payload để lấy userId
4. Inject userId vào req.body
5. Continue to next middleware

---

### 📂 `src/cache/`

#### 📄 `cache.service.ts`

**Chức năng:** In-memory caching với NodeCache

- Cache GET responses để giảm load trên services
- TTL: 5 seconds (development), khuyến nghị 300s (production)
- Cache endpoints:
  - `/booking/movies` - Danh sách phim
  - `/booking/showtimes` - Lịch chiếu
- Tạo unique cache key từ URL + query params
- Auto-cleanup expired cache entries

**Methods:**

- `checkCache()` - Middleware kiểm tra cache trước khi proxy
- `saveCache()` - Middleware lưu response vào cache sau khi proxy

**Lợi ích:**

- Giảm response time từ ~500ms → ~10ms
- Giảm database queries
- Tối ưu bandwidth

---

### 📂 `src/config/`

#### 📄 `service.address.ts`

**Chức năng:** Service discovery và routing configuration

- Auto-detect Docker vs Localhost environment
- Map service names to addresses:
  - **auth-service** → `http://auth-service:3001` (Docker) / `http://localhost:3001` (Local)
  - **booking-service** → `http://booking-service:3002`
  - **user-service** → `http://user-service:3003`
  - **payment-service** → `http://payment-service:3004`
  - **notification-service** → `http://notification-service:3005`
- Dynamic route matching:
  - `/auth/*` → auth-service
  - `/booking/*` → booking-service
  - `/user/*` → user-service
  - `/payment/*` → payment-service
  - `/notification/*` → notification-service

**Logic:**

```typescript
const isDocker = process.env.DOCKER_ENV === "true";
const serviceHost = isDocker ? "service-name" : "localhost";
```

---

### 📂 `src/errorHandler/`

#### 📄 `errorHandler.ts`

**Chức năng:** Centralized error handling middleware

- Bắt tất cả errors từ downstream services
- Format error responses theo chuẩn JSON
- Log errors với timestamp
- Return appropriate HTTP status codes

**Error Response Format:**

```json
{
  "success": false,
  "message": "Error description",
  "error": "Error details"
}
```

---

#### 📄 `errorModel.ts`

**Chức năng:** Custom error class definitions

- `ApiError` class với properties:
  - `statusCode` - HTTP status code
  - `message` - User-friendly message
  - `isOperational` - Flag để phân biệt operational vs programming errors

---

#### 📄 `httpStatusCode.ts`

**Chức năng:** HTTP status code constants

```typescript
200 - OK
201 - Created
400 - Bad Request
401 - Unauthorized
404 - Not Found
500 - Internal Server Error
```

---

#### 📄 `messageCode.ts`

**Chức năng:** Standardized message templates

- Success messages
- Error messages
- Validation messages
- Vietnamese language support

---

### 📂 Root Files (API Gateway)

#### 📄 `package.json`

**Dependencies:**

- `express` - Web framework
- `express-http-proxy` - Reverse proxy
- `express-rate-limit` - Rate limiting
- `node-cache` - In-memory caching
- `axios` - HTTP client
- `dotenv` - Environment config

**DevDependencies:**

- `typescript` - TypeScript compiler
- `ts-node` - TypeScript execution
- `ts-node-dev` - Development auto-reload
- `@types/express` - Type definitions

**Scripts:**

- `npm start` - Production mode
- `npm run dev` - Development mode with auto-reload
- `npm run build` - Compile TypeScript to JavaScript

---

#### 📄 `tsconfig.json`

**Chức năng:** TypeScript compiler configuration

- Target: ES2020
- Module: CommonJS
- Strict type checking enabled
- Source maps for debugging
- Output directory: `dist/`

---

#### 📄 `Dockerfile`

**Chức năng:** Container image cho API Gateway
**Build steps:**

1. Base image: `node:20-alpine`
2. Install dependencies
3. Compile TypeScript
4. Expose port 3000
5. Start with `ts-node src/gateway.ts`

---

#### 📄 `README.md`

**Chức năng:** Documentation cho API Gateway

- Setup instructions
- Environment variables
- Routing rules
- Development guide

---

#### 📄 `SETUP.md`

**Chức năng:** Detailed setup guide

- Prerequisites
- Installation steps
- Configuration examples
- Troubleshooting

---

## Auth Service

**Ngôn ngữ:** JavaScript (Node.js)  
**Port:** 3001  
**Mục đích:** User authentication & authorization

### 📂 `srs/`

#### 📄 `index.js`

**Chức năng:** Entry point của Auth Service

- Khởi tạo Express server trên port 3001
- Connect MongoDB database
- Initialize Firebase Admin SDK
- Setup middleware: CORS, JSON parser
- Load routes: `/auth`, `/fcm`
- Setup Swagger documentation trên `/api-docs`
- Health check endpoint

**Startup flow:**

1. Load environment variables
2. Connect to MongoDB
3. Initialize Firebase
4. Setup middleware
5. Mount routes
6. Start listening on port 3001

---

### 📂 `controllers/`

#### 📄 `auth.controller.js`

**Chức năng:** Handle authentication logic
**Endpoints:**

**1. POST `/auth/register`**

- Validate input (email, password, phone)
- Check duplicate user
- Hash password với bcrypt (10 salt rounds)
- Create user trong MongoDB
- Generate JWT token (7-day expiration)
- Return user info + token

**2. POST `/auth/login`**

- Validate credentials
- Find user by email
- Compare password với bcrypt
- Generate JWT token
- Update FCM token nếu có
- Return user info + token

**3. GET `/auth/profile`**

- Requires JWT authentication
- Lấy user profile từ database
- Return user details (exclude password)

**4. PUT `/auth/profile`**

- Requires JWT authentication
- Update user information
- Validate new data
- Return updated profile

**Business Logic:**

- Password hashing tự động qua Mongoose pre-save hook
- Token expiration: `jwt.sign(payload, SECRET, { expiresIn: '7d' })`
- Password comparison: `bcrypt.compare(inputPassword, hashedPassword)`

---

#### 📄 `firebase-auth.controller.js`

**Chức năng:** Firebase Authentication integration
**Endpoint: POST `/auth/firebase`**

**Flow:**

1. Nhận Firebase ID Token từ client
2. Verify token với Firebase Admin SDK
3. Extract user info (uid, email, name, photoURL)
4. Check user tồn tại trong MongoDB
5. Nếu chưa có → Create new user
6. Generate JWT token
7. Return user + JWT token

**Use case:**

- Google Sign-In
- Facebook Sign-In
- Apple Sign-In

---

#### 📄 `fcm.controller.js`

**Chức năng:** Firebase Cloud Messaging token management
**Endpoints:**

**1. POST `/fcm/token`**

- Save FCM device token
- Associate token với userId
- Update existing token nếu có
- Dùng để gửi push notifications

**2. DELETE `/fcm/token`**

- Remove FCM token khi user logout
- Clean up device tokens

---

### 📂 `middlewares/`

#### 📄 `auth.middleware.js`

**Chức năng:** JWT authentication middleware cho protected routes
**Process:**

1. Extract token từ `Authorization: Bearer <token>`
2. Verify token với JWT_SECRET
3. Decode payload → lấy userId
4. Attach userId vào `req.userId`
5. Continue to controller

**Error handling:**

- No token → 401 Unauthorized
- Invalid token → 401 Unauthorized
- Expired token → 401 Unauthorized

---

#### 📄 `firebase.middleware.js`

**Chức năng:** Verify Firebase ID Tokens
**Process:**

1. Extract Firebase token từ header
2. Verify với Firebase Admin SDK
3. Decode user information
4. Attach Firebase UID vào request

---

#### 📄 `validate.middleware.js`

**Chức năng:** Request validation với Joi schemas
**Validates:**

- Email format
- Password strength (min 6 chars)
- Phone number format
- Required fields

**Usage:**

```javascript
router.post("/register", validate(registerSchema), authController.register);
```

---

### 📂 `repositories/`

#### 📄 `user.model.js`

**Chức năng:** MongoDB schema cho User collection
**Schema:**

```javascript
{
  email: String (unique, required),
  password: String (required, hashed),
  name: String,
  phone: String,
  role: String (default: 'user'), // 'user' | 'admin'
  fcmToken: String,
  firebaseUid: String,
  photoURL: String,
  createdAt: Date,
  updatedAt: Date
}
```

**Middleware:**

- `pre('save')` - Auto hash password trước khi lưu
- `methods.comparePassword()` - Compare hashed password

**Indexes:**

- email (unique)
- firebaseUid (unique, sparse)

---

### 📂 `routes/`

#### 📄 `auth.routes.js`

**Chức năng:** Define authentication endpoints
**Routes:**

```
POST   /auth/register         - Create new account
POST   /auth/login            - User login
POST   /auth/firebase         - Firebase auth
GET    /auth/profile          - Get user profile (protected)
PUT    /auth/profile          - Update profile (protected)
DELETE /auth/account          - Delete account (protected)
```

**Middleware chain:**

```
Public routes  → validate → controller
Private routes → validate → auth → controller
```

---

### 📂 `config/`

#### 📄 `database.js`

**Chức năng:** MongoDB connection setup
**Features:**

- Connection string từ environment
- Auto-reconnect on failure
- Connection pooling
- Error handling
- Success logging

**Connection options:**

```javascript
{
  useNewUrlParser: true,
  useUnifiedTopology: true,
  serverSelectionTimeoutMS: 5000
}
```

---

#### 📄 `firebase.js`

**Chức năng:** Initialize Firebase Admin SDK
**Setup:**

1. Load service account key từ `FireBase_Token.json`
2. Initialize với credentials
3. Export `admin` object cho controllers

**Usage:**

- Verify Firebase ID tokens
- Send push notifications
- Access Firebase services

---

#### 📄 `swagger.js`

**Chức năng:** API documentation configuration
**Setup:**

- Swagger UI tại `/api-docs`
- Auto-generate docs từ JSDoc comments
- Interactive API testing

**Definition:**

```javascript
{
  openapi: '3.0.0',
  info: {
    title: 'Auth Service API',
    version: '1.0.0'
  },
  servers: [{ url: 'http://localhost:3001' }]
}
```

---

### 📂 Root Files (Auth Service)

#### 📄 `package.json`

**Dependencies:**

- `express` - Web framework
- `mongoose` - MongoDB ODM
- `jsonwebtoken` - JWT generation/verification
- `bcryptjs` - Password hashing
- `firebase-admin` - Firebase SDK
- `joi` - Input validation
- `cors` - Cross-origin requests
- `swagger-jsdoc` - API docs
- `swagger-ui-express` - Swagger UI

**Scripts:**

- `npm start` - Production
- `npm run dev` - Development with nodemon

---

#### 📄 `Dockerfile`

**Chức năng:** Container image cho Auth Service
**Build:**

1. Base: `node:20-alpine`
2. Copy package files
3. Install dependencies
4. Copy source code
5. Expose port 3001
6. CMD: `node index.js`

---

#### 📄 `.env`

**Variables:**

```
PORT=3001
MONGODB_URI=mongodb://mongodb:27017/movie_booking
JWT_SECRET=your_secret_key
FIREBASE_PROJECT_ID=your_project_id
INTERNAL_API_KEY=secret_key
```

---

## Booking Service

**Ngôn ngữ:** JavaScript (Node.js)  
**Port:** 3002  
**Mục đích:** Quản lý booking, movies, showtimes, seats

### 📂 `srs/`

#### 📄 `index.js`

**Chức năng:** Entry point của Booking Service

- Server setup trên port 3002
- MongoDB connection
- Firebase initialization
- Routes: `/booking`
- Swagger documentation
- Socket.IO integration (optional)

---

### 📂 `controllers/`

#### 📄 `booking.controller.js`

**Chức năng:** Core booking business logic
**Endpoints:**

**1. POST `/booking/create`**
**Flow:**

1. Validate input (showtimeId, seatIds[], userId)
2. Check showtime exists
3. Check seats availability với atomic query:
   ```javascript
   { _id: { $in: seatIds }, status: 'available' }
   ```
4. Lock seats → status = 'booked'
5. Calculate total price
6. Create booking document
7. Send notification qua notification service
8. Return booking confirmation

**Race Condition Prevention:**

- Sử dụng `updateMany()` với condition check
- Nếu số seats updated < số seats requested → rollback
- Transaction-like behavior

**2. GET `/booking/user/:userId`**

- Lấy all bookings của user
- Populate movie, showtime, seat details
- Sort by created date descending

**3. GET `/booking/:bookingId`**

- Get single booking details
- Full information with movie/showtime/seats

**4. PUT `/booking/:bookingId/cancel`**

- Cancel booking
- Release seats → status = 'available'
- Update booking status = 'cancelled'
- Refund handling

**5. GET `/booking/movies`** (Cached)

- Get all available movies
- Return movie list with details

**6. GET `/booking/showtimes`** (Cached)

- Get showtimes by movie/date/cinema
- Filter available shows

**7. GET `/booking/seats/:showtimeId`**

- Get seat map for showtime
- Mark booked/available seats
- Return seat layout

---

### 📂 `services/`

#### 📄 `notification.service.js`

**Chức năng:** Inter-service communication với Notification Service
**Method:** `sendBookingNotification(userId, bookingData)`

**Process:**

1. Build notification payload
2. POST request to `http://notification-service:3005/notification/send`
3. Include internal API key header
4. Non-blocking call (không chờ response)

**Error handling:**

- Catch errors để không block booking flow
- Log errors để monitor

---

#### 📄 `fcm.service.js`

**Chức năng:** Firebase Cloud Messaging integration
**Method:** `sendPushNotification(fcmToken, title, body, data)`

**Process:**

1. Build FCM message payload
2. Send qua Firebase Admin SDK
3. Handle success/failure

**Use cases:**

- Booking confirmation
- Payment success
- Booking reminder
- Cancellation notice

---

### 📂 `repositories/`

#### 📄 `booking.model.js`

**Chức năng:** MongoDB schema cho Booking collection
**Schema:**

```javascript
{
  userId: ObjectId (ref: 'User'),
  showtimeId: ObjectId (ref: 'Showtime'),
  seatIds: [ObjectId] (ref: 'Seat'),
  totalPrice: Number,
  status: String, // 'pending', 'confirmed', 'cancelled'
  paymentStatus: String, // 'pending', 'paid', 'refunded'
  bookingCode: String (unique),
  createdAt: Date,
  updatedAt: Date
}
```

**Indexes:**

- userId
- bookingCode (unique)
- status
- paymentStatus

---

#### 📄 `movie.model.js`

**Chức năng:** MongoDB schema cho Movie collection
**Schema:**

```javascript
{
  title: String,
  description: String,
  genre: [String],
  duration: Number, // minutes
  releaseDate: Date,
  posterUrl: String,
  trailerUrl: String,
  rating: Number, // 0-10
  director: String,
  cast: [String],
  language: String,
  status: String // 'coming_soon', 'now_showing', 'ended'
}
```

---

#### 📄 `showtime.model.js`

**Chức năng:** MongoDB schema cho Showtime collection
**Schema:**

```javascript
{
  movieId: ObjectId (ref: 'Movie'),
  cinemaId: ObjectId,
  roomNumber: Number,
  startTime: Date,
  endTime: Date,
  price: Number,
  availableSeats: Number,
  totalSeats: Number
}
```

**Virtual fields:**

- `isAvailable` - Check if có ghế trống

---

#### 📄 `seat.model.js`

**Chức năng:** MongoDB schema cho Seat collection
**Schema:**

```javascript
{
  showtimeId: ObjectId (ref: 'Showtime'),
  row: String, // 'A', 'B', 'C'...
  number: Number, // 1, 2, 3...
  type: String, // 'standard', 'vip', 'couple'
  price: Number,
  status: String // 'available', 'booked', 'reserved'
}
```

**Compound Index:**

- (showtimeId, row, number) - unique constraint

---

### 📂 `routes/`

#### 📄 `booking.routes.js`

**Routes:**

```
POST   /booking/create          - Create booking (protected)
GET    /booking/user/:userId    - User bookings (protected)
GET    /booking/:bookingId      - Booking details (protected)
PUT    /booking/:bookingId/cancel - Cancel booking (protected)
GET    /booking/movies          - List movies (public, cached)
GET    /booking/showtimes       - List showtimes (public, cached)
GET    /booking/seats/:showtimeId - Seat map (public)
```

---

### 📂 `config/`

#### 📄 `seed.js`

**Chức năng:** Database seeding script
**Seeds:**

1. Sample movies (10-20 movies)
2. Showtimes (next 7 days)
3. Seats (auto-generate A1-J10 per showtime)

**Usage:** `npm run seed`

---

#### 📄 `database.js`

**Chức năng:** MongoDB connection

- Same as Auth Service

---

#### 📄 `firebase.js`

**Chức năng:** Firebase Admin initialization

- Share Firebase Token với Auth Service

---

#### 📄 `swagger.js`

**Chức năng:** Booking Service API docs

---

### 📂 `middlewares/`

#### 📄 `auth.middleware.js`

**Chức năng:** JWT verification (duplicate from auth-service)

---

#### 📄 `validate.middleware.js`

**Chức năng:** Joi validation
**Schemas:**

- createBookingSchema
- cancelBookingSchema
- showtimeQuerySchema

---

## User Service

**Ngôn ngữ:** JavaScript (Node.js)  
**Port:** 3003  
**Mục đích:** User profile management

### 📂 `srs/`

#### 📄 `index.js`

**Chức năng:** Entry point

- Server setup port 3003
- MongoDB connection
- Routes: `/user`

---

### 📂 `controllers/`

**Endpoints:**

**1. GET `/user/:userId`**

- Get user profile
- Return user details

**2. PUT `/user/:userId`**

- Update user profile
- Validate input
- Return updated user

**3. GET `/user/:userId/bookings`**

- Get user's booking history
- Cross-service call to booking-service

---

### 📂 `repositories/`

#### 📄 User model

- Share schema với auth-service hoặc duplicate

---

### 📂 `routes/`

#### 📄 `user.routes.js`

```
GET    /user/:userId            - Get profile (protected)
PUT    /user/:userId            - Update profile (protected)
GET    /user/:userId/bookings   - Booking history (protected)
```

---

## Payment Service

**Ngôn ngữ:** JavaScript (Node.js)  
**Port:** 3004  
**Mục đích:** Payment processing với VNPay

### 📂 `srs/`

#### 📄 `index.js`

**Chức năng:** Entry point

- Server port 3004
- VNPay SDK initialization
- Routes: `/payment`

---

### 📂 `controllers/`

#### 📄 `vnpay.controllers.js`

**Chức năng:** VNPay integration
**Endpoints:**

**1. POST `/payment/create`**
**Input:**

```javascript
{
  bookingId: String,
  amount: Number,
  orderInfo: String,
  returnUrl: String
}
```

**Flow:**

1. Validate booking exists
2. Check booking chưa paid
3. Create payment record (status: 'pending')
4. Build VNPay payment URL:
   - vnp_TmnCode (Merchant code)
   - vnp_Amount (amount \* 100)
   - vnp_OrderInfo
   - vnp_ReturnUrl
   - vnp_IpAddr
   - vnp_CreateDate
5. Generate secure hash (HMAC SHA512)
6. Return VNPay payment URL
7. User redirect to VNPay gateway

**2. GET `/payment/vnpay_return`** (Public endpoint)
**Flow:**

1. Nhận callback từ VNPay sau khi user thanh toán
2. Verify secure hash từ VNPay
3. Check vnp_ResponseCode:
   - '00' → Success
   - Other → Failed
4. Update payment status
5. Update booking paymentStatus
6. Send notification to user
7. Redirect to success/failure page

**Security:**

- HMAC SHA512 signature verification
- IP whitelist
- Timestamp validation (prevent replay attack)

**3. GET `/payment/:bookingId`**

- Get payment status
- Return payment details

---

### 📂 `services/`

#### 📄 `vnpay.service.js`

**Chức năng:** VNPay SDK wrapper
**Methods:**

- `createPaymentUrl()` - Generate payment URL
- `verifyReturnUrl()` - Verify callback signature
- `queryPayment()` - Query payment status from VNPay

---

#### 📄 `notification.service.js`

**Chức năng:** Send payment notifications
**Method:** `sendPaymentNotification(userId, paymentData)`

- Call notification-service
- Non-blocking call

---

### 📂 `repositories/`

#### 📄 `payment.model.js`

**Schema:**

```javascript
{
  bookingId: ObjectId (ref: 'Booking'),
  amount: Number,
  method: String, // 'vnpay', 'momo', 'cash'
  status: String, // 'pending', 'success', 'failed', 'refunded'
  vnpayTransactionNo: String,
  vnpayResponseCode: String,
  paidAt: Date,
  createdAt: Date
}
```

---

### 📂 `config/`

#### 📄 `vnpay.config.js`

**Chức năng:** VNPay configuration

```javascript
{
  vnp_TmnCode: process.env.VNP_TMN_CODE,
  vnp_HashSecret: process.env.VNP_HASH_SECRET,
  vnp_Url: 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html',
  vnp_ReturnUrl: process.env.VNP_RETURN_URL
}
```

---

### 📂 `routes/`

#### 📄 `payment.routes.js`

```
POST   /payment/create         - Create payment (protected)
GET    /payment/vnpay_return   - VNPay callback (public)
GET    /payment/:bookingId     - Payment status (protected)
POST   /payment/refund         - Refund payment (admin)
```

---

### 📂 `validators/`

#### 📄 `payment.validator.js`

**Schemas:**

- createPaymentSchema
- refundSchema

---

## Notification Service

**Ngôn ngữ:** JavaScript (Node.js)  
**Port:** 3005  
**Mục đích:** Real-time notifications & push notifications

### 📂 `srs/`

#### 📄 `index.js`

**Chức năng:** Entry point với Socket.IO
**Setup:**

1. Express server port 3005
2. HTTP server wrapper
3. Socket.IO server initialization
4. CORS configuration
5. MongoDB connection
6. Firebase initialization
7. Routes mounting
8. Socket.IO connection handler

**Socket.IO events:**

- `connection` - User connects
- `authenticate` - Verify JWT
- `join-room` - Join user room
- `disconnect` - User disconnects

---

### 📂 `controllers/`

#### 📄 `notification.controller.js`

**Endpoints:**

**1. POST `/notification/send`** (Internal API)
**Input:**

```javascript
{
  userId: String,
  title: String,
  message: String,
  type: String, // 'booking', 'payment', 'reminder'
  data: Object
}
```

**Flow:**

1. Verify internal API key
2. Create notification trong database
3. Get user's FCM token
4. Send via 3 channels:
   - **Database** - Save notification
   - **Socket.IO** - Real-time push to connected users
   - **FCM** - Push notification to mobile app
5. Return success

**Triple Delivery:**

```javascript
// 1. Database
await Notification.create(notificationData);

// 2. Socket.IO
io.to(`user_${userId}`).emit("notification", notificationData);

// 3. Firebase Cloud Messaging
await admin.messaging().send(fcmMessage);
```

**2. GET `/notification/user/:userId`**

- Get all notifications của user
- Mark as read option
- Pagination support

**3. PUT `/notification/:notificationId/read`**

- Mark notification as read
- Update `isRead: true`

**4. DELETE `/notification/:notificationId`**

- Delete notification

---

### 📂 `services/`

#### 📄 `notification.services.js`

**Methods:**

- `createNotification()` - Save to database
- `sendSocketNotification()` - Emit via Socket.IO
- `sendFCMNotification()` - Send via Firebase
- `getUserNotifications()` - Fetch user notifications

---

### 📂 `repositories/`

#### 📄 `Notification.model.js`

**Schema:**

```javascript
{
  userId: ObjectId (ref: 'User'),
  title: String,
  message: String,
  type: String, // 'booking', 'payment', 'reminder', 'system'
  data: Object, // Additional payload
  isRead: Boolean (default: false),
  createdAt: Date
}
```

**Indexes:**

- userId
- createdAt (descending)
- isRead

---

#### 📄 `userdevice.model.js`

**Schema:**

```javascript
{
  userId: ObjectId (ref: 'User'),
  fcmToken: String,
  deviceType: String, // 'ios', 'android', 'web'
  lastActive: Date
}
```

---

### 📂 `config/`

#### 📄 `socket.js`

**Chức năng:** Socket.IO server configuration
**Setup:**

```javascript
const io = socketIO(httpServer, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
  },
});

// Authentication middleware
io.use((socket, next) => {
  const token = socket.handshake.auth.token;
  // Verify JWT token
  // Attach userId to socket
  next();
});

// Connection handler
io.on("connection", (socket) => {
  const userId = socket.userId;

  // Join user-specific room
  socket.join(`user_${userId}`);

  console.log(`User ${userId} connected`);

  socket.on("disconnect", () => {
    console.log(`User ${userId} disconnected`);
  });
});
```

**Room naming:** `user_{userId}` để target specific users

---

#### 📄 `firebase.js`

**Chức năng:** Firebase Admin for FCM

---

#### 📄 `database.js`

**Chức năng:** MongoDB connection

---

### 📂 `routes/`

#### 📄 `notification.routes.js`

```
POST   /notification/send            - Send notification (internal)
GET    /notification/user/:userId    - Get user notifications (protected)
PUT    /notification/:id/read        - Mark as read (protected)
DELETE /notification/:id             - Delete notification (protected)
```

---

### 📂 `middlewares/`

#### 📄 `auth.middleware.js`

**Chức năng:**

1. JWT authentication cho REST endpoints
2. Internal API key verification cho inter-service calls

**Logic:**

```javascript
if (req.headers["x-internal-api-key"] === INTERNAL_API_KEY) {
  // Inter-service call
  return next();
} else {
  // Client call - verify JWT
  verifyJWT(token);
}
```

---

### 📂 `validators/`

#### 📄 `notification.validator.js`

**Schemas:**

- sendNotificationSchema
- markReadSchema

---

## 🔄 Inter-Service Communication

### Internal API Key Pattern

**Tất cả services sử dụng:**

```javascript
const internalApiKey = process.env.INTERNAL_API_KEY;

// Sender (booking-service → notification-service)
axios.post("http://notification-service:3005/notification/send", data, {
  headers: {
    "x-internal-api-key": internalApiKey,
  },
});

// Receiver (notification-service)
if (req.headers["x-internal-api-key"] !== internalApiKey) {
  return res.status(401).json({ error: "Unauthorized" });
}
```

---

## 📊 Service Dependencies

```
┌─────────────────┐
│   API Gateway   │  Port 3000
│   (TypeScript)  │
└────────┬────────┘
         │
    ┌────┴────┬────────┬────────┬────────┐
    │         │        │        │        │
    v         v        v        v        v
┌───────┐ ┌────────┐ ┌──────┐ ┌────────┐ ┌──────────────┐
│ Auth  │ │Booking │ │ User │ │Payment │ │Notification  │
│ 3001  │ │  3002  │ │ 3003 │ │  3004  │ │    3005      │
└───┬───┘ └───┬────┘ └──────┘ └───┬────┘ └──────┬───────┘
    │         │                    │              │
    │         └────────────────────┴──────────────┘
    │                     │
    └─────────────────────┴─────────────────┐
                                             v
                                     ┌──────────────┐
                                     │   MongoDB    │
                                     │    27017     │
                                     └──────────────┘
```

**Service Calls:**

- Booking → Notification (booking created)
- Payment → Notification (payment success)
- Payment → Booking (update payment status)

---

## 🔐 Security Files

### `.dockerignore`

**Mục đích:** Exclude files từ Docker build

```
node_modules/
.env
*.log
.git/
```

---

### `.gitignore`

**Mục đích:** Exclude files từ Git

```
node_modules/
.env
*.log
dist/
build/
```

---

### `.env.example`

**Mục đích:** Template cho environment variables

```
PORT=300X
MONGODB_URI=mongodb://mongodb:27017/movie_booking
JWT_SECRET=change_this_secret
INTERNAL_API_KEY=change_this_key
```

---

## 📚 Tổng Kết

### Tổng số files theo loại:

**Configuration Files:** 15+

- docker-compose.yml
- package.json (6 files - root + 5 services)
- tsconfig.json
- .env files
- .dockerignore files

**Source Code Files:** 50+

- Controllers: 10+ files
- Models: 8+ files
- Routes: 6+ files
- Services: 6+ files
- Middlewares: 8+ files
- Config: 15+ files

**Documentation Files:** 8+

- README.md (multiple)
- SETUP.md
- Swagger configs

**Total:** ~80+ files

---

## 🎯 Key Features Summary

| Service          | Core Features                   | Key Files                                                |
| ---------------- | ------------------------------- | -------------------------------------------------------- |
| **API Gateway**  | Routing, Auth, Caching          | gateway.ts, service.address.ts, cache.service.ts         |
| **Auth**         | Login, Register, JWT, Firebase  | auth.controller.js, user.model.js, auth.middleware.js    |
| **Booking**      | Create booking, Seat management | booking.controller.js, seat.model.js, movie.model.js     |
| **User**         | Profile management              | user.controller.js, user.model.js                        |
| **Payment**      | VNPay integration               | vnpay.controllers.js, vnpay.service.js, payment.model.js |
| **Notification** | Socket.IO, FCM, Real-time       | notification.controller.js, socket.js                    |

---

**Tạo bởi:** Backend Documentation Generator  
**Ngày:** January 21, 2026  
**Version:** 1.0.0
