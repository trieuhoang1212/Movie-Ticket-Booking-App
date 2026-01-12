import 'package:flutter/material.dart';
import 'booking_screen.dart';

class MovieDetailScreen extends StatefulWidget {
  // Nhận dữ liệu phim từ màn hình Home truyền sang
  final Map<String, String> movieData;

  const MovieDetailScreen({super.key, required this.movieData});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  // State để theo dõi ngày đang chọn trong lịch chiếu
  int _selectedDateIndex = 0;

  // Mock data cho lịch chiếu
  final List<Map<String, String>> scheduleDates = [
    {"day": "4/12", "dow": "Thứ 5"},
    {"day": "5/12", "dow": "Thứ 6"},
    {"day": "6/12", "dow": "Thứ 7"},
  ];

  // Mock data cho suất chiếu
  final List<String> timeSlots = ["8:00", "15:00", "19:30", "21:15"];

  final Color primaryRed = const Color(0xFFFF4444);
  final Color darkBackground = const Color(0xFF151720);

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin phim từ widget widget.movieData
    final movie = widget.movieData;

    return Scaffold(
      // Cho phép nội dung tràn lên behind AppBar
      extendBodyBehindAppBar: true,
      // Sử dụng Appbar trong suốt để chứa nút Back và nút Yêu thích
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.favorite_border, color: Colors.white),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/BG.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: darkBackground.withOpacity(0.4),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.55, // Chiếm khoảng 55% chiều cao màn hình
                  width: double.infinity,
                  child: Image.network(
                    movie["image"] ?? "",
                    fit: BoxFit.cover,
                    errorBuilder: (c, o, s) => Container(color: Colors.grey),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie["title"] ?? "Tên Phim",
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        movie["duration"] ?? "0h 0m",
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      _buildGenreTags(movie["genre"] ?? ""),
                      const SizedBox(height: 24),

                      // Nút Xem Trailer & Đánh giá
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              // 1. Tạo Gradient ở đây
                              gradient: LinearGradient(
                                colors: [Colors.red, Colors.red.shade900],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              icon: const Icon(Icons.play_circle_fill),
                              label: const Text("Xem Trailer", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.star, color: Color(0xFFFF4444), size: 24),
                          const SizedBox(width: 8),
                          Text(
                            movie["rating"] ?? "0.0/10",
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Phần Mô Tả
                      _buildSectionTitle("Mô Tả"),
                      const SizedBox(height: 12),
                      _buildInfoRow("Đạo diễn:", "Jared Bush, Byron Howard"),
                      _buildInfoRow("Diễn viên:", "Jason Bateman, Ginnifer Goodwin..."),
                      _buildInfoRow("Khởi chiếu:", "Thứ Sáu, 28/11/2025"),
                      const SizedBox(height: 24),

                      // Phần Nội Dung Phim
                      _buildSectionTitle("Nội Dung Phim"),
                      const SizedBox(height: 12),
                      Text(
                        "Cô thỏ cảnh sát Judy Hopps và người bạn cáo lém lỉnh Nick Wilde tái hợp trong một vụ án hoàn toàn mới, lao vào cuộc săn lùng đầy rẫy bất ngờ tại thành phố Zootopia sôi động...",
                        style: TextStyle(color: Colors.grey[300], height: 1.5),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      InkWell(
                        onTap: () {},
                        child: Text("view more", style: TextStyle(color: primaryRed)),
                      ),
                      const SizedBox(height: 32),

                      // Lịch Chiếu
                      Center(child: _buildSectionTitle("LỊCH CHIẾU")),
                      const SizedBox(height: 16),
                      _buildScheduleSelector(),
                      const SizedBox(height: 32),

                      // Danh Sách Rạp
                      Center(child: _buildSectionTitle("DANH SÁCH RẠP")),
                      const SizedBox(height: 16),
                      Center(
                        child: _buildCinemaCard(),
                      ),
                      // Thêm khoảng trống ở dưới để không bị nút Đặt vé che mất
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: darkBackground,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, -5)
            )
          ],
        ),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryRed, Colors.red.shade900],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingScreen(
                    movieData: widget.movieData,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,

              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              foregroundColor: Colors.white,
            ),
            child: const Text(
              "ĐẶT GHẾ",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  // Widget tiện ích: Tiêu đề section (Tái sử dụng style từ Home)
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  // Widget tiện ích: Dòng thông tin (Đạo diễn, Diễn viên...)
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Widget tiện ích: Hiển thị các tags thể loại
  Widget _buildGenreTags(String genreString) {
    // Tách chuỗi "Hài hước . Hoạt hình" thành mảng
    List<String> genres = genreString.split('.').map((e) => e.trim()).toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: genres.map((genre) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[600]!),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            genre,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        );
      }).toList(),
    );
  }

  // Widget tiện ích: Bộ chọn lịch chiếu
  Widget _buildScheduleSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(scheduleDates.length, (index) {
        final item = scheduleDates[index];
        final isSelected = index == _selectedDateIndex;

        return GestureDetector(
          onTap: () => setState(() => _selectedDateIndex = index),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            decoration: BoxDecoration(
              color: isSelected ? primaryRed : const Color(0xFF2A2D3A), // Màu đỏ nếu chọn, xám tối nếu không
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  item["day"]!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item["dow"]!,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Widget tiện ích: Card thông tin rạp
  Widget _buildCinemaCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "CUTH Lý Tự Trọng Quận 1",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "20 Lý Tự Trọng, Phường Bến Nghé, Quận 1, TP.HCM",
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
          const SizedBox(height: 16),
          const Text(
            "Thời Gian",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: timeSlots.map((time) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[700]!)
                ),
                child: Text(time, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}