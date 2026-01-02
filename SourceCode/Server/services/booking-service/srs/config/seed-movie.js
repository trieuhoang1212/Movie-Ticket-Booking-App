require("dotenv").config();
const mongoose = require("mongoose");
const Movie = require("../repositories/movie.model");

const MONGODB_URI =
  process.env.MONGODB_URI ||
  "mongodb://admin:admin123@localhost:27017/booking_ticket_movie?authSource=admin";

const sampleMovies = [
  {
    title: "Avatar: The Way of Water",
    description:
      "Jake Sully sống cùng gia đình mới của mình trên hành tinh Pandora. Khi một mối đe dọa quen thuộc trở lại để hoàn thành những gì đã bắt đầu trước đây, Jake phải làm việc với Neytiri và quân đội của chủng tộc Na'vi để bảo vệ hành tinh của họ.",
    duration: 192,
    genre: ["Sci-Fi", "Action", "Adventure"],
    releaseDate: new Date("2024-12-16"),
    rating: 8.5,
    posterUrl:
      "https://image.tmdb.org/t/p/w500/t6HIqrRAclMCA60NsSmeqe9RmNV.jpg",
    trailerUrl: "https://www.youtube.com/watch?v=d9MyW72ELq0",
    director: "James Cameron",
    cast: ["Sam Worthington", "Zoe Saldana", "Sigourney Weaver"],
    language: "English",
    status: "now_showing",
  },
  {
    title: "Spider-Man: No Way Home",
    description:
      "Peter Parker cầu cứu Doctor Strange sau khi danh tính của anh bị lộ. Khi một phép thuật để làm cho thế giới quên rằng anh là Spider-Man không diễn ra như kế hoạch, những kẻ thù nguy hiểm nhất từng đối đầu với Spider-Man trong mọi vũ trụ bắt đầu xuất hiện.",
    duration: 148,
    genre: ["Action", "Adventure", "Sci-Fi"],
    releaseDate: new Date("2024-12-15"),
    rating: 8.7,
    posterUrl:
      "https://image.tmdb.org/t/p/w500/1g0dhYtq4irTY1GPXvft6k4YLjm.jpg",
    trailerUrl: "https://www.youtube.com/watch?v=JfVOs4VSpmA",
    director: "Jon Watts",
    cast: ["Tom Holland", "Zendaya", "Benedict Cumberbatch"],
    language: "English",
    status: "now_showing",
  },
  {
    title: "The Batman",
    description:
      "Trong năm thứ hai của Batman trong vai trò người bảo vệ thành phố Gotham, anh phải đối mặt với một kẻ giết người hàng loạt tàn bạo nhắm vào các nhân vật chủ chốt của Gotham.",
    duration: 176,
    genre: ["Action", "Crime", "Drama"],
    releaseDate: new Date("2025-01-01"),
    rating: 8.2,
    posterUrl:
      "https://image.tmdb.org/t/p/w500/74xTEgt7R36Fpooo50r9T25onhq.jpg",
    trailerUrl: "https://www.youtube.com/watch?v=mqqft2x_Aa4",
    director: "Matt Reeves",
    cast: ["Robert Pattinson", "Zoë Kravitz", "Paul Dano"],
    language: "English",
    status: "coming_soon",
  },
  {
    title: "Top Gun: Maverick",
    description:
      "Sau hơn 30 năm phục vụ với tư cách là một phi công hàng đầu của Hải quân, Pete 'Maverick' Mitchell đang ở nơi anh thuộc về, thúc đẩy phong bì như một phi công thử nghiệm dũng cảm.",
    duration: 130,
    genre: ["Action", "Drama"],
    releaseDate: new Date("2024-11-20"),
    rating: 8.9,
    posterUrl:
      "https://image.tmdb.org/t/p/w500/62HCnUTziyWcpDaBO2i1DX17ljH.jpg",
    trailerUrl: "https://www.youtube.com/watch?v=qSqVVswa420",
    director: "Joseph Kosinski",
    cast: ["Tom Cruise", "Miles Teller", "Jennifer Connelly"],
    language: "English",
    status: "now_showing",
  },
  {
    title: "Doctor Strange in the Multiverse of Madness",
    description:
      "Doctor Strange, với sự giúp đỡ của các đồng minh huyền bí cũ và mới, đi qua những thực tại thay thế nguy hiểm và đáng kinh ngạc của Đa vũ trụ để đối đầu với một kẻ thù bí ẩn mới.",
    duration: 126,
    genre: ["Action", "Adventure", "Fantasy"],
    releaseDate: new Date("2024-12-10"),
    rating: 7.5,
    posterUrl:
      "https://image.tmdb.org/t/p/w500/9Gtg2DzBhmYamXBS1hKAhiwbBKS.jpg",
    trailerUrl: "https://www.youtube.com/watch?v=aWzlQ2N6qqg",
    director: "Sam Raimi",
    cast: ["Benedict Cumberbatch", "Elizabeth Olsen", "Chiwetel Ejiofor"],
    language: "English",
    status: "now_showing",
  },
];

async function seedMovies() {
  try {
    await mongoose.connect(MONGODB_URI);
    console.log("✅ Connected to MongoDB");

    // Xóa dữ liệu cũ
    await Movie.deleteMany({});
    console.log("Cleared old movies");

    // Thêm phim mới
    await Movie.insertMany(sampleMovies);
    console.log(`Inserted ${sampleMovies.length} movies`);

    mongoose.connection.close();
  } catch (error) {
    console.error("Error seeding movies:", error);
    process.exit(1);
  }
}

seedMovies();
