import 'package:doan/Views/BienBao/bien_bao_list_view.dart';
import 'package:doan/Views/Tip/tips_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Styles/app_colors.dart';
import '../Auth/login_view.dart';
import '../Rank/select_hang_view.dart';
import '../SetOfQuestions/select_bo_de_tn_view.dart';


// Services
import '../../Service/api_service.dart';
import '../../Service/sim_api.dart';
import '../sim/sim_home_view.dart';

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
    if (!mounted) return;
    setState(() {
      _userEmail = prefs.getString('user_email');
      _selectedHangName = prefs.getString('selected_hang_name');
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginView()),
          (route) => false,
    );
  }

  Future<void> _changeHang() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SelectHangView()),
    );
    _loadUserData(); // cập nhật lại sau khi chọn hạng
  }

  // Lấy token đã lưu
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ??   // <-- quan trọng: key đang dùng khi login
        prefs.getString('jwt_token') ??
        prefs.getString('access_token') ??
        prefs.getString('token');
  }


  Future<void> _openMoPhong() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa có token đăng nhập. Vui lòng đăng nhập lại.')),
      );
      return;
    }

    // ApiService.baseUrl là static const trong api_service.dart
    final api = SimApi(ApiService.baseUrl, token);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SimHomeView(api: api)),
    );
  }

  void _openTracNghiem() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SelectBoDeTnView()),
    );
  }

  void _openBienBao() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BienBaoListView()),
    );
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
                  const SizedBox(height: 22),
                ],
              ),

            // 3 nút chính theo yêu cầu
            ElevatedButton.icon(
              onPressed: _openTracNghiem,
              icon: const Icon(Icons.library_books),
              label: const Text("Ôn trắc nghiệm"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _openMoPhong,
              icon: const Icon(Icons.slow_motion_video),
              label: const Text("Ôn mô phỏng"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _openBienBao,
              icon: const Icon(Icons.traffic),
              label: const Text("Ôn biển báo"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (_) => const TestVideoScreen()),
            //     );
            //   },
            //   child: const Text('🔧 Test Video'),
            // ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: _changeHang,
              icon: const Icon(Icons.swap_horiz),
              label: const Text("Đổi hạng khác"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
                minimumSize: const Size.fromHeight(44),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
