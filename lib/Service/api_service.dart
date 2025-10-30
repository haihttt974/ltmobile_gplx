// lib/Service/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Đổi đúng PORT cho backend của bạn
  static const String baseUrl = "http://10.0.2.2:5091/api";

  // 🧩 Lấy origin để load static files ở wwwroot (bỏ /api)
  static String get staticBase {
    final u = Uri.parse(baseUrl);
    final port = (u.hasPort && u.port != 0) ? ':${u.port}' : '';
    return '${u.scheme}://${u.host}$port';
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse("$baseUrl$path");
    return await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
  }

  Future<http.Response> get(String path, {String? token}) async {
    final uri = Uri.parse("$baseUrl$path");
    return await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );
  }
}
