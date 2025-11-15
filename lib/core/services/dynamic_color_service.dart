import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:injectable/injectable.dart';

// A simple in-memory cache for the generated ColorSchemes.
final _cache = <String, ColorScheme>{};

/// --- Top-Level Function for Isolate ---
///
/// This function is responsible for all CPU-intensive work and
/// is run in a helper isolate via `compute()`.
///
/// It returns the BYTES (Uint8List) of the resized thumbnail.
Future<Uint8List> _generateThumbnailInIsolate(Uint8List imageBytes) async {
  try {
    // 1. Decode the image (CPU-intensive)
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Unable to decode image.');
    }

    // 2. --- CROP & RESIZE ---
    // We crop the image to a center square *first*,
    // then resize to a 100x100 thumbnail.
    // This ensures we are only analyzing the colors
    // that the user sees in the (BoxFit.cover) UI.
    final thumbnail = img.copyResizeCropSquare(
      image,
      size: 100, // 100x100 thumbnail
      interpolation: img.Interpolation.average,
    );

    // 3. Re-encode the thumbnail into bytes and return
    return img.encodePng(thumbnail);
  } catch (e) {
    debugPrint('Error in isolate: $e');
    rethrow;
  }
}

/// --- Service Class ---
///
/// Manages fetching and caching dynamic, accessible color schemes
/// from remote image URLs using an isolate-based pipeline.
@lazySingleton
class DynamicColorService {
  final http.Client _httpClient;

  DynamicColorService(this._httpClient);

  /// Fetches an image, processes it in an isolate, and returns a ColorScheme.
  Future<ColorScheme?> getColorSchemeFromUrl(String url) async {
    // 1. Check cache first
    if (_cache.containsKey(url)) {
      return _cache[url];
    }

    try {
      // 2. Fetch image bytes (Network I/O)
      final response = await _httpClient.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Uint8List imageBytes = response.bodyBytes;

        // 3. Offload CPU work to the helper isolate
        //    We get back the thumbnail bytes.
        final Uint8List thumbnailBytes = await compute(
          _generateThumbnailInIsolate,
          imageBytes,
        );

        // 4. --- RUN ON MAIN THREAD ---
        //    Now that we are back on the main thread (with the binding),
        //    we can safely generate the ColorScheme.
        final ColorScheme scheme = await ColorScheme.fromImageProvider(
          provider: MemoryImage(thumbnailBytes),
          brightness: Brightness.dark, // We want dark schemes
        );

        // 5. Cache and return the result
        _cache[url] = scheme;
        return scheme;
      }
    } catch (e) {
      debugPrint('Failed to generate color scheme: $e');
    }
    // Return null on failure
    return null;
  }
}
