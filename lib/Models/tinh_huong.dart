class TinhHuong {
  final int id;
  final String tieuDe;
  final String videoUrl;
  final double start; // giây
  final double end;   // giây
  final int? idChuong;
  final bool? kho;
  final String? urlAnhMeo;

  TinhHuong({
    required this.id,
    required this.tieuDe,
    required this.videoUrl,
    required this.start,
    required this.end,
    this.idChuong,
    this.kho,
    this.urlAnhMeo,
  });
  factory TinhHuong.fromJson(Map<String, dynamic> j) {
    final videoUrl = j['Video'] ?? j['video'] ?? j['videoUrl'] ?? j['VideoUrl'] ?? '';

    return TinhHuong(
      id: j['idTinhHuong'] ?? j['IdTinhHuong'],
      tieuDe: j['tieuDe'] ?? j['TieuDe'],
      videoUrl: videoUrl,
      start: (j['start'] ?? j['Start'] ?? j['tgBatDau'] ?? j['TgBatDau'] ?? 0).toDouble(),
      end: (j['end'] ?? j['End'] ?? j['tgKetThuc'] ?? j['TgKetThuc'] ?? 0).toDouble(),
      idChuong: j['idChuong'] ?? j['IdChuong'],
      kho: j['kho'] ?? j['Kho'],
      urlAnhMeo: j['urlAnhMeo'] ?? j['UrlAnhMeo'],
    );
  }
}
