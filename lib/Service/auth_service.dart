import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/auth_response.dart';
import '../Service/api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final http.Response resp = await _api.post(
      "/auth/login",
      {
        "email": email,
        "mat_Khau": password,
      },
    );

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return AuthResponse.fromJson(data);
    }

    if (resp.statusCode == 401) {
      throw AuthException("Email hoặc mật khẩu không đúng");
    }

    throw AuthException(
      "Lỗi máy chủ (${resp.statusCode})",
    );
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
