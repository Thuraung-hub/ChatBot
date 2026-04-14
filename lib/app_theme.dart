import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  
  // NEW: Semantic colors for states and feedback
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF42A5F5);
  static const Color disabled = Color(0xFF424242);
  static const Color overlay = Color(0xFF000000);
  
  // NEW: Light variants for better visual hierarchy
  static const Color errorLight = Color(0x33EF5350);
  static const Color successLight = Color(0x3366BB6A);
  static const Color warningLight = Color(0x33FFA726);
  static const Color infoLight = Color(0x3342A5F5);
  static const Color primaryLight = Color(0x1AD4AF37);

  // Backward-compatible color aliases used throughout existing screens.
  static const Color screenBg = background;
  static const Color royalBlue = primary;
  static const Color deepButtonBg = surface;
  static const Color deepButtonBorder = border;
  static const Color primaryDark = primary;
  static const Color dark = textPrimary;
  static const Color textDark = textDarkBase;
  static const Color textGray = textSecondary;
  static const Color borderGray = border;
  static const Color bgGray = surface;
  static const Color red = error;
  static const Color redLight = errorLight;
  static const Color green = success;

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
        fontFamily: GoogleFonts.inter().fontFamily,
        textTheme: _buildTextTheme(),
        scaffoldBackgroundColor: background,
        appBarTheme: AppBarTheme(
          backgroundColor: background,
          foregroundColor: textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: GoogleFonts.montserrat(
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
            side: const BorderSide(color: border),
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

  /// Build text theme with Google Fonts
  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.montserrat(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        color: textPrimary,
      ),
      displayMedium: GoogleFonts.montserrat(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: textPrimary,
      ),
      displaySmall: GoogleFonts.montserrat(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: textPrimary,
      ),
      headlineLarge: GoogleFonts.montserrat(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: textPrimary,
      ),
      headlineMedium: GoogleFonts.montserrat(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: textPrimary,
      ),
      headlineSmall: GoogleFonts.montserrat(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: textPrimary,
      ),
      titleLarge: GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: textPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: textPrimary,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: textPrimary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        color: textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        color: textPrimary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        color: textSecondary,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: textPrimary,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: textPrimary,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: textSecondary,
      ),
    );
  }
}

