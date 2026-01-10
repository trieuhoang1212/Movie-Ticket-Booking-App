import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Thêm dòng này
import 'firebase_options.dart';
import 'features/auth/screens/login_screen.dart';

// Import service thông báo (Đường dẫn dựa trên cấu trúc folder của bạn)
import 'features/home/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. Kết nối Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ KẾT NỐI FIREBASE THÀNH CÔNG!"); // <--- Đã thêm lệnh print

    // 2. Đăng ký xử lý Background (Phải làm ngay sau khi Firebase init)
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    // 3. Khởi tạo Notification Service (Để lấy Token và xin quyền)
    final notificationService = NotificationService();
    await notificationService.initNotifications();
    print("✅ ĐÃ KHỞI TẠO NOTIFICATION SERVICE");

  } catch (e) {
    print("❌ LỖI KẾT NỐI: $e"); // <--- Đã thêm lệnh print
  }

  // Chạy App
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UTH Student',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}