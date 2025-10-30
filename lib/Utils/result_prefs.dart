import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LastExamResult {
  final int boDeId;
  final String boDeName;
  final String maHang;
  final int tong;
  final int dung;
  final int sai;
  final int timestamp;

  LastExamResult({
    required this.boDeId,
    required this.boDeName,
    required this.maHang,
    required this.tong,
    required this.dung,
    required this.sai,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'boDeId': boDeId,
    'boDeName': boDeName,
    'maHang': maHang,
    'tong': tong,
    'dung': dung,
    'sai': sai,
    'ts': timestamp,
  };

  static LastExamResult fromJson(Map<String, dynamic> j) => LastExamResult(
    boDeId: j['boDeId'],
    boDeName: j['boDeName'] ?? '',
    maHang: j['maHang'] ?? '',
    tong: j['tong'] ?? 0,
    dung: j['dung'] ?? 0,
    sai: j['sai'] ?? 0,
    timestamp: j['ts'] ?? 0,
  );
}

class ResultPrefs {
  static const _kGlobal = 'last_exam_result';
  static String _kExam(int id) => 'last_exam_result_$id';

  // Lưu kết quả gần nhất toàn app (tuỳ dùng)
  static Future<void> saveGlobal(LastExamResult r) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kGlobal, jsonEncode(r.toJson()));
  }

  // Lưu/đọc kết quả cho **một bộ đề**
  static Future<void> saveForExam(LastExamResult r) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kExam(r.boDeId), jsonEncode(r.toJson()));
  }

  static Future<LastExamResult?> loadForExam(int boDeId) async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString(_kExam(boDeId));
    if (s == null || s.isEmpty) return null;
    return LastExamResult.fromJson(jsonDecode(s));
  }
}
