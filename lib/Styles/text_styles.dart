import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle titleLarge = TextStyle(
    color: AppColors.textWhite,
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyWhite = TextStyle(
    color: AppColors.textWhite,
    fontSize: 14,
  );
  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle heading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    color: Colors.white70,
  );
}
