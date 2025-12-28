import 'package:flutter/material.dart';

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
  final Color colorReserved = Colors.white;             // Trắng
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text("Đặt Vé", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
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

                    const Text("Ngày", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildSelector(dates, _selectedDateIndex, (index) {
                      setState(() => _selectedDateIndex = index);
                    }),
                    const SizedBox(height: 24),

                    const Text("Thời Gian", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            Text("CUTH Lý Tự Trọng Quận 1", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Text("Chọn địa chỉ khác", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: const [
            Icon(Icons.location_on, color: Colors.grey, size: 14),
            SizedBox(width: 4),
            Text("20 Lý Tự Trọng, Phường Bến Nghé, Quận 1", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildSelector(List<String> items, int selectedIndex, Function(int) onSelected) {
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
          // --- SỬA ĐỔI: Màn hình cong dùng ClipPath ---
          Column(
            children: [
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Lớp 1: Glow (Phát sáng)
                  Container(
                    margin: const EdgeInsets.only(top: 5), // Đẩy xuống một chút để ko bị hụt trên
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.7,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: primaryRed.withOpacity(0.5),
                          blurRadius: 25, // Độ nhòe
                          spreadRadius: 1,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                  ),

                  // Lớp 2: Ảnh màn hình cắt hình thang
                  ClipPath(
                    clipper: ScreenClipper(),
                    child: Stack(
                      children: [
                        // Ảnh phim
                        SizedBox(
                          height: 70, // Chiều cao màn hình
                          width: double.infinity,
                          child: Image.network(
                            widget.movieData["image"]!,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                        // Lớp phủ Gradient mờ dần xuống dưới
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
              const Text("MÀN HÌNH", style: TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
          // ---------------------------------------------

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

          // Chú thích
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
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
      child: ElevatedButton(
        onPressed: selectedSeats.isEmpty ? null : () {
          print("Đặt ${selectedSeats.length} vé thành công!");
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          disabledBackgroundColor: Colors.grey[800],
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text("ĐẶT GHẾ", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// --- CLASS MỚI: Cắt hình thang cong 3D ---
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