# 📡 Tài liệu tích hợp API - Movie Ticket Booking App

## ✅ Tình trạng tích hợp API

### 🎬 Movie Service
**File:** `Client/lib/features/home/services/movie_service.dart`
**Base URL:** `http://10.0.2.2:3000` (API Gateway)

#### Các endpoint đã tích hợp:
- ✅ `GET /api/booking/movies` - Lấy danh sách phim
- ✅ `GET /api/booking/movies?status=now_showing` - Phim đang chiếu
- ✅ `GET /api/booking/movies?status=coming_soon` - Phim sắp chiếu
- ✅ `GET /api/booking/movies/:id` - Chi tiết phim

**Sử dụng trong:**
- `home_screen.dart` - Hiển thị phim hot và đang chiếu
- Kết nối với Backend ✅

---

### 🎫 Booking Service
**File:** `Client/lib/features/home/services/booking_service.dart`
**Base URL:** `http://10.0.2.2:3002` (Booking Service trực tiếp)

#### Các endpoint đã tích hợp:
- ✅ `GET /my-bookings` - Lấy danh sách vé của user (có authentication)
- ✅ `GET /api/bookings/:id` - Chi tiết booking
- ✅ `POST /api/bookings/:id/cancel` - Hủy booking

**Authentication:** 
- Sử dụng Firebase Auth Token
- Dev mode: dùng token 'dev-token'

**Sử dụng trong:**
- `my_tickets_screen.dart` - Hiển thị vé đã đặt
- Kết nối với Backend ✅

---

## 🔄 Luồng dữ liệu đầy đủ

### 1. Xem phim (Home → Movie Detail)
```
User mở app
  ↓
HomeScreen gọi MovieService.getHotMovies()
  ↓
API: GET http://10.0.2.2:3000/api/booking/movies?status=now_showing
  ↓
Backend trả về danh sách phim
  ↓
Hiển thị phim trên HomeScreen
  ↓
User click vào phim
  ↓
Chuyển đến MovieDetailScreen với movieData
```

### 2. Đặt vé (Movie Detail → Booking → Confirmation)
```
User click "ĐẶT GHẾ" trên MovieDetailScreen
  ↓
Chuyển đến BookingScreen
  ↓
User chọn ngày, giờ, ghế
  ↓
Click "ĐẶT GHẾ"
  ↓
[TODO] Gọi BookingService.createBooking()
  ↓
[TODO] API: POST http://10.0.2.2:3002/bookings
  ↓
[TODO] Backend tạo booking và trả về kết quả
  ↓
[TODO] Chuyển đến màn hình xác nhận
```

### 3. Xem vé đã đặt (Bottom Nav → My Tickets)
```
User click icon vé trên Bottom Nav
  ↓
Chuyển đến MyTicketsScreen
  ↓
MyTicketsScreen gọi BookingService.getMyBookings()
  ↓
API: GET http://10.0.2.2:3002/my-bookings
  ↓
Backend trả về danh sách vé
  ↓
Hiển thị danh sách vé (Vé hiện tại / Vé đã xem)
```

---

## 📱 Cấu hình Network cho Android Emulator

**Quan trọng:** `10.0.2.2` = `localhost` của máy host

### Kiểm tra kết nối:
```bash
# 1. Đảm bảo services đang chạy
cd SourceCode/Server
docker-compose up -d

# 2. Kiểm tra ports
# API Gateway: http://localhost:3000
# Booking Service: http://localhost:3002

# 3. Test từ Flutter app sẽ dùng:
# http://10.0.2.2:3000
# http://10.0.2.2:3002
```

---

## 🎯 Các màn hình đã đồng bộ

### 1. HomeScreen ✅
- Import: MovieDetailScreen, FavoriteScreen, MyTicketsScreen
- Navigation: Click phim → MovieDetailScreen
- Bottom Nav: Chuyển đổi giữa Home/Tickets/Favorites
- API: Gọi MovieService để load phim

### 2. MovieDetailScreen ✅
- Nhận movieData từ HomeScreen
- Hiển thị thông tin chi tiết phim
- Button "ĐẶT GHẾ" → BookingScreen

### 3. BookingScreen ✅
- Nhận movieData từ MovieDetailScreen
- Chọn ngày, giờ, ghế
- [TODO] Tích hợp API createBooking

### 4. MyTicketsScreen ✅
- Gọi BookingService.getMyBookings()
- Hiển thị vé theo tabs (Hiện tại/Đã xem)
- Kết nối Backend ✅

### 5. FavoriteScreen ✅
- Nhận favoriteMovies từ HomeScreen
- [TODO] Lưu vào local storage hoặc backend

---

## 🚀 Các bước tiếp theo

### 1. Hoàn thiện BookingScreen
```dart
// TODO: Thêm API call để tạo booking
Future<void> _createBooking() async {
  final booking = await BookingService().createBooking(
    showtimeId: selectedShowtimeId,
    seatIds: selectedSeatIds,
  );
  // Navigate to confirmation screen
}
```

### 2. Thêm Showtime API
```dart
// TODO: Load suất chiếu thực từ backend
Future<List<Showtime>> getShowtimes(String movieId) async {
  // API call
}
```

### 3. Thêm Seat API
```dart
// TODO: Load danh sách ghế theo showtime
Future<List<Seat>> getSeats(String showtimeId) async {
  // API call
}
```

### 4. Authentication hoàn chỉnh
- Tích hợp Firebase Auth đầy đủ
- Thay thế 'dev-token' bằng token thật
- Xử lý trường hợp chưa đăng nhập

---

## ✅ Checklist tích hợp

- [x] MovieService kết nối API Gateway
- [x] BookingService kết nối Booking Service
- [x] MyTicketsScreen hiển thị vé từ backend
- [x] HomeScreen hiển thị phim từ backend
- [x] Navigation giữa các màn hình
- [ ] CreateBooking API integration
- [ ] Showtime API integration
- [ ] Seat Selection API integration
- [ ] Payment integration
- [ ] QR Code generation
- [ ] Push notification

---

## 🐛 Debug & Testing

### Test API từ terminal:
```bash
# Test movie API
curl http://localhost:3000/api/booking/movies

# Test booking API (cần token)
curl -H "Authorization: Bearer dev-token" http://localhost:3002/my-bookings
```

### Xem logs trong Flutter:
```dart
// MovieService và BookingService đã có print statements
// Check console khi chạy app để xem API responses
```

---

**Cập nhật:** 06/01/2026
**Status:** ✅ Backend đã kết nối, API calls hoạt động
