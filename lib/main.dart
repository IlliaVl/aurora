import 'package:aurora/core/di/injection_container.dart';
import 'package:aurora/features/random_image/presentation/pages/random_image_page.dart';
import 'package:flutter/material.dart';

// --- Aurora Brand Colors ---
const Color auroraBlack = Color(0xFF1C1C1E); // A very dark, near-black grey
const Color auroraOrange = Color(0xFFD95A2B); // Rich, burnt-orange accent
const Color auroraWhite = Color(0xFFF5F5F7); // Slightly off-white

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize dependencies
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // --- The core dark theme ---
    final ThemeData darkTheme = ThemeData(
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
          // Button background
          foregroundColor: auroraWhite,
          // Button text
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      // Theme for the loading indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: auroraOrange,
      ),
    );

    return MaterialApp(
      title: 'Aurora',
      // --- Enforce dark theme ---
      // This matches the strong brand identity
      themeMode: ThemeMode.dark,
      theme: darkTheme,
      darkTheme: darkTheme,
      debugShowCheckedModeBanner: false,
      // The entry point is now the BLoC-powered page
      home: const RandomImagePage(),
    );
  }
}
