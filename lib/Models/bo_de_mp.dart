class BoDeMp {
  final int id;
  final String ten;
  final int soTinhHuong;
  final String taoLuc;

  BoDeMp({required this.id, required this.ten, required this.soTinhHuong, required this.taoLuc});

  factory BoDeMp.fromJson(Map<String, dynamic> j) => BoDeMp(
    id: j['idBoDe'] ?? j['IdBoDe'],
    ten: j['tenBoDe'] ?? j['TenBoDe'],
    soTinhHuong: j['soTinhHuong'] ?? j['SoTinhHuong'],
    taoLuc: (j['taoLuc'] ?? j['TaoLuc']).toString(),
  );
}
