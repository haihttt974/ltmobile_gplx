class ChuongMp {
  final int id;
  final String ten;
  final int thuTu;
  ChuongMp({required this.id, required this.ten, required this.thuTu});
  factory ChuongMp.fromJson(Map<String, dynamic> j) => ChuongMp(
    id: j['idChuong'] ?? j['IdChuong'],
    ten: j['tenChuong'] ?? j['TenChuong'],
    thuTu: j['thuTu'] ?? j['ThuTu'],
  );
}
