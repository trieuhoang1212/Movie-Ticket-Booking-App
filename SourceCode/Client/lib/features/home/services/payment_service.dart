import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  // URL của Payment Service
  static const String baseUrl = 'http://10.0.2.2:3004';

  // Tạo URL thanh toán VNPay
  Future<String> createVNPayPayment({
    required String orderId,
    required int amount,
    required String orderInfo,
    String? bankCode,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final token = await user.getIdToken();

      final response = await http.post(
        Uri.parse('$baseUrl/api/payments/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'orderId': orderId,
          'amount': amount,
          'orderInfo': orderInfo,
          'bankCode': bankCode,
        }),
      );

      print('💳 Payment response status: ${response.statusCode}');
      print('💳 Payment response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true && data['paymentUrl'] != null) {
          return data['paymentUrl'];
        } else {
          throw Exception('Invalid response format');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      } else {
        final Map<String, dynamic> data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to create payment');
      }
    } catch (e) {
      print('❌ Error creating payment: $e');
      throw Exception('Error creating payment: $e');
    }
  }

  // Kiểm tra trạng thái thanh toán
  Future<Map<String, dynamic>> checkPaymentStatus(String orderId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final token = await user.getIdToken();

      final response = await http.get(
        Uri.parse('$baseUrl/api/payments/status/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to check payment status');
      }
    } catch (e) {
      print('❌ Error checking payment status: $e');
      throw Exception('Error checking payment status: $e');
    }
  }
}
