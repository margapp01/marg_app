import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/core/database/app_database.dart';
import 'package:marg_app/core/offline/cache_through.dart';
import 'package:marg_app/core/offline/offline_cache.dart';

void main() {
  late AppDatabase db;
  late OfflineCache cache;

  setUp(() {
    db = AppDatabase.withExecutor(NativeDatabase.memory());
    cache = OfflineCache(db);
  });
  tearDown(() => db.close());

  group('OfflineCache', () {
    test('writes and reads back an object payload', () async {
      await cache.write('k', {'a': 1, 'b': 'x'});
      final hit = await cache.read('k');
      expect(hit, isNotNull);
      expect(hit!.asMap, {'a': 1, 'b': 'x'});
      expect(hit.cachedAt, isA<DateTime>());
    });

    test('writes and reads back a list payload', () async {
      await cache.write('list', [1, 2, 3]);
      expect((await cache.read('list'))!.asList, [1, 2, 3]);
    });

    test('returns null on a miss and overwrites on rewrite', () async {
      expect(await cache.read('nope'), isNull);
      await cache.write('k', {'v': 1});
      await cache.write('k', {'v': 2});
      expect((await cache.read('k'))!.asMap, {'v': 2});
      expect(await cache.count(), 1);
    });

    test('clear empties the cache', () async {
      await cache.write('a', {'v': 1});
      await cache.write('b', {'v': 2});
      expect(await cache.count(), 2);
      await cache.clear();
      expect(await cache.count(), 0);
    });
  });

  group('cacheThroughObject', () {
    DioException netError() => DioException(requestOptions: RequestOptions(path: '/x'));

    test('online: fetches, caches the raw payload, and parses', () async {
      final value = await cacheThroughObject<int>(
        key: 'home',
        fetch: () async => {'count': 7},
        parse: (m) => m['count'] as int,
        cache: cache,
      );
      expect(value, 7);
      expect((await cache.read('home'))!.asMap, {'count': 7});
    });

    test('offline: falls back to the cached payload', () async {
      await cache.write('home', {'count': 42});
      final value = await cacheThroughObject<int>(
        key: 'home',
        fetch: () async => throw netError(),
        parse: (m) => m['count'] as int,
        cache: cache,
      );
      expect(value, 42);
    });

    test('offline with no cache: rethrows', () async {
      expect(
        () => cacheThroughObject<int>(
          key: 'cold',
          fetch: () async => throw netError(),
          parse: (m) => m['count'] as int,
          cache: cache,
        ),
        throwsA(isA<DioException>()),
      );
    });

    test('cacheThroughList falls back to a cached list offline', () async {
      await cache.write('items', [10, 20]);
      final value = await cacheThroughList<int>(
        key: 'items',
        fetch: () async => throw netError(),
        parse: (l) => l.length,
        cache: cache,
      );
      expect(value, 2);
    });
  });
}
