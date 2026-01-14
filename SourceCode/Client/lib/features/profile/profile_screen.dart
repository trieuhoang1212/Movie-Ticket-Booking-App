import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String _selectedGender = 'Khác';
  bool _isLoading = false;
  final List<String> _genders = ['Nam', 'Nữ', 'Khác'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // 1. LOAD DATA
  Future<void> _loadUserData() async {
    if (currentUser == null) return;
    setState(() => _isLoading = true);

    _nameController.text = currentUser!.displayName ?? '';
    _emailController.text = currentUser!.email ?? '';

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        if (data.containsKey('gender')) {
          setState(() {
            _selectedGender = data['gender'];
          });
        }
      }
    } catch (e) {
      print("Lỗi load data: $e");
    }

    setState(() => _isLoading = false);
  }

  // 2. CẬP NHẬT PROFILE
  Future<void> _updateProfile() async {
    if (currentUser == null) return;
    setState(() => _isLoading = true);

    try {
      await currentUser!.updateDisplayName(_nameController.text.trim());

      await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).set({
        'email': currentUser!.email,
        'displayName': _nameController.text.trim(),
        'gender': _selectedGender,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await currentUser!.reload();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cập nhật thành công!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 3. ĐĂNG XUẤT
  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider avatarImage;
    if (currentUser?.photoURL != null) {
      avatarImage = NetworkImage(currentUser!.photoURL!);
    } else {
      avatarImage = const AssetImage('assets/images/logo.png');
    }

    return Scaffold(
      // Cho phép body tràn lên cả phần AppBar (để background phủ toàn màn hình)
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Hồ sơ cá nhân", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: Stack(
        children: [
          // 1. LỚP ẢNH NỀN (Nằm dưới cùng)
          Positioned.fill(
            child: Image.asset(
              'assets/images/BG.png',
              fit: BoxFit.cover,
            ),
          ),

          // 2. LỚP PHỦ MÀU ĐEN (Tạo hiệu ứng tối)
          Positioned.fill(
            child: Container(
              color: const Color(0xFF151720).withOpacity(0.4), // Độ mờ giống Home Screen
            ),
          ),

          // 3. NỘI DUNG CHÍNH CỦA PROFILE (Dùng SafeArea để tránh tai thỏ)
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // AVATAR
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[800],
                      backgroundImage: avatarImage,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // FORM NHẬP LIỆU
                  _buildTextField("Email (Không đổi được)", _emailController, readOnly: true),
                  const SizedBox(height: 20),

                  _buildTextField("Tên hiển thị", _nameController, icon: Icons.person),
                  const SizedBox(height: 20),

                  // Dropdown Giới tính
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Giới tính", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F222A).withOpacity(0.8), // Thêm opacity cho hợp nền
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedGender,
                        dropdownColor: const Color(0xFF1F222A),
                        isExpanded: true,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        items: _genders.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() => _selectedGender = newValue!);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // BUTTON LƯU
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4444),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Lưu thay đổi", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // BUTTON ĐĂNG XUẤT
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _handleLogout,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Đăng xuất", style: TextStyle(color: Colors.red, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false, IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          style: TextStyle(color: readOnly ? Colors.grey : Colors.white),
          decoration: InputDecoration(
            filled: true,
            // Thêm opacity để input trường nhập trông trong suốt hơn, hòa vào nền
            fillColor: const Color(0xFF1F222A).withOpacity(0.8),
            prefixIcon: icon != null ? Icon(icon, color: Colors.white54) : const Icon(Icons.email, color: Colors.white54),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}