part of 'cli.dart';

mixin _AutoCache {
  Future<Result> maybeCached({
    required String cacheName,
    required bool cacheIf,
    required Future<Result> Function() retrieve,
  }) async {
    logVerbose("cache $cacheName? $cacheIf");
    if (cacheIf) {
      return await cached(
        key: cacheName,
        maxAge: _cachedDuration,
        retrieve: retrieve,
      );
    } else {
      return await retrieve();
    }
  }
}
