import 'package:dio/dio.dart';

import 'offline_cache.dart';

/// Read-through cache for a single JSON `data` payload.
///
/// Online path: fetch → persist the raw payload → parse & return.
/// Offline / network-failure path: fall back to the last cached payload if one
/// exists; otherwise rethrow the original error (nothing to show).
///
/// Only network-shaped failures ([DioException]) trigger the fallback — a real
/// parse/programming error still surfaces so bugs aren't masked.
Future<T> cacheThroughObject<T>({
  required String key,
  required Future<Map<String, dynamic>> Function() fetch,
  required T Function(Map<String, dynamic>) parse,
  required OfflineCache cache,
}) async {
  try {
    final data = await fetch();
    await cache.write(key, data);
    return parse(data);
  } on DioException {
    final cached = await cache.read(key);
    if (cached != null) return parse(cached.asMap);
    rethrow;
  }
}

/// List-payload variant of [cacheThroughObject].
Future<T> cacheThroughList<T>({
  required String key,
  required Future<List<dynamic>> Function() fetch,
  required T Function(List<dynamic>) parse,
  required OfflineCache cache,
}) async {
  try {
    final data = await fetch();
    await cache.write(key, data);
    return parse(data);
  } on DioException {
    final cached = await cache.read(key);
    if (cached != null) return parse(cached.asList);
    rethrow;
  }
}
