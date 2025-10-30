import '../Service/api_service.dart';

String buildImageUrl(String? rawPath) {
  if (rawPath == null) return '';

  var p = rawPath.trim();
  if (p.isEmpty) return '';

  // 1) Remap dữ liệu cũ nếu còn /assets/...
  if (p.startsWith('/assets/')) p = p.replaceFirst('/assets/', '/images/');
  if (p.startsWith('assets/'))  p = p.replaceFirst('assets/', 'images/');

  // 2) Khử trùng lặp "images/images" ở đầu
  if (p.startsWith('/images/images/')) p = p.replaceFirst('/images/images/', '/images/');
  if (p.startsWith('images/images/'))  p = p.replaceFirst('images/images/', 'images/');

  // 3) Chuẩn hoá leading slash một lần duy nhất
  if (p.startsWith('images/')) p = '/$p';
  if (!p.startsWith('/'))      p = '/$p';        // mọi case khác

  // 4) Nếu đã là full URL thì trả luôn
  if (p.startsWith('http://') || p.startsWith('https://')) return p;

  // 5) Ghép origin (bỏ /api)
  final u = Uri.parse(ApiService.baseUrl);       // ví dụ: http://10.0.2.2:5091/api
  final port = (u.hasPort && u.port != 0) ? ':${u.port}' : '';
  final origin = '${u.scheme}://${u.host}$port';

  final url = '$origin$p';
  return url;
}
