import 'package:flutter/material.dart';

class ResultCard extends StatelessWidget {
  final int soCau;
  final int tongDiem;
  final bool dat;
  final VoidCallback onLamLai;
  final VoidCallback onXemChiTiet;
  const ResultCard({
    super.key,
    required this.soCau,
    required this.tongDiem,
    required this.dat,
    required this.onLamLai,
    required this.onXemChiTiet,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = dat ? Colors.green.shade50 : Colors.red.shade50;
    final fg = dat ? Colors.green.shade700 : Colors.red.shade700;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dat ? 'ĐẠT' : 'CHƯA ĐẠT', style: theme.textTheme.titleLarge!.copyWith(color: fg, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('Câu đã làm: $soCau   |   Điểm: $tongDiem/50', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: onLamLai, child: const Text('Làm lại'))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(onPressed: onXemChiTiet, child: const Text('Xem đáp án'))),
          ])
        ],
      ),
    );
  }
}
