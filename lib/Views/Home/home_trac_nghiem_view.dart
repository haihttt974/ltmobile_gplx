// lib/Views/Home/home_trac_nghiem_view.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../BienBao/bien_bao_list_view.dart';
import '../Chapter/on_tap_theo_chuong_view.dart';
import '../SetOfQuestions/select_bo_de_tn_view.dart';
import '../Tip/tips_list_screen.dart';

class HomeTracNghiemView extends StatefulWidget {
  const HomeTracNghiemView({super.key});

  @override
  State<HomeTracNghiemView> createState() => _HomeTracNghiemViewState();
}

class _HomeTracNghiemViewState extends State<HomeTracNghiemView> {
  String _selectedHangName = '';
  int _tongCauHoi = 0;

  @override
  void initState() {
    super.initState();
    _loadHangInfo();
  }

  Future<void> _loadHangInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedHangName = prefs.getString('selected_hang_name') ?? '';
      // TODO: Lấy tổng câu hỏi từ API hoặc SharedPreferences
      _tongCauHoi = 250; // Placeholder
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Hạng $_selectedHangName: $_tongCauHoi câu 2025',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // TODO: Mở settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner thông báo
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF4CAF50)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Bạn đang ôn Bộ 600 câu hỏi mới\ndo Cục CSGT phát hành 6/2025.',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Thay đổi',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Grid các tính năng
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
                children: [
                  _buildFeatureCard(
                    title: 'Thi theo bộ đề',
                    icon: Icons.description,
                    color: const Color(0xFFF44336),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SelectBoDeTnView(),
                        ),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    title: 'Ôn tập câu hỏi',
                    icon: Icons.menu_book,
                    color: const Color(0xFF00BCD4),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OnTapTheoChuongView(),
                        ),
                      );
                    },
                  ),
                  // _buildFeatureCard(
                  //   title: '20 câu điểm liệt',
                  //   icon: Icons.verified,
                  //   color: const Color(0xFF795548),
                  //   onTap: () {
                  //     // TODO: Navigate to critical questions
                  //   },
                  // ),
                  // _buildFeatureCard(
                  //   title: 'Top 50 câu cần chú ý',
                  //   icon: Icons.bar_chart,
                  //   color: const Color(0xFF607D8B),
                  //   onTap: () {
                  //     // TODO: Navigate to top 50
                  //   },
                  // ),
                  _buildFeatureCard(
                    title: 'Các biển báo',
                    icon: Icons.traffic,
                    color: const Color(0xFF2196F3),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BienBaoListView(),
                        ),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    title: 'Mẹo ghi nhớ',
                    icon: Icons.lightbulb_outline,
                    color: const Color(0xFFE91E63),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TipsListScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Card bỏ quảng cáo
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFF44336), width: 3),
                    ),
                    child: const Center(
                      child: Text(
                        'ADS',
                        style: TextStyle(
                          color: Color(0xFFF44336),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Bỏ quảng cáo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}