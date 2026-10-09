import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/offline/cache_through.dart';
import '../../../../core/offline/offline_cache.dart';
import '../../domain/entities/home_dashboard.dart';
import '../../domain/repository/home_repository.dart';
import '../datasource/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._remote, this._cache);

  final HomeRemoteDataSource _remote;
  final OfflineCache _cache;

  /// One cache slot regardless of GPS — the last dashboard is the offline view.
  static const _cacheKey = 'home_dashboard';

  @override
  Future<HomeDashboard> loadDashboard({double? latitude, double? longitude}) {
    return cacheThroughObject(
      key: _cacheKey,
      fetch: () => _remote.fetchDashboard(latitude: latitude, longitude: longitude),
      parse: HomeDashboard.fromJson,
      cache: _cache,
    );
  }
}

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => HomeRepositoryImpl(
    ref.watch(homeRemoteDataSourceProvider),
    ref.watch(offlineCacheProvider),
  ),
);
