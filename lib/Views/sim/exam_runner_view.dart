import 'package:flutter/material.dart';
import '../../Models/tinh_huong.dart';
import '../../Service/sim_api.dart';
import '../../Components/tinh_huong_player.dart';
import '../../Components/result_card.dart';

enum ExamMode { boDe, random, kho }

class ExamRunnerView extends StatefulWidget {
  final ExamMode mode;
  final SimApi api;
  final int? idBoDe;
  final List<TinhHuong> tinhHuongs;
  final String title;
  const ExamRunnerView({super.key, required this.mode, required this.api, required this.tinhHuongs, required this.title, this.idBoDe});

  @override
  State<ExamRunnerView> createState() => _ExamRunnerViewState();
}

class _ExamRunnerViewState extends State<ExamRunnerView> {
  int idx = 0;
  final Map<int, double> clicks = {};
  int? tongDiem;
  bool? dat;
  List<Map<String, dynamic>>? chiTiet;

  Future<void> _submit() async {
    print('📄 Bắt đầu nộp bài...');
    print('📝 Số câu đã click: ${clicks.length}');
    print('📋 Chi tiết clicks: $clicks');

    final payload = clicks.entries
        .map((e) => {
      'IdTinhHuong': e.key,
      'ThoiDiemNhan': e.value
    })
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Lỗi nộp bài: $e')),
              ],
            ),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, size: 18),
                const SizedBox(width: 6),
                Text('$done/$total', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (tongDiem != null)
              ResultCard(
                soCau: done,
                tongDiem: tongDiem!,
                dat: dat ?? false,
                onLamLai: () {
                  setState(() {
                    tongDiem = null;
                    dat = null;
                    chiTiet = null;
                    clicks.clear();
                    idx = 0;
                  });
                },
                onXemChiTiet: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (_) {
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 12),
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.assessment, color: Colors.white),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Chi tiết kết quả',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                children: chiTiet!.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final m = entry.value;
                                  final id = m['idTinhHuong'] ?? m['IdTinhHuong'];
                                  final diem = m['diem'] ?? m['Diem'];

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: diem == 0
                                            ? [Colors.red[50]!, Colors.red[25]!.withOpacity(0.3)]
                                            : diem < 4
                                            ? [Colors.orange[50]!, Colors.orange[25]!.withOpacity(0.3)]
                                            : [Colors.green[50]!, Colors.green[25]!.withOpacity(0.3)],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: diem == 0
                                            ? Colors.red.withOpacity(0.3)
                                            : diem < 4
                                            ? Colors.orange.withOpacity(0.3)
                                            : Colors.green.withOpacity(0.3),
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: diem == 0
                                                ? [Colors.red[400]!, Colors.red[600]!]
                                                : diem < 4
                                                ? [Colors.orange[400]!, Colors.orange[600]!]
                                                : [Colors.green[400]!, Colors.green[600]!],
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '$diem',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        'Câu ${index + 1}: ${widget.tinhHuongs.firstWhere((x) => x.id == id).tieuDe}',
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      subtitle: Text(
                                        'Điểm: $diem',
                                        style: TextStyle(
                                          color: diem == 0
                                              ? Colors.red[700]
                                              : diem < 4
                                              ? Colors.orange[700]
                                              : Colors.green[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      trailing: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: diem == 0
                                              ? Colors.red
                                              : diem < 4
                                              ? Colors.orange
                                              : Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          diem == 0 ? Icons.close : Icons.check,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),

            const SizedBox(height: 16),

            // Progress indicator
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667eea).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.video_library, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Tình huống ${idx + 1} / $total',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (idx + 1) / total,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Đã làm: $done câu',
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                      ),
                      Text(
                        '${((idx + 1) / total * 100).toStringAsFixed(0)}%',
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Video player với status
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TinhHuongPlayer(
                    key: ValueKey(th.id),
                    url: th.videoUrl,
                    onClickAt: (sec) {
                      setState(() { clicks[th.id] = sec; });
                      print('🎯 Clicked at ${sec.toStringAsFixed(2)}s for TinhHuong #${th.id}');
                    },
                    bottom: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: clicks[th.id] != null
                              ? [Colors.green[50]!, Colors.green[100]!]
                              : [Colors.grey[100]!, Colors.grey[200]!],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: clicks[th.id] != null
                              ? Colors.green.withOpacity(0.5)
                              : Colors.grey.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: clicks[th.id] != null ? Colors.green : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              clicks[th.id] != null ? Icons.check_circle : Icons.space_bar,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  clicks[th.id] != null ? 'Đã ghi nhận!' : 'Nhấn SPACE',
                                  style: TextStyle(
                                    color: clicks[th.id] != null ? Colors.green[900] : Colors.grey[700],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  clicks[th.id] != null
                                      ? 'Thời điểm: ${clicks[th.id]!.toStringAsFixed(2)}s'
                                      : 'Nhấn khi phát hiện nguy hiểm',
                                  style: TextStyle(
                                    color: clicks[th.id] != null ? Colors.green[700] : Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Navigation buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: idx > 0
                          ? LinearGradient(
                        colors: [Colors.blue[400]!, Colors.blue[600]!],
                      )
                          : null,
                      color: idx > 0 ? null : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: idx > 0
                          ? [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                          : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: idx > 0 ? () { setState(() => idx--); } : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_back,
                              color: idx > 0 ? Colors.white : Colors.grey[500],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Câu trước',
                              style: TextStyle(
                                color: idx > 0 ? Colors.white : Colors.grey[500],
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: idx < total - 1
                          ? LinearGradient(
                        colors: [Colors.blue[400]!, Colors.blue[600]!],
                      )
                          : null,
                      color: idx < total - 1 ? null : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: idx < total - 1
                          ? [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                          : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: idx < total - 1 ? () { setState(() => idx++); } : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Câu sau',
                              style: TextStyle(
                                color: idx < total - 1 ? Colors.white : Colors.grey[500],
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward,
                              color: idx < total - 1 ? Colors.white : Colors.grey[500],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Submit button
            Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: clicks.isNotEmpty
                    ? const LinearGradient(
                  colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                )
                    : null,
                color: clicks.isEmpty ? Colors.grey[300] : null,
                borderRadius: BorderRadius.circular(14),
                boxShadow: clicks.isNotEmpty
                    ? [
                  BoxShadow(
                    color: const Color(0xFF11998e).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: clicks.isNotEmpty ? _submit : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_turned_in_rounded,
                        color: clicks.isNotEmpty ? Colors.white : Colors.grey[500],
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Nộp bài (${clicks.length}/$total câu)',
                        style: TextStyle(
                          color: clicks.isNotEmpty ? Colors.white : Colors.grey[500],
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}