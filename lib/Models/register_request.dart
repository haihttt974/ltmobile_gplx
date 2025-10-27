class RegisterRequest {
  final String email;
  final String matKhau;
  final String hoTen;
  final String soDienThoai;

  RegisterRequest({
    required this.email,
    required this.matKhau,
    required this.hoTen,
    required this.soDienThoai,
  });

  Map<String, dynamic> toJson() => {
    "email": email,
    "matKhau": matKhau,
    "hoTen": hoTen,
    "soDienThoai": soDienThoai,
  };
}
