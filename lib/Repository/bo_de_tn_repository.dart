import '../Models/bo_de_tn_model.dart';
import '../Service/bo_de_tn_service.dart';

class BoDeTnRepository {
  final BoDeTnService _service = BoDeTnService();

  Future<List<BoDeTnModel>> getBoDeTheoHang() async {
    return await _service.fetchBoDeTheoHang();
  }
}
