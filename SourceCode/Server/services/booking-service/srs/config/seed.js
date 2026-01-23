const mongoose = require("mongoose");
const path = require("path");
require("dotenv").config({ path: path.join(__dirname, "../.env") });
const Movie = require("../repositories/movie.model");
const Showtime = require("../repositories/showtime.model");
const Seat = require("../repositories/seat.model");

const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log("✅ MongoDB Connected");
  } catch (error) {
    console.error("❌ MongoDB Error:", error.message);
    process.exit(1);
  }
};

// Dữ liệu phim mẫu
const moviesData = [
  {
    title: "Avatar: The Way of Water",
    description:
      "Jake Sully sống với gia đình mới của mình trên hành tinh Pandora. Khi một mối đe dọa quen thuộc trở lại để hoàn thành nhiệm vụ chưa hoàn thành, Jake phải làm việc với Neytiri và quân đội của chủng tộc Na'vi để bảo vệ hành tinh của họ.",
    duration: 192,
    genre: ["Hành động", "Phiêu lưu", "Khoa học viễn tưởng"],
    releaseDate: new Date("2024-01-15"),
    rating: 8.5,
    posterUrl:
      "https://image.tmdb.org/t/p/w500/t6HIqrRAclMCA60NsSmeqe9RmNV.jpg",
    trailerUrl: "https://www.youtube.com/watch?v=d9MyW72ELq0",
    director: "James Cameron",
    cast: ["Sam Worthington", "Zoe Saldana", "Sigourney Weaver"],
    language: "English",
    status: "now_showing",
    isHot: true,
  },
  {
    title: "Mai",
    description:
      "Bộ phim kể về hành trình trả thù của một sát thủ tên Mai, người phải đối mặt với quá khứ tội lỗi và tìm kiếm sự cứu rỗi.",
    duration: 131,
    genre: ["Hành động", "Tâm lý"],
    releaseDate: new Date("2024-02-10"),
    rating: 7.8,
    posterUrl:
      "https://www.elle.vn/wp-content/uploads/2023/12/06/560540/poster-Mai-scaled.jpg",
    trailerUrl: "https://www.youtube.com/watch?v=example",
    director: "Trấn Thành",
    cast: ["Phương Anh Đào", "Tuấn Trần", "Hồng Đào"],
    language: "Vietnamese",
    status: "now_showing",
    isHot: true,
  },
  {
    title: "Godzilla x Kong: The New Empire",
    description:
      "Hai titan huyền thoại phải hợp tác để đối mặt với một mối đe dọa mới từ chiều sâu của Hollow Earth.",
    duration: 115,
    genre: ["Hành động", "Khoa học viễn tưởng", "Phiêu lưu"],
    releaseDate: new Date("2024-03-29"),
    rating: 8.2,
    posterUrl:
      "https://m.media-amazon.com/images/M/MV5BMTY0N2MzODctY2ExYy00OWYxLTkyNDItMTVhZGIxZjliZjU5XkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg",
    trailerUrl: "https://www.youtube.com/watch?v=lV1OOlGwExM",
    director: "Adam Wingard",
    cast: ["Rebecca Hall", "Brian Tyree Henry", "Dan Stevens"],
    language: "English",
    status: "now_showing",
    isHot: false,
  },
  {
    title: "Dune: Part Two",
    description:
      "Paul Atreides hợp nhất với Chani và Fremen trong khi tìm cách trả thù những kẻ đã phá hủy gia đình mình.",
    duration: 166,
    genre: ["Khoa học viễn tưởng", "Phiêu lưu", "Chính kịch"],
    releaseDate: new Date("2024-03-01"),
    rating: 8.9,
    posterUrl:
      "https://image.tmdb.org/t/p/w500/1pdfLvkbY9ohJlCjQH2CZjjYVvJ.jpg",
    trailerUrl: "https://www.youtube.com/watch?v=Way9Dexny3w",
    director: "Denis Villeneuve",
    cast: ["Timothée Chalamet", "Zendaya", "Rebecca Ferguson"],
    language: "English",
    status: "now_showing",
    isHot: false,
  },
  {
    title: "Kung Fu Panda 4",
    description:
      "Po phải đào tạo một chiến binh mới khi anh ta gặp phải một phù thủy độc ác có kế hoạch triệu hồi lại tất cả những kẻ thù cũ của Po.",
    duration: 94,
    genre: ["Hoạt hình", "Hài", "Phiêu lưu"],
    releaseDate: new Date("2024-03-08"),
    rating: 7.5,
    posterUrl:
      "https://image.tmdb.org/t/p/w500/kDp1vUBnMpe8ak4rjgl3cLELqjU.jpg",
    trailerUrl: "https://www.youtube.com/watch?v=_inKs4eeHiI",
    director: "Mike Mitchell",
    cast: ["Jack Black", "Awkwafina", "Viola Davis"],
    language: "English",
    status: "now_showing",
    isHot: true,
  },

  {
    title: "Deadpool 3",
    description:
      "Wade Wilson trở lại với những cuộc phiêu lưu mới trong vũ trụ điện ảnh Marvel.",
    duration: 120,
    genre: ["Hành động", "Hài", "Siêu anh hùng"],
    releaseDate: new Date("2024-07-26"),
    rating: 0,
    posterUrl:
      "https://image.tmdb.org/t/p/w500/4XM8DUTQb3lhLemJC51Jx4a2EuA.jpg",
    trailerUrl: "https://www.youtube.com/watch?v=example",
    director: "Shawn Levy",
    cast: ["Ryan Reynolds", "Hugh Jackman", "Emma Corrin"],
    language: "English",
    status: "coming_soon",
  },
  {
    title: "Inside Out 2",
    description:
      "Riley bước vào tuổi thiếu niên và những cảm xúc mới xuất hiện trong trụ sở chỉ huy.",
    duration: 100,
    genre: ["Hoạt hình", "Gia đình", "Phiêu lưu"],
    releaseDate: new Date("2024-06-14"),
    rating: 0,
    posterUrl:
      "https://image.tmdb.org/t/p/w500/vpnVM9B6NMmQpWeZvzLvDESb2QY.jpg",
    trailerUrl: "https://www.youtube.com/watch?v=example",
    director: "Kelsey Mann",
    cast: ["Amy Poehler", "Phyllis Smith", "Lewis Black"],
    language: "English",
    status: "now_showing",
  },
  {
    title: "A Quiet Place: Day One",
    description:
      "Câu chuyện về ngày đầu tiên của cuộc xâm lược của những sinh vật săn mồi bằng âm thanh.",
    duration: 110,
    genre: ["Kinh dị", "Khoa học viễn tưởng", "Thriller"],
    releaseDate: new Date("2024-06-28"),
    rating: 0,
    posterUrl:
      "https://image.tmdb.org/t/p/w500/yrpPYKijwdMHyTGIOd1iK1h0Xno.jpg",
    trailerUrl: "https://www.youtube.com/watch?v=example",
    director: "Michael Sarnoski",
    cast: ["Lupita Nyong'o", "Joseph Quinn", "Alex Wolff"],
    language: "English",
    status: "now_showing",
  },
  {
    title: "Mufasa: The Lion King",
    description:
      "Câu chuyện nguồn gốc về Mufasa, cha của Simba, và hành trình trở thành Vua của Pride Lands.",
    duration: 118,
    genre: ["Hoạt hình", "Phiêu lưu", "Gia đình"],
    releaseDate: new Date("2024-12-20"),
    rating: 8,
    posterUrl: "https://www.bhdstar.vn/wp-content/uploads/2024/12/referenceSchemeHeadOfficeallowPlaceHoldertrueheight700ldapp-10.jpg",
    trailerUrl: "https://www.youtube.com/watch?v=example",
    director: "Barry Jenkins",
    cast: ["Aaron Pierre", "Kelvin Harrison Jr.", "John Kani"],
    language: "English",
    status: "now_showing",
  },
];

