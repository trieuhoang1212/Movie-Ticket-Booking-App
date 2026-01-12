import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import 'database_helper.dart';


@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('--- Background Message ---');
  print('Title: ${message.notification?.title}');
  print('Payload: ${message.data}');

  // Lưu thông báo vào SQLite
  if (message.notification != null) {
    await DatabaseHelper.instance.addNotification(NotificationModel(
      title: message.notification!.title ?? "Thông báo",
      body: message.notification!.body ?? "",
      // Lấy loại thông báo từ data gửi kèm (nếu không có thì mặc định là reminder)
      type: message.data['type'] ?? 'reminder',
      time: DateTime.now().toString(),
      isRead: 0, // Mặc định là chưa đọc
    ));
  }
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  final AndroidNotificationChannel _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.defaultImportance,
  );

  Future<void> initNotifications() async {
    // Xin quyền thông báo
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Lấy Token
    final fCMToken = await _firebaseMessaging.getToken();
    if (kDebugMode) {
      print('====== FCM TOKEN ======');
      print(fCMToken);
      print('=======================');
    }

    // Khởi tạo thông báo cục bộ
    await _initLocalNotifications();

    // 2. XỬ LÝ KHI APP ĐANG MỞ (FOREGROUND)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final android = message.notification?.android;

      if (notification != null && android != null) {
        // A. Lưu vào Database trước
        DatabaseHelper.instance.addNotification(NotificationModel(
          title: notification.title ?? "Thông báo mới",
          body: notification.body ?? "",
          type: message.data['type'] ?? 'reminder',
          time: DateTime.now().toString(),
          isRead: 0,
        ));

        // B. Hiện Popup thông báo (Banner)
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannel.id,
              _androidChannel.name,
              channelDescription: _androidChannel.description,
              icon: '@mipmap/ic_launcher',
            ),
          ),
          payload: message.data.toString(),
        );
      }
    });

    // Xử lý sự kiện mở App từ thông báo
    initPushNotificationHandlers();
  }

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (payload) {
        print("User clicked on local notification: ${payload.payload}");
        // Tại đây bạn có thể điều hướng (Navigator) đến màn hình chi tiết nếu muốn
      },
    );

    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }

  void initPushNotificationHandlers() {
    // Khi app mở từ trạng thái Terminated (Đóng hẳn)
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print("App opened from Terminated state");
        // Xử lý điều hướng ở đây nếu cần
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("App opened from Background state");
    });
  }
}