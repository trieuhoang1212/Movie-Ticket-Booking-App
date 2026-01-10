import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Cần import intl để format giờ
import '../services/database_helper.dart';
import '../models/notification_model.dart';

// Chuyển sang StatefulWidget để có thể load lại dữ liệu
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // Hàm đọc dữ liệu từ DB
  Future<void> _loadNotifications() async {
    final data = await DatabaseHelper.instance.getNotifications();
    setState(() {
      _notifications = data;
      _isLoading = false;
    });
  }

  // Hàm tính thời gian "15m", "1h"
  String _formatTime(String timeString) {
    DateTime time = DateTime.parse(timeString);
    Duration diff = DateTime.now().difference(time);

    if (diff.inDays > 0) return "${diff.inDays}d";
    if (diff.inHours > 0) return "${diff.inHours}h";
    if (diff.inMinutes > 0) return "${diff.inMinutes}m";
    return "Now";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151720),
      appBar: AppBar(
        // ... (Giữ nguyên code AppBar cũ) ...
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text("Thông Báo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
        // Thêm nút refresh để test
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadNotifications,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? const Center(child: Text("Không có thông báo nào", style: TextStyle(color: Colors.grey)))
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = _notifications[index];
          return _buildNotificationItem(item);
        },
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel item) {
    bool isRead = item.isRead == 1;
    IconData iconData;

    // Logic chọn icon
    switch (item.type) {
      case 'payment':
      case 'booking':
        iconData = Icons.check_circle_outline;
        break;
      case 'reminder':
        iconData = Icons.access_time;
        break;
      default:
        iconData = Icons.notifications_none;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F222A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF2B2D3A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Icon(iconData, color: const Color(0xFFFF4444), size: 24),
              ),
              if (!isRead)
                Positioned(
                  top: 0, left: 0,
                  child: Container(
                    width: 10, height: 10,
                    decoration: const BoxDecoration(color: Color(0xFFFF4444), shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _formatTime(item.time), // Format thời gian
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.body,
                  style: TextStyle(color: Colors.grey[400], fontSize: 13, height: 1.4),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}