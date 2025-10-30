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
      backgroundColor: Colors.white, // ✅ Nền trắng
      appBar: AppBar(
        backgroundColor: Colors.white, // ✅ AppBar trắng
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black), // icon màu đen
        title: Text(
          'Đề thi ${_hangName ?? ""}',
          style: const TextStyle(
            color: Colors.black, // ✅ chữ đen
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
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
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(
                radius: 26,
                backgroundColor: Colors.grey.shade200,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.black, // ✅ chữ đen
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              title: Text(
                boDe.tenBoDe,
                style: const TextStyle(
                  color: Colors.black, // ✅ chữ đen
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                '${boDe.soCauHoi} câu hỏi • ${boDe.thoiGian} phút',
                style: const TextStyle(color: Colors.black54),
              ),
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
                await _refreshOne(boDe.idBoDe);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrailingResult(LastExamResult? r) {
    final bool has = r != null;
    final Color faint = Colors.black.withOpacity(0.28);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle,
            color: has ? const Color(0xFF22C55E) : faint, size: 14),
        const SizedBox(width: 6),
        Text(
          '${has ? r!.dung : 0}',
          style: TextStyle(
            fontSize: 16,
            color: has ? Colors.black : faint, // ✅ chữ đen
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 16),
        Icon(Icons.cancel,
            color: has ? const Color(0xFFEF4444) : faint, size: 14),
        const SizedBox(width: 6),
        Text(
          '${has ? r!.sai : 0}',
          style: TextStyle(
            fontSize: 16,
            color: has ? Colors.black : faint, // ✅ chữ đen
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.chevron_right, color: Colors.grey),
      ],
    );
  }
}
