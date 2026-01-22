import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../models/movie_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../profile/profile_screen.dart';
import '../services/movie_service.dart';
import 'my_tickets_screen.dart';
import 'favorite_screen.dart';
import 'movie_detail_screen.dart';
import 'notification_screen.dart';

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

  List<Movie> hotMovies = [];
  List<Movie> nowShowingMovies = [];
  final List<Map<String, String>> _favoriteMovies = [];

  bool isLoadingHotMovies = true;
  bool isLoadingNowShowingMovies = true;

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    try {
      // await Future.delayed(const Duration(seconds: 2)); // Dùng để test skeleton

      final hot = await _movieService.getHotMovies();
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

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 1:
        return const MyTicketsScreen();
      case 3:
        return FavoriteScreen(favoriteMovies: _favoriteMovies);
      case 4:
        return const NotificationScreen();
      default:
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
          ElevatedButton(onPressed: _loadMovies, child: const Text('Thử lại')),
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

          // --- PHIM HOT ---
          _buildSectionTitle("Phim đang hot"),
          const SizedBox(height: 16),
          isLoadingHotMovies
              ? const MovieSkeletonCard()
              : _buildMovieSlider(
            hotMovies,
            currentIndex: _currentHotMovieIndex,
            onPageChanged: (index) => setState(() => _currentHotMovieIndex = index),
          ),

          const SizedBox(height: 48),

          // --- PHIM ĐANG CHIẾU ---
          _buildSectionTitle("Phim đang chiếu"),
          const SizedBox(height: 16),
          isLoadingNowShowingMovies
              ? const MovieSkeletonCard()
              : _buildMovieSlider(
            nowShowingMovies,
            currentIndex: _currentNowShowingIndex,
            onPageChanged: (index) => setState(() => _currentNowShowingIndex = index),
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
        const Text("Xin Chào, User", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const CircleAvatar(radius: 20, backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=11")),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildMovieSlider(
      List<Movie> movies, {
        required int currentIndex,
        required Function(int) onPageChanged,
      }) {
    if (movies.isEmpty) return const Center(child: Text('Không có phim nào', style: TextStyle(color: Colors.white)));

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
                      // Poster ảnh
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: movie.posterUrl != null && movie.posterUrl!.isNotEmpty
                              ? Image.network(
                            movie.posterUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (c, o, s) => Container(color: Colors.grey, child: const Icon(Icons.movie, size: 50)),
                          )
                              : Container(color: Colors.grey, child: const Icon(Icons.movie, size: 50)),
                        ),
                      ),
                      // Icon yêu thích
                      Positioned(
                        top: 16, right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            // SỬA: withOpacity -> withValues
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle
                          ),
                          child: const Icon(Icons.favorite_border, color: Colors.white, size: 20),
                        ),
                      ),
                      // Box thông tin bên dưới
                      Positioned(
                        bottom: 16, left: 16, right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            // SỬA: withOpacity -> withValues
                            color: const Color(0xFF1F222A).withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(movie.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text(movie.durationFormatted, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(movie.genreFormatted, style: TextStyle(color: Colors.grey[400], fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Color(0xFFFF4444), size: 18),
                                  const SizedBox(width: 4),
                                  Text(movie.ratingFormatted, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF4444),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    ),
                                    child: Row(children: const [Icon(Icons.play_circle_outline, size: 18), SizedBox(width: 4), Text("Đặt vé ngay", style: TextStyle(fontWeight: FontWeight.bold))]),
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
        // Dot indicator
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
          border: const Border(top: BorderSide(color: Colors.white10))
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
      onPressed: () => setState(() => _selectedIndex = index),
      icon: Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 28),
    );
  }
}


class MovieSkeletonCard extends StatelessWidget {
  const MovieSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey[800]!;
    final highlightColor = Colors.grey[700]!;

    return SizedBox(
      height: 380,
      width: double.infinity,
      child: Stack(
        children: [
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // SỬA: withOpacity -> withValues
                color: const Color(0xFF1F222A).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Shimmer.fromColors(
                baseColor: baseColor,
                highlightColor: highlightColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 20, width: 200, color: Colors.black),
                    const SizedBox(height: 8),
                    Container(height: 20, width: 150, color: Colors.black),
                    const SizedBox(height: 12),
                    Container(height: 12, width: 100, color: Colors.black),
                    const SizedBox(height: 8),
                    Container(height: 12, width: 120, color: Colors.black),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(height: 18, width: 18, color: Colors.black),
                        const SizedBox(width: 4),
                        Container(height: 14, width: 30, color: Colors.black),
                        const Spacer(),
                        Container(
                          height: 40,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}