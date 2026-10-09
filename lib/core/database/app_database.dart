import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tables/cache_entries.dart';

part 'app_database.g.dart';

/// App-wide Drift database. Feature phases contribute tables to the
/// `tables:` list and bump [schemaVersion] with a migration.
@DriftDatabase(tables: [CacheEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'marg'));

  /// Test seam: inject an in-memory executor.
  AppDatabase.withExecutor(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.createTable(cacheEntries);
        },
      );

  /// Insert or replace a cached payload.
  Future<void> upsertCache(String key, String payload) =>
      into(cacheEntries).insertOnConflictUpdate(
        CacheEntriesCompanion.insert(key: key, payload: payload, updatedAt: DateTime.now()),
      );

  /// Read a cached payload, or null if absent.
  Future<CacheEntry?> readCache(String key) =>
      (select(cacheEntries)..where((t) => t.key.equals(key))).getSingleOrNull();

  /// Delete a single cached payload.
  Future<void> deleteCache(String key) =>
      (delete(cacheEntries)..where((t) => t.key.equals(key))).go();

  /// All cached rows (for storage management).
  Future<List<CacheEntry>> allCache() => select(cacheEntries).get();

  /// Clear the entire cache.
  Future<void> clearCache() => delete(cacheEntries).go();
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});
