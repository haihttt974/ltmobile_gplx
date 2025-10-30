import 'package:flutter/material.dart';
import '../../Service/sim_api.dart';
import '../../Models/bo_de_mp.dart';
import '../../Models/tinh_huong.dart';
import '../../Models/chuong_mp.dart';
import 'exam_runner_view.dart';
import '../../Components/primary_button.dart';

// các màn con: tách file riêng
import 'cau_hay_sai_view.dart';
import 'cau_diem_thap_view.dart';
import 'cau_kho_view.dart';
import 'luyen_chuong_view.dart';
import 'meo_ghi_nho_view.dart';

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
          FutureBuilder<List<BoDeMp>>(
            future: _boDe,
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Card(child: ListTile(title: Text('Đang tải bộ đề...')));
              }
              if (snap.hasError) {
                return Card(child: ListTile(title: Text('Lỗi tải bộ đề: ${snap.error}')));
              }
              final data = snap.data ?? [];
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
                          mode: ExamMode.boDe,
                          api: api,
                          idBoDe: b.id,
                          tinhHuongs: th,
                          title: b.ten,
                        ),
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
                  builder: (_) => ExamRunnerView(
                      mode: ExamMode.random, api: api, tinhHuongs: th, title: 'Ôn đề ngẫu nhiên'),
                ));
              }),

          // Liệt kê câu hay sai (0đ)
          item('Liệt kê câu hay sai (0đ)', 'Các câu bạn ấn sai (điểm 0) nhiều nhất.',
              Icons.close_rounded, () async {
                final list = await api.cauHaySai();
                if (!mounted) return;
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => CauHaySaiView(api: api, items: list),
                ));
              }),

          // Liệt kê câu bị điểm thấp (1-3)
          item('Liệt kê câu bị điểm thấp (1-3)', 'Các câu 1-3 điểm lặp lại nhiều.',
              Icons.warning_amber, () async {
                final list = await api.cauDiemThap();
                if (!mounted) return;
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => CauDiemThapView(api: api, items: list),
                ));
              }),

          // Lưu câu khó
          item('Lưu câu khó', 'Các tình huống đã đánh dấu khó để ôn lại.',
              Icons.bookmark_added, () async {
                final list = await api.listKho();
                if (!mounted) return;
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => CauKhoView(api: api, ds: list),
                ));
              }),

          // Luyện tập từng chương
          item('Luyện tập từng chương', 'Học theo từng chủ đề/chương.',
              Icons.menu_book, () async {
                final chuong = await api.listChuong();
                if (!mounted) return;
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => LuyenChuongView(api: api, chuong: chuong),
                ));
              }),

          // Mẹo ghi nhớ
          item('Mẹo ghi nhớ', 'Ảnh mẹo theo chương.',
              Icons.lightbulb, () async {
                final meo = await api.meo();
                if (!mounted) return;
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => MeoGhiNhoView(items: meo),
                ));
              }),
        ],
      ),
    );
  }
}
