import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../services/booking_service.dart';
import '../models/booking_model.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  // 0: Vé hiện tại, 1: Vé đã xem
  int _selectedTab = 0;

  final BookingService _bookingService = BookingService();
  List<Booking> _allBookings = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeDateFormatting();
    _loadBookings();
  }

  // Khởi tạo date formatting cho tiếng Việt
  Future<void> _initializeDateFormatting() async {
    await initializeDateFormatting('vi', null);
  }

  // Load danh sách vé từ API
  Future<void> _loadBookings() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final bookings = await _bookingService.getMyBookings();

      setState(() {
        _allBookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        // Hiển thị lỗi chi tiết hơn
        if (e.toString().contains('User not authenticated')) {
          _errorMessage = 'Bạn chưa đăng nhập. Vui lòng đăng nhập để xem vé.';
        } else if (e.toString().contains('Failed to load bookings')) {
          _errorMessage =
              'Không thể kết nối đến server. Vui lòng kiểm tra kết nối.';
        } else {
          _errorMessage = 'Có lỗi xảy ra: ${e.toString()}';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lọc danh sách vé theo Tab đang chọn
    // Tab 0: Vé hiện tại (pending, confirmed)
    // Tab 1: Vé đã xem (completed, cancelled)
    List<Booking> displayBookings = _allBookings.where((booking) {
      if (_selectedTab == 0) {
        return booking.status == 'pending' || booking.status == 'confirmed';
      } else {
        return booking.status == 'completed' || booking.status == 'cancelled';
      }
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF151720), // Màu nền tối
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () {
              Navigator.maybePop(context);
            },
          ),
        ),
        title: const Text(
          "Vé của tôi",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // 1. Tab Switcher (Vé hiện tại / Vé đã xem)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF1F222A), // Màu nền của thanh tab
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildTabButton("Vé hiện tại", 0),
                _buildTabButton("Vé đã xem", 1),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 2. Danh sách vé
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.grey,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _loadBookings,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF4444),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Thử lại"),
                          ),
                        ],
                      ),
                    ),
                  )
                : displayBookings.isEmpty
                ? Center(
                    child: Text(
                      "Chưa có vé nào",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadBookings,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: displayBookings.length,
                      itemBuilder: (context, index) {
                        return _buildTicketCard(displayBookings[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // Widget nút Tab
  Widget _buildTabButton(String title, int index) {
    bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF3B3E4A)
                : Colors.transparent, // Màu sáng hơn khi chọn
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // Widget Thẻ Vé
  Widget _buildTicketCard(Booking booking) {
    // Format ngày giờ
    final dateFormat = DateFormat('dd \'Tháng\' MM, yyyy', 'vi');
    final timeFormat = DateFormat('HH:mm');

    final formattedDate = dateFormat.format(booking.showtime.startTime);
    final formattedTime = timeFormat.format(booking.showtime.startTime);
    final seatCount = booking.seats.length;
    final seatText = '$seatCount chỗ ngồi';

    // Kiểm tra xem có thể hủy vé không (chỉ cho phép hủy vé pending/confirmed)
    final canCancel =
        booking.status == 'pending' || booking.status == 'confirmed';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F222A), // Màu nền Card
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ảnh Poster
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: booking.showtime.movie.posterUrl != null
                    ? Image.network(
                        booking.showtime.movie.posterUrl!,
                        width: 100,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (c, o, s) => Container(
                          width: 100,
                          height: 120,
                          color: Colors.grey,
                          child: const Icon(Icons.movie, color: Colors.white),
                        ),
                      )
                    : Container(
                        width: 100,
                        height: 120,
                        color: Colors.grey,
                        child: const Icon(Icons.movie, color: Colors.white),
                      ),
              ),
              const SizedBox(width: 16),
              // Thông tin vé
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 4),
                    // Tên phim
                    Text(
                      booking.showtime.movie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // Rạp phim
                    _buildInfoRow(
                      Icons.location_on_outlined,
                      booking.showtime.cinema,
                    ),
                    const SizedBox(height: 8),

                    // Ngày chiếu
                    _buildInfoRow(Icons.calendar_today_outlined, formattedDate),
                    const SizedBox(height: 8),

                    // Giờ và Số ghế
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formattedTime,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.event_seat,
                          color: Color(0xFFFF4444),
                          size: 16,
                        ), // Ghế màu đỏ
                        const SizedBox(width: 4),
                        Text(
                          seatText,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Nút hủy vé (chỉ hiện với vé pending/confirmed)
          if (canCancel) ...[
            const SizedBox(height: 12),
            const Divider(color: Colors.grey, thickness: 0.5),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showCancelConfirmDialog(booking),
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: const Text('Hủy vé'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.2),
                  foregroundColor: Colors.red,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red.withOpacity(0.3)),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Dialog xác nhận hủy vé
  Future<void> _showCancelConfirmDialog(Booking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F222A),
        title: const Text(
          'Xác nhận hủy vé',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Bạn có chắc muốn hủy vé xem phim "${booking.showtime.movie.title}"?',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hủy vé'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _cancelBooking(booking.id);
    }
  }

  // Thực hiện hủy vé
  Future<void> _cancelBooking(String bookingId) async {
    try {
      // Hiển thị loading
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Gọi API hủy vé
      final success = await _bookingService.cancelBooking(bookingId);

      if (!mounted) return;
      Navigator.pop(context); // Đóng loading dialog

      if (success) {
        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã hủy vé thành công'),
            backgroundColor: Colors.green,
          ),
        );

        // Reload danh sách vé
        _loadBookings();
      } else {
        throw Exception('Hủy vé thất bại');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Đóng loading dialog

      // Hiển thị lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 16),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
