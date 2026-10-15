import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../temple_detail/domain/entities/temple_detail.dart' show NearbyTempleRef;
import '../../domain/entities/my_route.dart';
import '../../domain/entities/route_detail_bundle.dart';
import '../../domain/entities/route_progress.dart';
import '../../domain/entities/yatra_route.dart';
import '../../domain/repository/routes_repository.dart';
import '../datasource/routes_remote_datasource.dart';

class RoutesRepositoryImpl implements RoutesRepository {
  RoutesRepositoryImpl(this._remote);

  final RoutesRemoteDataSource _remote;

  @override
  Future<List<YatraRoute>> discover({String? type, String? query}) =>
      _remote.list(type: type, query: query);

  @override
  Future<List<MyRouteProgress>> myRoutes() => _remote.myRoutes();

  @override
  Future<RouteDetailBundle> loadDetail(String slug) async {
    // Detail is the hard dependency; progress, visit dates and nearby
    // suggestions are best-effort so a failed sub-call still renders the route.
    final route = await _remote.detail(slug);
    final results = await Future.wait([
      _soft(() => _remote.progress(route.id)),
      _soft(_remote.visitDates),
      _soft(() => _remote.nearbyByStop(slug)),
    ]);
    return RouteDetailBundle(
      route: route,
      progress: results[0] as RouteProgress?,
      visitDateByTempleId: (results[1] as Map<String, DateTime>?) ?? const {},
      nearbyByTempleId: (results[2] as Map<String, List<NearbyTempleRef>>?) ?? const {},
    );
  }

  @override
  Future<void> enroll(String routeId) => _remote.enroll(routeId);

  @override
  Future<void> unenroll(String routeId) => _remote.unenroll(routeId);

  @override
  Future<List<int>> certificate(String routeId) => _remote.certificate(routeId);

  Future<Object?> _soft(Future<Object?> Function() task) async {
    try {
      return await task();
    } catch (_) {
      return null;
    }
  }
}

final routesRepositoryProvider = Provider<RoutesRepository>(
  (ref) => RoutesRepositoryImpl(ref.watch(routesRemoteDataSourceProvider)),
);
