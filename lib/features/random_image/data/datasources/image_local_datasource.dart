import 'dart:typed_data';
import 'package:hive_ce/hive.dart';
import 'package:injectable/injectable.dart';

/// Contract for local storage of image bytes
abstract class ImageLocalDataSourceInterface {
  Future<void> cacheImage(String url, Uint8List bytes);

  Uint8List? getCachedImage(String url);
}

@LazySingleton(as: ImageLocalDataSourceInterface)
class ImageLocalDataSource implements ImageLocalDataSourceInterface {
  static const String _boxName = 'image_cache';

  @override
  Future<void> cacheImage(String url, Uint8List bytes) async {
    final box = Hive.box(_boxName);
    await box.put(url, bytes);
  }

  @override
  Uint8List? getCachedImage(String url) {
    final box = Hive.box(_boxName);
    final dynamic data = box.get(url);

    if (data != null) {
      if (data is Uint8List) return data;
      if (data is List<int>) return Uint8List.fromList(data);
    }
    return null; // Cache miss
  }
}
