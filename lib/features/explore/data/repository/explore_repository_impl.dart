import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/explore_models.dart';
import '../datasource/explore_remote_datasource.dart';

/// Composes the Explore experience over the public temple + location + visit
/// endpoints. Category / state counts and exploration statistics are derived
/// here (client-side) from real backend data — nothing is fabricated.
class ExploreRepository {
  ExploreRepository(this._remote);

  final ExploreRemoteDataSource _remote;

  Future<List<ExploreTemple>> nearby({
    required double latitude,
    required double longitude,
    required int radiusMeters,
    int limit = 30,
  }) => _remote.nearby(latitude: latitude, longitude: longitude, radiusMeters: radiusMeters, limit: limit);

  Future<TemplePage> list({
    String? q,
    ExploreDeity? deity,
    String? stateId,
    String? cityId,
    ExploreSort sort = ExploreSort.popular,
    int page = 1,
    int limit = 20,
  }) => _remote.list(
    q: q,
    deity: deity?.wire,
    stateId: stateId,
    cityId: cityId,
    sortBy: sort.sortBy,
    sortOrder: sort.sortOrder,
    page: page,
    limit: limit,
  );

  /// One `limit=1` page of a query: the total is its count, the first temple
  /// (most-viewed unless [sort] says otherwise) lends it a photo. Null on error.
  Future<TemplePage?> _lead({ExploreDeity? deity, String? stateId, ExploreSort sort = ExploreSort.popular}) => _remote
      .list(deity: deity?.wire, stateId: stateId, sortBy: sort.sortBy, sortOrder: sort.sortOrder, limit: 1)
      .then<TemplePage?>((p) => p)
      .catchError((_) => null);

  /// The five real deity categories, each with a live published-temple count.
  Future<List<TempleCategory>> categories() async {
    final pages = await Future.wait(ExploreDeity.values.map((d) => _lead(deity: d)));
    return [
      for (final (i, page) in pages.indexed)
        TempleCategory(
          deity: ExploreDeity.values[i],
          count: page?.total ?? 0,
          coverImage: page?.temples.firstOrNull?.imageUrl,
          topTemple: page?.temples.firstOrNull?.name,
        ),
    ];
  }

  /// States with a published-temple count and lead photo each (parallel,
  /// fail-soft to 0).
  Future<List<ExploreStateItem>> statesWithCounts() async {
    final states = await _remote.states();
    final pages = await Future.wait(states.map((s) => _lead(stateId: s.id)));
    final withCounts = [
      for (final (i, page) in pages.indexed)
        states[i].withSummary(
          count: page?.total ?? 0,
          coverImage: page?.temples.firstOrNull?.imageUrl,
          topTemple: page?.temples.firstOrNull?.name,
        ),
    ];
    // Surface the richest states first; drop empties from the explorer.
    withCounts.sort((a, b) => (b.templeCount ?? 0).compareTo(a.templeCount ?? 0));
    return withCounts.where((s) => (s.templeCount ?? 0) > 0).toList(growable: false);
  }

  /// Every Explore collection with its live count and lead photo.
  Future<List<CollectionSummary>> collections() async {
    final pages = await Future.wait(kExploreCollections.map((c) => _lead(deity: c.deity, sort: c.sort)));
    return [
      for (final (i, page) in pages.indexed)
        CollectionSummary(
          collection: kExploreCollections[i],
          count: page?.total ?? 0,
          coverImage: page?.temples.firstOrNull?.imageUrl,
          topTemple: page?.temples.firstOrNull?.name,
        ),
    ];
  }

  /// Exploration statistics derived from `/my/visits`. [current] (if known)
  /// unlocks nearest / farthest temple.
  Future<ExploreStatistics> statistics({(double, double)? current}) async {
    final visits = await _remote.visits();
    if (visits.isEmpty) {
      return const ExploreStatistics(templesExplored: 0, thisMonth: 0, monthly: []);
    }

    final now = DateTime.now();
    final dated = visits.where((v) => v.visitedAt != null).toList();
    final thisMonth = dated.where((v) => v.visitedAt!.year == now.year && v.visitedAt!.month == now.month).length;

    // Trailing six months, oldest → newest.
    const labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final monthly = <(String, int)>[];
    for (var i = 5; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i);
      final count = dated.where((v) => v.visitedAt!.year == d.year && v.visitedAt!.month == d.month).length;
      monthly.add((labels[d.month - 1], count));
    }

    final sortedByDate = dated.map((v) => v.visitedAt!).toList()..sort();

    // Where the visits were: distinct states / cities, most-visited states.
    final perState = <String, int>{};
    for (final v in visits) {
      final state = v.state;
      if (state != null) perState[state] = (perState[state] ?? 0) + 1;
    }
    final cities = {for (final v in visits) if (v.city != null) '${v.city}|${v.state}'};
    final topStates = perState.entries.map((e) => (e.key, e.value)).toList()..sort((a, b) => b.$2.compareTo(a.$2));

    String? nearestName, farthestName;
    double? nearestKm, farthestKm;
    if (current != null) {
      double? best, worst;
      for (final v in visits) {
        if (v.latitude == null || v.longitude == null) continue;
        final km = _haversineKm(current.$1, current.$2, v.latitude!, v.longitude!);
        if (best == null || km < best) {
          best = km;
          nearestName = v.templeName;
          nearestKm = km;
        }
        if (worst == null || km > worst) {
          worst = km;
          farthestName = v.templeName;
          farthestKm = km;
        }
      }
    }

    return ExploreStatistics(
      templesExplored: visits.length,
      thisMonth: thisMonth,
      monthly: monthly,
      statesVisited: perState.length,
      citiesVisited: cities.length,
      topStates: topStates.take(_topStates).toList(growable: false),
      firstVisit: sortedByDate.isEmpty ? null : sortedByDate.first,
      lastVisit: sortedByDate.isEmpty ? null : sortedByDate.last,
      nearestName: nearestName,
      nearestKm: nearestKm,
      farthestName: farthestName,
      farthestKm: farthestKm,
    );
  }

  static const int _topStates = 5;

  static double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    double rad(double d) => d * math.pi / 180;
    final dLat = rad(lat2 - lat1);
    final dLon = rad(lon2 - lon1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(rad(lat1)) * math.cos(rad(lat2)) * math.sin(dLon / 2) * math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }
}

final exploreRepositoryProvider = Provider<ExploreRepository>(
  (ref) => ExploreRepository(ref.watch(exploreRemoteDataSourceProvider)),
);
