import 'dap_an_model.dart';

class CauHoiModel {
  final int idCauHoi;
  final int idChuong;
  final String noiDung;
  final String? hinhAnh;
  final bool cauLiet;
  final bool chuY;
  final bool xeMay;
  final String? urlAnhMeo;
  final int thuTu;
  final List<DapAnModel> dapAns;

  CauHoiModel({
    required this.idCauHoi,
    required this.idChuong,
    required this.noiDung,
    this.hinhAnh,
    required this.cauLiet,
    required this.chuY,
    required this.xeMay,
    this.urlAnhMeo,
    required this.thuTu,
    required this.dapAns,
  });

  factory CauHoiModel.fromJson(Map<String, dynamic> json) {
    return CauHoiModel(
      idCauHoi: json['idCauHoi'],
      idChuong: json['idChuong'],
      noiDung: json['noiDung'] ?? '',
      hinhAnh: json['hinhAnh'],
      cauLiet: json['cauLiet'] == 1 || json['cauLiet'] == true,
      chuY: json['chuY'] == 1 || json['chuY'] == true,
      xeMay: json['xeMay'] == 1 || json['xeMay'] == true,
      urlAnhMeo: json['urlAnhMeo'],
      thuTu: json['thuTu'],
      dapAns: (json['dapAns'] as List?)
          ?.map((da) => DapAnModel.fromJson(da))
          .toList() ?? [],
    );
  }
}