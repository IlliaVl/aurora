import 'package:flutter/material.dart';

// --- Aurora Brand Colors ---
const Color auroraBlack = Color(0xFF1C1C1E); // A very dark, near-black grey
const Color auroraOrange = Color(0xFFD95A2B); // Rich, burnt-orange accent
const Color auroraWhite = Color(0xFFF5F5F7); // Slightly off-white

class AppTheme {
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: auroraBlack,
    // The brand colors for the main color scheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: auroraOrange,
      brightness: Brightness.dark,
      primary: auroraOrange,
      onPrimary: auroraWhite,
      surface: auroraBlack,
      onSurface: auroraWhite,
      error: Colors.redAccent,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: auroraWhite,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: auroraOrange,
        foregroundColor: auroraWhite,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: auroraOrange,
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    scaffoldBackgroundColor: auroraWhite,
    colorScheme: ColorScheme.fromSeed(
      seedColor: auroraOrange,
      brightness: Brightness.light,
      primary: auroraOrange,
      onPrimary: Colors.white,
      surface: auroraWhite,
      onSurface: Colors.black,
      error: Colors.redAccent,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.black, // Dark text for light background
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        // As requested: Black button
        foregroundColor: auroraOrange,
        // As requested: Orange text
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: auroraOrange,
    ),
  );
}
