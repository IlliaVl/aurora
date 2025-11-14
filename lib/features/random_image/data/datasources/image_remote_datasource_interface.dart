import 'package:aurora/core/error/exceptions.dart';
import 'package:aurora/features/random_image/data/models/image_model.dart';

/// --- Abstract Contract for Data Source ---
///
/// Defines the contract for the remote data source. This is used
/// by the Repository to decouple it from the concrete implementation.
abstract class ImageRemoteDataSourceInterface {
  /// Fetches a random image from the remote API.
  ///
  /// Throws a [ServerException] if the network call fails.
  Future<ImageModel> getRandomImage();
}
