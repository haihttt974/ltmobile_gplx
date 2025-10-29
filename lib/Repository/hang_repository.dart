import '../Models/hang_model.dart';
import '../Service/hang_service.dart';

class HangRepository {
  final HangService _service = HangService();

  Future<List<HangModel>> getAllHangs() async {
    final data = await _service.fetchHangs();
    return data.map((e) => HangModel.fromJson(e)).toList();
  }
}
