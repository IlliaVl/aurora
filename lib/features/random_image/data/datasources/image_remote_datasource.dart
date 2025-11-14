import 'package:aurora/core/error/exceptions.dart';
import 'package:aurora/features/random_image/data/models/image_model.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'image_remote_datasource_interface.dart';

/// --- Implementation ---
///
/// This class is responsible for making the actual HTTP call
/// to the remote API using the [Dio] client.
/// It implements the [ImageRemoteDataSourceInterface] contract.
@LazySingleton(as: ImageRemoteDataSourceInterface)
class ImageRemoteDataSource implements ImageRemoteDataSourceInterface {
  final Dio dio;
  final String _apiUrl =
      "https://november7-730026606190.europe-west1.run.app/image";

  ImageRemoteDataSource(this.dio);

  @override
  Future<ImageModel> getRandomImage() async {
    try {
      final response = await dio.get(_apiUrl);

      if (response.statusCode == 200) {
        return ImageModel.fromJson(response.data);
      } else {
        throw ServerException('Failed to load image: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors (e.g., network, timeout)
      throw ServerException('Failed to connect: ${e.message}');
    } catch (e) {
      // Handle parsing errors or other exceptions
      throw ServerException('An unexpected error occurred: ${e.toString()}');
    }
  }
}
