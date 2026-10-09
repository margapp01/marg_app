import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/offline/cache_through.dart';
import '../../../../core/offline/offline_cache.dart';
import '../../domain/entities/temple_detail.dart';
import '../../domain/repository/temple_detail_repository.dart';
import '../datasource/temple_detail_remote_datasource.dart';

class TempleDetailRepositoryImpl implements TempleDetailRepository {
  TempleDetailRepositoryImpl(this._remote, this._cache);

  final TempleDetailRemoteDataSource _remote;
  final OfflineCache _cache;

  @override
  Future<TempleDetailBundle> loadBundle(String slug) async {
    // 1. The temple itself (needed for its id + coords) — the only hard
    //    dependency. Read-through cache: served from disk when offline, so a
    //    previously-opened temple still renders without a connection.
    final temple = await cacheThroughObject(
      key: 'temple_detail:$slug',
      fetch: () => _remote.detailData(slug),
      parse: TempleDetail.fromJson,
      cache: _cache,
    );

    // 2. Everything else loads in parallel and fails soft — a slow/failed
    //    section becomes null/[] instead of breaking the screen.
    final crowdF = _soft(_remote.crowd(temple.id));
    final bestF = _soft(_remote.bestTimeWindow(temple.id));
    final peakF = _soft(_remote.peakWindow(temple.id));
    final statusF = _soft(_remote.myStatus(temple.id));
    final nearbyF = _softList(_remote.nearby(temple.latitude, temple.longitude, temple.id));
    final summaryF = _soft(_remote.reviewSummary(temple.id));
    final reviewsF = _softList(_remote.reviews(temple.id));
    final myReviewF = _soft(_remote.myReview(temple.id));

    return TempleDetailBundle(
      temple: temple,
      crowd: await crowdF,
      bestTimeWindow: await bestF,
      peakWindow: await peakF,
      myStatus: await statusF,
      nearby: await nearbyF,
      reviewSummary: await summaryF,
      reviews: await reviewsF,
      myReview: await myReviewF,
    );
  }

  Future<T?> _soft<T>(Future<T> future) async {
    try {
      return await future;
    } catch (_) {
      return null;
    }
  }

  Future<List<T>> _softList<T>(Future<List<T>> future) async {
    try {
      return await future;
    } catch (_) {
      return const [];
    }
  }
}

final templeDetailRepositoryProvider = Provider<TempleDetailRepository>(
  (ref) => TempleDetailRepositoryImpl(
    ref.watch(templeDetailRemoteDataSourceProvider),
    ref.watch(offlineCacheProvider),
  ),
);
