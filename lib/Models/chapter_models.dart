// lib/Models/chapter_models.dart
class ChuongModel {
  final int idChuong;
  final int maChuong;
  final String tenChuong;
  final int soCauHoi; // số câu hỏi trong chương này (theo hạng)

  ChuongModel({
    required this.idChuong,
    required this.maChuong,
    required this.tenChuong,
    required this.soCauHoi,
  });

  factory ChuongModel.fromJson(Map<String, dynamic> json) {
    return ChuongModel(
      idChuong: json['idChuong'] ?? json['id_Chuong'] ?? 0,
      maChuong: json['maChuong'] ?? json['ma_chuong'] ?? 0,
      tenChuong: json['tenChuong'] ?? json['ten_chuong'] ?? '',
      soCauHoi: json['soCauHoi'] ?? json['so_cau_hoi'] ?? 0,
    );
  }
}

// Phản hồi tổng hợp từ /Chuong/theo-hang
class ChuongTheoHangResponse {
  final int tongSoCau;
  final List<ChuongModel> soCauTheoChuong;
  final int soCauLiet;

  ChuongTheoHangResponse({
    required this.tongSoCau,
    required this.soCauTheoChuong,
    required this.soCauLiet,
  });

  factory ChuongTheoHangResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['soCauTheoChuong'] as List<dynamic>? ?? [])
        .map((e) => ChuongModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return ChuongTheoHangResponse(
      tongSoCau: json['tongSoCau'] ?? 0,
      soCauTheoChuong: list,
      soCauLiet: json['soCauLiet'] ?? 0,
    );
  }
}

class ChuongThongKeModel {
  final String loai; // 'toan_bo', 'cau_liet', hoặc 'chuong'
  final int? idChuong;
  final String tieuDe;
  final String moTa;
  final int soCauHoi;
  final int soCauDung;
  final int soCauSai;
  final int soCauDaChon;

  ChuongThongKeModel({
    required this.loai,
    this.idChuong,
    required this.tieuDe,
    required this.moTa,
    required this.soCauHoi,
    this.soCauDung = 0,
    this.soCauSai = 0,
    this.soCauDaChon = 0,
  });

  double get tiLeHoanThanh {
    if (soCauHoi == 0) return 0;
    return (soCauDaChon / soCauHoi) * 100;
  }
}
