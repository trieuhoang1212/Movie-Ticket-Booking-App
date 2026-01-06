import 'package:flutter/material.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  // 0: Vé hiện tại, 1: Vé đã xem
  int _selectedTab = 0;

  // Mock Data: Danh sách vé
  final List<Map<String, dynamic>> _allTickets = [
    {
      "status": 0, // 0 = Hiện tại
      "title": "Zootopia 2",
      "image": "https://m.media-amazon.com/images/M/MV5BYjg1Mjc3MjQtMTZjNy00YWVlLWFhMWEtMWI3ZTgxYjJmNmRlXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg",
      "cinema": "BHD Star Thao Dien",
      "date": "26 Tháng 12, 2025",
      "time": "20:00",
      "seats": "1 chỗ ngồi"
    },
    {
      "status": 0,
      "title": "Avatar: Dòng Chảy Của Nước",
      "image": "https://m.media-amazon.com/images/M/MV5BYjhiNjBlODktY2ZiOC00YjVlLWFlNzAtNTVhNzM1YjI1NzMxXkEyXkFqcGdeQXVyMTEyMjM2NDc2._V1_.jpg",
      "cinema": "CGV Vincom Center",
      "date": "28 Tháng 12, 2025",
      "time": "18:30",
      "seats": "2 chỗ ngồi"
    },
    {
      "status": 1, // 1 = Đã xem
      "title": "Bố Già",
      "image": "https://upload.wikimedia.org/wikipedia/vi/8/80/Bo_Gia_2021_poster.jpg", // Link ví dụ
      "cinema": "CGV Giga Mall",
      "date": "15 Tháng 2, 2025",
      "time": "22:00",
      "seats": "4 chỗ ngồi"
    },
    {
      "status": 1,
      "title": "Nhà Bà Nữ",
      "image": "https://upload.wikimedia.org/wikipedia/vi/4/4e/Nha_ba_nu_poster.jpg", // Link ví dụ
      "cinema": "Galaxy Nguyễn Du",
      "date": "22 Tháng 1, 2025",
      "time": "19:00",
      "seats": "2 chỗ ngồi"
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Lọc danh sách vé theo Tab đang chọn
    List<Map<String, dynamic>> displayTickets = _allTickets
        .where((ticket) => ticket['status'] == _selectedTab)
        .toList();

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
              // Nếu màn hình này nằm trong BottomNav thì có thể ko cần nút back,
              // hoặc nút back dùng để quay về trang Home (index 0)
              // Ở đây mình để pop tạm thời.
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
            child: displayTickets.isEmpty
                ? Center(
              child: Text(
                "Chưa có vé nào",
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: displayTickets.length,
              itemBuilder: (context, index) {
                return _buildTicketCard(displayTickets[index]);
              },
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
            color: isSelected ? const Color(0xFF3B3E4A) : Colors.transparent, // Màu sáng hơn khi chọn
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
  Widget _buildTicketCard(Map<String, dynamic> ticket) {
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
            child: Image.network(
              ticket['image'],
              width: 100,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (c, o, s) => Container(
                width: 100,
                height: 120,
                color: Colors.grey,
                child: const Icon(Icons.movie),
              ),
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
                  ticket['title'],
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
                _buildInfoRow(Icons.location_on_outlined, ticket['cinema']),
                const SizedBox(height: 8),

                // Ngày chiếu
                _buildInfoRow(Icons.calendar_today_outlined, ticket['date']),
                const SizedBox(height: 8),

                // Giờ và Số ghế
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      ticket['time'],
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.event_seat, color: Color(0xFFFF4444), size: 16), // Ghế màu đỏ
                    const SizedBox(width: 4),
                    Text(
                      ticket['seats'],
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                )
              ],
            ),
          )
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