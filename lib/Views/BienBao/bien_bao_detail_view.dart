import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doan/Repository/bien_bao_repository.dart';
import 'package:doan/Models/bien_bao_model.dart';
import 'package:doan/Styles/app_colors.dart';

class BienBaoDetailView extends StatefulWidget {
  final int bienBaoId;

  const BienBaoDetailView({super.key, required this.bienBaoId});

  @override
  State<BienBaoDetailView> createState() => _BienBaoDetailViewState();
}

class _BienBaoDetailViewState extends State<BienBaoDetailView> {
  final BienBaoRepository _repo = BienBaoRepository();

  BienBaoDetailModel? _detail; // nullable, hiển thị sau khi load xong
  bool _loading = true;

  String _selectedStatus = 'chưa nhớ';
  final List<String> _statusOptions = const [
    'chưa nhớ',
    'đang nhớ',
    'đã thuộc',
  ];

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final BienBaoDetailModel data = await _repo.getBienBaoDetail(
        widget.bienBaoId,
      );
      if (!mounted) return;
      setState(() {
        _detail = data; // cùng type -> OK
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi tải chi tiết: $e')));
    }
  }

  Future<void> _saveStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // bạn đã lưu user_id khi login, nếu chưa hãy lưu thêm ở AuthRepository
    final int userId = prefs.getInt('user_id') ?? 0;

    if (userId == 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bạn cần đăng nhập lại')));
      return;
    }

    try {
      await _repo.updateTrangThai(widget.bienBaoId, userId, _selectedStatus);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Đã lưu: $_selectedStatus')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi lưu: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: const Text('Chi tiết biển báo'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _detail == null
          ? const Center(
              child: Text(
                'Không có dữ liệu',
                style: TextStyle(color: Colors.white),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _detail!.hinhAnh,
                      height: 200,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image,
                        color: Colors.white54,
                        size: 64,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _detail!.tenBienBao,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _detail!.yNghia,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Combobox chọn trạng thái
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedStatus,
                      isExpanded: true,
                      dropdownColor: AppColors.cardDark,
                      underline: const SizedBox(),
                      style: const TextStyle(color: Colors.white),
                      items: _statusOptions
                          .map(
                            (s) => DropdownMenuItem<String>(
                              value: s,
                              child: Text(s),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedStatus = v);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveStatus,
                    child: const Text('Lưu trạng thái'),
                  ),
                ],
              ),
            ),
    );
  }
}
