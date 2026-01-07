import 'package:flutter/material.dart';
import 'home_screen.dart';

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

  // --- DỮ LIỆU ---
  int _selectedDateIndex = 0;
  int _selectedTimeIndex = 0;
  final List<String> dates = ["4/12", "5/12", "6/12"];
  final List<String> times = ["8:00", "15:00", "19:30"];

  // CẤU TRÚC HÀNG GHẾ: Số lượng ghế từng hàng
  final List<int> rowSeatsCounts = [6, 8, 8, 8, 6];

  // Ghế đã đặt
  final Set<int> reservedSeats = {6, 13, 14, 21, 22, 29};

  final Set<int> selectedSeats = {};

  final int ticketPrice = 120000;

  String _getSeatName(int index) {
    int row = 0;
    int tempIndex = index;
    for (int count in rowSeatsCounts) {
      if (tempIndex < count) {
        // Tìm thấy hàng, chuyển row thành chữ cái (A=65, B=66...)
        String rowChar = String.fromCharCode(65 + row);
        return "$rowChar${tempIndex + 1}";
      }
      tempIndex -= count;
      row++;
    }
    return "??";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title:
        const Text("Đặt Vé", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 18, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCinemaInfo(),
                    const SizedBox(height: 24),

                    const Text("Ngày",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildSelector(dates, _selectedDateIndex, (index) {
                      setState(() => _selectedDateIndex = index);
                    }),
                    const SizedBox(height: 24),

                    const Text("Thời Gian",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildSelector(times, _selectedTimeIndex, (index) {
                      setState(() => _selectedTimeIndex = index);
                    }),
                    const SizedBox(height: 32),

                    // Sơ đồ ghế ngồi
                    _buildSeatMap(),
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

  Widget _buildCinemaInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text("CUTH Lý Tự Trọng Quận 1",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            Text("Chọn địa chỉ khác",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: const [
            Icon(Icons.location_on, color: Colors.grey, size: 14),
            SizedBox(width: 4),
            Text("20 Lý Tự Trọng, Phường Bến Nghé, Quận 1",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildSelector(
      List<String> items, int selectedIndex, Function(int) onSelected) {
    return Row(
      children: List.generate(items.length, (index) {
        bool isSelected = index == selectedIndex;
        return GestureDetector(
          onTap: () => onSelected(index),
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEBB4B4) : Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              items[index],
              style: TextStyle(
                color: Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSeatMap() {
    int seatCounter = 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          // Màn hình cong dùng ClipPath
          Column(
            children: [
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Lớp 1: Glow
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
                        )
                      ],
                    ),
                  ),
                  // Lớp 2: Ảnh màn hình
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
                            errorBuilder: (c, o, s) =>
                                Container(color: Colors.grey),
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
              const Text("MÀN HÌNH",
                  style: TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 30),

          // VẼ CÁC HÀNG GHẾ
          Column(
            children: List.generate(rowSeatsCounts.length, (rowIndex) {
              int count = rowSeatsCounts[rowIndex];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(count, (colIndex) {
                    int currentSeatIndex = seatCounter++;
                    return _buildSeatItem(currentSeatIndex);
                  }),
                ),
              );
            }),
          ),

          const SizedBox(height: 20),
          const Divider(color: Colors.grey, thickness: 0.5),
          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(colorReserved, "Reserved"),
              _buildLegendItem(colorAvailable, "Available"),
              _buildLegendItem(colorSelected, "Selected"),
            ],
          ),
          const SizedBox(height: 20),

          // Tổng tiền
          Text(
            "${selectedSeats.length * 120}.000đ for ${selectedSeats.length} tickets",
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  Widget _buildSeatItem(int index) {
    bool isReserved = reservedSeats.contains(index);
    bool isSelected = selectedSeats.contains(index);

    Color iconColor = colorAvailable;
    if (isReserved) iconColor = colorReserved;
    if (isSelected) iconColor = colorSelected;

    return GestureDetector(
      onTap: () {
        if (isReserved) return;
        setState(() {
          if (isSelected) {
            selectedSeats.remove(index);
          } else {
            selectedSeats.add(index);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Icon(
          Icons.chair_rounded,
          size: 26,
          color: iconColor,
        ),
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
          gradient: selectedSeats.isEmpty
              ? null
              : LinearGradient(
            colors: [primaryRed, Colors.red.shade900],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          color: selectedSeats.isEmpty ? Colors.grey[800] : null,
        ),
        child: ElevatedButton(
          // --- LOGIC CHUYỂN TRANG Ở ĐÂY ---
          onPressed: selectedSeats.isEmpty
              ? null
              : () {
            // 1. Tính tổng tiền
            int total = selectedSeats.length * ticketPrice;

            // 2. Chuyển đổi List<int> thành chuỗi tên ghế (VD: "A1, B2")
            List<int> sortedSeats = selectedSeats.toList()..sort();
            String seatString =
            sortedSeats.map((i) => _getSeatName(i)).join(", ");

            // 3. Chuyển sang màn Review
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReviewBookingScreen(
                  movieData: widget.movieData,
                  selectedSeats: seatString,
                  totalPrice: total,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent, // Để lộ màu nền xám
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text("ĐẶT GHẾ",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
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
                          errorBuilder: (c, o, s) =>
                              Container(color: Colors.grey, width: 80, height: 100),
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
                                  fontWeight: FontWeight.bold),
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
                            Text(movieData["genre"] ?? "Hành động",
                                style: TextStyle(
                                    color: Colors.grey[400], fontSize: 12)),
                            Text(movieData["duration"] ?? "2h 0m",
                                style: TextStyle(
                                    color: Colors.grey[400], fontSize: 12)),
                          ],
                        ),
                      )
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
                      const Text("Tổng cộng",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text("${totalPrice}đ",
                          style: const TextStyle(
                              color: Color(0xFFFF4444),
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            _buildGradientButton(
              text: "ĐẶT VÉ",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(
                      movieData: movieData,
                      totalPrice: totalPrice,
                      selectedSeats: selectedSeats,
                    ),
                  ),
                );
              },
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
      child:
      Text(text, style: const TextStyle(color: Colors.grey, fontSize: 10)),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// MÀN 2: PAYMENT
class PaymentScreen extends StatelessWidget {
  final Map<String, String> movieData;
  final int totalPrice;
  final String selectedSeats;

  const PaymentScreen({
    super.key,
    required this.movieData,
    required this.totalPrice,
    required this.selectedSeats,
  });

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
            const Text("Thông Tin Khách Hàng",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildTextField("Họ & Tên", "Nguyen Van A"),
            const SizedBox(height: 16),
            _buildTextField("Số điện thoại", "0123 456 789"),
            const SizedBox(height: 16),
            _buildTextField("Email", "nguyenvana@gmail.com"),
            const SizedBox(height: 32),
            const Text("Phương thức thanh toán",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildPaymentMethod(isActive: true, name: "VNPay"),
            const SizedBox(height: 12),
            _buildPaymentMethod(
                isActive: false, name: "Thẻ ATM / Visa / Master"),
            const SizedBox(height: 32),
            const Text("Giao Dịch",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
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
                  const Text("TỔNG THANH TOÁN",
                      style: TextStyle(color: Colors.grey)),
                  Text("${totalPrice}đ",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildGradientButton(
              text: "HOÀN THÀNH",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TicketSuccessScreen(
                      movieData: movieData,
                      selectedSeats: selectedSeats,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
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
                borderSide: BorderSide.none),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          Icon(Icons.payment,
              color: isActive ? const Color(0xFFFF4444) : Colors.grey),
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

  const TicketSuccessScreen({
    super.key,
    required this.movieData,
    required this.selectedSeats,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151720),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text("Hóa Đơn",
            style: TextStyle(fontWeight: FontWeight.bold)),
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
            const Text("Thanh toán thành công !",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
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
                                color: Colors.grey, width: 80, height: 100),
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
                                    fontWeight: FontWeight.bold),
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
                              Text("${movieData["genre"]}",
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 12)),
                              Text("${movieData["duration"]}",
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 12)),
                            ],
                          ),
                        )
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
                          )),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: const Text("Xem Chi Tiết Vé",
                  style: TextStyle(
                      color: Colors.grey, decoration: TextDecoration.underline)),
            ),
            const Spacer(),
            _buildGradientButton(
              text: "TRANG CHỦ",
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                        (Route<dynamic> route) => false);
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
      child:
      Text(text, style: const TextStyle(color: Colors.black, fontSize: 10)),
    );
  }

  Widget _buildTicketInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value,
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold)),
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
    title: Text(title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
    leading: Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
      child: IconButton(
        icon:
        const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    ),
  );
}

Widget _buildGradientButton(
    {required String text, required VoidCallback onPressed}) {
  return Container(
    width: double.infinity,
    height: 56,
    decoration: BoxDecoration(
      gradient:
      const LinearGradient(colors: [Color(0xFFFF4444), Color(0xFF990000)]),
      borderRadius: BorderRadius.circular(30),
    ),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(text,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
    ),
  );
}