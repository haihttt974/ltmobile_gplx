class BoDeTnModel {
  final int idBoDe;
  final String tenBoDe;
  final int thoiGian;
  final int soCauHoi;
  final int idHang;

  BoDeTnModel({
    required this.idBoDe,
    required this.tenBoDe,
    required this.thoiGian,
    required this.soCauHoi,
    required this.idHang,
  });

  factory BoDeTnModel.fromJson(Map<String, dynamic> json) {
    return BoDeTnModel(
      idBoDe: json['idBoDe'] ?? 0,
      tenBoDe: json['tenBoDe'] ?? '',
      thoiGian: json['thoiGian'] ?? 0,
      soCauHoi: json['soCauHoi'] ?? 0,
      idHang: json['idHang'] ?? 0,
    );
  }
}
