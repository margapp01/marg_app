import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';

/// A decoded cache hit: the stored JSON plus when it was written.
class CachedPayload {
  const CachedPayload(this.json, this.cachedAt);
  final Object json;
  final DateTime cachedAt;

  Map<String, dynamic> get asMap => (json as Map).cast<String, dynamic>();
  List<dynamic> get asList => json as List;
}

/// Drift-backed JSON read-through cache for offline support. Stores raw endpoint
/// `data` payloads (objects or arrays) keyed by a stable string, so any screen
/// can render its last-known-good state without a network connection.
class OfflineCache {
  OfflineCache(this._db);
  final AppDatabase _db;

  Future<void> write(String key, Object json) => _db.upsertCache(key, jsonEncode(json));

  Future<CachedPayload?> read(String key) async {
    final row = await _db.readCache(key);
    if (row == null) return null;
    try {
      return CachedPayload(jsonDecode(row.payload) as Object, row.updatedAt);
    } catch (_) {
      return null; // corrupt entry — treat as a miss
    }
  }

  Future<void> remove(String key) => _db.deleteCache(key);
  Future<void> clear() => _db.clearCache();

  /// Total number of cached entries (for storage management).
  Future<int> count() async => (await _db.allCache()).length;

  /// Approximate cached bytes across all entries (UTF-16 payload length).
  Future<int> approximateBytes() async =>
      (await _db.allCache()).fold<int>(0, (sum, e) => sum + e.payload.length);
}

final offlineCacheProvider = Provider<OfflineCache>(
  (ref) => OfflineCache(ref.watch(appDatabaseProvider)),
);
