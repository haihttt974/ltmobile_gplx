import 'package:flutter/material.dart';
import '../Styles/app_theme.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final String subtitle; // ví dụ: "1 mẹo", "2 mẹo"
  final List<Widget> children;
  final List<Color> colors; // 2 màu để tạo gradient

  const SectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          children: [
            // Header gradient giống hình mẫu
            Container(
              decoration: AppTheme.headerGradient(colors[0], colors[1]),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
                              fontSize: 16,
                            )),
                        const SizedBox(height: 2),
                        Text(subtitle,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            )),
                      ],
                    ),
                  ),
                  const Icon(Icons.expand_more, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Khối nội dung (trắng, bo tròn) – dùng cho mỗi “mẹo”
class TipBlock extends StatelessWidget {
  final String? title;
  final Widget body;

  const TipBlock({super.key, this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.softSurface(context),
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 8),
          ],
          body,
        ],
      ),
    );
  }
}
