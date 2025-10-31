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

    Widget item({
      required String title,
      required String sub,
      required IconData icon,
      required VoidCallback onTap,
      required Color color,
      required Color iconBgColor,
    }) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [iconBgColor, iconBgColor.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: iconBgColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sub,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: color, size: 18),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Mô phỏng lái xe', style: TextStyle(fontWeight: FontWeight.bold)),
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
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.directions_car, color: Colors.white, size: 40),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Học lái xe',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Luyện tập và thi thử',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Đề thi thử theo bộ đề
          FutureBuilder<List<BoDeMp>>(
            future: _boDe,
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
              if (snap.hasError) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text('Lỗi tải bộ đề: ${snap.error}'),
                );
              }
              final data = snap.data ?? [];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[50]!, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    leading: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.library_books, color: Colors.white, size: 28),
                    ),
                    title: const Text(
                      'Đề thi thử theo bộ đề',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Có ${data.length} bộ đề'),
                    children: data.map((b) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(b.ten, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('${b.soTinhHuong} tình huống'),
                        trailing: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
                        ),
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
                      ),
                    )).toList(),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 8),
          const Text(
            '🎯 Luyện tập',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),

          // Ôn đề ngẫu nhiên
          item(
            title: 'Ôn đề ngẫu nhiên',
            sub: 'Thi 10 tình huống ngẫu nhiên',
            icon: Icons.shuffle,
            color: const Color(0xFFf093fb),
            iconBgColor: const Color(0xFFf093fb),
            onTap: () async {
              final th = await api.randomSet(soTinhHuong: 10);
              if (!mounted) return;
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => ExamRunnerView(
                    mode: ExamMode.random, api: api, tinhHuongs: th, title: 'Ôn đề ngẫu nhiên'),
              ));
            },
          ),

          // Luyện tập từng chương
          item(
            title: 'Luyện tập từng chương',
            sub: 'Học theo từng chủ đề/chương',
            icon: Icons.menu_book,
            color: const Color(0xFF4facfe),
            iconBgColor: const Color(0xFF00f2fe),
            onTap: () async {
              final chuong = await api.listChuong();
              if (!mounted) return;
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => LuyenChuongView(api: api, chuong: chuong),
              ));
            },
          ),

          const SizedBox(height: 8),
          const Text(
            '📊 Phân tích & Ôn tập',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),

          // Liệt kê câu hay sai (0đ)
          item(
            title: 'Câu hay sai (0đ)',
            sub: 'Các câu bạn ấn sai nhiều nhất',
            icon: Icons.close_rounded,
            color: const Color(0xFFfa709a),
            iconBgColor: const Color(0xFFfee140),
            onTap: () async {
              final list = await api.cauHaySai();
              if (!mounted) return;
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => CauHaySaiView(api: api, items: list),
              ));
            },
          ),

          // Liệt kê câu bị điểm thấp (1-3)
          item(
            title: 'Câu bị điểm thấp (1-3)',
            sub: 'Các câu 1-3 điểm lặp lại nhiều',
            icon: Icons.warning_amber,
            color: const Color(0xFFffecd2),
            iconBgColor: const Color(0xFFfcb69f),
            onTap: () async {
              final list = await api.cauDiemThap();
              if (!mounted) return;
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => CauDiemThapView(api: api, items: list),
              ));
            },
          ),

          // Lưu câu khó
          item(
            title: 'Lưu câu khó',
            sub: 'Các tình huống đã đánh dấu khó',
            icon: Icons.bookmark_added,
            color: const Color(0xFFa8edea),
            iconBgColor: const Color(0xFFfed6e3),
            onTap: () async {
              final list = await api.listKho();
              if (!mounted) return;
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => CauKhoView(api: api, ds: list),
              ));
            },
          ),

          const SizedBox(height: 8),
          const Text(
            '💡 Mẹo & Hướng dẫn',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),

          // Mẹo ghi nhớ
          item(
            title: 'Mẹo ghi nhớ',
            sub: 'Ảnh mẹo theo chương',
            icon: Icons.lightbulb,
            color: const Color(0xFFffeaa7),
            iconBgColor: const Color(0xFFfdcb6e),
            onTap: () async {
              final meo = await api.meo();
              if (!mounted) return;
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => MeoGhiNhoView(items: meo),
              ));
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}