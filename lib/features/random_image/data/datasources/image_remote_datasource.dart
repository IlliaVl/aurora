import 'dart:typed_data'; // <-- ADDED
import 'package:aurora/core/error/exceptions.dart';
import 'package:aurora/features/random_image/data/datasources/image_remote_datasource_interface.dart';
import 'package:aurora/features/random_image/data/models/image_model.dart';

// --- We need ImageEntity ---
import 'package:aurora/features/random_image/domain/entities/image_entity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart'; // for @visibleForTesting
import 'package:injectable/injectable.dart';

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

  @visibleForTesting
  String? lastImageUrl;

  @override
  Future<ImageEntity> getRandomImage() async {
    try {
      // --- Step 1: Get the Image URL ---
      final response = await dio.get(_apiUrl);

      if (response.statusCode != 200) {
        throw ServerException(
          'Failed to load image URL: ${response.statusCode}',
        );
      }

      final imageModel = ImageModel.fromJson(response.data);
      lastImageUrl = imageModel.url; // Save for background

      // --- Step 2: Get the Image Bytes ---
      // This will throw a DioException (404) if the URL is bad
      final imageResponse = await dio.get(
        imageModel.url,
        // We must tell Dio to download this as raw bytes
        options: Options(responseType: ResponseType.bytes),
      );

      if (imageResponse.statusCode == 200) {
        // Return the entity with the raw bytes
        return ImageEntity(imageBytes: Uint8List.fromList(imageResponse.data));
      } else {
        throw ServerException(
          'Failed to download image: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // --- THIS IS THE FIX ---
      // If the image download fails (404, etc.), this will catch it
      // and throw a ServerException, which the BLoC can handle.
      throw ServerException('Failed to connect: ${e.message}');
    } catch (e) {
      // Handle parsing errors or other exceptions
      throw ServerException('An unexpected error occurred: ${e.toString()}');
    }
  }

  // --- We need a separate method for the background ---
  // The UI will call this *after* getting the image bytes,
  // to prevent the background from loading *before* the main image.
  @override
  String? getImageUrlForBackground() {
    return lastImageUrl;
  }
}
