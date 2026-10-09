import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/entities/explore_models.dart';

/// A page of temples plus its total (for "N temples" labels + pagination).
class TemplePage {
  const TemplePage({required this.temples, required this.total});
  final List<ExploreTemple> temples;
  final int total;
}

/// Talks to the public temple + location + visit endpoints. Reuses the
/// authenticated Dio (public endpoints ignore the token; `/my/visits` needs it).
class ExploreRemoteDataSource {
  ExploreRemoteDataSource(this._dio);

  final Dio _dio;

  Map<String, dynamic> _envelope(Response<dynamic> res) => (res.data as Map).cast<String, dynamic>();
  List<dynamic> _dataList(Response<dynamic> res) => (_envelope(res)['data'] as List?) ?? const [];
  int _total(Response<dynamic> res) {
    final p = (_envelope(res)['pagination'] as Map?)?.cast<String, dynamic>();
    return (p?['total'] as num?)?.toInt() ?? _dataList(res).length;
  }

  List<ExploreTemple> _parse(Response<dynamic> res) => _dataList(res)
      .whereType<Map<dynamic, dynamic>>()
      .map((e) => ExploreTemple.fromJson(e.cast<String, dynamic>()))
      .toList(growable: false);

  /// `/temples/nearby` → `{ temple, distanceMeters }[]`, already distance-sorted.
  Future<List<ExploreTemple>> nearby({
    required double latitude,
    required double longitude,
    required int radiusMeters,
    int limit = 30,
  }) async {
    final res = await _dio.get<dynamic>(
      '/temples/nearby',
      queryParameters: {'latitude': latitude, 'longitude': longitude, 'radius': radiusMeters, 'limit': limit},
    );
    return _parse(res);
  }

  /// `/temples` (or `/temples/search` when [q] is set) — filtered + sorted page.
  Future<TemplePage> list({
    String? q,
    String? deity,
    String? stateId,
    String? cityId,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
    int page = 1,
    int limit = 20,
  }) async {
    final path = (q != null && q.trim().isNotEmpty) ? '/temples/search' : '/temples';
    final res = await _dio.get<dynamic>(
      path,
      queryParameters: {
        if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
        'deity': ?deity,
        'stateId': ?stateId,
        'cityId': ?cityId,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
        'page': page,
        'limit': limit,
      },
    );
    return TemplePage(temples: _parse(res), total: _total(res));
  }

  /// Published-temple count for a filter (deity or state), via `limit=1` total.
  Future<List<ExploreStateItem>> states() async {
    final res = await _dio.get<dynamic>(
      '/states',
      queryParameters: const {'page': 1, 'limit': 100, 'sortBy': 'name', 'sortOrder': 'asc'},
    );
    return _dataList(res)
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => ExploreStateItem.fromJson(e.cast<String, dynamic>()))
        .toList(growable: false);
  }

  /// `/my/saved-temples` — the devotee's wishlist, newest first.
  Future<List<SavedTemple>> savedTemples({int limit = 50}) async {
    final res = await _dio.get<dynamic>('/my/saved-temples', queryParameters: {'page': 1, 'limit': limit});
    return _dataList(res)
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => SavedTemple.fromJson(e.cast<String, dynamic>()))
        .toList(growable: false);
  }

  Future<void> saveTemple(String templeId) => _dio.put<dynamic>('/my/saved-temples/$templeId');

  Future<void> unsaveTemple(String templeId) => _dio.delete<dynamic>('/my/saved-temples/$templeId');

  Future<List<VisitRecord>> visits() async {
    final res = await _dio.get<dynamic>(
      '/my/visits',
      queryParameters: const {'page': 1, 'limit': 100, 'sortOrder': 'desc'},
    );
    return _dataList(res)
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => VisitRecord.fromJson(e.cast<String, dynamic>()))
        .toList(growable: false);
  }
}

final exploreRemoteDataSourceProvider = Provider<ExploreRemoteDataSource>(
  (ref) => ExploreRemoteDataSource(ref.watch(dioProvider)),
);
