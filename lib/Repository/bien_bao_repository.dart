// lib/Repository/bien_bao_repository.dart

import 'package:doan/Service/bien_bao_service.dart';
import 'package:doan/Models/bien_bao_model.dart';

class BienBaoRepository {
  final BienBaoService _service = BienBaoService();

  /// Lấy danh sách tất cả biển báo
  Future<List<BienBaoModel>> getAllBienBao() =>
      _service.getAllBienBao();

  /// Lấy chi tiết biển báo theo ID
  Future<BienBaoDetailModel> getBienBaoDetail(int id) =>
      _service.getBienBaoDetail(id);

  /// Cập nhật trạng thái học biển báo cho user
  Future<void> updateTrangThai(int id, int userId, String danhGia) =>
      _service.updateTrangThai(id, userId, danhGia);
}
