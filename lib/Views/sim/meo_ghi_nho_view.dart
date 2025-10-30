import 'package:flutter/material.dart';

class MeoGhiNhoView extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const MeoGhiNhoView({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mẹo ghi nhớ')),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final m = items[i];
          final imgUrl = m['urlAnhMeo'] ?? m['UrlAnhMeo'];
          final title = m['tieuDe'] ?? m['TieuDe'];

          return GestureDetector(
            onTap: () {
              // Khi bấm vào hình -> mở ảnh phóng to
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _XemAnhPhanManHinh(imageUrl: imgUrl, title: title),
                ),
              );
            },
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Ink.image(
                image: NetworkImage(imgUrl),
                fit: BoxFit.cover,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      title,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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

// ============================
// Trang hiển thị ảnh phóng to
// ============================
class _XemAnhPhanManHinh extends StatelessWidget {
  final String imageUrl;
  final String title;

  const _XemAnhPhanManHinh({
    Key? key,
    required this.imageUrl,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true, // cho phép kéo
          minScale: 0.8,
          maxScale: 5.0,
          child: Image.network(imageUrl, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
