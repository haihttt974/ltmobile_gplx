import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/bo_de_tn_model.dart';
import '../../Repository/bo_de_tn_repository.dart';
import '../../Styles/app_colors.dart';
import '../../Styles/text_styles.dart';

import '../../Utils/result_prefs.dart';
import 'thi_trac_nghiem_view.dart';

class SelectBoDeTnView extends StatefulWidget {
  const SelectBoDeTnView({super.key});

  @override
  State<SelectBoDeTnView> createState() => _SelectBoDeTnViewState();
}

class _SelectBoDeTnViewState extends State<SelectBoDeTnView> {
  final BoDeTnRepository _repository = BoDeTnRepository();
  List<BoDeTnModel> _boDeList = [];
  String? _hangName;

  // lưu kết quả theo từng bộ đề
  final Map<int, LastExamResult> _lastByExam = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _hangName = prefs.getString('selected_hang_name') ?? '';
    try {
      final data = await _repository.getBoDeTheoHang();
      _boDeList = data;

      // load result cho từng bộ đề
      for (final b in _boDeList) {
        final r = await ResultPrefs.loadForExam(b.idBoDe);
        if (r != null) _lastByExam[b.idBoDe] = r;
      }
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi tải bộ đề: $e")),
        );
      }
    }
  }

  Future<void> _refreshOne(int boDeId) async {
    final r = await ResultPrefs.loadForExam(boDeId);
    if (r != null) {
      _lastByExam[boDeId] = r;
    } else {
      _lastByExam.remove(boDeId);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: Text('Đề thi ${_hangName ?? ""}', style: AppTextStyles.titleLarge),
      ),
      body: _boDeList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _boDeList.length,
        itemBuilder: (context, index) {
          final boDe = _boDeList[index];
          final r = _lastByExam[boDe.idBoDe];

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                radius: 26,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              title: Text(
                boDe.tenBoDe,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${boDe.soCauHoi} câu hỏi • ${boDe.thoiGian} phút',
                style: const TextStyle(color: Colors.black54),
              ),

              // ✅ Trailing: kết quả gần nhất của chính bộ đề này
              trailing: _buildTrailingResult(r),

              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ThiTracNghiemView(
                      boDe: boDe,
                      maHang: _hangName ?? '',
                    ),
                  ),
                );
                // quay về thì refresh chỉ bộ đề vừa làm
                await _refreshOne(boDe.idBoDe);
              },
            ),
          );
        },
      ),
    );
  }

  // Hiển thị icon ✓ số đúng & ✗ số sai (nhẹ như ảnh bạn gửi)
  Widget _buildTrailingResult(LastExamResult? r) {
    final bool has = r != null;
    final Color faint = Colors.black.withOpacity(0.28);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle,
            color: has ? const Color(0xFF22C55E) : faint, size: 22),
        const SizedBox(width: 6),
        Text(
          '${has ? r!.dung : 0}',
          style: TextStyle(
            fontSize: 16,
            color: has ? Colors.black87 : faint,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 16),
        Icon(Icons.cancel, color: has ? const Color(0xFFEF4444) : faint, size: 22),
        const SizedBox(width: 6),
        Text(
          '${has ? r!.sai : 0}',
          style: TextStyle(
            fontSize: 16,
            color: has ? Colors.black87 : faint,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.chevron_right, color: Colors.grey),
      ],
    );
  }
}
