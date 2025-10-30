import 'package:flutter/material.dart';
import '../../Service/sim_api.dart';

class CauDiemThapView extends StatelessWidget {
  final SimApi api;
  final List<Map<String, dynamic>> items;
  const CauDiemThapView({super.key, required this.api, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Câu điểm thấp (1–3)')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final m = items[i];
          final soLan = m['soLan'] ?? m['SoLan'];
          final tieuDe = m['tieuDe'] ?? m['TieuDe'];
          final id = m['idTinhHuong'] ?? m['IdTinhHuong'];
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('$soLan')),
              title: Text(tieuDe ?? ''),
              subtitle: Text('Id #$id'),
            ),
          );
        },
      ),
    );
  }
}
