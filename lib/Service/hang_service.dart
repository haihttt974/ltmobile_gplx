import 'dart:convert';
import 'api_service.dart';

class HangService {
  final ApiService _apiService = ApiService();

  Future<List<dynamic>> fetchHangs() async {
    final response = await _apiService.get('/hang');

    if (response.statusCode == 200) {
      // Giả sử API trả về một danh sách JSON
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Không thể tải danh sách hạng GPLX (mã lỗi: ${response.statusCode})');
    }
  }
}
