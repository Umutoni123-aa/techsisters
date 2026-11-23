import 'package:flutter/material.dart';

class AppColors {
  // Violet
  static const primary = Color(0xFF6B21A8);
  static const light = Color(0xFF7C3AED);
  static const deep = Color(0xFF4C1D95);
  static const night = Color(0xFF1E1B4B);
  static const violetSurface = Color(0xFFF3E8FF);
  static const violetBorder = Color(0xFFE9D5FF);
  static const soft = Color(0xFFC4B5FD);

  // Coral
  static const coral = Color(0xFFF43F5E);
  static const coralSurface = Color(0xFFFFF1F2);

  // Emerald
  static const emerald = Color(0xFF10B981);
  static const emeraldDark = Color(0xFF059669);
  static const emeraldSurface = Color(0xFFECFDF5);

  // Orange
  static const orange = Color(0xFFF97316);
  static const orangeSurface = Color(0xFFFFF7ED);

  // Amber
  static const amber = Color(0xFFF59E0B);
  static const amberSurface = Color(0xFFFFFBEB);

  // Slate (text and lines)
  static const slate900 = Color(0xFF0F172A);
  static const slate600 = Color(0xFF475569);
  static const slate500 = Color(0xFF64748B);
  static const slate400 = Color(0xFF94A3B8);
  static const slate300 = Color(0xFFCBD5E1);
  static const slateBorder = Color(0xFFE2E8F0);
  static const slateDivider = Color(0xFFF1F5F9);

  // Surfaces
  static const background = Color(0xFFF8F9FA);
  static const white = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.light,
      surface: AppColors.white,
      error: AppColors.coral,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.slate900),
      bodySmall: TextStyle(color: AppColors.slate600),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
  );
}
