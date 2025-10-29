import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // chỉnh IP/port này cho đúng backend ASP.NET của bạn
  static const String baseUrl = "http://10.0.2.2:5091/api";

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse("$baseUrl$path");
    return await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
      },
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
