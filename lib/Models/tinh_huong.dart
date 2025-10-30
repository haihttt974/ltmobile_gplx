class TinhHuong {
  final int id;
  final String tieuDe;
  final String videoUrl;
  final double start;
  final double end;
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
    var videoUrl = j['Video'] ?? j['video'] ?? j['videoUrl'] ?? j['VideoUrl'] ?? '';
    var urlAnhMeo = j['urlAnhMeo'] ?? j['UrlAnhMeo'] ?? '';

    // ✅ PHẢI CÓ DÒNG NÀY
    videoUrl = _fixUrl(videoUrl);
    urlAnhMeo = _fixUrl(urlAnhMeo);

    return TinhHuong(
      id: j['idTinhHuong'] ?? j['IdTinhHuong'],
      tieuDe: j['tieuDe'] ?? j['TieuDe'],
      videoUrl: videoUrl,
      start: (j['start'] ?? j['Start'] ?? j['tgBatDau'] ?? j['TgBatDau'] ?? 0).toDouble(),
      end: (j['end'] ?? j['End'] ?? j['tgKetThuc'] ?? j['TgKetThuc'] ?? 0).toDouble(),
      idChuong: j['idChuong'] ?? j['IdChuong'],
      kho: j['kho'] ?? j['Kho'],
      urlAnhMeo: urlAnhMeo,
    );
  }

  // ✅ THÊM METHOD NÀY
  static String _fixUrl(String url) {
    if (url.isEmpty) return url;


    // Đổi HTTPS → HTTP
    url = url.replaceAll('https://', 'http://');

    // Đổi port 7185 → 5091
    url = url.replaceAll(':7185', ':5091');

    // Đổi localhost → 10.0.2.2
    url = url.replaceAll('localhost', '10.0.2.2');
    url = url.replaceAll('127.0.0.1', '10.0.2.2');


    return url;
  }
}