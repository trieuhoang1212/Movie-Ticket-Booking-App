# Setup Nhanh API Gateway

## Bước 1: Cài đặt Dependencies

```bash
cd d:\Mobile\Project\SourceCode\Server\api-gateway
npm install
```

## Bước 2: Tạo file .env

```bash
# Copy file .env.example
cp .env.example .env

# Hoặc tạo file .env với nội dung:
PORT=3000
```

## Bước 3: Kiểm tra Service Addresses

Mở file `src/config/service.address.ts` và đảm bảo đang dùng localhost:

```typescript
const ContextPathMap: any = new Map([
  ["auth", "127.0.0.1:3001"],
  ["booking", "127.0.0.1:3002"],
  ["user", "127.0.0.1:3003"],
  ["payment", "127.0.0.1:3004"],
  ["notification", "127.0.0.1:3005"],
]);
```

## Bước 4: Chạy Gateway

```bash
# Development mode (auto-reload)
npm run dev

# Hoặc production mode
npm start
```

Gateway sẽ chạy tại: **http://localhost:3000**

## Bước 5: Test

### Test với browser/Postman

```
GET http://localhost:3000/api/booking/movies
```

### Test với cURL

```bash
# Public endpoint
curl http://localhost:3000/api/booking/movies

# Protected endpoint (cần token)
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
     http://localhost:3000/api/user/profile
```

## ⚠️ Lưu ý

1. **Đảm bảo các microservices đang chạy** tại các port tương ứng:

   - Auth service: port 3001
   - Booking service: port 3002
   - User service: port 3003
   - Payment service: port 3004
   - Notification service: port 3005

2. **Rate limiting đã bị tắt** trong file `gateway.ts` để dễ test

3. **Public endpoints** không cần authentication:

   - `/api/auth/login`
   - `/api/auth/register`
   - `/api/booking/movies`
   - `/api/booking/showtimes`

4. **Protected endpoints** cần JWT token trong header:
   ```
   Authorization: Bearer <token>
   ```

## 🐛 Troubleshooting

### Lỗi: Cannot find module

```bash
npm install
```

### Lỗi: Address already in use (port 3000)

Đổi port trong `.env`:

```
PORT=8000
```

### Lỗi: Service not responding

Kiểm tra các microservices có đang chạy không:

```bash
# Test từng service
curl http://127.0.0.1:3001/health
curl http://127.0.0.1:3002/health
# ...
```

### Gateway không forward request

Check logs trong console, xem service nào đang lỗi.

## 📝 Next Steps

1. Setup và chạy các microservices (auth, booking, user, payment, notification)
2. Test integration giữa gateway và services
3. Setup Docker Compose để chạy toàn bộ hệ thống
