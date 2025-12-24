import 'package:aurora/core/di/injection_container.dart';
import 'package:aurora/core/theme/app_theme.dart';
import 'package:aurora/features/random_image/presentation/pages/random_image_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

// --- Aurora Brand Colors ---
const Color auroraBlack = Color(0xFF1C1C1E); // A very dark, near-black grey
const Color auroraOrange = Color(0xFFD95A2B); // Rich, burnt-orange accent
const Color auroraWhite = Color(0xFFF5F5F7); // Slightly off-white

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // --- 1. Init Hive ---
  await Hive.initFlutter();

  // --- FIX: Open the correct box name ---
  // Must match the _boxName in ImageLocalDataSource ('image_cache_v2')
  await Hive.openBox('image_cache');
  // Initialize dependencies
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aurora',
      // --- Respect System Settings ---
      // This allows the app to switch between light and dark modes automatically
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      // Set to true to visually debug accessibility touch targets and labels
      // showSemanticsDebugger: true,
      home: const RandomImagePage(),
    );
  }
}
