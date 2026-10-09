import 'package:latlong2/latlong.dart';

/// How the pilgrim is travelling — picks the routing profile.
enum TravelMode {
  drive,

  /// A two-wheeler (motorbike / scooter).
  bike,
  walk;

  /// Straight-line distance within which walking is offered. Further than
  /// this a pilgrim drives or rides — a days-long walk isn't directions.
  static const double walkableMeters = 5000;

  /// The modes worth offering for a trip of [straightLineMeters].
  static List<TravelMode> forDistance(double straightLineMeters) =>
      straightLineMeters <= walkableMeters ? values : const [drive, bike];
}

/// Where the directions lead (a temple, usually).
class DirectionsArgs {
  const DirectionsArgs({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.place,
    this.imageUrl,
    this.templeSlug,
    this.returnOnArrival = false,
    this.initialMode = TravelMode.drive,
  });

  final String name;
  final double latitude;
  final double longitude;

  /// "City, State" under the name.
  final String? place;
  final String? imageUrl;

  /// Set for temples — enables "Check in" on arrival.
  final String? templeSlug;

  /// Opened from the visit flow: "Check in" just returns to it.
  final bool returnOnArrival;

  /// The mode the pilgrim already picked (falls back to drive when walking
  /// isn't offered for the distance).
  final TravelMode initialMode;

  LatLng get point => LatLng(latitude, longitude);
}

/// One turn-by-turn instruction.
class RouteStep {
  const RouteStep({required this.instruction, required this.distanceMeters, this.maneuver, this.modifier});

  final String instruction;
  final double distanceMeters;

  /// Mapbox/OSRM maneuver `type` (turn, depart, arrive, roundabout…) and
  /// `modifier` (left, slight right, uturn…), for the step icon.
  final String? maneuver;
  final String? modifier;
}

/// A routed path from the pilgrim to the destination.
class RoutePlan {
  const RoutePlan({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
    this.steps = const [],
    this.summary,
  });

  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;
  final List<RouteStep> steps;

  /// Main roads ("NH48, Ring Road"), when the router names them.
  final String? summary;

  static const Distance _distance = Distance();

  /// Index of the route vertex nearest [at].
  int nearestIndex(LatLng at) {
    var best = 0;
    var bestMeters = double.infinity;
    for (var i = 0; i < points.length; i++) {
      final d = _distance(at, points[i]);
      if (d < bestMeters) {
        bestMeters = d;
        best = i;
      }
    }
    return best;
  }

  /// How far [at] is from the route line (to its nearest vertex).
  double offRouteMeters(LatLng at) => points.isEmpty ? 0 : _distance(at, points[nearestIndex(at)]);

  /// Distance still to travel from [at], following the route.
  double remainingMeters(LatLng at) {
    if (points.length < 2) return distanceMeters;
    final from = nearestIndex(at);
    var meters = _distance(at, points[from]);
    for (var i = from; i < points.length - 1; i++) {
      meters += _distance(points[i], points[i + 1]);
    }
    return meters;
  }

  /// Time still to travel from [at], at the route's average pace.
  double remainingSeconds(LatLng at) =>
      distanceMeters <= 0 ? 0 : durationSeconds * (remainingMeters(at) / distanceMeters).clamp(0, 1);
}
