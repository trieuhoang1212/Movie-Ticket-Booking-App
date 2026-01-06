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

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F222A), // Màu nền Card
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
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
                    const Icon(Icons.access_time, color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      formattedTime,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
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
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
