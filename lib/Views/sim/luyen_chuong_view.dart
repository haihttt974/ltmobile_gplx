import 'package:flutter/material.dart';
import '../../Service/sim_api.dart';
import '../../Models/chuong_mp.dart';
import 'exam_runner_view.dart';

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
