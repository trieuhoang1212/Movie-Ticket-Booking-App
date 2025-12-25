class Movie {
  final String id;
  final String title;
  final String description;
  final int duration; // phút
  final List<String> genre;
  final DateTime releaseDate;
  final double rating;
  final String? posterUrl;
  final String? trailerUrl;
  final String? director;
  final List<String>? cast;
  final String language;
  final String status; // now_showing, coming_soon, ended

  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.genre,
    required this.releaseDate,
    required this.rating,
    this.posterUrl,
    this.trailerUrl,
    this.director,
    this.cast,
    this.language = 'Vietnamese',
    this.status = 'now_showing',
  });

  // Convert JSON từ API thành Movie object
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? 0,
      genre: List<String>.from(json['genre'] ?? []),
      releaseDate: DateTime.parse(
        json['releaseDate'] ?? DateTime.now().toIso8601String(),
      ),
      rating: (json['rating'] ?? 0).toDouble(),
      posterUrl: json['posterUrl'],
      trailerUrl: json['trailerUrl'],
      director: json['director'],
      cast: json['cast'] != null ? List<String>.from(json['cast']) : null,
      language: json['language'] ?? 'Vietnamese',
      status: json['status'] ?? 'now_showing',
    );
  }

  // Convert Movie object thành JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'duration': duration,
      'genre': genre,
      'releaseDate': releaseDate.toIso8601String(),
      'rating': rating,
      'posterUrl': posterUrl,
      'trailerUrl': trailerUrl,
      'director': director,
      'cast': cast,
      'language': language,
      'status': status,
    };
  }

  // Lấy thời lượng dạng readable (vd: "1h 48m")
  String get durationFormatted {
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    return '${hours}h ${minutes}m';
  }

  // Lấy thể loại dạng string (vd: "Hành động . Phiêu lưu")
  String get genreFormatted {
    return genre.join(' . ');
  }

  // Lấy rating dạng string (vd: "8.5/10")
  String get ratingFormatted {
    return '${rating.toStringAsFixed(1)}/10';
  }
}
