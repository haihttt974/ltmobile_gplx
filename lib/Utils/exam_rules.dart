import '../Models/cau_hoi_model.dart';
import '../Models/dap_an_model.dart';
import '../Models/exam_result_model.dart';

/// Rút trích mã hạng chuẩn từ chuỗi bất kỳ.
/// Ví dụ: "Hạng A1" -> "A1", "hạng b1 " -> "B1"
String _extractHang(String raw) {
  final s = raw.trim().toUpperCase();
  final re = RegExp(
    r'\b(A1|A|B1|B|C1|C|D1|D2|D|BE|C1E|CE|D1E|D2E|DE)\b',
    caseSensitive: false,
  );
  final m = re.firstMatch(s);
  return (m != null) ? m.group(1)!.toUpperCase() : s; // nếu không match, trả về s để thấy bug
}

/// Số câu đúng tối thiểu theo hạng
int requiredForHang(String maHangRaw) {
  final h = _extractHang(maHangRaw);

  switch (h) {
    case 'A1':
      return 21; // 21/25
    case 'A':
    case 'B1':
      return 23; // 23/25
    case 'B':
      return 27; // 27/30
    case 'C1':
      return 32; // 32/35
    case 'C':
      return 36; // 36/40
    default:
      const nhom45 = {
        'D1', 'D2', 'D', 'BE', 'C1E', 'CE', 'D1E', 'D2E', 'DE'
      };
      if (nhom45.contains(h)) return 41; // 41/45
      return 0; // hạng lạ -> 0 để dễ phát hiện
  }
}

/// Chấm bài
ExamResult chamBai({
  required String maHang,
  required List<CauHoiModel> dsCauHoi,
  required Map<int, int> luaChonNguoiDung, // { idCauHoi : idDapAn }
}) {
  final hang = _extractHang(maHang);
  final tong = dsCauHoi.length;
  final yeuCau = requiredForHang(hang);

  int dung = 0;
  bool saiCauLiet = false;

  for (final q in dsCauHoi) {
    final pickedId = luaChonNguoiDung[q.idCauHoi];

    final DapAnModel? correct = q.dapAns.firstWhere(
          (d) => d.dapAnDung == true,
      orElse: () => null as DapAnModel,
    );

    final pickedCorrect =
        pickedId != null && correct != null && pickedId == correct.idDapAn;

    if (pickedCorrect) dung++;

    if (q.cauLiet == true && !pickedCorrect) {
      saiCauLiet = true; // sai hoặc bỏ trống câu liệt
    }
  }

  final sai = tong - dung;
  final dat = (dung >= yeuCau) && !saiCauLiet;

  return ExamResult(
    maHang: hang,
    yeuCau: yeuCau,
    tongCau: tong,
    soCauDung: dung,
    soCauSai: sai,
    saiCauLiet: saiCauLiet,
    dat: dat,
  );
}
