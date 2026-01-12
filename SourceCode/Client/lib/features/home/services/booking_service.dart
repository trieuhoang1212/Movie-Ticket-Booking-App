import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../models/booking_model.dart';
import '../models/showtime_model.dart';
import '../models/seat_model.dart';

class BookingService {
  // URL của API Gateway
  // Android emulator: 10.0.2.2 = localhost của máy host
  static const String baseUrl = 'http://10.0.2.2:3000/api/booking';

  // Lấy danh sách booking của user hiện tại
  Future<List<Booking>> getMyBookings() async {
    try {
      // Lấy Firebase token để authenticate
      final user = FirebaseAuth.instance.currentUser;

      // Tạm thời dùng mock token cho development
      final token = user != null ? await user.getIdToken() : 'dev-token';

      // Gọi API
      final response = await http.get(
        Uri.parse('$baseUrl/my-bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📱 Response status: ${response.statusCode}');
      print('📱 Response body: ${response.body}');

      // Kiểm tra response
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Parse danh sách bookings từ response
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> bookingsJson = data['data']['bookings'];
          return bookingsJson.map((json) => Booking.fromJson(json)).toList();
        } else {
          throw Exception('Invalid response format');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception('Failed to load bookings: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching bookings: $e');
      throw Exception('Error fetching bookings: $e');
    }
  }

  // Lấy chi tiết 1 booking theo ID
  Future<Booking> getBookingById(String bookingId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final token = await user.getIdToken();

      final response = await http.get(
        Uri.parse('$baseUrl/$bookingId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          return Booking.fromJson(data['data']['booking']);
        } else {
          throw Exception('Invalid response format');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Booking not found');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to load booking: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching booking details: $e');
      throw Exception('Error fetching booking details: $e');
    }
  }

  // Hủy booking
  Future<bool> cancelBooking(String bookingId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final token = await user.getIdToken();

      final response = await http.post(
        Uri.parse('$baseUrl/$bookingId/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['success'] == true;
      } else {
        throw Exception('Failed to cancel booking: ${response.statusCode}');
      }
    } catch (e) {
      print('Error cancelling booking: $e');
      throw Exception('Error cancelling booking: $e');
    }
  }

  // Lấy danh sách showtimes theo movieId
  Future<List<Showtime>> getShowtimesByMovie(String movieId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/movies/$movieId/showtimes'),
        headers: {'Content-Type': 'application/json'},
      );

      print('📅 Showtimes response status: ${response.statusCode}');
      // print('📅 Showtimes response body: ${response.body}'); // Comment để tránh log quá dài

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> showtimesJson = data['data']['showtimes'];

          // DEBUG: In showtime đầu tiên để kiểm tra cấu trúc
          if (showtimesJson.isNotEmpty) {
            print('🔍 First showtime structure:');
            print('   _id: ${showtimesJson[0]['_id']}');
            print(
              '   cinemaHall type: ${showtimesJson[0]['cinemaHall']?.runtimeType}',
            );
            print('   cinemaHall value: ${showtimesJson[0]['cinemaHall']}');
            print(
              '   movieId type: ${showtimesJson[0]['movieId']?.runtimeType}',
            );
          }
          return showtimesJson.map((json) => Showtime.fromJson(json)).toList();
        } else {
          throw Exception('Invalid response format');
        }
      } else if (response.statusCode == 404) {
        throw Exception('No showtimes found for this movie');
      } else {
        throw Exception('Failed to load showtimes: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching showtimes: $e');
      throw Exception('Error fetching showtimes: $e');
    }
  }

  // Lấy danh sách ghế theo showtimeId
  Future<List<Seat>> getSeatsByShowtime(String showtimeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/showtimes/$showtimeId/seats'),
        headers: {'Content-Type': 'application/json'},
      );

      print('💺 Seats response status: ${response.statusCode}');
      print('💺 Seats response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> seatsJson = data['data']['seats'];
          return seatsJson.map((json) => Seat.fromJson(json)).toList();
        } else {
          throw Exception('Invalid response format');
        }
      } else if (response.statusCode == 404) {
        throw Exception('No seats found for this showtime');
      } else {
        throw Exception('Failed to load seats: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching seats: $e');
      throw Exception('Error fetching seats: $e');
    }
  }

  // Tạo booking mới
  Future<Booking> createBooking({
    required String showtimeId,
    required List<String> seatIds,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final token = await user.getIdToken();

      final requestBody = {'showtimeId': showtimeId, 'seatIds': seatIds};
      print('📤 Creating booking with: $requestBody');

      final response = await http.post(
        Uri.parse('$baseUrl'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      print('🎫 Create booking response status: ${response.statusCode}');
      print('🎫 Create booking response body: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          return Booking.fromJson(data['data']['booking']);
        } else {
          throw Exception('Invalid response format');
        }
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Bad request');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        throw Exception('Failed to create booking: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error creating booking: $e');
      throw Exception('Error creating booking: $e');
    }
  }
}
