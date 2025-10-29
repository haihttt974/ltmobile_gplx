import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/bo_de_tn_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BoDeTnService {
  final String baseUrl = 'http://10.0.2.2:5091/api/BoDeTn'; // ⚠️ sửa theo cổng backend của bạn

  Future<List<BoDeTnModel>> fetchBoDeTheoHang() async {
    final prefs = await SharedPreferences.getInstance();
    final idHang = prefs.getInt('selected_hang_id');

    if (idHang == null) {
      throw Exception("Chưa chọn hạng GPLX!");
    }

    final url = Uri.parse('$baseUrl/hang/$idHang'); // GET: api/BoDeTn/hang/{idHang}
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => BoDeTnModel.fromJson(e)).toList();
    } else {
      throw Exception('Không thể tải bộ đề trắc nghiệm (mã lỗi: ${response.statusCode})');
    }
  }
}
