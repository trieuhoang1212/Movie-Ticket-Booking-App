import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'email_login_screen.dart';
import 'signup_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../home/services/fcm_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // --- HÀM XỬ LÝ ĐĂNG NHẬP GOOGLE ---
  Future<void> _signInWithGoogle(BuildContext context) async {
    // Hiện vòng xoay loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. Kích hoạt luồng xác thực Google (Mở popup chọn tài khoản)
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // Nếu user hủy (bấm ra ngoài hoặc bấm cancel)
      if (googleUser == null) {
        if (context.mounted) Navigator.pop(context); // Tắt loading
        return;
      }

      // 2. Lấy thông tin xác thực (Token) từ request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Tạo credential mới cho Firebase từ Token của Google
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Đăng nhập vào Firebase
      await FirebaseAuth.instance.signInWithCredential(credential);

      // 4.1. Lưu FCM token lên server
      try {
        final fcmService = FCMService();
        await fcmService.saveFCMToken();
      } catch (e) {
        print('⚠️ Failed to save FCM token: $e');
      }

      // 5. Nếu thành công
      if (context.mounted) {
        Navigator.pop(context); // Tắt loading

        // Chuyển sang HomeScreen và xóa lịch sử để không back lại được Login
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đăng nhập Google thành công!")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Tắt loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi đăng nhập: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
      print("Google Sign-In Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //  ẢNH NỀN
          Positioned.fill(
            child: Image.asset('assets/images/BG.png', fit: BoxFit.cover),
          ),

          // LỚP PHỦ MÀU ĐEN MỜ
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(
                0.2,
              ), // Sử dụng withOpacity cho ổn định
            ),
          ),

          // NỘI DUNG CHÍNH
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100),

                // LOGO
                Container(
                  width: 156,
                  height: 156,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/logo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // TITLE
                const Text(
                  "Chào mừng trở lại!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 44),

                // FACEBOOK BUTTON
                _socialButton(
                  icon: Icons.facebook,
                  text: "Đăng nhập với Facebook",
                  iconColor: Colors.blue,
                  onTap: () {
                    // Chưa tích hợp
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Tính năng Facebook đang phát triển"),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // GOOGLE BUTTON (ĐÃ TÍCH HỢP)
                _socialButton(
                  icon: Icons.g_mobiledata,
                  text: "Đăng nhập với Google",
                  iconColor: Colors.red,
                  onTap: () => _signInWithGoogle(context), // <--- GỌI HÀM Ở ĐÂY
                ),

                const SizedBox(height: 12),

                // APPLE BUTTON
                _socialButton(
                  icon: Icons.apple,
                  text: "Đăng nhập với Apple",
                  iconColor: Colors.white,
                  onTap: () {
                    // Chưa tích hợp
                  },
                ),

                const SizedBox(height: 20),

                // OR DIVIDER
                Row(
                  children: const [
                    Expanded(child: Divider(color: Colors.grey)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text("or", style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(child: Divider(color: Colors.grey)),
                  ],
                ),

                const SizedBox(height: 20),

                // LOGIN WITH PASSWORD
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Container(
                    width: 380,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFFFF3A3A), Color(0xFFCC0000)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EmailLoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Log in with password",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // REGISTER LINK
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Chưa có tài khoản? ",
                      style: TextStyle(color: Colors.grey),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Đăng kí",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _socialButton({
    required IconData icon,
    required String text,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap, // <--- Gắn sự kiện vào đây
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 12),
                Text(text, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
