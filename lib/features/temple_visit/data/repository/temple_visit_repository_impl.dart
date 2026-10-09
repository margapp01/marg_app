import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/checkin_request.dart';
import '../../domain/entities/checkin_result.dart';
import '../../domain/entities/visit_route_progress.dart';
import '../../domain/entities/visit_temple.dart';
import '../../domain/repository/temple_visit_repository.dart';
import '../datasource/temple_visit_remote_datasource.dart';

class TempleVisitRepositoryImpl implements TempleVisitRepository {
  TempleVisitRepositoryImpl(this._remote);

  final TempleVisitRemoteDataSource _remote;

  @override
  Future<VisitTemple> temple(String slug) => _remote.temple(slug);

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
  (ref) => TempleVisitRepositoryImpl(ref.watch(templeVisitRemoteDataSourceProvider)),
);
