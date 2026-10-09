import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/entities/my_route.dart';
import '../../domain/entities/route_progress.dart';
import '../../domain/entities/yatra_route.dart';

/// Talks to `/routes`, `/routes/:id/progress`, `/my/routes`, `/my/visits`.
class RoutesRemoteDataSource {
  RoutesRemoteDataSource(this._dio);

  final Dio _dio;

  Map<String, dynamic> _data(Response<dynamic> res) =>
      ((res.data as Map)['data'] as Map).cast<String, dynamic>();

  List<dynamic> _dataList(Response<dynamic> res) =>
      ((res.data as Map)['data'] as List?) ?? const [];

  Future<List<YatraRoute>> list({String? type, String? query}) async {
    final res = await _dio.get<dynamic>('/routes', queryParameters: {
      'page': 1,
      'limit': 50,
      'type': ?type,
      if (query != null && query.isNotEmpty) 'q': query,
    });
    return _dataList(res)
        .whereType<Map<dynamic, dynamic>>()
        .map((m) => YatraRoute.fromJson(m.cast<String, dynamic>()))
        .where((r) => r.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<YatraRoute> detail(String slug) async {
    final res = await _dio.get<dynamic>('/routes/$slug');
    return YatraRoute.fromJson(_data(res));
  }

  Future<RouteProgress> progress(String routeId) async {
    final res = await _dio.get<dynamic>('/routes/$routeId/progress');
    return RouteProgress.fromJson(_data(res));
  }

  Future<List<MyRouteProgress>> myRoutes() async {
    final res = await _dio.get<dynamic>('/my/routes');
    return _dataList(res)
        .whereType<Map<dynamic, dynamic>>()
        .map((m) => MyRouteProgress.fromJson(m.cast<String, dynamic>()))
        .where((r) => r.routeId.isNotEmpty)
        .toList(growable: false);
  }

  /// Save a route to the user's journeys (Planned).
  Future<void> enroll(String routeId) => _dio.post<dynamic>('/my/routes/$routeId/enroll');

  /// Remove a not-yet-started route from the user's journeys.
  Future<void> unenroll(String routeId) => _dio.delete<dynamic>('/my/routes/$routeId/enroll');

  /// Download the route completion certificate PDF bytes (authenticated).
  Future<List<int>> certificate(String routeId) async {
    final res = await _dio.get<List<int>>(
      '/my/routes/$routeId/certificate',
      options: Options(responseType: ResponseType.bytes),
    );
    return res.data ?? const [];
  }

  /// Visit dates keyed by temple id, from the user's recent visits. Used for
  /// the journey timeline. Paginated at 100 — deep histories may be truncated.
  Future<Map<String, DateTime>> visitDates() async {
    final res = await _dio.get<dynamic>('/my/visits', queryParameters: {'page': 1, 'limit': 100});
    final map = <String, DateTime>{};
    for (final row in _dataList(res).whereType<Map<dynamic, dynamic>>()) {
      final m = row.cast<String, dynamic>();
      final templeId = m['templeId'] as String?;
      final raw = (m['visitDate'] ?? m['visitedAt']) as String?;
      if (templeId == null || raw == null) continue;
      final date = DateTime.tryParse(raw);
      if (date == null) continue;
      // Keep the earliest visit per temple.
      final existing = map[templeId];
      if (existing == null || date.isBefore(existing)) map[templeId] = date;
    }
    return map;
  }
}

final routesRemoteDataSourceProvider = Provider<RoutesRemoteDataSource>(
  (ref) => RoutesRemoteDataSource(ref.watch(dioProvider)),
);
