class Showtime {
  final String id;
  final String movieId;
  final String cinemaHall;
  final DateTime startTime;
  final DateTime endTime;
  final ShowtimePrice price;
  final int availableSeats;
  final String status;

  Showtime({
    required this.id,
    required this.movieId,
    required this.cinemaHall,
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.availableSeats,
    required this.status,
  });

  factory Showtime.fromJson(Map<String, dynamic> json) {
    // movieId có thể là String hoặc Object (nếu backend populate)
    String movieIdValue = '';
    if (json['movieId'] != null) {
      if (json['movieId'] is String) {
        movieIdValue = json['movieId'] as String;
      } else if (json['movieId'] is Map) {
        // Backend populate movieId thành object, lấy _id
        movieIdValue = json['movieId']['_id'] ?? '';
      }
    }

    return Showtime(
      id: json['_id'] ?? '',
      movieId: movieIdValue,
      cinemaHall: json['cinemaHall'] ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      price: ShowtimePrice.fromJson(json['price'] ?? {}),
      availableSeats: json['availableSeats'] ?? 0,
      status: json['status'] ?? 'available',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'movieId': movieId,
      'cinemaHall': cinemaHall,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'price': price.toJson(),
      'availableSeats': availableSeats,
      'status': status,
    };
  }
}

class ShowtimePrice {
  final int regular;
  final int vip;
  final int couple;

  ShowtimePrice({
    required this.regular,
    required this.vip,
    required this.couple,
  });

  factory ShowtimePrice.fromJson(Map<String, dynamic> json) {
    return ShowtimePrice(
      regular: json['regular'] ?? 0,
      vip: json['vip'] ?? 0,
      couple: json['couple'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'regular': regular, 'vip': vip, 'couple': couple};
  }
}
