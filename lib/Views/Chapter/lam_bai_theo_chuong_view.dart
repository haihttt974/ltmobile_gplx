// lib/Views/Chapter/lam_bai_theo_chuong_view.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../Service/api_service.dart';

class LamBaiTheoChuongView extends StatefulWidget {
  final String title;
  final List<dynamic> cauHoiItems;
  final int idHang;
  final bool isXeMay;
  final String mode;
  final int? idChuong;

  const LamBaiTheoChuongView({
    super.key,
    required this.title,
    required this.cauHoiItems,
    required this.idHang,
    required this.isXeMay,
    required this.mode,
    this.idChuong,
  });

  @override
  State<LamBaiTheoChuongView> createState() => _LamBaiTheoChuongViewState();
}

class _LamBaiTheoChuongViewState extends State<LamBaiTheoChuongView> {
  int _currentIndex = 0;
  final Map<int, int> _selectedAnswers = {};
  final Map<int, bool> _revealResult = {};
  String _serverOriginCache = '';

  @override
  void initState() {
    super.initState();
    _loadSavedProgress();
  }

  // ===== LƯU & TẢI TIẾN TRÌNH =====

  String _getStorageKey() {
    if (widget.mode == 'chuong' && widget.idChuong != null) {
      return 'progress_${widget.idHang}_chuong_${widget.idChuong}';
    } else if (widget.mode == 'cau_liet') {
      return 'progress_${widget.idHang}_cau_liet';
    } else {
      return 'progress_${widget.idHang}_toan_bo';
    }
  }

  Future<void> _loadSavedProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getStorageKey();
      final savedData = prefs.getString(key);

