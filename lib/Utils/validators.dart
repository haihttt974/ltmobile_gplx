class Validators {
  static String? validateEmail(String value) {
    if (value.isEmpty) return "Email không được để trống";
    if (!value.contains("@")) return "Email không hợp lệ";
    return null;
  }

  static String? validatePassword(String value) {
    if (value.isEmpty) return "Mật khẩu không được để trống";
    if (value.length < 4) return "Mật khẩu quá ngắn";
    return null;
  }
}
