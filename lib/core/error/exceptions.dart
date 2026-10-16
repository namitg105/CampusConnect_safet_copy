/// Thrown by remote data sources when a Firebase call fails.
/// Repositories catch it and turn it into a `ServerFailure`.
class ServerException implements Exception {
  final String message;
  const ServerException(this.message);

  @override
  String toString() => message;
}

/// Thrown by local data sources when reading/writing the cache fails.
class CacheException implements Exception {
  final String message;
  const CacheException(this.message);

  @override
  String toString() => message;
}
