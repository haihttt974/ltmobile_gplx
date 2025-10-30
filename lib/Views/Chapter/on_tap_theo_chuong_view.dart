// lib/Views/Chapter/on_tap_theo_chuong_view.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../Models/chapter_models.dart';
import '../../Service/chapter_service.dart';
import '../../Styles/app_colors.dart';
import 'lam_bai_theo_chuong_view.dart';

class OnTapTheoChuongView extends StatefulWidget {
  const OnTapTheoChuongView({super.key});

  @override
  State<OnTapTheoChuongView> createState() => _OnTapTheoChuongViewState();
}

class _OnTapTheoChuongViewState extends State<OnTapTheoChuongView> {
  final ChuongService _chuongService = ChuongService();

  bool _isLoading = true;
  String? _errorMessage;

  String _selectedHangName = '';
  int _selectedHangId = 0;
  bool _isXeMay = false;

  List<ChuongThongKeModel> _danhSachChuong = [];

  @override
  void initState() {
    super.initState();
    _loadDataAndFetch();
  }

  Future<void> _loadDataAndFetch() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final hangName = prefs.getString('selected_hang_name') ?? '';
      final hangId = prefs.getInt('selected_hang_id') ?? 0;

      if (hangId == 0) {
        setState(() {
          _errorMessage = 'Vui lòng chọn hạng GPLX trước';
          _isLoading = false;
        });
        return;
      }

      final isXeMay = hangName.trim().toUpperCase().startsWith('A');

      setState(() {
        _selectedHangName = hangName;
        _selectedHangId = hangId;
        _isXeMay = isXeMay;
      });

