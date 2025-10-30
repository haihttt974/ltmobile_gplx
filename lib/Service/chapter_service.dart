// lib/Service/chuong_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/chapter_models.dart';
import 'api_service.dart';

class ChuongService {
  final ApiService _apiService = ApiService();

  // Lấy gói thống kê chương theo hạng (object)
  Future<ChuongTheoHangResponse> getChuongTheoHang(int idHang) async {
    try {
      final response = await _apiService.get(
        '/Chuong/theo-hang?idHang=$idHang',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
        jsonDecode(utf8.decode(response.bodyBytes));
        return ChuongTheoHangResponse.fromJson(data);
      }
      throw Exception('Không thể tải danh sách chương');
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  // Lấy tổng số câu hỏi theo hạng
  Future<int> getTongSoCauHoiTheoHang(int idHang) async {
    try {
      final response = await _apiService.get(
        '/CauHoi/tong-so-cau?idHang=$idHang',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['tongSoCau'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // Lấy số câu liệt theo hạng
  Future<int> getSoCauLietTheoHang(int idHang) async {
    try {
      final response = await _apiService.get(
        '/CauHoi/so-cau-liet?idHang=$idHang',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['soCauLiet'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
  // Lấy toàn bộ câu hỏi theo hạng (A/A1: 250; khác: 600)
  Future<Map<String, dynamic>> getCauHoiByHang(int idHang, {int? idChuong}) async {
    final path = idChuong == null
        ? '/CauHoi/by-hang?idHang=$idHang'
        : '/CauHoi/by-hang?idHang=$idHang&idChuong=$idChuong';

    final res = await _apiService.get(path);
    if (res.statusCode == 200) {
      return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    }
    throw Exception('Không tải được danh sách câu hỏi');
  }

// Lấy CÂU LIỆT theo hạng (A/A1 lọc XeMay=true)
  Future<Map<String, dynamic>> getCauLietByHang(int idHang, {int? idChuong}) async {
    final path = idChuong == null
        ? '/CauHoi/liet-by-hang?idHang=$idHang'
        : '/CauHoi/liet-by-hang?idHang=$idHang&idChuong=$idChuong';

    final res = await _apiService.get(path);
    if (res.statusCode == 200) {
      return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    }
    throw Exception('Không tải được danh sách câu LIỆT');
  }
  // Lấy danh sách câu hỏi theo chương (lọc theo XeMay nếu hạng là A/A1)
  Future<Map<String, dynamic>> getCauHoiByChuong(int idHang, {int? idChuong}) async {
    final path = idChuong == null
        ? '/CauHoi/by-chuong?idHang=$idHang'
        : '/CauHoi/by-chuong?idHang=$idHang&idChuong=$idChuong';

    final res = await _apiService.get(path);
    if (res.statusCode == 200) {
      return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    }
    throw Exception('Không tải được danh sách câu hỏi theo chương');
  }

}