// Tạo showtimes cho mỗi phim
const createShowtimesForMovie = (movieId, movieTitle) => {
  const showtimes = [];
  const cinemas = ["CGV Vincom", "Galaxy Cinema"]; // Giảm từ 4 xuống 2 rạp
  const times = ["13:00", "16:00", "19:00"]; // Giảm từ 5 xuống 3 suất

  // Tạo suất chiếu cho 3 ngày tới (giảm từ 7 xuống 3)
  for (let day = 0; day < 3; day++) {
    const date = new Date();
    date.setDate(date.getDate() + day);

    cinemas.forEach((cinema) => {
      times.forEach((time) => {
        const [hours, minutes] = time.split(":");
        const startTime = new Date(date);
        startTime.setHours(parseInt(hours), parseInt(minutes), 0);

        showtimes.push({
          movieId,
          cinemaHall: `${cinema} - Phòng ${Math.floor(Math.random() * 5) + 1}`,
          startTime,
          endTime: new Date(startTime.getTime() + 120 * 60000), // +2 hours
          price: {
            regular: 75000,
            vip: 120000,
            couple: 200000,
          },
          availableSeats: 96, // 8 rows x 12 seats = 96 seats
          status: "available",
        });
      });
    });
  }

  return showtimes;
};

// Tạo ghế cho mỗi showtime
const createSeatsForShowtime = (showtimeId) => {
  const seats = [];
  const rows = ["A", "B", "C", "D", "E", "F", "G", "H"];
  const seatsPerRow = 12;

  rows.forEach((row, rowIndex) => {
    for (let i = 1; i <= seatsPerRow; i++) {
      let type = "regular";
      if (rowIndex >= 6) type = "vip"; // 2 hàng cuối là VIP
      if (i === 5 || i === 6) type = "couple"; // Ghế đôi ở giữa

      seats.push({
        showtimeId,
        seatNumber: `${row}${i}`,
        row,
        type,
        status: "available",
      });
    }
  });

  return seats;
};

