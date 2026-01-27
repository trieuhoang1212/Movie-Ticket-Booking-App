import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home_screen.dart';
import '../services/booking_service.dart';
import '../services/payment_service.dart';
import '../models/showtime_model.dart';
import '../models/seat_model.dart';

class BookingScreen extends StatefulWidget {
  final Map<String, String> movieData;

  const BookingScreen({super.key, required this.movieData});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // --- MÀU SẮC & STYLE ---
  final Color primaryRed = const Color(0xFFFF4444);
  final Color darkBackground = const Color(0xFF151720);
  final Color cardBackground = const Color(0xFF2B2D3A);

  // Màu ghế
  final Color colorAvailable = const Color(0xFF494B56); // Xám tối
  final Color colorReserved = Colors.white; // Trắng
  final Color colorSelected = const Color(0xFFFF4444); // Đỏ

  final BookingService _bookingService = BookingService();

  List<Showtime> _showtimes = [];
  List<Seat> _seats = [];
  int _selectedShowtimeIndex = 0;
  Showtime? _selectedShowtime;
  bool _isLoadingShowtimes = true;
  bool _isLoadingSeats = false;
  bool _isCreatingBooking = false;
  String? _errorMessage;

  // Ghế đã chọn (lưu seat IDs)
  final Set<String> _selectedSeatIds = {};
  final Map<String, Seat> _seatMap = {};

  @override
  void initState() {
    super.initState();
    _loadShowtimes();
  }

