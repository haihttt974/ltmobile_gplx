import 'package:doan/Service/bien_bao_service.dart';
import 'package:doan/Models/bien_bao_model.dart';

class BienBaoRepository {
  final _service = BienBaoService();

  Future<List<BienBaoModel>> getAllBienBao({required int userId}) =>
      _service.getAllBienBao(userId: userId);

  Future<BienBaoDetailModel> getBienBaoDetail(int id) =>
      _service.getBienBaoDetail(id);

  Future<void> updateTrangThai(int id, int userId, String danhGia) =>
      _service.updateTrangThai(id, userId, danhGia);
}
