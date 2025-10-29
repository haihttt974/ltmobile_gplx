import 'package:flutter/material.dart';

class AppTheme {
  static const _radius = 16.0;

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF6F7FB),
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),

      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
      ),

      dividerColor: const Color(0xFFE9ECF2),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  // Helpers for gradient section headers
  static BoxDecoration headerGradient(Color a, Color b) => BoxDecoration(
    gradient: LinearGradient(
      colors: [a, b],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(18),
  );

  static BoxDecoration softSurface(BuildContext ctx) => BoxDecoration(
    color: Theme.of(ctx).cardColor,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: const Color(0xFFE9ECF2)),
  );

  static BoxDecoration infoBox(Color bg) => BoxDecoration(
    color: bg,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: bg.withOpacity(.6)),
  );
}
