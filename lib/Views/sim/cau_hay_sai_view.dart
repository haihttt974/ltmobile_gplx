import 'package:flutter/material.dart';
import '../../Service/sim_api.dart';

class CauHaySaiView extends StatelessWidget {
  final SimApi api;
  final List<Map<String, dynamic>> items;
  const CauHaySaiView({super.key, required this.api, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Câu hay sai (0đ)')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 6),
        itemBuilder: (_, i) {
          final m = items[i];
          final soLan0 = m['soLan0'] ?? m['SoLan0'];
          final tieuDe = m['tieuDe'] ?? m['TieuDe'];
          final id = m['idTinhHuong'] ?? m['IdTinhHuong'];
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('$soLan0')),
              title: Text(tieuDe ?? ''),
              subtitle: Text('Id #$id'),
            ),
          );
        },
      ),
    );
  }
}
