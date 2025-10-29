class HangModel {
  final int idHang;
  final String maHang;
  final String tenDayDu;
  final String moTa;

  HangModel({
    required this.idHang,
    required this.maHang,
    required this.tenDayDu,
    required this.moTa,
  });

  factory HangModel.fromJson(Map<String, dynamic> json) {
    return HangModel(
      idHang: json['idHang'] ?? 0, // ✅ key đúng với JSON
      maHang: json['maHang'] ?? '',
      tenDayDu: json['tenDayDu'] ?? '',
      moTa: json['moTa'] ?? '',
    );
  }
}
