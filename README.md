# Movie-Ticket-Booking-App

## 📖 Giới thiệu (Introduction)

**CUTH** là dự án đồ án môn học được xây dựng nhằm giải quyết bài toán đặt vé xem phim truyền thống. Thay vì phải đến rạp xếp hàng, người dùng có thể thực hiện mọi thao tác từ chọn phim, chọn ghế, mua bắp nước và thanh toán ngay trên thiết bị di động.

Đồng thời, hệ thống cung cấp một công cụ quản trị mạnh mẽ cho Admin rạp chiếu để quản lý suất chiếu, quản lý vé, quản lý thông tin người dùng và thông báo

### 🎯 Mục tiêu dự án

- Hợp tác với nhóm tạo ra một ứng dụng đặt vé xem phim với trải nghiệm người dùng (UX) mượt mà, hiện đại, gần đầy đủ các tính năng cần thiết.
- Áp dụng kiến trúc Microservices và Clean Architecture để đảm bảo tính mở rộng.
- Tối ưu hóa quy trình đặt vé thời gian thực (Real-time booking) bằng liên kết VNPay
-

## 🔥 Chức năng Chính

### 👤 Đối với Khách hàng (End-User)

- **Đăng ký/Đăng nhập:** Hỗ trợ xác thực bảo mật bằng **FireBase**
- **Khám phá phim:** Xem danh sách phim đang chiếu, sắp chiếu.
- **Đặt vé thông minh:**
  - Chọn rạp và suất chiếu.
  - Sơ đồ ghế trực quan (phân biệt ghế thường, VIP, ghế đôi).
  - Chọn Combo bắp nước.
- **Thanh toán:** Tích hợp giả lập thanh toán sử dụng VNPay để hỗ trợ trực tuyến.
- **Vé điện tử:** Lưu trữ vé dưới dạng QR Code để check-in.
- **Thông Báo:** Thông báo đầy đủ các thông tin khi người dùng về các liên quan về đặt vé xem phim.

## 💻 Công nghệ Sử dụng

### Mobile App (Frontend)

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **State Management:** Flutter Bloc / Provider
- **Design:** Figma
- **Local Storage:** Shared Preferences / Hive

### 🔍 Backend & Database 

#### **Kiến trúc (Architecture)**

- **Pattern:** Microservices Architecture
- **API Gateway:** Node.js + TypeScript + Express.js
  - Routing & Load Balancing
  - Authentication Middleware
  - Request Caching (node-cache)
  - Error Handling & Logging

#### **Microservices**

1. **Auth Service** (JavaScript)

   - User Registration & Login
   - JWT Token Generation & Verification
   - Password Hashing (bcryptjs)
   - Firebase Authentication Integration
   - API Documentation (Swagger UI)

2. **Booking Service** (JavaScript)

   - Movie & Showtime Management
   - Seat Selection & Real-time Availability
   - Ticket Booking Logic
   - QR Code Generation

3. **User Service** (JavaScript)

   - User Profile Management
   - Booking History
   - Preferences & Settings

4. **Payment Service** (JavaScript)

   - VNPay Integration
   - Transaction Processing
   - Payment History & Refunds

5. **Notification Service** (JavaScript)
   - Email Notifications
   - Push Notifications (Firebase Cloud Messaging)
   - Booking Confirmations & Reminders

#### **Database**

- **MongoDB 8.2.2:** NoSQL database
  - User data, Booking records
  - Movie & Theater information
  - Transaction logs
- **Mongoose:** ODM for MongoDB

#### **Security & Authentication**

- **JWT (jsonwebtoken):** Stateless authentication
- **bcryptjs:** Password hashing (salt rounds: 10)
- **Firebase Admin SDK:** Additional authentication layer
- **CORS:** Cross-Origin Resource Sharing enabled
- **Environment Variables:** Sensitive data protection

#### **Validation & Documentation**

- **Joi:** Request validation
- **Swagger UI:** Interactive API documentation
- **JSDoc:** Code-level documentation

#### **DevOps & Deployment**

- **Docker:** Containerization (node:20-alpine)
- **Docker Compose:** Multi-container orchestration
- **Healthchecks:** Service monitoring
- **Non-root User:** Security best practices

### 🔥 Tools & DevOps

- **IDE:** Visual Studio Code, Visual Studio 2022
- **Version Control:** Git, GitHub
- **API Testing:** Postman / Swagger UI

---
