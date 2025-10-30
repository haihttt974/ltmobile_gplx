import 'dart:async';
import 'package:flutter/material.dart';
import '../../Models/bo_de_tn_model.dart';
import '../../Models/cau_hoi_model.dart';
import '../../Models/dap_an_model.dart';
import '../../Models/exam_result_model.dart';
import '../../Repository/thi_tn_repository.dart';
import '../../Utils/exam_rules.dart';
import '../../Utils/image_url.dart';
import '../../Utils/result_prefs.dart';

class ThiTracNghiemView extends StatefulWidget {
  final BoDeTnModel boDe;
  final String maHang; // ví dụ: "A1;

  const ThiTracNghiemView({
    super.key,
    required this.boDe,
    required this.maHang,
  });

  @override
  State<ThiTracNghiemView> createState() => _ThiTracNghiemViewState();
}
enum QState { unanswered, answered, correct, wrong }
class _ThiTracNghiemViewState extends State<ThiTracNghiemView> {
  final ThiTnRepository _repo = ThiTnRepository();
  List<CauHoiModel> _dsCauHoi = [];
  late List<QState> _qStates;
  bool _loading = true;

  // map lưu đáp án người dùng chọn: { idCauHoi : idDapAn }
  final Map<int, int> _luaChonNguoiDung = {};

  // câu hiện tại đang xem (index trong _dsCauHoi)
  int _currentIndex = 0;

  // trạng thái nộp bài
  bool _daNopBai = false;
  ExamResult? _ketQua;

  // đếm ngược
  Timer? _timer;
  late int _secondsLeft;

