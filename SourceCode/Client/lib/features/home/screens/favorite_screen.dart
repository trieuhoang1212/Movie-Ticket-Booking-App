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
    return Scaffold(
      // Cho phép ảnh nền tràn lên sau AppBar
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          "Danh sách yêu thích",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        // Nút Back
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
            onPressed: () {
              // Nếu màn hình này nằm trong TabBar thì nút này có thể không cần thiết,
              // nhưng nếu được push từ màn hình khác thì cần pop.
              // Dùng maybePop để an toàn.
              Navigator.maybePop(context);
            },
          ),
        ),
      ),
      body: Stack(
        children: [
          // 1. ẢNH NỀN (Background Image)
          Positioned.fill(
            child: Image.asset('assets/images/BG.png', fit: BoxFit.cover),
          ),

          // 2. LỚP PHỦ MÀU ĐEN MỜ (Overlay)
          Positioned.fill(
            child: Container(
              // Dùng withValues thay cho withOpacity
              color: const Color(0xFF151720).withValues(alpha: 0.5),
            ),
          ),

          // 3. NỘI DUNG DANH SÁCH
          favoriteMovies.isEmpty
              ? _buildEmptyState()
              : SafeArea(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteMovies.length,
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
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            "Chưa có phim yêu thích",
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
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
          // Làm nền item hơi trong suốt để thấy background phía sau
          color: const Color(0xFF2B2D3A).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          // Thêm viền nhẹ
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            // Ảnh phim
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                movie["image"] ?? "",
                height: 100,
                width: 80,
                fit: BoxFit.cover,
                errorBuilder: (c, o, s) => Container(
                  height: 100,
                  width: 80,
                  color: Colors.grey,
                  child: const Icon(Icons.movie, color: Colors.white),
                ),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                      const Icon(
                        Icons.star,
                        color: Color(0xFFFF4444),
                        size: 16,
                      ),
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
                  ),
                ],
              ),
            ),

            // Icon Tim
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 50),
                  child: const Icon(
                    Icons.favorite,
                    color: Color(0xFFFF4444),
                    size: 24,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
