import 'package:dartz/dartz.dart';
import 'package:aurora/core/error/failures.dart';
import 'package:aurora/features/random_image/domain/entities/image_entity.dart';

/// Defines the contract for the Image Repository.
/// The Domain layer depends on this, not the implementation.
abstract class ImageRepositoryInterface {
  /// Fetches a random image.
  ///
  /// Returns [Either] a [Failure] or an [ImageEntity].
  Future<Either<Failure, ImageEntity>> getRandomImage();
}
