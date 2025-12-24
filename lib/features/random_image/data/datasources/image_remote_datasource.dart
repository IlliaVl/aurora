import 'package:aurora/core/error/exceptions.dart';
import 'package:aurora/features/random_image/data/datasources/image_remote_datasource_interface.dart';
import 'package:aurora/features/random_image/data/models/image_model.dart';
import 'package:aurora/features/random_image/domain/entities/image_entity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'dart:typed_data';

@LazySingleton(as: ImageRemoteDataSourceInterface)
class ImageRemoteDataSource implements ImageRemoteDataSourceInterface {
  final Dio dio;
  final String _apiUrl =
      "https://november7-730026606190.europe-west1.run.app/image";

  ImageRemoteDataSource(this.dio);

  @visibleForTesting
  String? lastImageUrl;

  @override
  Future<ImageModel> fetchRandomImageModel() async {
    try {
      // 1. Get the JSON which contains the URL
      final response = await dio.get(_apiUrl);

      if (response.statusCode != 200) {
        throw ServerException(
          'Failed to load image URL: ${response.statusCode}',
        );
      }

      final imageModel = ImageModel.fromJson(response.data);
      lastImageUrl = imageModel.url;
      return imageModel;
    } on DioException catch (e) {
      throw ServerException('Could not connect to server. Please try again.');
    } catch (e) {
      throw ServerException('An unexpected error occurred.');
    }
  }

  @override
  Future<Uint8List> downloadImage(String url) async {
    try {
      // 2. Download the actual bytes from the specific URL
      final response = await dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        return Uint8List.fromList(response.data);
      } else {
        throw ServerException(
          'Failed to download image: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // We catch the technical error and convert it to a
      // simple, user-friendly message.
      if (e.response != null && e.response?.statusCode == 404) {
        throw ServerException(
          'Oops! The image could not be found.',
        );
      } else {
        // Handle other Dio errors (network, timeout, etc.)
        throw ServerException('Could not connect to server. Please try again.');
      }
    } catch (e) {
      // Handle parsing errors or other unexpected exceptions
      throw ServerException('An unexpected error occurred.');
    }
  }

  // --- We need a separate method for the background ---
  // The UI will call this *after* getting the image bytes,
  // to prevent the background from loading *before* the main image.
  @override
  String? getImageUrlForBackground() => lastImageUrl;
}
