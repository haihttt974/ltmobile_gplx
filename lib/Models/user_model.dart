class UserModel {
  final int userId;
  final String email;
  final String? hoTen;
  final String? soDienThoai;
  final String? avatar;

  UserModel({
    required this.userId,
    required this.email,
    this.hoTen,
    this.soDienThoai,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json["userId"] ?? 0,
      email: json["email"] ?? "",
      hoTen: json["hoTen"],
      soDienThoai: json["soDienThoai"],
      avatar: json["avatar"],
    );
  }
}
