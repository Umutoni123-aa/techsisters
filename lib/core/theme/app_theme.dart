import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF6A1B9A);
  static const secondary = Color(0xFFE91E63);
  static const background = Color(0xFFF8F5FA);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
      );
}