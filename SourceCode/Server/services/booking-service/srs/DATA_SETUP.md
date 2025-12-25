# Hướng dẫn tạo dữ liệu cho Frontend

## 📊 Cấu trúc dữ liệu

Frontend cần các loại dữ liệu sau:

1. **Phim Hot (Now Showing)** - Phim đang chiếu
2. **Phim Sắp Chiếu (Coming Soon)** - Phim sắp ra mắt
3. **Suất chiếu (Showtimes)** - Lịch chiếu theo phim
4. **Ghế (Seats)** - Sơ đồ ghế theo suất chiếu

## 🚀 Cách tạo dữ liệu

### Bước 1: Chạy seed script

```bash
cd services/booking-service/srs
node seed.js
```

Script này sẽ tạo:

- 10 phim (5 đang chiếu + 5 sắp chiếu)
- Suất chiếu cho phim đang chiếu (7 ngày tới, 4 rạp, 5 khung giờ/ngày)
- Ghế cho mỗi suất chiếu (8 hàng x 12 ghế)

### Bước 2: Kiểm tra dữ liệu

```bash
# Kết nối MongoDB
mongo mongodb://localhost:27017/booking_ticket_movie

# Hoặc với authentication
mongo mongodb://admin:admin123@localhost:27017/booking_ticket_movie?authSource=admin

# Kiểm tra
use booking_ticket_movie
db.movies.count()
db.showtimes.count()
db.seats.count()
```

## 📡 API Endpoints cho Frontend

### 1. Lấy danh sách phim đang chiếu (Hot Movies)

```javascript
// GET /api/bookings/movies?status=now_showing

fetch("http://localhost:3002/api/bookings/movies?status=now_showing")
  .then((res) => res.json())
  .then((data) => {
    console.log("Phim đang chiếu:", data.data.movies);
  });
```

**Response:**

```json
{
  "success": true,
  "data": {
    "movies": [
      {
        "_id": "...",
        "title": "Avatar: The Way of Water",
        "description": "...",
        "duration": 192,
        "genre": ["Hành động", "Phiêu lưu"],
        "releaseDate": "2024-01-15T00:00:00.000Z",
        "rating": 8.5,
        "posterUrl": "https://...",
        "trailerUrl": "https://...",
        "status": "now_showing"
      }
    ]
  }
}
```

### 2. Lấy danh sách phim sắp chiếu

```javascript
// GET /api/bookings/movies?status=coming_soon

fetch("http://localhost:3002/api/bookings/movies?status=coming_soon")
  .then((res) => res.json())
  .then((data) => {
    console.log("Phim sắp chiếu:", data.data.movies);
  });
```

### 3. Lấy chi tiết 1 phim

```javascript
// GET /api/bookings/movies/:movieId (cần thêm endpoint này)

fetch(`http://localhost:3002/api/bookings/movies/${movieId}`)
  .then((res) => res.json())
  .then((data) => {
    console.log("Chi tiết phim:", data.data.movie);
  });
```

### 4. Lấy suất chiếu theo phim

```javascript
// GET /api/bookings/showtimes/:movieId

fetch(`http://localhost:3002/api/bookings/showtimes/${movieId}`)
  .then((res) => res.json())
  .then((data) => {
    console.log("Suất chiếu:", data.data.showtimes);
  });
```

**Response:**

```json
{
  "success": true,
  "data": {
    "showtimes": [
      {
        "_id": "...",
        "movieId": {...},
        "cinema": "CGV Vincom",
        "room": "Phòng 1",
        "startTime": "2024-12-24T10:00:00.000Z",
        "endTime": "2024-12-24T12:00:00.000Z",
        "price": {
          "standard": 75000,
          "vip": 120000,
          "couple": 200000
        },
        "status": "available"
      }
    ]
  }
}
```

### 5. Lấy ghế theo suất chiếu

```javascript
// GET /api/bookings/seats/:showtimeId

fetch(`http://localhost:3002/api/bookings/seats/${showtimeId}`)
  .then((res) => res.json())
  .then((data) => {
    console.log("Ghế:", data.data.seats);
  });
```

## 🎨 Hiển thị trên Frontend

### Component: Phim Hot (Now Showing)

```jsx
import { useEffect, useState } from "react";

