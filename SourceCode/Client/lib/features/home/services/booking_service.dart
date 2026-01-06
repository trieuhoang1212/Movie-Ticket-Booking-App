import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../models/booking_model.dart';

class BookingService {
  // URL của API - Gọi trực tiếp đến Booking Service
  // Android emulator: 10.0.2.2 = localhost của máy host
  static const String baseUrl = 'http://10.0.2.2:3002';

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
        Uri.parse('$baseUrl/api/bookings/$bookingId'),
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
        Uri.parse('$baseUrl/api/bookings/$bookingId/cancel'),
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

      final response = await http.post(
        Uri.parse('$baseUrl/api/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'showtimeId': showtimeId, 'seatIds': seatIds}),
      );

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
      print('Error creating booking: $e');
      throw Exception('Error creating booking: $e');
    }
  }
}
