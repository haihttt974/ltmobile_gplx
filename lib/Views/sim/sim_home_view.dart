import 'package:flutter/material.dart';
import '../../Service/sim_api.dart';
import '../../Models/bo_de_mp.dart';
import '../../Models/tinh_huong.dart';
import '../../Models/chuong_mp.dart';
import 'exam_runner_view.dart';
import '../../Components/primary_button.dart';

class SimHomeView extends StatefulWidget {
  final SimApi api;
  const SimHomeView({super.key, required this.api});

  @override
  State<SimHomeView> createState() => _SimHomeViewState();
}

class _SimHomeViewState extends State<SimHomeView> {
  late final SimApi api = widget.api;
  Future<List<BoDeMp>>? _boDe;

  @override
  void initState() {
    super.initState();
    _boDe = api.listBoDe();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget item(String title, String sub, IconData icon, VoidCallback onTap, {Widget? trailing}) {
      return Card(
        child: ListTile(
          leading: CircleAvatar(child: Icon(icon)),
          title: Text(title, style: theme.textTheme.titleMedium),
          subtitle: Text(sub),
          trailing: trailing ?? const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mô phỏng lái xe')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Đề thi thử theo bộ đề
          FutureBuilder(
            future: _boDe,
            builder: (_, snap) {
              if (!snap.hasData) return const Card(child: ListTile(title: Text('Đang tải bộ đề...')));
              final data = snap.data!;
              return Card(
                child: ExpansionTile(
                  leading: const CircleAvatar(child: Icon(Icons.library_books)),
                  title: const Text('Đề thi thử theo bộ đề'),
                  subtitle: Text('Có ${data.length} bộ đề'),
                  children: data.map((b) => ListTile(
                    title: Text(b.ten),
                    subtitle: Text('${b.soTinhHuong} tình huống'),
                    trailing: const Icon(Icons.play_arrow),
                    onTap: () async {
                      final th = await api.getBoDe(b.id);
                      if (!mounted) return;
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => ExamRunnerView(
                            mode: ExamMode.boDe, api: api, idBoDe: b.id, tinhHuongs: th, title: b.ten),
                      ));
                    },
                  )).toList(),
                ),
              );
            },
          ),

          // Ôn đề ngẫu nhiên
          item('Ôn đề ngẫu nhiên', 'Thi 10 tình huống ngẫu nhiên (không lưu lịch sử).',
              Icons.shuffle, () async {
                final th = await api.randomSet(soTinhHuong: 10);
                if (!mounted) return;
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ExamRunnerView(mode: ExamMode.random, api: api, tinhHuongs: th, title: 'Ôn đề ngẫu nhiên'),
                ));
              }),

          // Liệt kê câu hay sai (0đ)
          item('Liệt kê câu hay sai (0đ)', 'Các câu bạn ấn sai (điểm 0) nhiều nhất.',
              Icons.close_rounded, () async {
                final list = await api.cauHaySai();
                if (!mounted) return;
                Navigator.push(context, MaterialPageRoute(builder: (_) => CauHaySaiView(api: api, items: list)));
              }),

          // Liệt kê câu bị điểm thấp (1-3)
          item('Liệt kê câu bị điểm thấp (1-3)', 'Các câu 1-3 điểm lặp lại nhiều.',
              Icons.warning_amber, () async {
                final list = await api.cauDiemThap();
                if (!mounted) return;
                Navigator.push(context, MaterialPageRoute(builder: (_) => CauDiemThapView(api: api, items: list)));
              }),

          // Lưu câu khó
          item('Lưu câu khó', 'Các tình huống đã đánh dấu khó để ôn lại.', Icons.bookmark_added, () async {
            final list = await api.listKho();
            if (!mounted) return;
            Navigator.push(context, MaterialPageRoute(builder: (_) => CauKhoView(api: api, ds: list)));
          }),

          // Luyện tập từng chương
          item('Luyện tập từng chương', 'Học theo từng chủ đề/chương.', Icons.menu_book, () async {
            final chuong = await api.listChuong();
            if (!mounted) return;
            Navigator.push(context, MaterialPageRoute(builder: (_) => LuyenChuongView(api: api, chuong: chuong)));
          }),

          // Mẹo ghi nhớ
          item('Mẹo ghi nhớ', 'Ảnh mẹo theo chương.', Icons.lightbulb, () async {
            final meo = await api.meo();
            if (!mounted) return;
            Navigator.push(context, MaterialPageRoute(builder: (_) => MeoGhiNhoView(items: meo)));
          }),
        ],
      ),
    );
  }
}

/* ====== các màn con bên dưới ====== */

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
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${m['soLan0'] ?? m['SoLan0']}')),
              title: Text(m['tieuDe'] ?? m['TieuDe']),
              subtitle: Text('Id #${m['idTinhHuong'] ?? m['IdTinhHuong']}'),
              trailing: IconButton(
                icon: const Icon(Icons.play_circle),
                onPressed: () async {
                  // mở 1 tình huống để ôn lại
                  final th = await api.tinhHuongTheoChuong(-1); // placeholder không dùng
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

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
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${m['soLan'] ?? m['SoLan']}')),
              title: Text(m['tieuDe'] ?? m['TieuDe']),
              subtitle: Text('Id #${m['idTinhHuong'] ?? m['IdTinhHuong']}'),
            ),
          );
        },
      ),
    );
  }
}

class CauKhoView extends StatelessWidget {
  final SimApi api;
  final List<TinhHuong> ds;
  const CauKhoView({super.key, required this.api, required this.ds});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Câu khó đã lưu')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemCount: ds.length,
        itemBuilder: (_, i) {
          final th = ds[i];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.flag),
              title: Text(th.tieuDe),
              subtitle: Text('Chương ${th.idChuong ?? '-'}'),
              trailing: Switch(
                value: th.kho ?? true,
                onChanged: (v) async {
                  await api.toggleKho(th.id, v);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật')));
                },
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ExamRunnerView(
                      mode: ExamMode.kho, api: api, tinhHuongs: [th], title: 'Ôn câu khó'),
                ));
              },
            ),
          );
        },
      ),
    );
  }
}

class LuyenChuongView extends StatelessWidget {
  final SimApi api;
  final List<ChuongMp> chuong;
  const LuyenChuongView({super.key, required this.api, required this.chuong});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Luyện tập từng chương')),
      body: ListView.builder(
        itemCount: chuong.length,
        itemBuilder: (_, i) {
          final c = chuong[i];
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${c.thuTu}')),
              title: Text(c.ten),
              onTap: () async {
                final ds = await api.tinhHuongTheoChuong(c.id);
                if (!context.mounted) return;
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ExamRunnerView(
                      mode: ExamMode.random, api: api, tinhHuongs: ds, title: c.ten),
                ));
              },
            ),
          );
        },
      ),
    );
  }
}

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
