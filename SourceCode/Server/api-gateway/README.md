# API Gateway - Movie Ticket Booking System

API Gateway cho hệ thống đặt vé xem phim, quản lý routing đến 5 microservices.

## 🎯 Chức năng

- **Routing**: Điều hướng requests đến các microservices tương ứng
- **Authentication**: Xác thực JWT token trước khi forward request
- **Caching**: Cache responses của movies list và showtimes
- **Logging**: Log tất cả requests với timestamp và user info
- **Error Handling**: Xử lý lỗi tập trung và trả về format chuẩn

## 🗺️ Service Routing

| Route                 | Service              | Port | Mô tả                             |
| --------------------- | -------------------- | ---- | --------------------------------- |
| `/api/auth/*`         | auth-service         | 3001 | Đăng ký, đăng nhập, Firebase auth |
| `/api/booking/*`      | booking-service      | 3002 | Đặt vé, quản lý phim, suất chiếu  |
| `/api/user/*`         | user-service         | 3003 | Quản lý thông tin người dùng      |
| `/api/payment/*`      | payment-service      | 3004 | Thanh toán VNPay, transactions    |
| `/api/notification/*` | notification-service | 3005 | Gửi thông báo, email              |

## 🔓 Public Endpoints (Không cần authentication)

- `POST /api/auth/login`
- `POST /api/auth/register`
- `POST /api/auth/firebase-login`
- `GET /api/booking/movies`
- `GET /api/booking/showtimes`
- `GET /api/user/health`

## 🚀 Cài đặt và Chạy

### Development (Localhost)

```bash
# Cài đặt dependencies
npm install

# Chạy dev mode (auto restart)
npm run dev

# Hoặc chạy bình thường
npm start
```

Gateway sẽ chạy tại: `http://localhost:3000`

### Production với Docker

```bash
# Build TypeScript sang JavaScript
npm run build

# Build Docker image
docker build -t movie-booking-api-gateway .

# Run container
docker run -p 3000:3000 movie-booking-api-gateway
```

## 📝 Cấu hình

### Service Addresses

Sửa file `src/config/service.address.ts`:

```typescript
// Localhost development
const ContextPathMap: any = new Map([
  ["auth", "127.0.0.1:3001"],
  ["booking", "127.0.0.1:3002"],
  // ...
]);

// Docker compose
const ContextPathMap: any = new Map([
  ["auth", "auth-service:3001"],
  ["booking", "booking-service:3002"],
  // ...
]);
```

### Environment Variables

```bash
PORT=3000  # Port gateway sẽ chạy
```

## 🔐 Authentication Flow

1. Client gửi request với header: `Authorization: Bearer <JWT_TOKEN>`
2. Gateway kiểm tra public endpoint → skip nếu là public
3. Gateway forward token đến auth-service để verify
4. Nếu valid, gateway thêm `__user_info` vào header và forward đến service
5. Service nhận được request với thông tin user đã authenticated

## 📦 Caching

Cache được áp dụng cho:

- `GET /api/booking/movies` - Danh sách phim
- `GET /api/booking/showtimes` - Lịch chiếu

Cache time: 5 phút (config trong `cache.service.ts`)

## 🛠️ Testing

### Test với cURL

```bash
# Public endpoint (không cần token)
curl http://localhost:3000/api/booking/movies

# Protected endpoint (cần token)
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
     http://localhost:3000/api/booking/my-tickets
```

### Test với Postman

1. Import collection từ `/postman`
2. Set environment variable `api_gateway_url` = `http://localhost:3000`
3. Login để lấy token
4. Set token vào Authorization header

## 📊 Logs

Format log:

```
[2025-12-09T15:30:45.123Z] GET /api/booking/movies
  Query: {"cinema_id":"1"}

[2025-12-09T15:30:46.456Z] POST /api/booking/book-ticket
  User: john@example.com
  Body: {"movie_id":"123","seat":"A1"}
```

## 🐛 Error Handling

Tất cả lỗi được format theo:

```json
{
  "error": true,
  "code": "ERROR_CODE",
  "message": "Error description"
}
```

HTTP Status Codes:

- `401` - Authentication failed
- `500` - Internal server error
- Other codes được forward từ microservices

## 🔧 Tech Stack

- **TypeScript** - Type safety
- **Express** - Web framework
- **express-http-proxy** - Proxy middleware
- **node-cache** - In-memory caching
- **express-rate-limit** - Rate limiting (currently disabled)

## 📁 Project Structure

```
api-gateway/
├── src/
│   ├── gateway.ts                 # Main gateway logic
│   ├── authentication/
│   │   └── authentication.service.ts  # JWT verification
│   ├── cache/
│   │   └── cache.service.ts       # Caching logic
│   ├── config/
│   │   └── service.address.ts     # Service routing config
│   └── errorHandler/
│       ├── errorHandler.ts
│       └── errorModel.ts
├── Dockerfile
├── package.json
└── tsconfig.json
```
