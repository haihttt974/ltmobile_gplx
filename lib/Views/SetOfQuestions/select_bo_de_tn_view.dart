import 'package:flutter/material.dart';
import '../../Models/bo_de_tn_model.dart';
import '../../Repository/bo_de_tn_repository.dart';
import '../../Styles/app_colors.dart';
import '../../Styles/text_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectBoDeTnView extends StatefulWidget {
  const SelectBoDeTnView({super.key});

  @override
  State<SelectBoDeTnView> createState() => _SelectBoDeTnViewState();
}

class _SelectBoDeTnViewState extends State<SelectBoDeTnView> {
  final BoDeTnRepository _repository = BoDeTnRepository();
  List<BoDeTnModel> _boDeList = [];
  String? _hangName;

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
      setState(() => _boDeList = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi tải bộ đề: $e")),
        );
      }
    }
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
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Text('${index + 1}',
                    style: const TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold)),
              ),
              title: Text(
                boDe.tenBoDe,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                  '${boDe.soCauHoi} câu hỏi • ${boDe.thoiGian} phút'),
              trailing:
              const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                // TODO: mở màn thi trắc nghiệm chi tiết
              },
            ),
          );
        },
      ),
    );
  }
}
