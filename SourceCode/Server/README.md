# Movie Ticket Booking App - Server


## 📦 Các Service

- **API Gateway**: Điểm truy cập chính, xác thực JWT, định tuyến request
- **Auth Service**: Đăng ký, đăng nhập, quản lý token
- **User Service**: Quản lý thông tin người dùng
- **Booking Service**: Xử lý đặt vé, chọn ghế
- **Payment Service**: Tích hợp VNPay, xử lý thanh toán
- **Notification Service**: Gửi thông báo email/push

## 🛠️ Tech Stack

- **Runtime**: Node.js 20
- **Language**: TypeScript (Gateway), JavaScript (Services)
- **Database**: MongoDB 8.2.2
- **Auth**: JWT, bcryptjs, Firebase Admin SDK
- **Container**: Docker, Docker Compose
- **Documentation**: Swagger UI

## 🚀 Cài đặt và Chạy

### Yêu cầu
- Node.js 20+
- Docker & Docker Compose
- MongoDB (hoặc dùng Docker)

### Chạy với Docker
```bash
cd SourceCode/Server
docker-compose up -d
```

## 📝 API Documentation

Swagger UI có sẵn tại mỗi service:
- Auth Service: http://localhost:3001/api-docs
- API Gateway: http://localhost:3000/health

## 🔒 Bảo mật

- Tất cả `.env` files đã được thêm vào `.gitignore`
- Sử dụng file `.env.example` làm template
- JWT token cho authentication
- Password hashing với bcryptjs

## 📂 Cấu trúc thư mục

```
Server/
├── api-gateway/          # API Gateway (TypeScript)
├── services/
│   ├── auth-service/     # Xác thực người dùng
│   ├── user-service/     # Quản lý user
│   ├── booking-service/  # Đặt vé
│   ├── payment-service/  # Thanh toán
│   └── notification-service/  # Thông báo
├── docker-compose.yml    # Docker orchestration
└── README.md
```
