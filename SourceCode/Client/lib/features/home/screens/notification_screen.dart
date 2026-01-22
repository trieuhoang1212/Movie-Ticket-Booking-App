import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/notification_model.dart';

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

  // Hàm tính thời gian
  String _formatTime(String timeString) {
    DateTime time = DateTime.parse(timeString);
    Duration diff = DateTime.now().difference(time);

    if (diff.inDays > 0) return "${diff.inDays}d";
    if (diff.inHours > 0) return "${diff.inHours}h";
    if (diff.inMinutes > 0) return "${diff.inMinutes}m";
    return "Now";
  }

  // Hàm xóa một thông báo
  Future<void> _deleteNotification(NotificationModel notification) async {
    await DatabaseHelper.instance.deleteNotification(notification.id!);
    await _loadNotifications();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🗑️ Đã xóa thông báo'),
          backgroundColor: Colors.grey,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Hàm xác nhận xóa tất cả
  Future<void> _confirmDeleteAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F222A),
        title: const Text(
          'Xóa tất cả thông báo?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Bạn có chắc muốn xóa tất cả thông báo?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteAllNotifications();
      await _loadNotifications();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🗑️ Đã xóa tất cả thông báo'),
            backgroundColor: Colors.grey,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // 🧪 Hàm test thêm thông báo booking
  Future<void> _addTestBookingNotification() async {
    final notification = NotificationModel(
      title: '🎉 Đặt vé thành công!',
      body: 'Bạn đã đặt vé phim "Avatar 3: The Way of Water" - Ghế: A1, A2. Tổng tiền: 450000đ',
      type: 'booking',
      time: DateTime.now().toString(),
      isRead: 0,
    );

    await DatabaseHelper.instance.addNotification(notification);
    await _loadNotifications();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Đã thêm thông báo test'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Cho phép nội dung tràn lên sau AppBar
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Thông Báo",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alert, color: Colors.orange),
            tooltip: 'Thêm thông báo test',
            onPressed: _addTestBookingNotification,
          ),
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.red),
              tooltip: 'Xóa tất cả',
              onPressed: _confirmDeleteAll,
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      // 2. Sử dụng Stack để thêm hình nền
      body: Stack(
        children: [
          // LỚP 1: ẢNH NỀN
          Positioned.fill(
            child: Image.asset(
              'assets/images/BG.png',
              fit: BoxFit.cover,
            ),
          ),

          // LỚP 2: LỚP PHỦ MÀU ĐEN MỜ
          Positioned.fill(
            child: Container(
              color: const Color(0xFF151720).withValues(alpha: 0.5),
            ),
          ),

          // LỚP 3: NỘI DUNG CHÍNH (Trong SafeArea)
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notifications.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  const Text(
                    "Không có thông báo nào",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = _notifications[index];
                return Dismissible(
                  key: Key(item.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xFF1F222A),
                        title: const Text(
                          'Xóa thông báo?',
                          style: TextStyle(color: Colors.white),
                        ),
                        content: const Text(
                          'Bạn có chắc muốn xóa thông báo này?',
                          style: TextStyle(color: Colors.grey),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text(
                              'Hủy',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'Xóa',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) {
                    _deleteNotification(item);
                  },
                  child: _buildNotificationItem(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel item) {
    bool isRead = item.isRead == 1;
    IconData iconData;

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
        // Làm nền hộp thông báo hơi trong suốt để thấy background
        color: const Color(0xFF1F222A).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF2B2D3A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                ),
                child: Icon(iconData, color: const Color(0xFFFF4444), size: 24),
              ),
              if (!isRead)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF4444),
                      shape: BoxShape.circle,
                    ),
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _formatTime(item.time),
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.body,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 13,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}