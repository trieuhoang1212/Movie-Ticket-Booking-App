import 'package:flutter/material.dart';
import 'email_login_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(
        children: [
          //  ẢNH NỀN
          Positioned.fill(
            child: Image.asset(
              'assets/images/BG.png',
              fit: BoxFit.cover,
            ),
          ),

          // LỚP PHỦ MÀU ĐEN MỜ
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.1),
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

                // FACEBOOK
                _socialButton(
                  icon: Icons.facebook,
                  text: "Đăng nhập với Facebook",
                  iconColor: Colors.blue,
                ),

                const SizedBox(height: 12),

                // GOOGLE
                _socialButton(
                  icon: Icons.g_mobiledata,
                  text: "Đăng nhập với Google",
                  iconColor: Colors.red,
                ),

                const SizedBox(height: 12),

                // APPLE
                _socialButton(
                  icon: Icons.apple,
                  text: "Đăng nhập với Apple",
                  iconColor: Colors.white,
                ),

                const SizedBox(height: 20),

                // OR
                Row(
                  children: const [
                    Expanded(child: Divider(color: Colors.grey)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        "or",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey)),
                  ],
                ),

                const SizedBox(height: 20),

                // LOGIN WITH PASSWORD
                // LOGIN WITH PASSWORD - GRADIENT
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Container(
                    width: 380,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xFFFF3A3A),
                          Color(0xFFCC0000),
                        ],
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
                      // Chuyển sang màn hình EmailLoginScreen
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EmailLoginScreen()),
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

                // REGISTER
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Chưa có tài khoản? ",
                      style: TextStyle(color: Colors.grey),
                    ),


                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/signup');

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


                const SizedBox(height: 20), // Khoảng trống dưới cùng
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}