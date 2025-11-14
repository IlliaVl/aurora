/// Thrown when a server call fails (e.g., 4xx, 5xx)
class ServerException implements Exception {
  final String message;

  ServerException(this.message);
}

/// Thrown when a local cache operation fails
class CacheException implements Exception {
  final String message;

  CacheException(this.message);
}
