import 'package:flutter/material.dart';
import 'movie_detail_screen.dart';

class FavoriteScreen extends StatelessWidget {
  // 1. Khai báo biến để nhận danh sách phim từ HomeScreen
  final List<Map<String, String>> favoriteMovies;

  const FavoriteScreen({
    super.key,
    required this.favoriteMovies, // Bắt buộc truyền vào
  });

  @override
  Widget build(BuildContext context) {
    // LƯU Ý: Đã xóa phần mock data cũ ở đây

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Danh sách yêu thích",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        // Nút Back (Trong ngữ cảnh BottomNav có thể không cần, nhưng giữ lại theo thiết kế của bạn)
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          // 1. Nền Background chung
          Positioned.fill(
            child: Image.asset(
              'assets/images/BG.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: const Color(0xFF151720).withOpacity(0.9),
            ),
          ),

          // 2. Nội dung danh sách (Đã sửa logic)
          favoriteMovies.isEmpty
              ? _buildEmptyState() // Nếu list rỗng thì hiện thông báo
              : SafeArea(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteMovies.length, // Dùng độ dài list thực tế
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final movie = favoriteMovies[index];
                return _buildFavoriteItem(context, movie);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị khi chưa có phim yêu thích
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "Chưa có phim yêu thích",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteItem(BuildContext context, Map<String, String> movie) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen(movieData: movie),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF2B2D3A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // Ảnh phim
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                movie["image"] ?? "", // Thêm check null an toàn
                height: 100,
                width: 80,
                fit: BoxFit.cover,
                errorBuilder: (c, o, s) => Container(height: 100, width: 80, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 16),

            // Thông tin
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie["title"] ?? "",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie["duration"] ?? "",
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movie["genre"] ?? "",
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFF4444), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        movie["rating"] ?? "",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            // Icon Tim (luôn hiển thị màu đỏ vì đây là màn hình yêu thích)
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 50),
                  child: const Icon(Icons.favorite, color: Color(0xFFFF4444), size: 24),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}