function HotMovies() {
  const [movies, setMovies] = useState([]);

  useEffect(() => {
    fetch("http://localhost:3002/api/bookings/movies?status=now_showing")
      .then((res) => res.json())
      .then((data) => setMovies(data.data.movies));
  }, []);

  return (
    <div className="hot-movies">
      <h2>Phim Hot</h2>
      <div className="movies-grid">
        {movies.map((movie) => (
          <div key={movie._id} className="movie-card">
            <img src={movie.posterUrl} alt={movie.title} />
            <h3>{movie.title}</h3>
            <p>⭐ {movie.rating}/10</p>
            <p>⏱️ {movie.duration} phút</p>
            <button>Đặt vé</button>
          </div>
        ))}
      </div>
    </div>
  );
}
```

### Component: Phim Sắp Chiếu

```jsx
function ComingSoonMovies() {
  const [movies, setMovies] = useState([]);

  useEffect(() => {
    fetch("http://localhost:3002/api/bookings/movies?status=coming_soon")
      .then((res) => res.json())
      .then((data) => setMovies(data.data.movies));
  }, []);

  return (
    <div className="coming-soon">
      <h2>Phim Sắp Chiếu</h2>
      <div className="movies-grid">
        {movies.map((movie) => (
          <div key={movie._id} className="movie-card">
            <img src={movie.posterUrl} alt={movie.title} />
            <h3>{movie.title}</h3>
            <p>
              📅 Khởi chiếu:{" "}
              {new Date(movie.releaseDate).toLocaleDateString("vi-VN")}
            </p>
            <button disabled>Sắp ra mắt</button>
          </div>
        ))}
      </div>
    </div>
  );
}
```

### Component: Chi tiết phim & Chọn suất

```jsx
function MovieDetail({ movieId }) {
  const [movie, setMovie] = useState(null);
  const [showtimes, setShowtimes] = useState([]);

  useEffect(() => {
    // Lấy thông tin phim
    fetch(`http://localhost:3002/api/bookings/movies`)
      .then((res) => res.json())
      .then((data) => {
        const found = data.data.movies.find((m) => m._id === movieId);
        setMovie(found);
      });

    // Lấy suất chiếu
    fetch(`http://localhost:3002/api/bookings/showtimes/${movieId}`)
      .then((res) => res.json())
      .then((data) => setShowtimes(data.data.showtimes));
  }, [movieId]);

  if (!movie) return <div>Loading...</div>;

  return (
    <div className="movie-detail">
      <div className="movie-info">
        <img src={movie.posterUrl} alt={movie.title} />
        <div>
          <h1>{movie.title}</h1>
          <p>{movie.description}</p>
          <p>
            ⏱️ {movie.duration} phút | {movie.genre.join(", ")}
          </p>
          <p>🎬 {movie.director}</p>
        </div>
      </div>

      <h2>Chọn suất chiếu</h2>
      <div className="showtimes-list">
        {showtimes.map((showtime) => (
          <div key={showtime._id} className="showtime-card">
            <p>🏢 {showtime.cinema}</p>
            <p>🕒 {new Date(showtime.startTime).toLocaleString("vi-VN")}</p>
            <p>💰 Từ {showtime.price.standard.toLocaleString()}đ</p>
            <button onClick={() => selectShowtime(showtime._id)}>Chọn</button>
          </div>
        ))}
      </div>
    </div>
  );
}
```

## 🔧 API còn thiếu cần thêm

Thêm vào `booking.controller.js`:

```javascript
// Lấy chi tiết 1 phim
exports.getMovieById = async (req, res) => {
  try {
    const { id } = req.params;
    const movie = await Movie.findById(id);

    if (!movie) {
      return res.status(404).json({
        success: false,
        message: "Movie not found",
      });
    }

    res.status(200).json({
      success: true,
      data: { movie },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server error",
      error: error.message,
    });
  }
};
```

Thêm route:

```javascript
router.get("/movies/:id", bookingController.getMovieById);
```

## 📝 Tóm tắt

1. **Chạy seed.js** để tạo dữ liệu mẫu
2. **Sử dụng các API** đã có trong booking-service
3. **Frontend gọi API** để hiển thị:
   - Phim hot: `?status=now_showing`
   - Phim sắp chiếu: `?status=coming_soon`
   - Suất chiếu: `/showtimes/:movieId`
   - Ghế: `/seats/:showtimeId`

Dữ liệu đã sẵn sàng cho frontend! 🎉