  @override
  void initState() {
    super.initState();
    _taiCauHoi();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _taiCauHoi() async {
    try {
      final data = await _repo.getCauHoiTheoBoDe(widget.boDe.idBoDe);

      final int thoiGianPhut = widget.boDe.thoiGian ?? 20;
      _secondsLeft = thoiGianPhut * 60;

      setState(() {
        _dsCauHoi = data;
        _qStates = List<QState>.filled(_dsCauHoi.length, QState.unanswered);
        _loading = false;
      });

      _startTimer();
    } catch (e) {
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Lỗi tải câu hỏi: $e')));
      }
    }
  }



  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) {
        t.cancel();
        _nopBaiThi(auto: true);
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  String _formatTime(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  // chọn đáp án
  void _chonDapAn(CauHoiModel cauHoi, DapAnModel dapAn) {
    if (_daNopBai) return;
    setState(() {
      _luaChonNguoiDung[cauHoi.idCauHoi] = dapAn.idDapAn;
      if (!_daNopBai) {
        _qStates[_currentIndex] = QState.answered;
      }
      setState(() {});
    });
  }

  // chuyển câu tiếp / trước
  void _chuyenCauKeTiep() {
    if (_currentIndex < _dsCauHoi.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _chuyenCauTruoc() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  // xác nhận thoát khi bấm back trước khi nộp
  void _xacNhanThoat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Kết thúc bài thi?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'Bạn có muốn kết thúc bài thi và chấm điểm bài thi không?',
          style: TextStyle(fontSize: 15),
        ),
        actionsPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Bỏ qua',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _nopBaiThi();
            },
            child: const Text(
              'Kết thúc',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // nộp bài
  Future<void> _nopBaiThi({bool auto = false}) async {
    if (_daNopBai) return;

    final result = chamBai(
      maHang: widget.maHang,
      dsCauHoi: _dsCauHoi,
      luaChonNguoiDung: _luaChonNguoiDung,
    );

    // đánh dấu đúng/sai cho từng tab
    for (var i = 0; i < _dsCauHoi.length; i++) {
      final q = _dsCauHoi[i];
      final picked = _luaChonNguoiDung[q.idCauHoi];
      DapAnModel? _findCorrect(List<DapAnModel> list) {
        for (final d in list) {
          if (d.dapAnDung == true) return d;
        }
        return null;
      }
      final DapAnModel? correct = _findCorrect(q.dapAns);
      if (correct != null && picked == correct.idDapAn) {
        _qStates[i] = QState.correct;
      } else {
        _qStates[i] = QState.wrong;
      }
    }

    setState(() {
      _daNopBai = true;
      _ketQua = result;
    });

    // Lưu kết quả gần nhất CHO BỘ ĐỀ HIỆN TẠI + global (optional)
    final last = LastExamResult(
      boDeId: widget.boDe.idBoDe,
      boDeName: widget.boDe.tenBoDe,
      maHang: result.maHang,
      tong: result.tongCau,
      dung: result.soCauDung,
      sai: result.soCauSai,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    await ResultPrefs.saveForExam(last);
    await ResultPrefs.saveGlobal(last); // không bắt buộc

    _showKetQuaDialog(result, auto: auto);
  }

  void _showKetQuaDialog(ExamResult result, {bool auto = false}) {
    showDialog(
      context: context,
      barrierDismissible: !auto,
      builder: (_) => AlertDialog(
        title: Text(
          result.dat ? 'KẾT QUẢ: ĐẠT ✅' : 'KẾT QUẢ: KHÔNG ĐẠT ❌',
          style: TextStyle(
            color: result.dat ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tổng câu: ${result.tongCau}'),
            Text('Đúng: ${result.soCauDung}'),
            Text('Sai: ${result.soCauSai}'),
            Text('Sai câu liệt: ${result.saiCauLiet ? "Có ❌" : "Không ✅"}'),
            const SizedBox(height: 8),
            Text(
              'Yêu cầu hạng ${result.maHang}: '
                  '${result.yeuCau}/${result.tongCau} và không sai câu liệt',
              style: const TextStyle(fontStyle: FontStyle.italic),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Đóng',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ====== STYLE / THEME ======

  // nền chung nhạt kiểu xanh-trắng
  Color get _bgPage => const Color(0xFFF8FAFC);

  // gradient header
  LinearGradient get _headerGradient => const LinearGradient(
    colors: [
      Color(0xFF2563EB), // xanh sáng
      Color(0xFF1E40AF), // xanh đậm
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // tab "Câu 1 / Câu 2 / ..."
  Color get _tabBgActive => const Color(0xFF2563EB);
  Color get _tabBgInactive => const Color(0xFFE5E7EB);
  Color get _tabTextActive => Colors.white;
  Color get _tabTextInactive => Colors.black87;

  // card câu hỏi chính
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

  // khung ảnh minh hoạ
  BoxDecoration get _imageBox => BoxDecoration(
    color: const Color(0xFFF1F5F9),
    borderRadius: BorderRadius.circular(6),
    border: Border.all(color: const Color(0xFFE2E8F0)),
  );

  // style block đáp án (trước và sau khi nộp bài)
  BoxDecoration _dapAnBox({
    required bool isSelected,
    required bool isCorrect,
    required bool isWrongPicked,
  }) {
    // mặc định
    Color borderColor = const Color(0xFFE2E8F0);
    Color bgColor = Colors.white;

    if (!_daNopBai) {
      // chưa nộp: chỉ highlight cái mình chọn
      if (isSelected) {
        borderColor = const Color(0xFF2563EB);
        bgColor = const Color(0xFF2563EB).withOpacity(0.05);
      }
    } else {
      // đã nộp: hiển thị đúng/sai
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

  // vòng tròn số đáp án
  BoxDecoration get _dapAnCircleBox => BoxDecoration(
    shape: BoxShape.circle,
    color: Colors.white,
    border: Border.all(color: Colors.black54, width: 1),
  );

  // nền highlight cả câu sau khi nộp bài
  Color _nenToanBoCauSauNop(CauHoiModel q) {
    if (!_daNopBai) return Colors.transparent;
    final idChon = _luaChonNguoiDung[q.idCauHoi];
    if (idChon == null) return Colors.transparent;
    final dapAnChon = q.dapAns.firstWhere(
          (d) => d.idDapAn == idChon,
      orElse: () => null as DapAnModel,
    );
    if (dapAnChon == null) return Colors.transparent;

    if (dapAnChon.dapAnDung == true) {
      return Colors.green.withOpacity(0.05);
    } else {
      return Colors.red.withOpacity(0.05);
    }
  }

  Color _colorFor(int index, bool isCurrent) {
    // ưu tiên current giữ style cũ của bạn
    if (isCurrent) return _tabBgActive;

    switch (_qStates[index]) {
      case QState.unanswered:
        return _tabBgInactive;                 // xám nhạt như cũ
      case QState.answered:
        return const Color(0xFFE6F7EE);        // xanh nhạt (đã chọn)
      case QState.correct:
        return const Color(0xFF22C55E);        // xanh đậm (đúng)
      case QState.wrong:
        return const Color(0xFFEF4444);        // đỏ (sai)
    }
  }
  // ====== UI BUILD ======

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_dsCauHoi.isEmpty) {
      return Scaffold(
        backgroundColor: _bgPage,
        body: const Center(
          child: Text('Không có câu hỏi'),
        ),
      );
    }

    final CauHoiModel cauHoi = _dsCauHoi[_currentIndex];
    final String imgUrl = buildImageUrl(cauHoi.hinhAnh);
    final int tongCau = _dsCauHoi.length;
    final int daLam = _luaChonNguoiDung.length;
    final int cauHienTaiSo = _currentIndex + 1;
    final int? dapAnDaChon = _luaChonNguoiDung[cauHoi.idCauHoi];

    return Scaffold(
      backgroundColor: _bgPage,
      body: Column(
        children: [
          // HEADER xanh (back + tiến trình + timer + Chấm điểm)
          Container(
            padding: const EdgeInsets.only(
              top: 40, // chừa status bar
              left: 12,
              right: 16,
              bottom: 12,
            ),
            decoration: BoxDecoration(
              gradient: _headerGradient,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // BACK
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    if (!_daNopBai) {
                      _xacNhanThoat();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),

                // PROGRESS (đã làm / tổng)
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$daLam/$tongCau',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),

                const Spacer(),

                // TIMER
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 6, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _formatTime(_secondsLeft),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),

                const Spacer(),

                // CHẤM ĐIỂM (nộp bài)
                GestureDetector(
                  onTap: _nopBaiThi,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 6, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                    child: const Text(
                      'Chấm điểm',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // DÃY TAB "Câu 1 | Câu 2 | ..."
          Container(
            width: double.infinity,
            color: Colors.white,
            padding:
            const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(tongCau, (i) {
                  final bool isCurrent = i == _currentIndex;
                  final String label = 'Câu ${i + 1}';
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentIndex = i;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _colorFor(i, isCurrent),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: ( _qStates[i] == QState.correct || _qStates[i] == QState.wrong )
                              ? Colors.white
                              : (isCurrent ? _tabTextActive : _tabTextInactive),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // NỘI DUNG CÂU HỎI + ĐÁP ÁN
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                color: _nenToanBoCauSauNop(cauHoi),
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
                          // dòng câu hỏi
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0F2FE),
                                  borderRadius:
                                  BorderRadius.circular(6),
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
                                  'Câu $cauHienTaiSo: ${cauHoi.noiDung ?? "..."}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // badge điểm liệt
                          if (cauHoi.cauLiet == true)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDC2626),
                                borderRadius:
                                BorderRadius.circular(4),
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
                                    : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                errorBuilder: (c, e, s) {
                                  debugPrint('IMAGE LOAD ERROR: $e');
                                  return _placeholderImg();
                                },
                              ),
                            )
                                : _placeholderImg(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // LIST ĐÁP ÁN
                    Column(
                      children: cauHoi.dapAns.map((dapAn) {
                        final bool isSelected =
                            dapAnDaChon != null &&
                                dapAnDaChon == dapAn.idDapAn;

                        final bool isCorrect =
                            dapAn.dapAnDung == true;
                        final bool isWrongPicked =
                            _daNopBai &&
                                isSelected &&
                                !isCorrect;

                        final String circleLabel =
                            '${dapAn.thuTu}';
                        // muốn A/B/C thì thay bằng:
                        // String.fromCharCode(65 + dapAn.thuTu - 1);

                        return GestureDetector(
                          onTap: () => _chonDapAn(cauHoi, dapAn),
                          child: Container(
                            width: double.infinity,
                            margin:
                            const EdgeInsets.only(bottom: 10),
                            decoration: _dapAnBox(
                              isSelected: isSelected,
                              isCorrect: isCorrect,
                              isWrongPicked: isWrongPicked,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 12,
                            ),
                            child: Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                // vòng số đáp án
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: _dapAnCircleBox,
                                  alignment: Alignment.center,
                                  child: Text(
                                    circleLabel,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // text đáp án
                                Expanded(
                                  child: Text(
                                    // TODO: thay bằng dapAn.noiDung khi backend trả text câu trả lời
                                    'Đáp án $circleLabel',
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
          ),

          // THANH ĐIỀU HƯỚNG DƯỚI (Câu trước / Câu sau / Nộp bài)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Câu trước
                Expanded(
                  child: Opacity(
                    opacity: _currentIndex > 0 ? 1 : 0.4,
                    child: IgnorePointer(
                      ignoring: _currentIndex == 0,
                      child: _btnBottomNeutral(
                        text: 'Câu trước',
                        icon: Icons.arrow_back,
                        onTap: _chuyenCauTruoc,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Câu sau
                Expanded(
                  child: Opacity(
                    opacity: _currentIndex < _dsCauHoi.length - 1
                        ? 1
                        : 0.4,
                    child: IgnorePointer(
                      ignoring:
                      _currentIndex == _dsCauHoi.length - 1,
                      child: _btnBottomNeutral(
                        text: 'Câu sau',
                        icon: Icons.arrow_forward,
                        onTap: _chuyenCauKeTiep,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Nộp bài
                Expanded(
                  child: _btnBottomDanger(
                    text: 'Nộp bài',
                    icon: Icons.check,
                    onTap: _nopBaiThi,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // nút xám (Câu trước / Câu sau)
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
        padding:
        const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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

  // nút đỏ (Nộp bài)
  Widget _btnBottomDanger({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFDC2626),
          borderRadius: BorderRadius.circular(8),
        ),
        padding:
        const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // placeholder ảnh nếu không có hoặc lỗi
  Widget _placeholderImg() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(
          Icons.image_outlined,
          color: Color(0xFF94A3B8),
          size: 32,
        ),
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
}
