import 'package:flutter/material.dart';

class AppTheme {
  static const _radius = 16.0;

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,

      // Nền sáng
      scaffoldBackgroundColor: const Color(0xFFF6F7FB),

      // Bảng màu seed (giữ seed bạn đang dùng)
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),

      // AppBar gọn, chữ đậm
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),

      // ✅ Dùng CardThemeData để khớp kiểu
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
      ),

      // Divider nhẹ
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE9ECF2),
        thickness: 1,
        space: 1,
      ),

      // ListTile mặc định không padding hai bên
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  // ===== Helpers =====

  /// Gradient header cho SectionCard
  static BoxDecoration headerGradient(Color a, Color b) => BoxDecoration(
    gradient: LinearGradient(
      colors: [a, b],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(18),
  );

  /// Nền mềm cho TipBlock
  static BoxDecoration softSurface(BuildContext ctx) => BoxDecoration(
    color: Theme.of(ctx).cardColor,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: const Color(0xFFE9ECF2)),
  );

  /// Hộp thông tin (info/warn/danger)
  static BoxDecoration infoBox(Color bg) => BoxDecoration(
    color: bg,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: bg.withOpacity(.6)),
  );
}
