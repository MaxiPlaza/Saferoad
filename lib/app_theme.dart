import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF0066CC);
  static const Color secondaryColor = Color(0xFF00CC66);
  static const Color errorColor = Color(0xFFCC0000);
  static const Color warningColor = Color(0xFFFFCC00);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}
