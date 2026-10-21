import 'dart:math' as math;
import 'dart:ui';

import 'package:latlong2/latlong.dart' show LatLng;

/// Journeys drawn as gentle arcs instead of straight hops: each pair of
/// consecutive stops is joined by a quadratic Bézier bowed to the left of the
/// direction of travel, so out-and-back legs curve apart instead of
/// overlapping.
abstract final class ArcPath {
  /// How far the curve bows, as a fraction of the hop's length — a gentle
  /// sweep, not a loop.
  static const double bend = 0.1;

  /// Points sampled per hop on a map — smooth at any zoom, cheap to draw.
  static const int samples = 24;

  /// The arcs through [stops] as map coordinates, for a `Polyline`. Works in
  /// a locally flattened plane (longitude scaled by cos(latitude)) so the bow
  /// looks the same in every direction.
  static List<LatLng> geo(List<LatLng> stops, {double bend = ArcPath.bend, int samples = ArcPath.samples}) {
    if (stops.length < 2) return stops;
    return [
      stops.first,
      for (var i = 1; i < stops.length; i++)
        for (var s = 1; s <= samples; s++) _at(stops[i - 1], stops[i], s / samples, bend),
    ];
  }

  /// The middle of the arc from [a] to [b], and the direction of travel there
  /// as a screen angle in radians (0 = east, clockwise) on a north-up map —
  /// where a direction arrow goes.
  static ({LatLng point, double angle}) midpoint(LatLng a, LatLng b, {double bend = ArcPath.bend}) {
    final before = _at(a, b, 0.45, bend);
    final after = _at(a, b, 0.55, bend);
    // Web Mercator: x grows east, y grows north; the screen's y grows down.
    double mercY(LatLng p) => math.log(math.tan(math.pi / 4 + p.latitude * math.pi / 360));
    final dx = (after.longitude - before.longitude) * math.pi / 180;
    final dy = mercY(after) - mercY(before);
    return (point: _at(a, b, 0.5, bend), angle: math.atan2(-dy, dx));
  }

  // The point at [t] (0–1) along the bowed hop from [a] to [b].
  static LatLng _at(LatLng a, LatLng b, double t, double bend) {
    final k = math.cos((a.latitude + b.latitude) / 2 * math.pi / 180);
    final ax = a.longitude * k, ay = a.latitude;
    final bx = b.longitude * k, by = b.latitude;
    final cx = (ax + bx) / 2 - (by - ay) * bend;
    final cy = (ay + by) / 2 + (bx - ax) * bend;
    final u = 1 - t;
    return LatLng(u * u * ay + 2 * u * t * cy + t * t * by, (u * u * ax + 2 * u * t * cx + t * t * bx) / k);
  }

  /// The order to join [stops] so the line reads as one trail across the map
  /// rather than a zig-zag: the shortest open path found by a nearest-
  /// neighbour walk from every start, untangled with 2-opt. Returns indices
  /// into [stops]. Meant for the handful of stops on a route.
  static List<int> trailOrder(List<LatLng> stops) {
    final n = stops.length;
    if (n < 3) return [for (var i = 0; i < n; i++) i];
    double d(int a, int b) {
      final k = math.cos((stops[a].latitude + stops[b].latitude) / 2 * math.pi / 180);
      final dx = (stops[a].longitude - stops[b].longitude) * k;
      final dy = stops[a].latitude - stops[b].latitude;
      return math.sqrt(dx * dx + dy * dy);
    }

    double length(List<int> path) {
      var total = 0.0;
      for (var i = 1; i < path.length; i++) {
        total += d(path[i - 1], path[i]);
      }
      return total;
    }

    List<int>? best;
    var bestLength = double.infinity;
    for (var start = 0; start < n; start++) {
      final path = [start];
      final left = {for (var i = 0; i < n; i++) i}..remove(start);
      while (left.isNotEmpty) {
        final next = left.reduce((a, b) => d(path.last, a) <= d(path.last, b) ? a : b);
        path.add(next);
        left.remove(next);
      }
      // 2-opt: reverse any stretch whose ends cross back over the path.
      var improved = true;
      while (improved) {
        improved = false;
        for (var i = 0; i < n - 2; i++) {
          for (var j = i + 2; j < n; j++) {
            final after = j + 1 < n ? d(path[i], path[j]) + d(path[i + 1], path[j + 1]) : d(path[i], path[j]);
            final before = j + 1 < n ? d(path[i], path[i + 1]) + d(path[j], path[j + 1]) : d(path[i], path[i + 1]);
            if (after < before - 1e-9) {
              path.setRange(i + 1, j + 1, path.sublist(i + 1, j + 1).reversed);
              improved = true;
            }
          }
        }
      }
      final total = length(path);
      if (total < bestLength) {
        bestLength = total;
        best = path;
      }
    }
    return best!;
  }

  /// The arcs through [stops] on a canvas (y grows downward, so the bow is
  /// mirrored to stay on the same visual side as [geo]).
  static Path screen(List<Offset> stops, {double bend = ArcPath.bend}) {
    final path = Path();
    if (stops.isEmpty) return path;
    path.moveTo(stops.first.dx, stops.first.dy);
    for (var i = 1; i < stops.length; i++) {
      final a = stops[i - 1];
      final b = stops[i];
      final mid = (a + b) / 2;
      final c = mid + Offset(b.dy - a.dy, -(b.dx - a.dx)) * bend;
      path.quadraticBezierTo(c.dx, c.dy, b.dx, b.dy);
    }
    return path;
  }

  /// [source] cut into [dash]-long strokes separated by [gap].
  static Path dashed(Path source, {double dash = 6, double gap = 4}) {
    final out = Path();
    for (final metric in source.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += dash + gap) {
        out.addPath(metric.extractPath(d, math.min(d + dash, metric.length)), Offset.zero);
      }
    }
    return out;
  }
}
