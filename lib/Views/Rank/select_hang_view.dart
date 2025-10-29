import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/hang_model.dart';
import '../../Repository/hang_repository.dart';
import '../../Styles/app_colors.dart';
import '../../Styles/text_styles.dart';

class SelectHangView extends StatefulWidget {
  const SelectHangView({super.key});

  @override
  State<SelectHangView> createState() => _SelectHangViewState();
}

class _SelectHangViewState extends State<SelectHangView> {
  final HangRepository _repository = HangRepository();
  int? selectedHangId;
  String? selectedHangName;
  List<HangModel> hangs = [];

  @override
  void initState() {
    super.initState();
    _loadSelectedHang();
    _loadHangs();
  }

  /// 📦 Lấy hạng đã lưu trước đó
  Future<void> _loadSelectedHang() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedHangId = prefs.getInt('selected_hang_id');
      selectedHangName = prefs.getString('selected_hang_name');
    });
  }

  /// 🔄 Lấy danh sách hạng từ API
  Future<void> _loadHangs() async {
    final list = await _repository.getAllHangs();
    setState(() => hangs = list);
  }

  /// 💾 Khi chọn hạng
  Future<void> _saveSelectedHang(HangModel hang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_hang_id', hang.idHang);
    await prefs.setString('selected_hang_name', hang.tenDayDu);

    setState(() {
      selectedHangId = hang.idHang;
      selectedHangName = hang.tenDayDu;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Đã chọn hạng: ${hang.tenDayDu}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: const Text('Chọn hạng GPLX', style: AppTextStyles.title),
      ),
      body: hangs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: hangs.length,
        itemBuilder: (context, index) {
          final hang = hangs[index];
          final isSelected = hang.idHang == selectedHangId;

          return GestureDetector(
            onTap: () => _saveSelectedHang(hang), // 🎯 Tick khi chọn
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.cardSelected
                    : AppColors.cardNormal,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey.shade800,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(hang.tenDayDu,
                            style: AppTextStyles.heading),
                        const SizedBox(height: 6),
                        Text(
                          hang.moTa,
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_off,
                    color: isSelected ? Colors.lightBlue : Colors.grey,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
