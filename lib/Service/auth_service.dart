import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/auth_response.dart';
import '../Models/register_request.dart';
import '../Models/verify_request.dart';
import '../Service/api_service.dart';

// Tầng nói chuyện trực tiếp với API HTTP
class AuthService {
  final ApiService _api = ApiService();

  // ĐĂNG NHẬP
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final http.Response resp = await _api.post(
      "/auth/login",
      {
        "email": email,
        // quan trọng: key JSON phải khớp backend (Mat_khau)
        // backend mong "mat_khau" (thường snake_case), không phải "mat_Khau" hay "matKhau"
        "mat_khau": password,
      },
    );

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return AuthResponse.fromJson(data);
    }

    if (resp.statusCode == 401) {
      throw AuthException("Email hoặc mật khẩu không đúng");
    }

    throw AuthException("Lỗi máy chủ (${resp.statusCode})");
  }

  // ĐĂNG KÝ (bước 1: gửi OTP đến email)
  // gọi /auth/register, không trả token
  Future<void> register(RegisterRequest req) async {
    final http.Response resp = await _api.post(
      "/auth/register",
      req.toJson(),
    );

    // THÀNH CÔNG
    if (resp.statusCode == 200) {
      return;
    }

    // Ghi log cho dễ soi
    // print("[REGISTER] status=${resp.statusCode}");
    // print("[REGISTER] rawBody=${resp.body}");

    // cố gắng phân tích response body
    dynamic body;
    try {
      body = jsonDecode(resp.body);
    } catch (e) {
      body = resp.body; // không phải json, giữ dạng text
    }

    // body là JSON map?
    if (body is Map<String, dynamic>) {
      // 1. Trường hợp backend custom: { "message": "Email đã được sử dụng" }
      if (body["message"] is String && (body["message"] as String).isNotEmpty) {
        throw AuthException(body["message"]);
      }

      // 2. ASP.NET Core ProblemDetails style:
      // { "title": "...", "errors": { "Email": ["Email đã được sử dụng"] } }
      // Ưu tiên lấy lỗi cụ thể theo field Email nếu có
      if (body["errors"] is Map) {
        final errors = body["errors"] as Map;

        // thử lấy lỗi Email đầu tiên
        final emailErr = errors["Email"];
        if (emailErr is List && emailErr.isNotEmpty && emailErr.first is String) {
          throw AuthException(emailErr.first);
        }

        // fallback: lấy bất kỳ lỗi đầu tiên trong errors
        if (errors.isNotEmpty) {
          final firstKey = errors.keys.first;
          final firstVal = errors[firstKey];
          if (firstVal is List && firstVal.isNotEmpty && firstVal.first is String) {
            throw AuthException(firstVal.first);
          }
        }
      }

      // 3. Nếu có "title" (ASP.NET mặc định)
      if (body["title"] is String && (body["title"] as String).isNotEmpty) {
        throw AuthException(body["title"]);
      }

      // 4. Nếu có "Message" viết hoa kiểu C# PascalCase
      if (body["Message"] is String && (body["Message"] as String).isNotEmpty) {
        throw AuthException(body["Message"]);
      }
    }

    // body không phải map JSON hoặc parse không được case nào ở trên
    // quăng ra text thuần (cắt {}, "" cho đỡ xấu)
    final fallbackMsg = resp.body.isNotEmpty
        ? resp.body.replaceAll(RegExp(r'[{}"]'), '')
        : "Đăng ký thất bại (${resp.statusCode})";

    throw AuthException(fallbackMsg);
  }

  // XÁC THỰC OTP (bước 2: verify OTP)
  // gọi /auth/verify, backend trả token + user
  Future<AuthResponse> verifyOtp(VerifyRequest req) async {
    final http.Response resp = await _api.post(
      "/auth/verify",
      req.toJson(), // { email, otpCode }
    );

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return AuthResponse.fromJson(data);
    }

    try {
      final body = jsonDecode(resp.body);
      if (body is Map && body["message"] is String) {
        throw AuthException(body["message"]);
      }
    } catch (_) {}

    throw AuthException("Xác minh OTP thất bại (${resp.statusCode})");
  }

  Future<void> sendResetLink(String email) async {
    final resp = await _api.post(
      "/auth/forgot-password",
      { "email": email },
    );

    if (resp.statusCode == 200) {
      return;
    }

    // cố gắng lấy message backend
    try {
      final body = jsonDecode(resp.body);
      if (body is Map && body["message"] is String) {
        throw AuthException(body["message"]);
      }
    } catch (_) {}

    throw AuthException("Không thể gửi email đặt lại mật khẩu (${resp.statusCode})");
  }
  // === QUÊN MẬT KHẨU (3 bước) ===

  // B1: Gửi OTP reset password về email
  // POST /auth/forgot-password/send
  Future<void> sendForgotPasswordOtp(String email) async {
    final http.Response resp = await _api.post(
      "/auth/forgot-password/send",
      {
        "email": email,
      },
    );

    if (resp.statusCode == 200) {
      // success, không cần data thêm
      return;
    }

    // lỗi -> cố gắng đọc message backend
    try {
      final body = jsonDecode(resp.body);
      if (body is Map && body["message"] is String) {
        throw AuthException(body["message"]);
      }
    } catch (_) {}

    throw AuthException("Không thể gửi OTP (${resp.statusCode})");
  }

  // B2: Xác thực OTP, backend trả resetToken
  // POST /auth/forgot-password/verify
  Future<String> verifyForgotPassword({
    required String email,
    required String otpCode,
  }) async {
    final http.Response resp = await _api.post(
      "/auth/forgot-password/verify",
      {
        "email": email,
        "otpCode": otpCode,
      },
    );

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      // backend trả { message: "...", resetToken: "..." }
      final token = data["resetToken"];
      if (token is String && token.isNotEmpty) {
        return token;
      }
      // nếu vì lý do gì backend không trả resetToken
      throw AuthException("Thiếu resetToken từ server");
    }

    try {
      final body = jsonDecode(resp.body);
      if (body is Map && body["message"] is String) {
        throw AuthException(body["message"]);
      }
    } catch (_) {}

    throw AuthException("OTP không hợp lệ (${resp.statusCode})");
  }

  // B3: Gửi mật khẩu mới kèm resetToken
  // POST /auth/forgot-password/reset
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    final http.Response resp = await _api.post(
      "/auth/forgot-password/reset",
      {
        "resetToken": resetToken,
        "newPassword": newPassword,
      },
    );

    if (resp.statusCode == 200) {
      // success đổi mật khẩu ok
      return;
    }

    try {
      final body = jsonDecode(resp.body);
      if (body is Map && body["message"] is String) {
        throw AuthException(body["message"]);
      }
    } catch (_) {}

    throw AuthException("Đổi mật khẩu thất bại (${resp.statusCode})");
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