      if (savedData != null) {
        final Map<String, dynamic> data = json.decode(savedData);

        setState(() {
          final answers = data['selectedAnswers'] as Map<String, dynamic>?;
          if (answers != null) {
            _selectedAnswers.clear();
            answers.forEach((idStr, thuTu) {
              _selectedAnswers[int.parse(idStr)] = thuTu as int;
            });
          }

          final reveals = data['revealResult'] as Map<String, dynamic>?;
          if (reveals != null) {
            _revealResult.clear();
            reveals.forEach((idStr, value) {
              _revealResult[int.parse(idStr)] = value as bool;
            });
          }
        });
      }
    } catch (e) {
      debugPrint('[LOAD-ERROR] $e');
    }
  }

  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getStorageKey();

      final Map<String, dynamic> data = {
        'selectedAnswers': _selectedAnswers.map((k, v) => MapEntry(k.toString(), v)),
        'revealResult': _revealResult.map((k, v) => MapEntry(k.toString(), v)),
        'lastUpdate': DateTime.now().toIso8601String(),
      };

      await prefs.setString(key, json.encode(data));
    } catch (e) {
      debugPrint('[SAVE-ERROR] $e');
    }
  }

  // ===== CHUẨN HÓA URL ẢNH =====

  String _originFromApiBase() {
    if (_serverOriginCache.isNotEmpty) return _serverOriginCache;
    final base = ApiService.baseUrl;
    _serverOriginCache = base.replaceFirst(RegExp(r'/api/?$'), '');
    return _serverOriginCache;
  }

  String fixImageUrl(String raw) {
    var url = (raw).toString().trim();
    if (url.isEmpty) return '';
    url = url.replaceFirst(RegExp(r'^/assets/'), '/');
    url = url.replaceAll('\\', '/');
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    final p = url.startsWith('/') ? url : '/$url';
    return '${_originFromApiBase()}$p';
  }

  // ===== STYLE / THEME (giống thi_trac_nghiem_view) =====

  Color get _bgPage => const Color(0xFFF8FAFC);

  LinearGradient get _headerGradient => const LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  BoxDecoration get _questionCardBox => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: const Color(0xFFE5E7EB)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.03),
        blurRadius: 8,
        offset: const Offset(0, 4),
      )
    ],
  );

  BoxDecoration get _imageBox => BoxDecoration(
    color: const Color(0xFFF1F5F9),
    borderRadius: BorderRadius.circular(6),
    border: Border.all(color: const Color(0xFFE2E8F0)),
  );

  BoxDecoration _dapAnBox({
    required bool isSelected,
    required bool isCorrect,
    required bool isWrongPicked,
    required bool showResult,
  }) {
    Color borderColor = const Color(0xFFE2E8F0);
    Color bgColor = Colors.white;

    if (!showResult) {
      if (isSelected) {
        borderColor = const Color(0xFF2563EB);
        bgColor = const Color(0xFF2563EB).withOpacity(0.05);
      }
    } else {
      if (isCorrect) {
        borderColor = Colors.green;
        bgColor = Colors.green.withOpacity(0.05);
      } else if (isWrongPicked) {
        borderColor = Colors.red;
        bgColor = Colors.red.withOpacity(0.05);
      }
    }

    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: borderColor, width: 1.5),
    );
  }

  BoxDecoration get _dapAnCircleBox => BoxDecoration(
    shape: BoxShape.circle,
    color: Colors.white,
    border: Border.all(color: Colors.black54, width: 1),
  );

  Color _colorForTab(int index, bool isCurrent) {
    if (isCurrent) return const Color(0xFF2563EB);

    final q = _qAt(index);
    final idCauHoi = q['idCauHoi'] as int?;
    if (idCauHoi == null) return const Color(0xFFE5E7EB);

    final isAnswered = _selectedAnswers.containsKey(idCauHoi);
    if (!isAnswered) return const Color(0xFFE5E7EB);

    // Kiểm tra đúng/sai
    final selectedThuTu = _selectedAnswers[idCauHoi];
    final answers = _answersOf(index);
    final correctAnswer = answers.firstWhere(
          (a) => a['dapAnDung'] == true,
      orElse: () => {},
    );
    final correctThuTu = correctAnswer['thuTu'] as int?;

    if (selectedThuTu == correctThuTu) {
      return const Color(0xFF22C55E); // xanh đậm (đúng)
    } else {
      return const Color(0xFFEF4444); // đỏ (sai)
    }
  }

  // ===== UI BUILD =====

  @override
  Widget build(BuildContext context) {
    final total = widget.cauHoiItems.length;
    if (total == 0) {
      return Scaffold(
        backgroundColor: _bgPage,
        body: const Center(
          child: Text('Không có câu hỏi'),
        ),
      );
    }

    final q = _qAt(_currentIndex);
    final idCauHoi = q['idCauHoi'] as int?;
    final answers = _answersOf(_currentIndex);
    final selectedThuTu = idCauHoi != null ? _selectedAnswers[idCauHoi] : null;
    final showResult = idCauHoi != null ? (_revealResult[idCauHoi] == true) : false;
    final imgUrl = fixImageUrl((q['hinhAnh'] ?? '').toString());
    final cauHienTaiSo = _currentIndex + 1;
    final daLam = _selectedAnswers.length;

    final hasCorrect = answers.any((a) => a['dapAnDung'] == true);
    final correctThuTu = hasCorrect
        ? answers.firstWhere((a) => a['dapAnDung'] == true)['thuTu'] as int
        : null;

    return Scaffold(
      backgroundColor: _bgPage,
      body: Column(
        children: [
          // ===== HEADER XANH =====
          Container(
            padding: const EdgeInsets.only(top: 40, left: 12, right: 16, bottom: 12),
            decoration: BoxDecoration(gradient: _headerGradient),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$daLam/$total',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // ===== DÃY TAB CÂU HỎI =====
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(total, (i) {
                  final isCurrent = i == _currentIndex;
                  final qTab = _qAt(i);
                  final idTab = qTab['idCauHoi'] as int?;
                  final isAnswered = idTab != null && _selectedAnswers.containsKey(idTab);

                  // Kiểm tra đúng/sai cho màu text
                  bool isCorrectAnswer = false;
                  bool isWrongAnswer = false;
                  if (isAnswered) {
                    final selectedTab = _selectedAnswers[idTab];
                    final answersTab = _answersOf(i);
                    final correctTab = answersTab.firstWhere(
                          (a) => a['dapAnDung'] == true,
                      orElse: () => {},
                    );
                    final correctThuTuTab = correctTab['thuTu'] as int?;
                    if (selectedTab == correctThuTuTab) {
                      isCorrectAnswer = true;
                    } else {
                      isWrongAnswer = true;
                    }
                  }

                  return GestureDetector(
                    onTap: () => setState(() => _currentIndex = i),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: _colorForTab(i, isCurrent),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Câu ${i + 1}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: (isCorrectAnswer || isWrongAnswer)
                              ? Colors.white
                              : (isCurrent ? Colors.white : Colors.black87),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // ===== NỘI DUNG CÂU HỎI + ĐÁP ÁN =====
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CARD CÂU HỎI
                  Container(
                    width: double.infinity,
                    decoration: _questionCardBox,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dòng câu hỏi
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.quiz_outlined,
                                color: Color(0xFF0284C7),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Câu $cauHienTaiSo${q['idCauHoi'] != null ? ': ${q['noiDung'] ?? "..."}' : ''}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Badge điểm liệt
                        if (q['cauLiet'] == true)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ĐIỂM LIỆT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        const SizedBox(height: 12),

                        // Ảnh
                        Container(
                          width: double.infinity,
                          height: 180,
                          decoration: _imageBox,
                          alignment: Alignment.center,
                          child: (imgUrl.isNotEmpty)
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              imgUrl,
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: double.infinity,
                              loadingBuilder: (c, child, prog) => prog == null
                                  ? child
                                  : const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2)),
                              errorBuilder: (c, e, s) => _placeholderImg(),
                            ),
                          )
                              : _placeholderImg(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Nút Hiển thị/Ẩn kết quả
                  if (selectedThuTu != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: idCauHoi != null
                                ? () {
                              setState(() {
                                _revealResult[idCauHoi] = !(showResult);
                              });
                              _saveProgress();
                            }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            icon: Icon(showResult ? Icons.visibility_off : Icons.visibility),
                            label: Text(showResult ? 'Ẩn kết quả' : 'Hiển thị kết quả'),
                          ),
                          const SizedBox(width: 12),
                          if (showResult)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: (selectedThuTu == correctThuTu)
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: (selectedThuTu == correctThuTu)
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    (selectedThuTu == correctThuTu)
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color: (selectedThuTu == correctThuTu)
                                        ? Colors.green
                                        : Colors.red,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    (selectedThuTu == correctThuTu)
                                        ? 'Bạn chọn ĐÚNG'
                                        : 'Bạn chọn SAI',
                                    style: TextStyle(
                                      color: (selectedThuTu == correctThuTu)
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                  // LIST ĐÁP ÁN
                  Column(
                    children: answers.map((dapAn) {
                      final thuTu = dapAn['thuTu'] ?? 1;
                      final isSelected = selectedThuTu == thuTu;
                      final isCorrect = dapAn['dapAnDung'] == true;
                      final isWrongPicked = showResult && isSelected && !isCorrect;

                      return GestureDetector(
                        onTap: idCauHoi != null
                            ? () => _onSelectAnswer(idCauHoi, thuTu as int)
                            : null,
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: _dapAnBox(
                            isSelected: isSelected,
                            isCorrect: isCorrect && showResult,
                            isWrongPicked: isWrongPicked,
                            showResult: showResult,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: _dapAnCircleBox,
                                alignment: Alignment.center,
                                child: Text(
                                  '$thuTu',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  dapAn['noiDung']?.toString() ?? 'Đáp án $thuTu',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // ===== THANH ĐIỀU HƯỚNG DƯỚI =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Opacity(
                    opacity: _currentIndex > 0 ? 1 : 0.4,
                    child: IgnorePointer(
                      ignoring: _currentIndex == 0,
                      child: _btnBottomNeutral(
                        text: 'Câu trước',
                        icon: Icons.arrow_back,
                        onTap: () => setState(() => _currentIndex -= 1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Opacity(
                    opacity: _currentIndex < total - 1 ? 1 : 0.4,
                    child: IgnorePointer(
                      ignoring: _currentIndex == total - 1,
                      child: _btnBottomNeutral(
                        text: 'Câu sau',
                        icon: Icons.arrow_forward,
                        onTap: () => setState(() => _currentIndex += 1),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== WIDGETS HELPER =====

  Widget _btnBottomNeutral({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.black87),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImg() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_outlined, color: Color(0xFF94A3B8), size: 32),
        SizedBox(height: 8),
        Text(
          'Không có hình minh hoạ',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  // ===== DATA HELPERS =====

  Map<String, dynamic> _qAt(int index) {
    final raw = widget.cauHoiItems[index];
    if (raw is Map<String, dynamic>) return raw;
    return Map<String, dynamic>.from(raw as Map);
  }

  List<Map<String, dynamic>> _answersOf(int index) {
    final q = _qAt(index);
    final list = q['dapAn'] as List<dynamic>? ?? [];
    return list
        .map((e) => e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e))
        .toList()
      ..sort((a, b) => (a['thuTu'] ?? 0).compareTo(b['thuTu'] ?? 0));
  }

  void _onSelectAnswer(int idCauHoi, int thuTu) {
    setState(() {
      _selectedAnswers[idCauHoi] = thuTu;
    });
    _saveProgress();
  }
}