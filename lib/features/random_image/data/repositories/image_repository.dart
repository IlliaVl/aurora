import 'package:aurora/features/random_image/data/datasources/image_local_datasource.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:aurora/core/error/exceptions.dart';
import 'package:aurora/core/error/failures.dart';
import 'package:aurora/features/random_image/data/datasources/image_remote_datasource_interface.dart';
import 'package:aurora/features/random_image/domain/entities/image_entity.dart';
import 'package:aurora/features/random_image/domain/repositories/image_repository_interface.dart';

/// --- Concrete Implementation of Repository ---
/// This class implements the Domain layer's contract.
/// It's responsible for coordinating data from the local/remote
/// data source and handling exceptions.
@LazySingleton(as: ImageRepositoryInterface)
class ImageRepository implements ImageRepositoryInterface {
  final ImageRemoteDataSourceInterface remoteDataSource;
  final ImageLocalDataSourceInterface localDataSource;

  ImageRepository(this.remoteDataSource, this.localDataSource);

  @override
  Future<Either<Failure, ImageEntity>> getRandomImage() async {
    try {
      // 1. Get the URL for the next random image
      final imageModel = await remoteDataSource.fetchRandomImageModel();
      final url = imageModel.url;

      // 2. CHECK HIVE: Do we already have bytes for this URL?
      final cachedBytes = localDataSource.getCachedImage(url);

      if (cachedBytes != null) {
        // --- CACHE HIT ---
        // Return bytes immediately without downloading
        return Right(ImageEntity(imageBytes: cachedBytes));
      }

      // --- CACHE MISS ---
      // 3. Download bytes from network
      final remoteBytes = await remoteDataSource.downloadImage(url);

      // 4. Save to Hive for next time
      await localDataSource.cacheImage(url, remoteBytes);

      return Right(ImageEntity(imageBytes: remoteBytes));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure("An unexpected error occurred"));
    }
  }
}
