import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/location/location_service.dart';
import '../../data/datasource/explore_remote_datasource.dart';
import '../../data/repository/explore_repository_impl.dart';
import '../../domain/entities/explore_models.dart';

/// The map/nearby anchor point. [precise] is false when we fell back to a
/// default centre (permission not granted / no fix) — the UI says so honestly.
class ExploreLocation {
  const ExploreLocation(this.latitude, this.longitude, {this.precise = true});
  final double latitude;
  final double longitude;
  final bool precise;

  (double, double) get pair => (latitude, longitude);

  /// Mahakaleshwar, Ujjain — a sensible default centre when GPS is unavailable.
  static const fallback = ExploreLocation(23.1828, 75.7772, precise: false);
}

/// Resolves the user's location without ever prompting on load (mirrors the
/// Home dashboard): last-known-if-granted, else a flagged fallback. [locate]
/// performs an explicit, user-initiated high-accuracy capture (may prompt).
class ExploreLocationController extends AutoDisposeAsyncNotifier<ExploreLocation> {
  @override
  Future<ExploreLocation> build() => _lastKnownOrFallback();

  Future<void> locate() async {
    state = const AsyncLoading<ExploreLocation>().copyWithPrevious(state);
    final res = await ref.read(locationServiceProvider).capture();
    if (res.isSuccess) {
      state = AsyncData(ExploreLocation(res.location!.latitude, res.location!.longitude));
    } else {
      state = AsyncData(await _lastKnownOrFallback());
    }
  }

  Future<ExploreLocation> _lastKnownOrFallback() async {
    try {
      final p = await Geolocator.checkPermission();
      if (p == LocationPermission.always || p == LocationPermission.whileInUse) {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) return ExploreLocation(last.latitude, last.longitude);
      }
    } catch (_) {
      /* best-effort */
    }
    return ExploreLocation.fallback;
  }
}

final exploreLocationProvider = AutoDisposeAsyncNotifierProvider<ExploreLocationController, ExploreLocation>(
  ExploreLocationController.new,
);

// ── Nearby ────────────────────────────────────────────────────────────────

typedef NearbyQuery = ({double lat, double lng, int radiusKm, ExploreDeity? deity});

/// Nearby temples for an anchor + radius (+ optional deity, filtered client-side
/// since deity isn't a param on `/temples/nearby`).
final exploreNearbyProvider = FutureProvider.autoDispose.family<List<ExploreTemple>, NearbyQuery>((ref, q) async {
  final repo = ref.watch(exploreRepositoryProvider);
  final list = await repo.nearby(latitude: q.lat, longitude: q.lng, radiusMeters: q.radiusKm * 1000, limit: 80);
  if (q.deity == null) return list;
  return list.where((t) => t.deity == q.deity!.wire).toList(growable: false);
});

// ── Dashboard rails ─────────────────────────────────────────────────────────

final explorePopularProvider = FutureProvider.autoDispose<List<ExploreTemple>>(
  (ref) async => (await ref.watch(exploreRepositoryProvider).list(sort: ExploreSort.popular, limit: 10)).temples,
);

final exploreNewestProvider = FutureProvider.autoDispose<List<ExploreTemple>>(
  (ref) async => (await ref.watch(exploreRepositoryProvider).list(sort: ExploreSort.newest, limit: 10)).temples,
);

final exploreCategoriesProvider = FutureProvider.autoDispose<List<TempleCategory>>(
  (ref) => ref.watch(exploreRepositoryProvider).categories(),
);

final exploreStatesProvider = FutureProvider.autoDispose<List<ExploreStateItem>>(
  (ref) => ref.watch(exploreRepositoryProvider).statesWithCounts(),
);

final exploreCollectionsProvider = FutureProvider.autoDispose<List<CollectionSummary>>(
  (ref) => ref.watch(exploreRepositoryProvider).collections(),
);

/// Recently visited (from `/my/visits`) — real, not "saved". Fail-soft to [].
final exploreRecentVisitsProvider = FutureProvider.autoDispose<List<VisitRecord>>((ref) async {
  try {
    return await ref.watch(exploreRemoteDataSourceProvider).visits();
  } catch (_) {
    return const [];
  }
});

// ── Browse list (collection / category / state / city) ─────────────────────────────

typedef BrowseQuery = ({ExploreDeity? deity, String? stateId, String? cityId, ExploreSort sort});

final exploreBrowseProvider = FutureProvider.autoDispose.family<TemplePage, BrowseQuery>(
  (ref, q) => ref
      .watch(exploreRepositoryProvider)
      .list(deity: q.deity, stateId: q.stateId, cityId: q.cityId, sort: q.sort, limit: 40),
);

// ── Statistics ──────────────────────────────────────────────────────────────

final exploreStatisticsProvider = FutureProvider.autoDispose<ExploreStatistics>((ref) async {
  final loc = ref.watch(exploreLocationProvider).valueOrNull;
  return ref.watch(exploreRepositoryProvider).statistics(current: loc?.precise == true ? loc!.pair : null);
});

// ── Saved Places ────────────────────────────────────────────────────────────

/// The devotee's saved temples. [remove] is optimistic: the card leaves the
/// list immediately and comes back if the request fails.
class SavedTemplesController extends AutoDisposeAsyncNotifier<List<SavedTemple>> {
  @override
  Future<List<SavedTemple>> build() => ref.watch(exploreRemoteDataSourceProvider).savedTemples();

  Future<void> refresh() async {
    state = const AsyncLoading<List<SavedTemple>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => ref.read(exploreRemoteDataSourceProvider).savedTemples());
  }

  /// Returns false when the server rejected the removal (list restored).
  Future<bool> remove(String templeId) async {
    final before = state.valueOrNull ?? const <SavedTemple>[];
    state = AsyncData(before.where((s) => s.temple.id != templeId).toList(growable: false));
    try {
      await ref.read(exploreRemoteDataSourceProvider).unsaveTemple(templeId);
      return true;
    } catch (_) {
      state = AsyncData(before);
      return false;
    }
  }
}

final savedTemplesProvider = AutoDisposeAsyncNotifierProvider<SavedTemplesController, List<SavedTemple>>(
  SavedTemplesController.new,
);
