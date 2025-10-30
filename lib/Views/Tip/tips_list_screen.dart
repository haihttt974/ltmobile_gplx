import 'package:flutter/material.dart';
import '../../Styles/app_theme.dart';
import 'tips_memory_screen.dart';
import 'dart:convert';

class TipsListScreen extends StatefulWidget {
  const TipsListScreen({super.key});

  @override
  State<TipsListScreen> createState() => _TipsListScreenState();
}

class _TipsListScreenState extends State<TipsListScreen> {
  String searchQuery = '';
  final TextEditingController _controller = TextEditingController();

  // Dữ liệu cứng các mẹo (như trong danh sách)
  final List<Map<String, dynamic>> allTips = [
    {
      'title': 'Nồng độ cồn',
      'subtitle': '1 mẹo',
      'colors': [Color(0xFFEC6F66), Color(0xFFF3A183)],
      'key': 'alcohol',
      'keywords': ['cồn', 'nồng độ', 'alcohol', 'bia', 'rượu']
    },
    {
      'title': 'Khoảng cách an toàn',
      'subtitle': '2 mẹo',
      'colors': [Color(0xFF56CCF2), Color(0xFF2F80ED)],
      'key': 'distance',
      'keywords': ['khoảng cách', 'distance', 'an toàn']
    },
    {
      'title': 'Các hạng GPLX',
      'subtitle': '4 mẹo',
      'colors': [Color(0xFF9C27B0), Color(0xFFE91E63)],
      'key': 'license',
      'keywords': ['bằng lái', 'gplx', 'license', 'driving license']
    },
    {
      'title': 'Hỏi về tuổi',
      'subtitle': '1 nhóm',
      'colors': [Color(0xFF00B09B), Color(0xFF96C93D)],
      'key': 'age',
      'keywords': ['tuổi', 'age']
    },
    {
      'title': 'Cao tốc/đường hầm/nơi hạn chế',
      'subtitle': '1 nhóm',
      'colors': [Color(0xFFfbab66), Color(0xFFf7418c)],
      'key': 'rules',
      'keywords': ['cao tốc', 'đường hầm', 'hạn chế', 'highway', 'tunnel']
    },
    {
      'title': 'Nhất chớm – Nhì ưu – Tam – Tứ',
      'subtitle': '1 nhóm',
      'colors': [Color(0xFF36D1DC), Color(0xFF5B86E5)],
      'key': 'priority',
      'keywords': ['ưu tiên', 'chớm', 'priority']
    },
    {
      'title': 'Biển báo & nhóm biển',
      'subtitle': '2 mẹo',
      'colors': [Color(0xFFf7971e), Color(0xFFffd200)],
      'key': 'signs',
      'keywords': ['biển', 'biển báo', 'sign', 'signs']
    },
    {
      'title': 'Tốc độ tối đa',
      'subtitle': '4 nhóm',
      'colors': [Color(0xFFee0979), Color(0xFFff6a00)],
      'key': 'speed',
      'keywords': ['tốc độ', 'speed']
    },
    {
      'title': 'Khái niệm & quy tắc nhanh',
      'subtitle': '1 nhóm',
      'colors': [Color(0xFF12c2e9), Color(0xFFc471ed)],
      'key': 'concept',
      'keywords': ['khái niệm', 'quy tắc', 'concept', 'rule']
    },
    {
      'title': 'Nghiệp vụ vận tải',
      'subtitle': '1 nhóm',
      'colors': [Color(0xFF43cea2), Color(0xFF185a9d)],
      'key': 'transport',
      'keywords': ['vận tải', 'transport']
    },
    {
      'title': 'Kỹ thuật lái xe',
      'subtitle': '1 nhóm',
      'colors': [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
      'key': 'technic',
      'keywords': ['kỹ thuật', 'technic', 'driving technique']
    },
    {
      'title': 'Cấu tạo & sửa chữa',
      'subtitle': '1 nhóm',
      'colors': [Color(0xFF00c6ff), Color(0xFF0072ff)],
      'key': 'mechanic',
      'keywords': ['sửa chữa', 'cấu tạo', 'mechanic', 'repair']
    },
    {
      'title': 'Các quy tắc sa hình khác',
      'subtitle': 'Ưu tiên & dốc',
      'colors': [Color(0xFFff9966), Color(0xFFff5e62)],
      'key': 'intersection',
      'keywords': ['sa hình', 'intersection', 'dốc']
    },
  ];

  // Bỏ dấu tiếng Việt để tìm không dấu
  String _normalize(String input) {
    const withDiacritics =
        'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
    const withoutDiacritics =
        'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';
    var result = input.toLowerCase();
    for (var i = 0; i < withDiacritics.length; i++) {
      result = result.replaceAll(withDiacritics[i], withoutDiacritics[i]);
    }
    return result;
  }

  List<Map<String, dynamic>> _filteredTips() {
    if (searchQuery.isEmpty) return allTips;
    final norm = _normalize(searchQuery);
    return allTips.where((tip) {
      final normTitle = _normalize(tip['title']);
      final normSub = _normalize(tip['subtitle']);
      final normKeywords =
      (tip['keywords'] as List).map((e) => _normalize(e)).toList();
      return normTitle.contains(norm) ||
          normSub.contains(norm) ||
          normKeywords.any((k) => k.contains(norm));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTips();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
          children: [
            // ===== Header có gradient + ô tìm kiếm =====
            Container(
              decoration: AppTheme.headerGradient(
                const Color(0xFFEC6F66),
                const Color(0xFFF3A183),
              ),
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/home',
                                (route) => false,
                          );
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.lightbulb, color: Colors.white),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Mẹo ghi nhớ',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const Icon(Icons.share_outlined, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.search,
                            color: Colors.white70, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            style: const TextStyle(color: Colors.white),
                            cursorColor: Colors.white,
                            decoration: const InputDecoration(
                              hintText: 'Tìm mẹo ghi nhớ...',
                              hintStyle: TextStyle(color: Colors.white70),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (value) =>
                                setState(() => searchQuery = value),
                            onChanged: (value) =>
                                setState(() => searchQuery = value),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ===== Hiển thị danh sách mẹo (lọc theo từ khóa) =====
            const SizedBox(height: 10),
            if (filtered.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 30),
                child: Center(
                  child: Text('Không tìm thấy mẹo phù hợp 😅'),
                ),
              )
            else
              for (final tip in filtered)
                _TipCategoryCard(
                  title: tip['title'],
                  subtitle: tip['subtitle'],
                  colors: List<Color>.from(tip['colors']),
                  sectionKey: tip['key'],
                ),
          ],
        ),
      ),
    );
  }
}

// ================== Card mẹo ==================

class _TipCategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Color> colors;
  final String sectionKey;

  const _TipCategoryCard({
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.sectionKey,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TipsMemoryScreen(onlySectionKey: sectionKey),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: AppTheme.headerGradient(colors[0], colors[1]),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(
          children: [
            const Icon(Icons.tips_and_updates, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
