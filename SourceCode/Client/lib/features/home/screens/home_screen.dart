import 'package:flutter/material.dart';
import 'movie_detail_screen.dart';
import 'favorite_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  int _currentHotMovieIndex = 0;
  int _currentNowShowingIndex = 0;
  // --- CHÈN ĐOẠN NÀY VÀO ---
  // Danh sách lưu phim yêu thích
  final List<Map<String, String>> _favoriteMovies = [];
  void _toggleFavorite(Map<String, String> movie) {
    setState(() {
      if (_favoriteMovies.contains(movie)) {
        _favoriteMovies.remove(movie);
      } else {
        _favoriteMovies.add(movie);
      }
    });
  }
  // -------------------------


  // Mock data
  final List<Map<String, String>> hotMovies = [
    {
      "title": "Zootopia 2",
      "image": "https://m.media-amazon.com/images/M/MV5BYjg1Mjc3MjQtMTZjNy00YWVlLWFhMWEtMWI3ZTgxYjJmNmRlXkEyXkFqcGc@._V1_FMjpg_UX1000_.jpg",
      "duration": "1h 48m",
      "genre": "Hài hước . Hoạt hình . Động vật",
      "rating": "8.7/10"
    },
    {
      "title": "Avatar 2",
      "image": "https://m.media-amazon.com/images/M/MV5BYjhiNjBlODktY2ZiOC00YjVlLWFlNzAtNTVhNzM1YjI1NzMxXkEyXkFqcGdeQXVyMTEyMjM2NDc2._V1_.jpg",
      "duration": "3h 12m",
      "genre": "Hành động . Viễn tưởng",
      "rating": "9.0/10"
    },
  ];

  final List<Map<String, String>> nowShowingMovies = [
    {
      "title": "Truy tìm Long Diên Hương",
      "image": "https://cdn.galaxycine.vn/media/2025/1/15/men-in-black-500_1736932475681.jpg",
      "duration": "1h 48m",
      "genre": "Hài hước . Hành động",
      "rating": "8.0/10"
    },
    {
      "title": "Truy tìm Long Diên Hương",
      "image": "https://cdn.galaxycine.vn/media/2025/1/15/men-in-black-500_1736932475681.jpg",
      "duration": "1h 48m",
      "genre": "Hài hước . Hành động",
      "rating": "8.0/10"
    },
    {
      "title": "Truy tìm Long Diên Hương",
      "image": "https://cdn.galaxycine.vn/media/2025/1/15/men-in-black-500_1736932475681.jpg",
      "duration": "1h 48m",
      "genre": "Hài hước . Hành động",
      "rating": "8.0/10"
    },
  ];

  @override
  Widget build(BuildContext context) {
    // --- 2. DANH SÁCH CÁC MÀN HÌNH TƯƠNG ỨNG VỚI TAB ---
    final List<Widget> pages = [
      _buildHomeContent(),
      const Center(child: Text("Vé của tôi", style: TextStyle(color: Colors.white))), // Index 1
      const Center(child: Text("Tìm kiếm", style: TextStyle(color: Colors.white))),   // Index 2
      FavoriteScreen(favoriteMovies: _favoriteMovies),
      const Center(child: Text("Thông báo", style: TextStyle(color: Colors.white))),  // Index 4
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: pages[_selectedIndex],

      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHomeContent() {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/BG.png',
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: Container(
            color: const Color(0xFF151720).withOpacity(0.4),
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 48),

                // Phim hot
                _buildSectionTitle("Phim đang hot"),
                const SizedBox(height: 16),
                _buildMovieSlider(
                  hotMovies,
                  currentIndex: _currentHotMovieIndex,
                  onPageChanged: (index) {
                    setState(() => _currentHotMovieIndex = index);
                  },
                ),

                const SizedBox(height: 48),

                // Phim đang chiếu
                _buildSectionTitle("Phim đang chiếu"),
                const SizedBox(height: 16),
                _buildMovieSlider(
                  nowShowingMovies,
                  currentIndex: _currentNowShowingIndex,
                  onPageChanged: (index) {
                    setState(() => _currentNowShowingIndex = index);
                  },
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Xin Chào, User",
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=11"),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildMovieSlider(
      List<Map<String, String>> movies, {
        required int currentIndex,
        required Function(int) onPageChanged,
      }) {
    return Column(
      children: [
        SizedBox(
          height: 380,
          child: PageView.builder(
            itemCount: movies.length,
            controller: PageController(viewportFraction: 1.0),
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: Stack(
                  children: [

                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(
                          movie["image"]!,
                          fit: BoxFit.cover,
                          errorBuilder: (c, o, s) => Container(color: Colors.grey),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 16, right: 16,
                      child: GestureDetector(
                        onTap: () {
                          _toggleFavorite(movie); // Gọi hàm khi bấm
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _favoriteMovies.contains(movie) ? Icons.favorite : Icons.favorite_border,
                            color: _favoriteMovies.contains(movie) ? const Color(0xFFFF4444) : Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16, left: 16, right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F222A).withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(movie["title"]!, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(movie["duration"]!, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(movie["genre"]!, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Color(0xFFFF4444), size: 18),
                                const SizedBox(width: 4),
                                Text(movie["rating"]!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                const Spacer(),
                                // Bọc nút trong Container để tạo Gradient
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Color(0xFFFF4444), // Màu đỏ tươi (Gốc)
                                        Color(0xFFCC0000), // Màu đỏ đậm hơn (Để tạo chiều sâu)
                                        // Hoặc bạn có thể dùng [Color(0xFFFF4444), Colors.orange] nếu muốn rực rỡ
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20), // Bo góc phải khớp với nút
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MovieDetailScreen(
                                            movieData: movie,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent, // QUAN TRỌNG: Để lộ màu gradient bên dưới
                                      shadowColor: Colors.transparent,     // Tắt bóng đen mặc định (nếu muốn đẹp hơn)
                                      foregroundColor: Colors.white,       // Màu chữ/icon
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(Icons.play_circle_outline, size: 18),
                                        SizedBox(width: 4),
                                        Text("Đặt vé ngay", style: TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),


        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(movies.length, (index) {
            bool isActive = index == currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: isActive ? 30 : 10,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFFF4444) : Colors.grey[800],
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.only(
        top: 16,
        bottom: 16 + bottomPadding,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF151720).withOpacity(0.5),
        border: const Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_filled, 0),
          _buildNavItem(Icons.confirmation_number_outlined, 1),
          _buildNavItem(Icons.search, 2),
          _buildNavItem(Icons.favorite, 3), // Icon Yêu thích (Index 3)
          _buildNavItem(Icons.notifications_none, 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return IconButton(
      onPressed: () => setState(() => _selectedIndex = index),
      icon: Icon(
        icon,
        color: isSelected ? const Color(0xFFFF4444) : Colors.grey,
        size: 28,
      ),
    );
  }
}