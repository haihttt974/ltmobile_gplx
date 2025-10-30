import 'package:flutter/material.dart';
import '/../Models/tinh_huong.dart';
import '/../Service/sim_api.dart';

class MeoGhiNhoView extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const MeoGhiNhoView({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mẹo ghi nhớ')),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final m = items[i];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Ink.image(
              image: NetworkImage(m['urlAnhMeo'] ?? m['UrlAnhMeo']),
              fit: BoxFit.cover,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  color: Colors.black54,
                  padding: const EdgeInsets.all(6),
                  child: Text(
                    m['tieuDe'] ?? m['TieuDe'],
                    style: const TextStyle(color: Colors.white),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
