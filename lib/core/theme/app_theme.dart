import 'package:flutter/material.dart';

class AppColors {
  // Violet (from Figma)
  static const primary = Color(0xFF6B21A8);
  static const light = Color(0xFF7C3AED);
  static const deep = Color(0xFF4C1D95);
  static const night = Color(0xFF1E1B4B);
  static const violetSurface = Color(0xFFF3E8FF);
  static const border = Color(0xFFE9D5FF);
  static const soft = Color(0xFFC4B5FD);

  // Coral (from Figma)
  static const coral = Color(0xFFF43F5E);
  static const coralSurface = Color(0xFFFFF1F2);

  
  static const background = Color(0xFFF5F3FA);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.light,
        ),
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