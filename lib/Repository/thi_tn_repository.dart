import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/cau_hoi_model.dart';
import '../Service/api_service.dart';

class ThiTnRepository {
  final ApiService _apiService = ApiService();

  Future<List<CauHoiModel>> getCauHoiTheoBoDe(int idBoDe) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/BoDeTn/$idBoDe/cau-hoi'),
      );
      print("GET Câu Hỏi: ${ApiService.baseUrl}/BoDeTn/$idBoDe/cau-hoi");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));

        return data.map((json) => CauHoiModel.fromJson(json)).toList();
      } else {
        throw Exception('Lỗi tải câu hỏi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }
}
