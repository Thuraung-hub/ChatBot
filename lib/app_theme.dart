import 'package:flutter/material.dart';

class AppTheme {
  static const Color screenBg = Color(0xFF0B121C);
  static const Color royalBlue = Color(0xFF137FEC);
  static const Color deepButtonBg = Color(0xFF1A1E26);
  static const Color deepButtonBorder = Color(0xFF2D3748);
  static const Color primary = Color(0xFF4F46E5);    // indigo-600
  static const Color primaryLight = Color(0xFFEEF2FF); // indigo-50
  static const Color primaryDark = Color(0xFF4338CA); // indigo-700
  static const Color dark = Color(0xFF111827);        // gray-900
  static const Color textGray = Color(0xFF6B7280);    // gray-500
  static const Color borderGray = Color(0xFFF3F4F6);  // gray-100
  static const Color bgGray = Color(0xFFF9FAFB);      // gray-50
  static const Color red = Color(0xFFDC2626);         // red-600
  static const Color redLight = Color(0xFFFEF2F2);    // red-50
  static const Color green = Color(0xFF16A34A);       // green-600

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ),
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: screenBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: dark,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: dark,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: borderGray),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: bgGray,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          prefixIconColor: textGray,
          suffixIconColor: textGray,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: royalBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
            minimumSize: const Size.fromHeight(52),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          contentTextStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      );
}
