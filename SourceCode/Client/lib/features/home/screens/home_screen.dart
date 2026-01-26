import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../profile/profile_screen.dart';
import '../services/movie_service.dart';
import 'my_tickets_screen.dart';
import 'favorite_screen.dart';
import 'movie_detail_screen.dart';
import 'notification_screen.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _currentHotMovieIndex = 0;
  int _currentNowShowingIndex = 0;


  final MovieService _movieService = MovieService();
  // Dữ liệu phim từ API
  List<Movie> hotMovies = [];
  List<Movie> nowShowingMovies = [];

  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // Danh sách phim yêu thích (tạm thời mock)
  final List<Map<String, String>> _favoriteMovies = [];

  // Trạng thái loading
  bool isLoadingHotMovies = true;
  bool isLoadingNowShowingMovies = true;

  // Thông báo lỗi
  String? errorMessage;

  // Widget hiển thị hiệu ứng Skeleton
  Widget _buildSkeletonLoader() {
    return SizedBox(
      height: 380, // Chiều cao khớp với _buildMovieSlider
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(), // Không cho cuộn khi đang load
        itemCount: 2, // Hiển thị giả 2 item
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Shimmer.fromColors(
              // Màu nền tối (hợp với theme app của bạn)
              baseColor: const Color(0xFF2B2D3A),
              // Màu sáng chạy qua (hiệu ứng)
              highlightColor: const Color(0xFF3F4250),
              child: Container(
                // Độ rộng chiếm gần hết màn hình giống PageView của bạn
                width: MediaQuery.of(context).size.width - 32,
                decoration: BoxDecoration(
                  color: Colors.black, // Bắt buộc phải có màu để Shimmer hoạt động
                  borderRadius: BorderRadius.circular(24),
                ),
                // Giả lập cấu trúc bên trong (Optional: để nhìn chi tiết hơn)
                child: Stack(
                  children: [
                    // Giả lập phần text ở dưới
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(height: 20, width: 150, color: Colors.white),
                          const SizedBox(height: 8),
                          Container(height: 12, width: 100, color: Colors.white),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  // Load dữ liệu phim từ API
  Future<void> _loadMovies() async {
    try {
      // Load phim đang hot (now_showing + isHot = true)
      final hot = await _movieService.getHotMovies();

      // Load tất cả phim đang chiếu (now_showing)
      final nowShowing = await _movieService.getNowShowingMovies();

      setState(() {
        hotMovies = hot;
        nowShowingMovies = nowShowing;
        isLoadingHotMovies = false;
        isLoadingNowShowingMovies = false;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        isLoadingHotMovies = false;
        isLoadingNowShowingMovies = false;
        errorMessage = 'Không thể tải dữ liệu phim: $e';
      });
    }
  }
  bool _isFavorite(Movie movie) {
    return _favoriteMovies.any((m) => m['title'] == movie.title);
  }

  // Hàm thêm/xóa phim khỏi danh sách yêu thích
  void _toggleFavorite(Movie movie) {
    setState(() {
      if (_isFavorite(movie)) {
        // Nếu đã có thì xóa đi
        _favoriteMovies.removeWhere((m) => m['title'] == movie.title);
      } else {
        // Nếu chưa có thì thêm vào
        // Chuyển đổi object Movie sang Map<String, String> như FavoriteScreen yêu cầu
        _favoriteMovies.add({
          'id': movie.id.toString(),
          'title': movie.title,
          'image': movie.posterUrl ?? '',
          'duration': movie.durationFormatted,
          'genre': movie.genreFormatted,
          'rating': movie.ratingFormatted,
        });
      }
    });
  }

  // Render màn hình theo tab được chọn
  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 1: // Vé của tôi
        return const MyTicketsScreen();
      case 2: // Tìm kiếm (tạm thời hiển thị home)
        return _buildHomeContent();
      case 3: // Yêu thích
        return FavoriteScreen(favoriteMovies: _favoriteMovies);
      case 4: // Thông báo
        return const NotificationScreen();
      case 5: // Profile
        return const ProfileScreen();
      default: // Home
        return _buildHomeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/BG.png', fit: BoxFit.cover),
          ),

          Positioned.fill(
            child: Container(
              color: const Color(0xFF151720).withValues(alpha: 0.4),
            ),
          ),

          SafeArea(child: _getCurrentScreen()),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHomeContent() {
    return errorMessage != null
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadMovies,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 48),

                // Phim hot
                _buildSectionTitle("Phim đang hot"),
                const SizedBox(height: 16),
                isLoadingHotMovies
                    ? _buildSkeletonLoader()
                    : _buildMovieSlider(
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
                isLoadingNowShowingMovies
                    ? _buildSkeletonLoader()
                    : _buildMovieSlider(
                        nowShowingMovies,
                        currentIndex: _currentNowShowingIndex,
                        onPageChanged: (index) {
                          setState(() => _currentNowShowingIndex = index);
                        },
                      ),

                const SizedBox(height: 80),
              ],
            ),
          );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Xin Chào, ${_currentUser?.displayName ?? 'User'}",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() => _selectedIndex = 5); // Chuyển sang tab Profile
          },
          child: CircleAvatar(
            radius: 20,
            backgroundImage: _currentUser?.photoURL != null
                ? NetworkImage(_currentUser!.photoURL!)
                : const NetworkImage("https://i.pravatar.cc/150?img=11"),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMovieSlider(
    List<Movie> movies, {
    required int currentIndex,
    required Function(int) onPageChanged,
  }) {
    if (movies.isEmpty) {
      return const Center(
        child: Text('Không có phim nào', style: TextStyle(color: Colors.white)),
      );
    }

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
              return GestureDetector(
                onTap: () {
                  // Chuyển đến màn hình chi tiết phim
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MovieDetailScreen(
                        movieData: {
                          'id': movie.id,
                          'title': movie.title,
                          'image': movie.posterUrl ?? '',
                          'duration': movie.durationFormatted,
                          'genre': movie.genreFormatted,
                          'rating': movie.ratingFormatted,
                        },
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child:
                              movie.posterUrl != null &&
                                  movie.posterUrl!.isNotEmpty
                              ? Image.network(
                                  movie.posterUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, o, s) => Container(
                                    color: Colors.grey,
                                    child: const Center(
                                      child: Icon(
                                        Icons.movie,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                    ),
                                  ),
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Container(
                                          color: Colors.grey,
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      },
                                )
                              : Container(
                                  color: Colors.grey,
                                  child: const Center(
                                    child: Icon(
                                      Icons.movie,
                                      color: Colors.white,
                                      size: 50,
                                    ),
                                  ),
                                ),
                        ),
                      ),

                      Positioned(
                        top: 16,
                        right: 16,
                        child: GestureDetector(
                          onTap: () {
                            _toggleFavorite(movie);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            // 3. Thay đổi Icon dựa trên trạng thái
                            child: Icon(
                              _isFavorite(movie) ? Icons.favorite : Icons.favorite_border,
                              color: _isFavorite(movie) ? const Color(0xFFFF4444) : Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF1F222A,
                            ).withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                movie.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                movie.durationFormatted,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                movie.genreFormatted,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Color(0xFFFF4444),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    movie.ratingFormatted,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              MovieDetailScreen(
                                                movieData: {
                                                  'id': movie.id,
                                                  'title': movie.title,
                                                  'image':
                                                      movie.posterUrl ?? '',
                                                  'duration':
                                                      movie.durationFormatted,
                                                  'genre': movie.genreFormatted,
                                                  'rating':
                                                      movie.ratingFormatted,
                                                },
                                              ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF4444),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(
                                          Icons.play_circle_outline,
                                          size: 18,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          "Đặt vé ngay",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF151720).withValues(alpha: 0.5),
        border: const Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_filled, 0),
          _buildNavItem(Icons.confirmation_number_outlined, 1),
          _buildNavItem(Icons.search, 2),
          _buildNavItem(Icons.favorite_border, 3),
          _buildNavItem(Icons.notifications_none, 4),
          _buildNavItem(Icons.person_outline, 5),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return IconButton(
      onPressed: () {
        setState(() => _selectedIndex = index);
      },
      icon: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.grey,
        size: 28,
      ),
    );
  }
}
