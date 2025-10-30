import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:doan/Models/bien_bao_model.dart';
import 'package:doan/Service/api_service.dart';

class BienBaoService {
  Future<List<BienBaoModel>> getAllBienBao({required int userId}) async {
    final res = await http.get(
      Uri.parse('${ApiService.baseUrl}/BienBao?userId=$userId'),
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => BienBaoModel.fromJson(e)).toList();
    }
    throw Exception('Lỗi tải danh sách biển báo');
  }

  Future<BienBaoDetailModel> getBienBaoDetail(int id) async {
    final res = await http.get(
      Uri.parse('${ApiService.baseUrl}/BienBao/$id'),
    );
    if (res.statusCode == 200) {
      return BienBaoDetailModel.fromJson(jsonDecode(res.body));
    }
    throw Exception('Không tìm thấy biển báo');
  }

  Future<void> updateTrangThai(int id, int userId, String danhGia) async {
    final res = await http.post(
      Uri.parse('${ApiService.baseUrl}/BienBao/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'danhGia': danhGia}),
    );
    if (res.statusCode != 200) {
      throw Exception('Cập nhật trạng thái thất bại');
    }
  }
}
