import 'package:dio/dio.dart';
import '../Models/bo_de_mp.dart';
import '../Models/tinh_huong.dart';
import '../Models/ket_qua_mp.dart';
import '../Models/chuong_mp.dart';

class SimApi {
  final Dio _dio;
  SimApi(String baseUrl, String jwt)
      : _dio = Dio(BaseOptions(
    baseUrl: '$baseUrl/sim',
    headers: {'Authorization': 'Bearer $jwt'},
  ));

  // Bộ đề
  Future<List<BoDeMp>> listBoDe() async {
    final rs = await _dio.get('/bo-de');
    return (rs.data as List).map((e) => BoDeMp.fromJson(e)).toList();
    // [{IdBoDe, TenBoDe, SoTinhHuong, TaoLuc}]
  }

  // Lấy tình huống trong bộ đề
  Future<List<TinhHuong>> getBoDe(int idBoDe) async {
    final rs = await _dio.get('/bo-de/$idBoDe');
    return (rs.data as List).map((e) => TinhHuong.fromJson(e)).toList();
    // [{IdTinhHuong, ThuTu, IdBoDe, TieuDe, Video, Start, End}]
  }

  // Nộp bài theo bộ đề (có lưu lịch sử)
  Future<KetQuaMp> nopBaiBoDe(int idBoDe, List<Map<String, dynamic>> clicks) async {
    final rs = await _dio.post('/thi-bo-de/$idBoDe/nop-bai', data: {'clicks': clicks});
    return KetQuaMp.fromJson(rs.data);
  }

  // Đề ngẫu nhiên
  Future<List<TinhHuong>> randomSet({required int soTinhHuong, int? idChuong}) async {
    final rs = await _dio.post('/thi-ngau-nhien', data: {'soTinhHuong': soTinhHuong, 'idChuong': idChuong});
    return (rs.data as List).map((e) => TinhHuong.fromJson(e)).toList();
  }

  Future<KetQuaMp> randomSubmit(List<Map<String, dynamic>> clicks, {int nguongDat = 35}) async {
    final rs = await _dio.post('/thi-ngau-nhien/nop-bai', data: {'clicks': clicks}, queryParameters: {'nguongDat': nguongDat});
    return KetQuaMp.fromJson(rs.data);
  }

  // Câu khó
  Future<List<TinhHuong>> listKho() async {
    final rs = await _dio.get('/kho');
    return (rs.data as List).map((e) => TinhHuong.fromJson(e)).toList();
  }

  Future<List<TinhHuong>> randomKho({required int soTinhHuong, int? idChuong}) async {
    final rs = await _dio.post('/kho/random', data: {'soTinhHuong': soTinhHuong, 'idChuong': idChuong});
    return (rs.data as List).map((e) => TinhHuong.fromJson(e)).toList();
  }

  Future<KetQuaMp> randomKhoSubmit(List<Map<String, dynamic>> clicks, {int nguongDat = 35}) async {
    final rs = await _dio.post('/kho/nop-bai', data: {'clicks': clicks}, queryParameters: {'nguongDat': nguongDat});
    return KetQuaMp.fromJson(rs.data);
  }

  Future<void> toggleKho(int idTinhHuong, bool value) async {
    await _dio.patch('/tinh-huong/$idTinhHuong/kho', queryParameters: {'value': value});
  }

  // Thống kê
  Future<List<Map<String, dynamic>>> cauHaySai() async {
    final rs = await _dio.get('/cau-hay-sai');
    return (rs.data as List).cast<Map<String, dynamic>>();
    // [{IdTinhHuong, TieuDe, SoLan0}]
  }

  Future<List<Map<String, dynamic>>> cauDiemThap({int min = 1, int max = 3}) async {
    final rs = await _dio.get('/cau-diem-thap', queryParameters: {'min': min, 'max': max});
    return (rs.data as List).cast<Map<String, dynamic>>();
    // [{IdTinhHuong, TieuDe, SoLan}]
  }

  // Chương & mẹo
  Future<List<ChuongMp>> listChuong() async {
    final rs = await _dio.get('/chuong');
    return (rs.data as List).map((e) => ChuongMp.fromJson(e)).toList();
  }

  Future<List<TinhHuong>> tinhHuongTheoChuong(int idChuong) async {
    final rs = await _dio.get('/chuong/$idChuong/tinh-huong');
    return (rs.data as List).map((e) => TinhHuong.fromJson(e)).toList();
  }

  Future<List<Map<String, dynamic>>> meo() async {
    final rs = await _dio.get('/meo');
    return (rs.data as List).cast<Map<String, dynamic>>();
    // [{IdTinhHuong, IdChuong, TieuDe, UrlAnhMeo}]
  }
}