// Chạy seed
const seedDatabase = async () => {
  try {
    await connectDB();

    console.log("🗑️  Clearing existing data...");
    await Movie.deleteMany({});
    await Showtime.deleteMany({});
    await Seat.deleteMany({});

    console.log("🎬 Creating movies...");
    const createdMovies = await Movie.insertMany(moviesData);
    console.log(`✅ Created ${createdMovies.length} movies`);

    console.log("🎭 Creating showtimes...");
    let allShowtimes = [];
    for (const movie of createdMovies) {
      if (movie.status === "now_showing") {
        const showtimes = createShowtimesForMovie(movie._id, movie.title);
        allShowtimes = allShowtimes.concat(showtimes);
      }
    }
    const createdShowtimes = await Showtime.insertMany(allShowtimes);
    console.log(`✅ Created ${createdShowtimes.length} showtimes`);

    console.log("💺 Creating seats...");
    let allSeats = [];
    for (const showtime of createdShowtimes) {
      const seats = createSeatsForShowtime(showtime._id);
      allSeats = allSeats.concat(seats);
    }
    await Seat.insertMany(allSeats);
    console.log(`✅ Created ${allSeats.length} seats`);

    console.log("🎉 Database seeded successfully!");

    // Hiển thị thống kê
    const nowShowingCount = await Movie.countDocuments({
      status: "now_showing",
    });
    const comingSoonCount = await Movie.countDocuments({
      status: "coming_soon",
    });

    console.log("\n📊 Summary:");
    console.log(`- Phim đang chiếu: ${nowShowingCount}`);
    console.log(`- Phim sắp chiếu: ${comingSoonCount}`);
    console.log(`- Tổng suất chiếu: ${createdShowtimes.length}`);
    console.log(`- Tổng ghế: ${allSeats.length}`);

    process.exit(0);
  } catch (error) {
    console.error("❌ Seed error:", error);
    process.exit(1);
  }
};

seedDatabase();