      await _fetchDanhSachChuong();
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi: $e';
        _isLoading = false;
      });
    }
  }

  String _getStorageKey(String mode, {int? idChuong}) {
    if (mode == 'chuong' && idChuong != null) {
      return 'progress_${_selectedHangId}_chuong_$idChuong';
    } else if (mode == 'cau_liet') {
      return 'progress_${_selectedHangId}_cau_liet';
    } else {
      return 'progress_${_selectedHangId}_toan_bo';
    }
  }

  Future<Map<String, int>> _loadStatsForMode(String mode,
      {int? idChuong, List<dynamic>? cauHoiItems}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getStorageKey(mode, idChuong: idChuong);
      final savedData = prefs.getString(key);

      if (savedData == null || cauHoiItems == null) {
        return {'dung': 0, 'sai': 0, 'daChon': 0};
      }

      final Map<String, dynamic> data = json.decode(savedData);
      final answersMap = data['selectedAnswers'] as Map<String, dynamic>?;

      if (answersMap == null) {
        return {'dung': 0, 'sai': 0, 'daChon': 0};
      }

      final Map<int, int> selectedAnswers = {};
      answersMap.forEach((idStr, thuTu) {
        selectedAnswers[int.parse(idStr)] = thuTu as int;
      });

      int dung = 0;
      int sai = 0;
      int daChon = 0;

      for (var item in cauHoiItems) {
        final q =
        item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item as Map);
        final idCauHoi = q['idCauHoi'] as int?;
        if (idCauHoi == null) continue;

        final selectedThuTu = selectedAnswers[idCauHoi];
        if (selectedThuTu != null) {
          daChon++;

          final dapAnList = q['dapAn'] as List<dynamic>? ?? [];
          final answers = dapAnList
              .map((e) => e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e))
              .toList();

          final correctAnswer = answers.firstWhere(
                (a) => a['dapAnDung'] == true,
            orElse: () => {},
          );

          final correctThuTu = correctAnswer['thuTu'] as int?;
          if (correctThuTu != null) {
            if (selectedThuTu == correctThuTu) {
              dung++;
            } else {
              sai++;
            }
          }
        }
      }

      return {'dung': dung, 'sai': sai, 'daChon': daChon};
    } catch (e) {
      debugPrint('[STATS-ERROR] $e');
      return {'dung': 0, 'sai': 0, 'daChon': 0};
    }
  }

  Future<void> _fetchDanhSachChuong() async {
    try {
      final tongSoCau = await _chuongService.getTongSoCauHoiTheoHang(_selectedHangId);
      final soCauLiet = await _chuongService.getSoCauLietTheoHang(_selectedHangId);

      final resp = await _chuongService.getChuongTheoHang(_selectedHangId);
      final danhSachChuong = resp.soCauTheoChuong;

      final List<ChuongThongKeModel> result = [];

      final payloadToanBo = await _chuongService.getCauHoiByHang(_selectedHangId);
      final itemsToanBo = payloadToanBo['items'] as List<dynamic>? ?? [];
      final statsToanBo =
      await _loadStatsForMode('toan_bo', cauHoiItems: itemsToanBo);

      result.add(ChuongThongKeModel(
        loai: 'toan_bo',
        tieuDe: 'Toàn bộ $tongSoCau câu hỏi',
        moTa: '$tongSoCau câu hỏi trong bộ đề hiện tại',
        soCauHoi: tongSoCau,
        soCauDung: statsToanBo['dung']!,
        soCauSai: statsToanBo['sai']!,
        soCauDaChon: statsToanBo['daChon']!,
      ));

      if (soCauLiet > 0) {
        final payloadCauLiet = await _chuongService.getCauLietByHang(_selectedHangId);
        final itemsCauLiet = payloadCauLiet['items'] as List<dynamic>? ?? [];
        final statsCauLiet =
        await _loadStatsForMode('cau_liet', cauHoiItems: itemsCauLiet);

        result.add(ChuongThongKeModel(
          loai: 'cau_liet',
          tieuDe: 'Câu hỏi điểm liệt',
          moTa: '$soCauLiet câu điểm liệt',
          soCauHoi: soCauLiet,
          soCauDung: statsCauLiet['dung']!,
          soCauSai: statsCauLiet['sai']!,
          soCauDaChon: statsCauLiet['daChon']!,
        ));
      }

      for (final chuong in danhSachChuong) {
        if (chuong.soCauHoi > 0) {
          final payloadChuong = await _chuongService.getCauHoiByHang(
            _selectedHangId,
            idChuong: chuong.idChuong,
          );
          final itemsChuong = payloadChuong['items'] as List<dynamic>? ?? [];
          final statsChuong = await _loadStatsForMode('chuong',
              idChuong: chuong.idChuong, cauHoiItems: itemsChuong);

          result.add(ChuongThongKeModel(
            loai: 'chuong',
            idChuong: chuong.idChuong,
            tieuDe: chuong.tenChuong,
            moTa: '${chuong.soCauHoi} câu trong chương "${chuong.tenChuong}"',
            soCauHoi: chuong.soCauHoi,
            soCauDung: statsChuong['dung']!,
            soCauSai: statsChuong['sai']!,
            soCauDaChon: statsChuong['daChon']!,
          ));
        }
      }

      setState(() {
        _danhSachChuong = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải danh sách chương: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Ôn tập theo chương',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadDataAndFetch,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDataAndFetch,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_danhSachChuong.isEmpty) {
      return const Center(
        child: Text(
          'Không có dữ liệu',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _danhSachChuong.length,
      itemBuilder: (context, index) {
        final chuong = _danhSachChuong[index];
        return _buildChuongCard(chuong);
      },
    );
  }

  Widget _buildChuongCard(ChuongThongKeModel chuong) {
    final tiLeHoanThanh =
    chuong.soCauHoi > 0 ? (chuong.soCauDaChon / chuong.soCauHoi * 100).round() : 0;

    final Color cardColor = Colors.white;
    final Color borderColor = chuong.loai == 'toan_bo'
        ? Colors.blue
        : chuong.loai == 'cau_liet'
        ? Colors.purple
        : Colors.grey.shade300;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _navigateToLamBai(chuong),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chuong.tieuDe,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  chuong.moTa,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: tiLeHoanThanh / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      tiLeHoanThanh == 100 ? Colors.green : Colors.orange,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatItem('Đúng', chuong.soCauDung, Colors.green),
                    const SizedBox(width: 24),
                    _buildStatItem('Sai', chuong.soCauSai, Colors.red),
                    const SizedBox(width: 24),
                    _buildStatItem('Đã chọn', chuong.soCauDaChon, Colors.orange),
                    const Spacer(),
                    Text(
                      'Số câu: ${chuong.soCauHoi}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.black87, fontSize: 13),
        ),
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _navigateToLamBai(ChuongThongKeModel chuong) async {
    try {
      if (chuong.loai == 'toan_bo') {
        final payload = await _chuongService.getCauHoiByHang(_selectedHangId);
        final items = payload['items'] as List<dynamic>? ?? [];
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LamBaiTheoChuongView(
              title: 'Toàn bộ $_selectedHangName',
              cauHoiItems: items,
              idHang: _selectedHangId,
              isXeMay: _isXeMay,
              mode: 'toan_bo',
            ),
          ),
        ).then((_) => _fetchDanhSachChuong());
      } else if (chuong.loai == 'cau_liet') {
        final payload = await _chuongService.getCauLietByHang(_selectedHangId);
        final items = payload['items'] as List<dynamic>? ?? [];
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LamBaiTheoChuongView(
              title: 'Câu LIỆT - $_selectedHangName',
              cauHoiItems: items,
              idHang: _selectedHangId,
              isXeMay: _isXeMay,
              mode: 'cau_liet',
            ),
          ),
        ).then((_) => _fetchDanhSachChuong());
      } else {
        final payload = await _chuongService.getCauHoiByHang(
          _selectedHangId,
          idChuong: chuong.idChuong,
        );
        final items = payload['items'] as List<dynamic>? ?? [];
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LamBaiTheoChuongView(
              title: chuong.tieuDe,
              cauHoiItems: items,
              idHang: _selectedHangId,
              isXeMay: _isXeMay,
              mode: 'chuong',
              idChuong: chuong.idChuong,
            ),
          ),
        ).then((_) => _fetchDanhSachChuong());
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')));
    }
  }
}
