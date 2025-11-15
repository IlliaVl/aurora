import 'package:aurora/core/error/exceptions.dart';

// --- We now return ImageEntity ---
import 'package:aurora/features/random_image/domain/entities/image_entity.dart';

/// --- Abstract Contract for Data Source ---
///
/// Defines the contract for the remote data source. This is used
/// by the Repository to decouple it from the concrete implementation.
abstract class ImageRemoteDataSourceInterface {
  /// Fetches a random image URL and then fetches the image bytes.
  ///
  /// Throws a [ServerException] if any network call fails.
  Future<ImageEntity> getRandomImage();

  /// Gets the last successfully fetched image URL.
  /// Used for the blurred background.
  String? getImageUrlForBackground();
}
