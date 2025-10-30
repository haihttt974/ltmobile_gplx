class KetQuaMp {
  final int tongDiem;
  final bool dat;
  final int? idBaiMp; // chỉ có khi thi theo bộ đề
  final List<Map<String, dynamic>> chiTiet; // {idTinhHuong, diem}

  KetQuaMp({required this.tongDiem, required this.dat, this.idBaiMp, required this.chiTiet});

  factory KetQuaMp.fromJson(Map<String, dynamic> j) => KetQuaMp(
    tongDiem: j['tongDiem'],
    dat: j['dat'],
    idBaiMp: j['idBaiMp'],
    chiTiet: (j['chiTiet'] as List).cast<Map<String, dynamic>>(),
  );
}
