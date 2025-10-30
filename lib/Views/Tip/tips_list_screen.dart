import 'package:flutter/material.dart';
import '../../Styles/app_theme.dart';
import 'tips_memory_screen.dart';

class TipsListScreen extends StatelessWidget {
  const TipsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
          children: [
            // Header + ô tìm kiếm mẫu (không cần logic)
            Container(
              decoration: AppTheme.headerGradient(
                const Color(0xFFEC6F66),
                const Color(0xFFF3A183),
              ),
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 16),
              child: Column(
                children: [
                  Row(
                    children: const [
                      Icon(Icons.lightbulb, color: Colors.white),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Mẹo ghi nhớ',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Icon(Icons.share_outlined, color: Colors.white),
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
                      children: const [
                        Icon(Icons.search, color: Colors.white70, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tìm mẹo ghi nhớ...',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Counters
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: const [
                  _Counter(value: '12', label: 'Chủ đề'),
                  _Counter(value: '19', label: 'Mẹo hay'),
                  _Counter(value: '0', label: 'Đã lưu'),
                ],
              ),
            ),

            // Danh sách chủ đề
            ..._categories.map(
                  (c) => _GradientTile(
                title: c.title,
                subtitle: c.subtitle,
                colors: c.colors,
                icon: c.icon,
                onTap: () {
                  // ⬇️ Điều hướng trực tiếp, chỉ hiển thị 1 section tương ứng
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TipsMemoryScreen(
                        onlySectionKey: c.sectionKey,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),
            // Footer note
            Container(
              decoration: AppTheme.softSurface(context),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: const [
                  Icon(Icons.emoji_events_outlined),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Học mẹo, thi đỗ dễ! Tổng hợp từ kinh nghiệm học viên đã thi đỗ.',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==== UI helpers =============================================================
class _Counter extends StatelessWidget {
  final String value;
  final String label;
  const _Counter({required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }
}

class _GradientTile extends StatelessWidget {
  final String title, subtitle;
  final List<Color> colors;
  final IconData icon;
  final VoidCallback onTap;

  const _GradientTile({
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            )
          ],
        ),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: Colors.white),
            ),
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
                      style:
                      const TextStyle(color: Colors.white70, fontSize: 12)),
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

// ==== Dữ liệu menu ===========================================================
class _Cat {
  final String sectionKey, title, subtitle;
  final List<Color> colors;
  final IconData icon;
  const _Cat(
      this.sectionKey, this.title, this.subtitle, this.colors, this.icon);
}

// NOTE: sectionKey phải khớp với TipsMemoryScreen._sectionByKey()
const _categories = <_Cat>[
  _Cat('alcohol', 'Nồng độ cồn', '1 mẹo',
      [Color(0xFFEC6F66), Color(0xFFF3A183)], Icons.traffic),
  _Cat('distance', 'Khoảng cách an toàn', '2 mẹo',
      [Color(0xFF56CCF2), Color(0xFF2F80ED)], Icons.timeline),
  _Cat('license', 'Các hạng GPLX', '4 mẹo',
      [Color(0xFF9C27B0), Color(0xFFE91E63)], Icons.fire_truck),
  _Cat('age', 'Hỏi về tuổi', '1 nhóm',
      [Color(0xFF00B09B), Color(0xFF96C93D)], Icons.person),
  _Cat('rules', 'Cao tốc/đường hầm/nơi hạn chế', '1 nhóm',
      [Color(0xFFfbab66), Color(0xFFf7418c)], Icons.block),
  _Cat('priority', 'Nhất chớm – Nhì ưu – Tam – Tứ', '1 nhóm',
      [Color(0xFF36D1DC), Color(0xFF5B86E5)], Icons.priority_high),
  _Cat('signs', 'Biển báo & nhóm biển', '2 mẹo',
      [Color(0xFFf7971e), Color(0xFFffd200)], Icons.traffic_outlined),
  _Cat('speed', 'Tốc độ tối đa', '4 nhóm',
      [Color(0xFFee0979), Color(0xFFff6a00)], Icons.speed),
  _Cat('concept', 'Khái niệm & quy tắc nhanh', '1 nhóm',
      [Color(0xFF12c2e9), Color(0xFFc471ed)], Icons.rule),
  _Cat('transport', 'Nghiệp vụ vận tải', '1 nhóm',
      [Color(0xFF43cea2), Color(0x185a9d)], Icons.local_shipping_outlined),
  _Cat('technic', 'Kỹ thuật lái xe', '1 nhóm',
      [Color(0xFF8E2DE2), Color(0xFF4A00E0)], Icons.handyman),
  _Cat('mechanic', 'Cấu tạo & sửa chữa', '1 nhóm',
      [Color(0xFF00c6ff), Color(0xFF0072ff)], Icons.build),
];
