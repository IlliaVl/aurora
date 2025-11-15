import 'dart:typed_data'; // <-- ADDED
import 'package:equatable/equatable.dart';

/// --- Business Entity ---
///
/// This object represents the actual image data
/// that our UI will display.
class ImageEntity extends Equatable {
  // --- UPDATED ---
  /// The raw bytes of the image.
  final Uint8List imageBytes;

  const ImageEntity({required this.imageBytes});

  @override
  List<Object> get props => [imageBytes];
}
