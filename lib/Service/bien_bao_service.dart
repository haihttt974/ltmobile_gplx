// lib/Service/bien_bao_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:doan/Models/bien_bao_model.dart';
import 'package:doan/Service/api_service.dart';

class BienBaoService {
  /// Nếu cần dùng token/header từ ApiService, bạn có thể thêm hàm lấy header ở đây.

  Future<List<BienBaoModel>> getAllBienBao() async {
    final res = await http.get(Uri.parse('${ApiService.baseUrl}/BienBao'));

    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((e) => BienBaoModel.fromJson(e)).toList();
    } else {
      throw Exception('Lỗi tải danh sách biển báo');
    }
  }

  Future<BienBaoDetailModel> getBienBaoDetail(int id) async {
    final res = await http.get(Uri.parse('${ApiService.baseUrl}/BienBao/$id'));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return BienBaoDetailModel.fromJson(data);
    } else {
      throw Exception('Không tìm thấy biển báo');
    }
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
