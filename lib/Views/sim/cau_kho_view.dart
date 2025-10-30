import 'package:flutter/material.dart';
import '../../Service/sim_api.dart';
import '../../Models/tinh_huong.dart';
import 'exam_runner_view.dart';

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
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã cập nhật')),
                    );
                  }
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
