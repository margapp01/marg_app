import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/offline/cache_through.dart';
import '../../../../core/offline/offline_cache.dart';
import '../../domain/entities/checkin_request.dart';
import '../../domain/entities/checkin_result.dart';
import '../../domain/entities/visit_route_progress.dart';
import '../../domain/entities/visit_temple.dart';
import '../../domain/repository/temple_visit_repository.dart';
import '../datasource/temple_visit_remote_datasource.dart';

class TempleVisitRepositoryImpl implements TempleVisitRepository {
  TempleVisitRepositoryImpl(this._remote, this._cache);

  final TempleVisitRemoteDataSource _remote;
  final OfflineCache _cache;

  /// Read-through the Temple Detail cache entry: a pilgrim who opened the
  /// temple before the climb can still check in where there is no network.
  @override
  Future<VisitTemple> temple(String slug) => cacheThroughObject(
        key: 'temple_detail:$slug',
        fetch: () => _remote.templeData(slug),
        parse: VisitTemple.fromJson,
        cache: _cache,
      );

  @override
  Future<CheckinResult> checkIn(String templeId, CheckinRequest request) =>
      _remote.checkIn(templeId, request);

  @override
  Future<VisitRouteProgress?> routeProgress(String templeId) async {
    try {
      return await _remote.routeProgress(templeId);
    } catch (_) {
      // Route progress is an enrichment for the reward screens — its failure
      // must never break a successful check-in.
      return null;
    }
  }
}

final templeVisitRepositoryProvider = Provider<TempleVisitRepository>(
  (ref) => TempleVisitRepositoryImpl(
    ref.watch(templeVisitRemoteDataSourceProvider),
    ref.watch(offlineCacheProvider),
  ),
);
