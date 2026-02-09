import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color secondaryColor = Color(0xFF10B981);
  static const Color accentColor = Color(0xFFF59E0B);
  static const Color dangerColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFFB923C);

  static const Color bgColor = Color(0xFFFAFAFA);
  static const Color darkBgColor = Color(0xFF1F2937);
  static const Color textColor = Color(0xFF1F2937);
  static const Color textLightColor = Color(0xFF6B7280);
  static const Color borderColor = Color(0xFFE5E7EB);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: bgColor,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: textColor,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBgColor,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Color(0xFF111827),
      foregroundColor: Colors.white,
    ),
  );
}

class AppColors {
  static const Color primary = AppTheme.primaryColor;
  static const Color secondary = AppTheme.secondaryColor;
  static const Color accent = AppTheme.accentColor;
  static const Color danger = AppTheme.dangerColor;
  static const Color warning = AppTheme.warningColor;
}
