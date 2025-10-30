class DapAnModel {
  final int idDapAn;
  final int idCauHoi;
  final int thuTu; // 1, 2, 3, 4
  final bool dapAnDung;

  DapAnModel({
    required this.idDapAn,
    required this.idCauHoi,
    required this.thuTu,
    required this.dapAnDung,
  });

  factory DapAnModel.fromJson(Map<String, dynamic> json) {
    return DapAnModel(
      idDapAn: json['idDapAn'],
      idCauHoi: json['idCauHoi'],
      thuTu: json['thuTu'],
      dapAnDung: json['dapAnDung'] == 1 || json['dapAnDung'] == true,
    );
  }
}