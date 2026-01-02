import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart';

class MovieService {
  // URL của API Gateway - Thay đổi theo môi trường của bạn
  static const String baseUrl = 'http://localhost:3000';

  // Lấy danh sách phim theo status
  Future<List<Movie>> getMovies({String? status}) async {
    try {
      // Build URL với query parameter
      String url = '$baseUrl/api/booking/movies';
      if (status != null) {
        url += '?status=$status';
      }

      // Gọi API
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      // Kiểm tra response
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Parse danh sách phim từ response
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> moviesJson = data['data']['movies'];
          return moviesJson.map((json) => Movie.fromJson(json)).toList();
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load movies: ${response.statusCode}');
      }
    } catch (e) {
      ('Error fetching movies: $e');
      throw Exception('Error fetching movies: $e');
    }
  }

  // Lấy phim đang hot (now_showing)
  Future<List<Movie>> getHotMovies() async {
    return await getMovies(status: 'now_showing');
  }

  // Lấy phim sắp chiếu (coming_soon)
  Future<List<Movie>> getComingSoonMovies() async {
    return await getMovies(status: 'coming_soon');
  }

  // Lấy chi tiết 1 phim theo ID
  Future<Movie> getMovieById(String movieId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/booking/movies/$movieId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          return Movie.fromJson(data['data']['movie']);
        } else {
          throw Exception('Invalid response format');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Movie not found');
      } else {
        throw Exception('Failed to load movie: ${response.statusCode}');
      }
    } catch (e) {
      ('Error fetching movie details: $e');
      throw Exception('Error fetching movie details: $e');
    }
  }
}
