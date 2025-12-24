import 'dart:typed_data';

import 'package:aurora/core/error/exceptions.dart';
import 'package:aurora/features/random_image/data/models/image_model.dart';

/// --- Abstract Contract for Data Source ---
///
/// Defines the contract for the remote data source. This is used
/// by the Repository to decouple it from the concrete implementation.
abstract class ImageRemoteDataSourceInterface {
  /// Fetches the JSON model containing the random image URL.
  ///
  /// Throws a [ServerException] if any network call fails.
  Future<ImageModel> fetchRandomImageModel();

  /// Downloads the raw bytes for a specific image URL.
  ///
  /// Throws a [ServerException] if any network call fails.
  Future<Uint8List> downloadImage(String url);

  /// Gets the last successfully fetched image URL.
  /// Used for the blurred background.
  String? getImageUrlForBackground();
}
