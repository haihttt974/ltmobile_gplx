import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/bo_de_tn_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Service/api_service.dart';

class BoDeTnService {
  Future<List<BoDeTnModel>> fetchBoDeTheoHang() async {
    final prefs = await SharedPreferences.getInstance();
    final idHang = prefs.getInt('selected_hang_id');

    if (idHang == null) {
      throw Exception("Chưa chọn hạng GPLX!");
    }

    // ✅ KHÔNG thêm /api lần nữa
    final url = Uri.parse('${ApiService.baseUrl}/BoDeTn/hang/$idHang');
    print("GET: $url");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data =
      jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((e) => BoDeTnModel.fromJson(e)).toList();
    } else {
      throw Exception('Không thể tải bộ đề (${response.statusCode})');
    }
  }
}
