class BoDeTnModel {
  final int idBoDe;
  final String tenBoDe;
  final int thoiGian;
  final int soCauHoi;
  final bool hoatDong;
  final int idHang;
  final int? diemDat; // Thêm field này

  BoDeTnModel({
    required this.idBoDe,
    required this.tenBoDe,
    required this.thoiGian,
    required this.soCauHoi,
    required this.hoatDong,
    required this.idHang,
    this.diemDat,
  });

  factory BoDeTnModel.fromJson(Map<String, dynamic> json) {
    return BoDeTnModel(
      idBoDe: json['idBoDe'],
      tenBoDe: json['tenBoDe'],
      thoiGian: json['thoiGian'],
      soCauHoi: json['soCauHoi'],
      hoatDong: json['hoatDong'] == 1 || json['hoatDong'] == true,
      idHang: json['idHang'],
      diemDat: json['diemDat'],
    );
  }
}