import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doan/Repository/bien_bao_repository.dart';
import 'package:doan/Models/bien_bao_model.dart';
import 'package:doan/Styles/app_colors.dart';
import 'bien_bao_detail_view.dart';

class BienBaoListView extends StatefulWidget {
  const BienBaoListView({super.key});

  @override
  State<BienBaoListView> createState() => _BienBaoListViewState();
}

class _BienBaoListViewState extends State<BienBaoListView> {
  final BienBaoRepository _repo = BienBaoRepository();
  List<BienBaoModel> _items = [];
  bool _loading = true;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('user_id') ?? 0;
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final data = await _repo.getAllBienBao(userId: _userId ?? 0);
      if (!mounted) return;
      setState(() {
        _items = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi tải biển báo: $e')));
    }
  }

  Color _borderColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'đã nhớ':
        return Colors.greenAccent;
      case 'chưa nhớ':
        return Colors.redAccent;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: const Text('Ôn tập biển báo'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (ctx, i) {
          final item = _items[i];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BienBaoDetailView(
                    bienBaoId: item.idBienBao,
                    currentIndex: i,
                    allIds: _items.map((e) => e.idBienBao).toList(),
                  ),
                ),
              ).then((_) => _fetch());
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _borderColor(item.danhGia), width: 2),
              ),
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.hinhAnh,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image, color: Colors.white54),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
