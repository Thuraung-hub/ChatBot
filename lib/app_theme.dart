import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color primary = Color(0xFFD4AF37);
  static const Color onPrimary = Color(0xFF111111);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textDarkBase = Color(0xFF111111);
  static const Color border = Color(0xFF2A2A2A);
  static const Color error = Color(0xFFEF5350);
  static const Color success = Color(0xFF66BB6A);

  // Backward-compatible color aliases used throughout existing screens.
  static const Color screenBg = background;
  static const Color royalBlue = primary;
  static const Color deepButtonBg = surface;
  static const Color deepButtonBorder = border;
  static const Color primaryLight = surface;
  static const Color primaryDark = primary;
  static const Color dark = textPrimary;
  static const Color textDark = textDarkBase;
  static const Color textGray = textSecondary;
  static const Color borderGray = border;
  static const Color bgGray = surface;
  static const Color red = error;
  static const Color redLight = Color(0x33EF5350);
  static const Color green = success;

  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 57,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.0,
      color: textPrimary,
    ),
    displayMedium: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 45,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.8,
      color: textPrimary,
    ),
    displaySmall: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 36,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.6,
      color: textPrimary,
    ),
    headlineLarge: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      color: textPrimary,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
      color: textPrimary,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 24,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
      color: textPrimary,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
      color: textPrimary,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: textPrimary,
    ),
    titleSmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: textPrimary,
    ),
    bodyLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.1,
      color: textPrimary,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.1,
      color: textPrimary,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.2,
      color: textSecondary,
    ),
    labelLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: textPrimary,
    ),
    labelMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      color: textPrimary,
    ),
    labelSmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      color: textSecondary,
    ),
  );

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          onPrimary: onPrimary,
          secondary: primary,
          surface: surface,
          onSurface: textPrimary,
          error: error,
          onError: Colors.white,
        ),
        fontFamily: 'Inter',
        textTheme: _textTheme,
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          foregroundColor: textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'Montserrat',
            color: textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.2,
          ),
        ),
        cardTheme: CardThemeData(
          color: surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: border),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          prefixIconColor: textSecondary,
          suffixIconColor: textSecondary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: border),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
            minimumSize: const Size.fromHeight(52),
            textStyle: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              letterSpacing: 0.2,
            ),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: surface,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          contentTextStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
      );
}
