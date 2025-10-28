import 'package:flutter/material.dart';
import '../Styles/app_theme.dart';

enum NoteType { info, warn, danger }

class NoteBox extends StatelessWidget {
  final String text;
  final NoteType type;
  final IconData? icon;

  const NoteBox({
    super.key,
    required this.text,
    this.type = NoteType.info,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final (Color bg, IconData i) = switch (type) {
      NoteType.info => (const Color(0xFFFFF7E6), Icons.lightbulb),
      NoteType.warn => (const Color(0xFFFFEFEF), Icons.warning_amber),
      NoteType.danger => (const Color(0xFFFFE8E8), Icons.report),
    };
    return Container(
      decoration: AppTheme.infoBox(bg),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? i, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
