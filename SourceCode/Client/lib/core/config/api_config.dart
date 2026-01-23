class ApiConfig {
  // Thay đổi URL này khi deploy
  // Development: http://10.0.2.2:3000
  // Ngrok: https://abc123xyz.ngrok-free.app (thay bằng URL của bạn)
  // Production: https://your-domain.com hoặc http://your-server-ip:3000

  // 🔥 NGROK: Thay URL này bằng URL từ Ngrok
  static const String baseUrl =
      'https://animally-nonseismic-hadlee.ngrok-free.dev';
  static const String paymentBaseUrl =
      'https://animally-nonseismic-hadlee.ngrok-free.dev';

  // API endpoints
  static const String authEndpoint = '/api/auth';
  static const String bookingEndpoint = '/api/bookings';
  static const String movieEndpoint = '/api/booking/movies';
  static const String paymentEndpoint = '/api/payments';
}
