import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

// --- Aurora Brand Colors ---
const Color auroraBlack = Color(0xFF1C1C1E); // A very dark, near-black grey
const Color auroraOrange = Color(0xFFD95A2B); // Rich, burnt-orange accent
const Color auroraWhite = Color(0xFFF5F5F7); // Slightly off-white

void main() {
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
      title: 'Aurora Image Fetcher',
      theme: darkTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark,
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // --- State Variables ---
  String? _imageUrl;
  bool _isLoading = false;
  String? _error;

  final String _apiUrl =
      "https://november7-730026606190.europe-west1.run.app/image";

  // --- Logic ---
  Future<void> _fetchImage() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http
          .get(Uri.parse(_apiUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _imageUrl = data['url'];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load image: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = "Oops! Something went wrong. Please try again.";
        _imageUrl = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "AURORA",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- The Image Display Area ---
              AspectRatio(
                aspectRatio: 1.0, // Enforces a square
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _buildImageWidget(),
                ),
              ),
              const SizedBox(height: 32),

              // --- The "Another" Button ---
              ElevatedButton(
                // Disable the button while loading
                onPressed: _isLoading ? null : _fetchImage,
                // Style is controlled by the ElevatedButtonTheme
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          // The color is set by ProgressIndicatorTheme
                        ),
                      )
                    : const Text("Another"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper widget to decide what to show in the image area
  Widget _buildImageWidget() {
    if (_error != null) {
      // --- Error State ---
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      );
    }

    if (_imageUrl != null) {
      // --- Success State ---
      return CachedNetworkImage(
        imageUrl: _imageUrl!,
        fit: BoxFit.cover,
        // --- Placeholder while loading image ---
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator()),
        // --- Widget to show if image fails to load ---
        errorWidget: (context, url, error) => Center(
          child: Icon(
            Icons.broken_image,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
            size: 40,
          ),
        ),
      );
    }

    // --- Initial Loading State ---
    // This is shown when _imageUrl is null and there's no error,
    // (e.g., during the very first load)
    return const Center(child: CircularProgressIndicator());
  }
}
