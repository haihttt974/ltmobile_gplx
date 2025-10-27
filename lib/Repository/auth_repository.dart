import 'package:shared_preferences/shared_preferences.dart';
import '../Models/auth_response.dart';
import '../Service/auth_service.dart';

class AuthRepository {
  final AuthService _authService = AuthService();

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

  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
    await prefs.remove("user_id");
    await prefs.remove("user_email");
    await prefs.remove("user_name");
    await prefs.remove("user_avatar");
  }
}
