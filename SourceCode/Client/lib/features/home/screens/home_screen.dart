import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../services/movie_service.dart';

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

  // Trạng thái loading
  bool isLoadingHotMovies = true;
  bool isLoadingNowShowingMovies = true;

  // Thông báo lỗi
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  // Load dữ liệu phim từ API
  Future<void> _loadMovies() async {
    try {
      // Load phim đang hot (now_showing)
      final hot = await _movieService.getHotMovies();

      // Load phim đang chiếu (cũng là now_showing, bạn có thể dùng coming_soon nếu muốn)
      final nowShowing = await _movieService.getMovies(status: 'now_showing');

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
            child: Container(color: const Color(0xFF151720).withOpacity(0.4)),
          ),

          SafeArea(
            child: errorMessage != null
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
                            ? const Center(child: CircularProgressIndicator())
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
                            ? const Center(child: CircularProgressIndicator())
                            : _buildMovieSlider(
                                nowShowingMovies,
                                currentIndex: _currentNowShowingIndex,
                                onPageChanged: (index) {
                                  setState(
                                    () => _currentNowShowingIndex = index,
                                  );
                                },
                              ),

                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Xin Chào, User",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
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
              return Container(
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
                                      if (loadingProgress == null) return child;
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
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_border,
                          color: Colors.white,
                          size: 20,
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
                          color: const Color(0xFF1F222A).withOpacity(0.95),
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
                                  onPressed: () {},
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
                                      Icon(Icons.play_circle_outline, size: 18),
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
        color: const Color(0xFF151720).withOpacity(0.5),
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
        color: isSelected ? Colors.white : Colors.grey,
        size: 28,
      ),
    );
  }
}
