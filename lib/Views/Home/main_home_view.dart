import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Styles/app_colors.dart';
import '../auth/login_view.dart';

class MainHomeView extends StatelessWidget {
  const MainHomeView({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
    await prefs.remove("user_id");
    await prefs.remove("user_email");

    // Điều hướng về màn Login và xóa toàn bộ navigation stack
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginView()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        title: const Text(
          "Trang chính",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: "Đăng xuất",
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Xin chào, bạn đã đăng nhập!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _handleLogout(context),
              child: const Text(
                "Đăng xuất",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
