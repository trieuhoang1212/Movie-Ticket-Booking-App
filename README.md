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

### Backend & Database

- **Core:** ASP.NET Core Web API (C#)
- **Architecture:** Clean Architecture, Repository Pattern
- **Database:** SQL Server / PostgreSQL
- **ORM:** Entity Framework Core
- **Authentication:** JWT (JSON Web Token) / Firebase Auth

### Tools & DevOps

- **IDE:** Visual Studio Code, Visual Studio 2022
- **Version Control:** Git, GitHub
- **API Testing:** Postman / Swagger UI

---
