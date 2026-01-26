import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class FCMService {
  static const String baseUrl = 'http://192.168.88.136:3000/api/auth';
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Đăng nhập/Đồng bộ user từ Firebase vào backend
  Future<bool> authenticateWithBackend() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('⚠️ User not authenticated');
        return false;
      }

      final authToken = await user.getIdToken();

      final response = await http.post(
        Uri.parse('$baseUrl/firebase-auth'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        print('✅ User authenticated with backend');
        return true;
      } else {
        print('❌ Backend authentication failed: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error authenticating with backend: $e');
      return false;
    }
  }

  // Lưu FCM token lên server
  Future<void> saveFCMToken() async {
    try {
      // Bước 1: Đăng nhập với backend (tạo user nếu chưa có)
      final authenticated = await authenticateWithBackend();
      if (!authenticated) {
        print('⚠️ Skipping FCM token save - backend authentication failed');
        return;
      }

      // Bước 2: Lấy FCM token
      final fcmToken = await _firebaseMessaging.getToken();
      if (fcmToken == null) {
        print('⚠️ FCM Token is null');
        return;
      }

      print('📱 FCM Token: $fcmToken');

      // Lấy Firebase Auth token
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('⚠️ User not authenticated');
        return;
      }

      final authToken = await user.getIdToken();

      // Gửi FCM token lên server
      final response = await http.post(
        Uri.parse('$baseUrl/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({'fcmToken': fcmToken}),
      );

      if (response.statusCode == 200) {
        print('✅ FCM token saved to server');
      } else {
        print('❌ Failed to save FCM token: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Error saving FCM token: $e');
    }
  }

  // Xóa FCM token khi logout
  Future<void> deleteFCMToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final authToken = await user.getIdToken();

      await http.delete(
        Uri.parse('$baseUrl/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      print('✅ FCM token deleted from server');
    } catch (e) {
      print('❌ Error deleting FCM token: $e');
    }
  }

  // Subscribe to topic (optional - for broadcast messages)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('✅ Subscribed to topic: $topic');
    } catch (e) {
      print('❌ Error subscribing to topic: $e');
    }
  }
}