  Future<void> _loadShowtimes() async {
    setState(() {
      _isLoadingShowtimes = true;
      _errorMessage = null;
    });

    try {
      final movieId = widget.movieData['id'] ?? '';
      print('DEBUG BookingScreen - movieId: $movieId');
      print('DEBUG BookingScreen - movieData: ${widget.movieData}');
      final showtimes = await _bookingService.getShowtimesByMovie(movieId);

      setState(() {
        _showtimes = showtimes;
        _isLoadingShowtimes = false;
        if (showtimes.isNotEmpty) {
          _selectedShowtime = showtimes[0];
          _loadSeats(showtimes[0].id);
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingShowtimes = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadSeats(String showtimeId) async {
    setState(() {
      _isLoadingSeats = true;
      _errorMessage = null;
      _selectedSeatIds.clear();
      _seatMap.clear();
    });

    try {
      final seats = await _bookingService.getSeatsByShowtime(showtimeId);

      setState(() {
        _seats = seats;
        // Tạo map để truy cập nhanh
        for (var seat in seats) {
          _seatMap[seat.id] = seat;
        }
        _isLoadingSeats = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSeats = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _onShowtimeSelected(int index) {
    setState(() {
      _selectedShowtimeIndex = index;
      _selectedShowtime = _showtimes[index];
    });
    _loadSeats(_showtimes[index].id);
  }

  int _getSeatPrice(Seat seat) {
    if (_selectedShowtime == null) return 0;
    switch (seat.type) {
      case 'vip':
        return _selectedShowtime!.price.vip;
      case 'couple':
        return _selectedShowtime!.price.couple;
      default:
        return _selectedShowtime!.price.regular;
    }
  }

  int get _totalAmount {
    int total = 0;
    for (var seatId in _selectedSeatIds) {
      final seat = _seatMap[seatId];
      if (seat != null) {
        total += _getSeatPrice(seat);
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Đặt Vé",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: _isLoadingShowtimes
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadShowtimes,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCinemaInfo(),
                          const SizedBox(height: 24),
                          const Text(
                            "Chọn suất chiếu",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildShowtimeSelector(),
                          const SizedBox(height: 24),
                          _isLoadingSeats
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : _buildSeatMap(),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomButton(),
                ],
              ),
            ),
    );
  }

  // Widget để hiển thị showtime selector
  Widget _buildShowtimeSelector() {
    if (_showtimes.isEmpty) {
      return const Text(
        "Không có suất chiếu nào",
        style: TextStyle(color: Colors.grey),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_showtimes.length, (index) {
          final showtime = _showtimes[index];
          final isSelected = index == _selectedShowtimeIndex;
          final startTime = showtime.startTime;

          return GestureDetector(
            onTap: () => _onShowtimeSelected(index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFF4444) : Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: const Color(0xFFFF4444), width: 2)
                    : null,
              ),
              child: Column(
                children: [
                  Text(
                    "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}",
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[300],
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    showtime.cinemaHall,
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCinemaInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "CUTH Lý Tự Trọng Quận 1",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Chọn địa chỉ khác",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: const [
            Icon(Icons.location_on, color: Colors.grey, size: 14),
            SizedBox(width: 4),
            Text(
              "20 Lý Tự Trọng, Phường Bến Nghé, Quận 1",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSeatMap() {
    if (_seats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Text(
          "Không có ghế nào",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Nhóm ghế theo hàng
    Map<String, List<Seat>> seatsByRow = {};
    for (var seat in _seats) {
      if (!seatsByRow.containsKey(seat.row)) {
        seatsByRow[seat.row] = [];
      }
      seatsByRow[seat.row]!.add(seat);
    }

    // Sắp xếp các hàng theo thứ tự A, B, C...
    List<String> sortedRows = seatsByRow.keys.toList()..sort();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          // Màn hình
          Column(
            children: [
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.7,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: primaryRed.withOpacity(0.5),
                          blurRadius: 25,
                          spreadRadius: 1,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                  ),
                  ClipPath(
                    clipper: ScreenClipper(),
                    child: Stack(
                      children: [
                        SizedBox(
                          height: 70,
                          width: double.infinity,
                          child: Image.network(
                            widget.movieData["image"]!,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                        Container(
                          height: 70,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                darkBackground.withOpacity(0.9),
                              ],
                              stops: const [0.3, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "MÀN HÌNH",
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Hiển thị ghế theo hàng
          Column(
            children: sortedRows.map((row) {
              List<Seat> rowSeats = seatsByRow[row]!;
              // Sắp xếp ghế trong hàng theo số ghế
              rowSeats.sort((a, b) {
                int numA = int.tryParse(a.seatNumber.substring(1)) ?? 0;
                int numB = int.tryParse(b.seatNumber.substring(1)) ?? 0;
                return numA.compareTo(numB);
              });

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: rowSeats
                      .map((seat) => _buildSeatItem(seat))
                      .toList(),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),
          const Divider(color: Colors.grey, thickness: 0.5),
          const SizedBox(height: 15),

          // Chú thích
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(colorReserved, "Đã đặt"),
              _buildLegendItem(colorAvailable, "Có sẵn"),
              _buildLegendItem(colorSelected, "Đã chọn"),
            ],
          ),

          const SizedBox(height: 20),

          // Tổng tiền
          Text(
            "${(_totalAmount / 1000).toStringAsFixed(0)}.000đ cho ${_selectedSeatIds.length} vé",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatItem(Seat seat) {
    bool isBooked = seat.status == 'booked' || seat.status == 'reserved';
    bool isSelected = _selectedSeatIds.contains(seat.id);

    Color iconColor = colorAvailable;
    if (isBooked) iconColor = colorReserved;
    if (isSelected) iconColor = colorSelected;

    return GestureDetector(
      onTap: () {
        if (isBooked) return;
        setState(() {
          if (isSelected) {
            _selectedSeatIds.remove(seat.id);
          } else {
            _selectedSeatIds.add(seat.id);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2), // Giảm từ 4 → 2
        child: Icon(
          Icons.chair_rounded,
          size: 24,
          color: iconColor,
        ), // Giảm từ 26 → 24
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Icon(Icons.chair_rounded, size: 20, color: color),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: darkBackground,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: _selectedSeatIds.isEmpty || _isCreatingBooking
              ? null
              : LinearGradient(
                  colors: [primaryRed, Colors.red.shade900],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          borderRadius: BorderRadius.circular(16),
          color: _selectedSeatIds.isEmpty || _isCreatingBooking
              ? Colors.grey[800]
              : null,
        ),
        child: ElevatedButton(
          onPressed: _selectedSeatIds.isEmpty || _isCreatingBooking
              ? null
              : _createBookingAndProceed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isCreatingBooking
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  "ĐẶT GHẾ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _createBookingAndProceed() async {
    if (_selectedShowtime == null) return;

    setState(() {
      _isCreatingBooking = true;
    });

    try {
      // Tạo booking
      final booking = await _bookingService.createBooking(
        showtimeId: _selectedShowtime!.id,
        seatIds: _selectedSeatIds.toList(),
      );

      // Tạo chuỗi ghế đã chọn để hiển thị
      List<Seat> selectedSeatsList = _selectedSeatIds
          .map((id) => _seatMap[id])
          .whereType<Seat>()
          .toList();
      selectedSeatsList.sort((a, b) => a.seatNumber.compareTo(b.seatNumber));
      String seatString = selectedSeatsList.map((s) => s.seatNumber).join(", ");

      setState(() {
        _isCreatingBooking = false;
      });

      // Chuyển sang màn thanh toán
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            movieData: widget.movieData,
            totalPrice: _totalAmount,
            selectedSeats: seatString,
            bookingId: booking.id,
            showtimeInfo: _selectedShowtime!,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isCreatingBooking = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class ScreenClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 20);
    path.quadraticBezierTo(size.width / 2, -15, size.width, 20);
    path.lineTo(size.width * 0.85, size.height);
    path.lineTo(size.width * 0.15, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ==========================================
// CÁC MÀN HÌNH TIẾP THEO (DÁN VÀO CÙNG FILE)
// ==========================================

// MÀN 1: REVIEW
class ReviewBookingScreen extends StatelessWidget {
  final Map<String, String> movieData;
  final String selectedSeats;
  final int totalPrice;

  const ReviewBookingScreen({
    super.key,
    required this.movieData,
    required this.selectedSeats,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151720),
      appBar: _buildAppBar(context, "Nội Dung"),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1F222A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          movieData["image"] ?? "",
                          width: 80,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (c, o, s) => Container(
                            color: Colors.grey,
                            width: 80,
                            height: 100,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movieData["title"] ?? "Tên Phim",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildTag("13+"),
                                const SizedBox(width: 8),
                                _buildTag("ENG"),
                                const SizedBox(width: 8),
                                _buildTag("SUB"),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              movieData["genre"] ?? "Hành động",
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              movieData["duration"] ?? "2h 0m",
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildInfoRow("RẠP", "CUTH"),
                  _buildInfoRow("NGÀY", "26/12/2025"),
                  _buildInfoRow("SUẤT CHIẾU", "15:00"),
                  _buildInfoRow("GHẾ", selectedSeats),
                  const Divider(color: Colors.grey, height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Tổng cộng",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${totalPrice}đ",
                        style: const TextStyle(
                          color: Color(0xFFFF4444),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            _buildGradientButton(
              text: "ĐẶT VÉ (Giả lập)",
              onPressed: null, // Disabled vì đã skip ReviewBookingScreen
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.grey, fontSize: 10),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// MÀN 2: PAYMENT
class PaymentScreen extends StatefulWidget {
  final Map<String, String> movieData;
  final int totalPrice;
  final String selectedSeats;
  final String bookingId;
  final Showtime showtimeInfo;

  const PaymentScreen({
    super.key,
    required this.movieData,
    required this.totalPrice,
    required this.selectedSeats,
    required this.bookingId,
    required this.showtimeInfo,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  bool _isProcessingPayment = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151720),
      appBar: _buildAppBar(context, "Thanh Toán"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Thông Tin Khách Hàng",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField("Họ & Tên", "Nguyen Van A"),
            const SizedBox(height: 16),
            _buildTextField("Số điện thoại", "0123 456 789"),
            const SizedBox(height: 16),
            _buildTextField("Email", "nguyenvana@gmail.com"),
            const SizedBox(height: 32),
            const Text(
              "Phương thức thanh toán",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPaymentMethod(isActive: true, name: "VNPay"),
            const SizedBox(height: 12),
            _buildPaymentMethod(
              isActive: false,
              name: "Thẻ ATM / Visa / Master",
            ),
            const SizedBox(height: 32),
            const Text(
              "Giao Dịch",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1F222A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "TỔNG THANH TOÁN",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    "${widget.totalPrice ~/ 1000}.000đ",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildGradientButton(
              text: _isProcessingPayment ? "ĐANG XỬ LÝ..." : "THANH TOÁN VNPAY",
              onPressed: _isProcessingPayment ? null : _processPayment,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessingPayment = true;
    });

    try {
      // Tạo payment URL từ VNPay
      final paymentUrl = await _paymentService.createVNPayPayment(
        orderId: widget.bookingId,
        amount: widget.totalPrice,
        orderInfo: 'Thanh toan ve xem phim ${widget.movieData['title']}',
        bankCode: null,
      );

      setState(() {
        _isProcessingPayment = false;
      });

      // Mở URL VNPay trong in-app browser
      final Uri uri = Uri.parse(paymentUrl);
      try {
        print('🌐 Launching URL: $paymentUrl');

        // Dùng inAppWebView để mở trong app, tương thích với emulator
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.inAppWebView,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );

        print('🌐 Launch result: $launched');

        if (!launched) {
          throw Exception('Không thể khởi chạy URL VNPay');
        }

        // Sau khi mở VNPay, chuyển sang màn success (giả định thanh toán thành công)
        // Trong thực tế, cần callback từ VNPay để xác nhận
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TicketSuccessScreen(
              movieData: widget.movieData,
              selectedSeats: widget.selectedSeats,
              bookingId: widget.bookingId,
            ),
          ),
        );
      } catch (launchError) {
        print('❌ Launch error: $launchError');
        throw Exception('Không thể mở VNPay: $launchError');
      }
    } catch (e) {
      setState(() {
        _isProcessingPayment = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi thanh toán: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildTextField(String label, String initialValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1F222A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethod({required bool isActive, required String name}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1F222A),
        borderRadius: BorderRadius.circular(12),
        border: isActive ? Border.all(color: const Color(0xFFFF4444)) : null,
      ),
      child: Row(
        children: [
          Icon(
            Icons.payment,
            color: isActive ? const Color(0xFFFF4444) : Colors.grey,
          ),
          const SizedBox(width: 12),
          Text(name, style: const TextStyle(color: Colors.white)),
          const Spacer(),
          if (isActive)
            const Icon(Icons.check_circle, color: Color(0xFFFF4444), size: 20),
          if (!isActive)
            const Icon(Icons.circle_outlined, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}

// MÀN 3: SUCCESS (HÓA ĐƠN)
class TicketSuccessScreen extends StatelessWidget {
  final Map<String, String> movieData;
  final String selectedSeats;
  final String bookingId;

  const TicketSuccessScreen({
    super.key,
    required this.movieData,
    required this.selectedSeats,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151720),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Hóa Đơn",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFFFF4444), size: 64),
            const SizedBox(height: 16),
            const Text(
              "Thanh toán thành công !",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            movieData["image"] ?? "",
                            width: 80,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (c, o, s) => Container(
                              color: Colors.grey,
                              width: 80,
                              height: 100,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                movieData["title"] ?? "Movie Title",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildTagLight("13+"),
                                  const SizedBox(width: 4),
                                  _buildTagLight("ENG"),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "${movieData["genre"]}",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                "${movieData["duration"]}",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Colors.grey),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildTicketInfoRow("RẠP", "CUTH"),
                        _buildTicketInfoRow("NGÀY", "04/12/2025"),
                        _buildTicketInfoRow("GIỜ", "15:00"),
                        _buildTicketInfoRow("GHẾ", selectedSeats),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Mock Barcode
                  Container(
                    height: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        30,
                        (index) => Container(
                          width: index % 3 == 0 ? 4 : 2,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: const Text(
                "Xem Chi Tiết Vé",
                style: TextStyle(
                  color: Colors.grey,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const Spacer(),
            _buildGradientButton(
              text: "TRANG CHỦ",
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagLight(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black, fontSize: 10),
      ),
    );
  }

  Widget _buildTicketInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// HELPER WIDGETS
AppBar _buildAppBar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    title: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
    ),
    leading: Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          size: 18,
          color: Colors.white,
        ),
        onPressed: () => Navigator.pop(context),
      ),
    ),
  );
}

Widget _buildGradientButton({
  required String text,
  required VoidCallback? onPressed,
}) {
  return Container(
    width: double.infinity,
    height: 56,
    decoration: BoxDecoration(
      gradient: onPressed != null
          ? const LinearGradient(colors: [Color(0xFFFF4444), Color(0xFF990000)])
          : null,
      borderRadius: BorderRadius.circular(30),
      color: onPressed == null ? Colors.grey[700] : null,
    ),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        disabledBackgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
  );
}
