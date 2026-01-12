import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Hàm đăng ký
  Future<String?> register({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Null nghĩa là thành công, không có lỗi
    } on FirebaseAuthException catch (e) {
      return e.message; // Trả về thông báo lỗi (ví dụ: email đã tồn tại)
    }
  }

  // Hàm đăng nhập
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Thành công
    } on FirebaseAuthException catch (e) {
      return e.message; // Trả về lỗi (sai pass, không tìm thấy user)
    }
  }

  // Hàm đăng xuất
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}
