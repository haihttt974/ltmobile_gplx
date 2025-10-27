import 'package:shared_preferences/shared_preferences.dart';

import '../Models/auth_response.dart';
import '../Models/register_request.dart';
import '../Models/verify_request.dart';
import '../Service/auth_service.dart';

// Tầng "ứng dụng" (application layer):
// - gọi AuthService (HTTP layer)
// - lưu token, user info vào SharedPreferences
class AuthRepository {
  final AuthService _authService = AuthService();

  // ĐĂNG NHẬP
  Future<AuthResponse> login(String email, String password) async {
    final res = await _authService.login(email: email, password: password);

    // lưu token + info
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token", res.token);
    await prefs.setInt("user_id", res.user.userId);
    await prefs.setString("user_email", res.user.email);
    await prefs.setString("user_name", res.user.hoTen ?? "");
    await prefs.setString("user_avatar", res.user.avatar ?? "");

    return res;
  }

  // ĐĂNG KÝ (gửi OTP)
  Future<void> register(RegisterRequest req) async {
    // gọi service để yêu cầu server gửi OTP
    await _authService.register(req);
    // chưa lưu token ở bước này vì user chưa verify
  }

  // XÁC THỰC OTP
  // nếu OTP đúng -> server tạo user -> trả token + user
  // mình lưu luôn token, như là login sau verify
  Future<AuthResponse> verify(VerifyRequest req) async {
    final res = await _authService.verifyOtp(req);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token", res.token);
    await prefs.setInt("user_id", res.user.userId);
    await prefs.setString("user_email", res.user.email);
    await prefs.setString("user_name", res.user.hoTen ?? "");
    await prefs.setString("user_avatar", res.user.avatar ?? "");

    return res;
  }

  // lấy token đã lưu (cho SplashView)
  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

  // đăng xuất
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
    await prefs.remove("user_id");
    await prefs.remove("user_email");
    await prefs.remove("user_name");
    await prefs.remove("user_avatar");
  }
}
