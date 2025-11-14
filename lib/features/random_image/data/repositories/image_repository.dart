import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:aurora/core/error/exceptions.dart';
import 'package:aurora/core/error/failures.dart';
import 'package:aurora/features/random_image/data/datasources/image_remote_datasource_interface.dart';
import 'package:aurora/features/random_image/domain/entities/image_entity.dart';
import 'package:aurora/features/random_image/domain/repositories/image_repository_interface.dart';

/// --- Concrete Implementation of Repository ---
/// This class implements the Domain layer's contract.
/// It's responsible for coordinating data from data sources
/// (remote, local) and handling exceptions.
@LazySingleton(as: ImageRepositoryInterface)
class ImageRepository implements ImageRepositoryInterface {
  final ImageRemoteDataSourceInterface remoteDataSource;

  ImageRepository(this.remoteDataSource);

  @override
  Future<Either<Failure, ImageEntity>> getRandomImage() async {
    try {
      final remoteImage = await remoteDataSource.getRandomImage();
      return Right(remoteImage.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
