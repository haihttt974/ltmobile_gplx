import 'package:flutter/material.dart';
import 'package:doan/Repository/bien_bao_repository.dart';
import 'package:doan/Models/bien_bao_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doan/Styles/app_colors.dart';
import 'package:flip_card/flip_card.dart';

class BienBaoDetailView extends StatefulWidget {
  final int bienBaoId;
  final int? currentIndex; // index trong danh sách (để next/prev)
  final List<int>? allIds; // danh sách id toàn bộ biển báo

  const BienBaoDetailView({
    super.key,
    required this.bienBaoId,
    this.currentIndex,
    this.allIds,
  });

  @override
  State<BienBaoDetailView> createState() => _BienBaoDetailViewState();
}

class _BienBaoDetailViewState extends State<BienBaoDetailView> {
  final BienBaoRepository _repo = BienBaoRepository();
  BienBaoDetailModel? _detail;
  bool _loading = true;
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  String? _selectedStatus; // “Đã nhớ” / “Chưa nhớ”

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => _loading = true);
    try {
      final data = await _repo.getBienBaoDetail(widget.bienBaoId);
      if (!mounted) return;
      setState(() {
        _detail = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi tải chi tiết: $e')));
    }
  }

  Future<void> _update(String danhGia) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id') ?? 0;

    try {
      await _repo.updateTrangThai(widget.bienBaoId, userId, danhGia);
      if (!mounted) return;
      setState(() => _selectedStatus = danhGia);
    } catch (e) {
      // nếu bạn vẫn muốn biết lỗi, chỉ log ra console thôi
      print('Lỗi lưu trạng thái flashcard: $e');
    }
  }

  void _goNext() {
    if (widget.allIds != null &&
        widget.currentIndex != null &&
        widget.currentIndex! < widget.allIds!.length - 1) {
      final nextId = widget.allIds![widget.currentIndex! + 1];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BienBaoDetailView(
            bienBaoId: nextId,
            currentIndex: widget.currentIndex! + 1,
            allIds: widget.allIds,
          ),
        ),
      );
    }
  }

  void _goPrevious() {
    if (widget.allIds != null &&
        widget.currentIndex != null &&
        widget.currentIndex! > 0) {
      final prevId = widget.allIds![widget.currentIndex! - 1];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BienBaoDetailView(
            bienBaoId: prevId,
            currentIndex: widget.currentIndex! - 1,
            allIds: widget.allIds,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
          child: Text('Không có dữ liệu',
              style: TextStyle(color: Colors.white)))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // PHẦN FLIP CARD
            Expanded(
              child: FlipCard(
                key: cardKey,
                flipOnTouch: true,
                front: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Image.network(
                      _detail!.hinhAnh,
                      width: size.width * 0.8, // To hơn
                      height: size.height * 0.6,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                back: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _detail!.tenBienBao,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _detail!.yNghia,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 18, // chữ to hơn
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // PHẦN NÚT
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _navButton(Icons.arrow_back_ios, _goPrevious),
                _statusButton("Chưa nhớ", Colors.redAccent),
                _statusButton("Đã nhớ", Colors.greenAccent),
                _navButton(Icons.arrow_forward_ios, _goNext),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusButton(String text, Color color) {
    final bool selected = _selectedStatus == text;

    return ElevatedButton(
      onPressed: () => _update(text),
      style: ElevatedButton.styleFrom(
        elevation: selected ? 4 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        backgroundColor: selected ? color : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color, width: 2),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: selected ? Colors.white : color,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _navButton(IconData icon, VoidCallback onTap) {
    return Ink(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white30, width: 1.5),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white70),
        onPressed: onTap,
      ),
    );
  }
}
