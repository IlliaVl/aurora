import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:aurora/core/error/failures.dart';
import 'package:aurora/features/random_image/domain/entities/image_entity.dart';
import 'package:aurora/features/random_image/domain/repositories/image_repository_interface.dart';

/// This class encapsulates the single business rule of getting an image.
@lazySingleton
class GetRandomImage {
  final ImageRepositoryInterface repository;

  GetRandomImage(this.repository);

  Future<Either<Failure, ImageEntity>> call() async =>
      await repository.getRandomImage();
}
