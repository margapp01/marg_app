import 'dart:math' as math;

import 'route_progress.dart';
import 'yatra_route.dart';

/// Per-temple status within a route journey.
enum TempleJourneyStatus { completed, current, remaining }

/// Everything the Route Detail screen renders: the route, the user's live
/// progress (if signed-in / started), and visit dates (for the timeline).
/// Completion/rewards are ALWAYS derived from backend progress — never locally.
class RouteDetailBundle {
  const RouteDetailBundle({
    required this.route,
    this.progress,
    this.visitDateByTempleId = const {},
  });

  final YatraRoute route;
  final RouteProgress? progress;
  final Map<String, DateTime> visitDateByTempleId;

  int get completedCount => progress?.completedTemples ?? _visitedInRoute;
  int get totalCount => progress?.totalTemples ?? route.temples.length;
  int get percent => progress?.percent ?? (totalCount == 0 ? 0 : (completedCount * 100 / totalCount).round());
  bool get isComplete => progress?.isComplete ?? (totalCount > 0 && completedCount >= totalCount);

  int get _visitedInRoute =>
      route.temples.where((t) => visitDateByTempleId.containsKey(t.temple.id)).length;

  /// Status of a temple: completed (visited / not remaining), current (the
  /// route's next temple), else remaining.
  TempleJourneyStatus statusOf(RouteTempleEntry entry) {
    final id = entry.temple.id;
    if (progress != null) {
      if (!progress!.remainingTempleIds.contains(id)) return TempleJourneyStatus.completed;
      if (progress!.nextTemple?.id == id) return TempleJourneyStatus.current;
      return TempleJourneyStatus.remaining;
    }
    if (visitDateByTempleId.containsKey(id)) return TempleJourneyStatus.completed;
    return TempleJourneyStatus.remaining;
  }

  bool isCompleted(RouteTempleEntry entry) => statusOf(entry) == TempleJourneyStatus.completed;

  /// The route's next temple with its photo and coordinates, while in progress.
  RouteTempleEntry? get nextEntry {
    final id = progress?.nextTemple?.id;
    if (id == null) return null;
    for (final e in route.temples) {
      if (e.temple.id == id) return e;
    }
    return null;
  }

  /// When the route was completed: the date of its last visit.
  DateTime? get completedOn {
    if (!isComplete) return null;
    final dates = route.temples.map((t) => visitDateByTempleId[t.temple.id]).whereType<DateTime>();
    return dates.isEmpty ? null : dates.reduce((a, b) => a.isAfter(b) ? a : b);
  }

  /// Journey duration in days from the first to the last visit on this route,
  /// derived from real visit dates. Null when fewer than one visit is dated.
  int? get journeyDurationDays {
    final dates = route.temples
        .map((t) => visitDateByTempleId[t.temple.id])
        .whereType<DateTime>()
        .toList()
      ..sort();
    if (dates.isEmpty) return null;
    return dates.last.difference(dates.first).inDays + 1;
  }

  /// Distance (km) covered so far — great-circle hops between consecutive
  /// completed temples, in route order. Derived from coordinates.
  double get distanceCoveredKm {
    var meters = 0.0;
    RouteTempleEntry? prev;
    for (final entry in route.temples) {
      if (!isCompleted(entry)) {
        prev = null;
        continue;
      }
      if (prev != null) {
        meters += _haversineMeters(
          prev.temple.latitude, prev.temple.longitude,
          entry.temple.latitude, entry.temple.longitude,
        );
      }
      prev = entry;
    }
    return meters / 1000;
  }
}

double _haversineMeters(double lat1, double lon1, double lat2, double lon2) {
  if ((lat1 == 0 && lon1 == 0) || (lat2 == 0 && lon2 == 0)) return 0;
  const r = 6371000.0;
  final dLat = _rad(lat2 - lat1);
  final dLon = _rad(lon2 - lon1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_rad(lat1)) * math.cos(_rad(lat2)) * math.sin(dLon / 2) * math.sin(dLon / 2);
  return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}

double _rad(double deg) => deg * math.pi / 180;
