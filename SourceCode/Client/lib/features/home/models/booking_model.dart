class Booking {
  final String id;
  final String userId;
  final BookingShowtime showtime;
  final List<BookingSeat> seats;
  final double totalAmount;
  final String bookingCode;
  final String status; // pending, confirmed, cancelled, completed
  final String paymentStatus; // pending, paid, refunded
  final String? paymentMethod;
  final String? qrCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.id,
    required this.userId,
    required this.showtime,
    required this.seats,
    required this.totalAmount,
    required this.bookingCode,
    required this.status,
    required this.paymentStatus,
    this.paymentMethod,
    this.qrCode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    // Backend trả về 'showtime' object (không phải 'showtimeId')
    final showtimeData = json['showtime'] ?? json['showtimeId'] ?? {};

    return Booking(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      showtime: BookingShowtime.fromJson(showtimeData),
      seats:
          (json['seats'] as List?)
              ?.map((seat) => BookingSeat.fromJson(seat))
              .toList() ??
          [],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      bookingCode: json['bookingCode'] ?? '',
      status: json['status'] ?? 'pending',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      paymentMethod: json['paymentMethod'],
      qrCode: json['qrCode'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  // Helper để kiểm tra vé đã xem chưa
  bool get isCompleted => status == 'completed' || status == 'cancelled';
}

class BookingShowtime {
  final String id;
  final MovieInfo movie;
  final DateTime startTime;
  final DateTime endTime;
  final String cinema;
  final String screen;
  final String status;

  BookingShowtime({
    required this.id,
    required this.movie,
    required this.startTime,
    required this.endTime,
    required this.cinema,
    required this.screen,
    required this.status,
  });

  factory BookingShowtime.fromJson(Map<String, dynamic> json) {
    // Backend trả về format: showtime.movieTitle, showtime.moviePoster, showtime.theaterName
    String cinema = json['theaterName'] ?? json['cinema'] ?? 'Unknown Cinema';
    String screen =
        json['roomName'] ?? json['room'] ?? json['screen'] ?? 'Unknown Screen';

    // Parse movie info
    MovieInfo movie;
    if (json['movieId'] != null && json['movieId'] is Map) {
      // Format cũ: có movieId object
      movie = MovieInfo.fromJson(json['movieId']);
    } else {
      // Format mới từ backend: movieTitle, moviePoster trực tiếp
      movie = MovieInfo(
        id: json['movieId']?.toString() ?? '',
        title: json['movieTitle'] ?? 'Unknown Movie',
        posterUrl: json['moviePoster'],
      );
    }

    return BookingShowtime(
      id: json['_id'] ?? '',
      movie: movie,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'])
          : DateTime.now(),
      cinema: cinema,
      screen: screen,
      status: json['status'] ?? 'available',
    );
  }
}

class MovieInfo {
  final String id;
  final String title;
  final String? posterUrl;

  MovieInfo({required this.id, required this.title, this.posterUrl});

  factory MovieInfo.fromJson(Map<String, dynamic> json) {
    return MovieInfo(
      id: json['_id'] ?? '',
      title: json['title'] ?? 'Unknown Movie',
      posterUrl: json['posterUrl'],
    );
  }
}

class BookingSeat {
  final String seatId;
  final String seatNumber;
  final String type;
  final double price;

  BookingSeat({
    required this.seatId,
    required this.seatNumber,
    required this.type,
    required this.price,
  });

  factory BookingSeat.fromJson(Map<String, dynamic> json) {
    return BookingSeat(
      seatId: json['seatId'] ?? '',
      seatNumber: json['seatNumber'] ?? '',
      type: json['type'] ?? 'standard',
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}
