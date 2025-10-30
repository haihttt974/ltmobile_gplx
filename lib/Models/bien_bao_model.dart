// lib/Models/bien_bao_model.dart

class BienBaoModel {
  final int idBienBao;
  final String tenBienBao;
  final String hinhAnh;
  final String? danhGia; // có thể null

  BienBaoModel({
    required this.idBienBao,
    required this.tenBienBao,
    required this.hinhAnh,
    this.danhGia,
  });

  factory BienBaoModel.fromJson(Map<String, dynamic> json) {
    return BienBaoModel(
      idBienBao: json['idBienBao'],
      tenBienBao: json['tenBienBao'],
      hinhAnh: json['hinhAnh'],
      danhGia: json['danhGia'],
    );
  }
}

class BienBaoDetailModel {
  final int idBienBao;
  final String tenBienBao;
  final String hinhAnh;
  final String yNghia;

  BienBaoDetailModel({
    required this.idBienBao,
    required this.tenBienBao,
    required this.hinhAnh,
    required this.yNghia,
  });

  factory BienBaoDetailModel.fromJson(Map<String, dynamic> json) {
    return BienBaoDetailModel(
      idBienBao: json['idBienBao'],
      tenBienBao: json['tenBienBao'],
      hinhAnh: json['hinhAnh'],
      yNghia: json['yNghia'],
    );
  }
}
