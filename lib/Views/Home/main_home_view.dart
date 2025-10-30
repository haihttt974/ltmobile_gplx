import 'package:doan/Views/BienBao/bien_bao_list_view.dart';
import 'package:doan/Views/SetOfQuestions/select_bo_de_tn_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Styles/app_colors.dart';
import '../Auth/login_view.dart';
import '../Rank/select_hang_view.dart';
import '../SetOfQuestions/select_bo_de_tn_view.dart'; 
import '../Tip/tips_list_screen.dart';


class MainHomeView extends StatefulWidget {
  const MainHomeView({super.key});

  @override
  State<MainHomeView> createState() => _MainHomeViewState();
}

class _MainHomeViewState extends State<MainHomeView> {
  String? _userEmail;
  String? _selectedHangName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('user_email');
      _selectedHangName = prefs.getString('selected_hang_name');
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginView()),
            (route) => false,
      );
    }
  }

  Future<void> _changeHang() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SelectHangView()),
    );
    _loadUserData(); // cập nhật lại sau khi chọn hạng
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: const Text(
          "Trang chính",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Đăng xuất",
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_userEmail != null)
              Text(
                "Xin chào, $_userEmail!",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            const SizedBox(height: 16),
            if (_selectedHangName != null)
              Column(
                children: [
                  const Text(
                    "Hạng GPLX hiện tại:",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _selectedHangName!,
                    style: const TextStyle(
                      color: Colors.lightBlueAccent,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Đổi hạng

                  ElevatedButton.icon(
                    onPressed: _changeHang,
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text("Đổi hạng khác"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Bộ đề trắc nghiệm
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SelectBoDeTnView(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.library_books),
                    label: const Text("Bộ đề trắc nghiệm"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 🔥 Mẹo ghi nhớ

                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TipsListScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.tips_and_updates_outlined),
                    label: const Text("Mẹo ghi nhớ"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      foregroundColor: Colors.white,
                    ),
                  ),
				          ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BienBaoListView()),
                      );
                    },
                    icon: const Icon(Icons.traffic),
                    label: const Text("Biển báo"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: _changeHang,
                icon: const Icon(Icons.settings),
                label: const Text("Chọn hạng GPLX"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
