import 'package:flutter/material.dart';

class CoutelyaColors {
  static const purple = Color(0xFF5B1778);
  static const purpleDark = Color(0xFF35104A);
  static const purpleSoft = Color(0xFFF4ECF8);
  static const gold = Color(0xFFE3A018);
  static const goldSoft = Color(0xFFFFF4D8);
  static const green = Color(0xFF159B64);
  static const greenSoft = Color(0xFFE8F7EF);
  static const red = Color(0xFFE64046);
  static const redSoft = Color(0xFFFFECEE);
  static const blue = Color(0xFF3978D3);
  static const ink = Color(0xFF211829);
  static const muted = Color(0xFF756C7A);
  static const background = Color(0xFFFBF9FC);
  static const border = Color(0xFFE8E1EA);
}

class CoutelyaTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: CoutelyaColors.purple,
      brightness: Brightness.light,
      primary: CoutelyaColors.purple,
      secondary: CoutelyaColors.gold,
      surface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: CoutelyaColors.background,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: CoutelyaColors.background,
        foregroundColor: CoutelyaColors.ink,
        titleTextStyle: TextStyle(
          color: CoutelyaColors.ink,
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CoutelyaColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CoutelyaColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CoutelyaColors.purple, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: CoutelyaColors.purple,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: CoutelyaColors.border),
        ),
      ),
      dividerTheme: const DividerThemeData(color: CoutelyaColors.border),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
