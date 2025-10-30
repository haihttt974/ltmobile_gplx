import 'package:flutter/material.dart';
import '../../Models/tinh_huong.dart';
import '../../Service/sim_api.dart';
import '../../Components/tinh_huong_player.dart';
import '../../Components/result_card.dart';

enum ExamMode { boDe, random, kho }

class ExamRunnerView extends StatefulWidget {
  final ExamMode mode;
  final SimApi api;
  final int? idBoDe;                  // chỉ dùng khi mode=boDe
  final List<TinhHuong> tinhHuongs;   // danh sách đã load sẵn
  final String title;
  const ExamRunnerView({super.key, required this.mode, required this.api, required this.tinhHuongs, required this.title, this.idBoDe});

  @override
  State<ExamRunnerView> createState() => _ExamRunnerViewState();
}

class _ExamRunnerViewState extends State<ExamRunnerView> {
  int idx = 0;
  final Map<int, double> clicks = {}; // IdTinhHuong -> thời điểm nhấn (giây)
  int? tongDiem;
  bool? dat;
  List<Map<String, dynamic>>? chiTiet;

  Future<void> _submit() async {
    print('🔄 Bắt đầu nộp bài...');
    print('📝 Số câu đã click: ${clicks.length}');
    print('📋 Chi tiết clicks: $clicks');

    final payload = clicks.entries
        .map((e) => {'idTinhHuong': e.key, 'thoiDiemNhan': e.value})
        .toList();

    print('📤 Payload gửi lên: $payload');

    final mode = widget.mode;
    final api = widget.api;

    try {
      print('⏳ Đang gọi API...');

      var kq = switch (mode) {
        ExamMode.boDe   => await api.nopBaiBoDe(widget.idBoDe!, payload),
        ExamMode.random => await api.randomSubmit(payload),
        ExamMode.kho    => await api.randomKhoSubmit(payload),
      };

      print('✅ Nhận kết quả: $kq');
      print('📊 Tổng điểm: ${kq.tongDiem}');
      print('🎯 Đạt: ${kq.dat}');

      setState(() {
        tongDiem = kq.tongDiem;
        dat = kq.dat;
        chiTiet = kq.chiTiet;
      });

      print('✅ Đã cập nhật UI');
    } catch (e, stackTrace) {
      print('❌ LỖI KHI NỘP BÀI: $e');
      print('Stack trace: $stackTrace');

      // Hiển thị lỗi cho user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi nộp bài: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final th = widget.tinhHuongs[idx];
    final total = widget.tinhHuongs.length;
    final done = clicks.length;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            if (tongDiem != null)
              ResultCard(
                soCau: done,
                tongDiem: tongDiem!,
                dat: dat ?? false,
                onLamLai: () {
                  setState(() { tongDiem = null; dat = null; chiTiet = null; clicks.clear(); idx = 0; });
                },
                onXemChiTiet: () {
                  showModalBottomSheet(context: context, builder: (_) {
                    return ListView(
                      padding: const EdgeInsets.all(12),
                      children: chiTiet!.map((m) {
                        final id = m['idTinhHuong'];
                        final diem = m['diem'];
                        return ListTile(
                          leading: CircleAvatar(child: Text('$diem')),
                          title: Text(widget.tinhHuongs.firstWhere((x) => x.id == id).tieuDe),
                          subtitle: Text('Điểm: $diem'),
                          trailing: Icon(diem == 0 ? Icons.close : Icons.check, color: diem==0?Colors.red:Colors.green),
                        );
                      }).toList(),
                    );
                  });
                },
              ),

            const SizedBox(height: 8),
            Text('Tình huống ${idx + 1}/$total', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),

            TinhHuongPlayer(
              key: ValueKey(th.id),
              url: th.videoUrl,
              onClickAt: (sec) {
                setState(() { clicks[th.id] = sec; });
              },
              bottom: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Nhấn SPACE khi phát hiện nguy hiểm. Đã ghi nhận: ${clicks[th.id]?.toStringAsFixed(2) ?? "--"}s'),
              ),
            ),

            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: OutlinedButton(
                  onPressed: idx>0?(){ setState(() => idx--); }:null,
                  child: const Text('Câu trước'),
                )),
                const SizedBox(width: 12),
                Expanded(child: OutlinedButton(
                  onPressed: idx < total-1 ? (){ setState(() => idx++); } : null,
                  child: const Text('Câu sau'),
                )),
              ],
            ),

            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: clicks.isNotEmpty ? _submit : null,
              icon: const Icon(Icons.assignment_turned_in_rounded),
              label: const Text('Nộp bài'),
            ),
          ],
        ),
      ),
    );
  }
}
