import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/config/app_config.dart';
import '../domain/route_plan.dart';

/// Road routing. Mapbox Directions (traffic-aware driving, walking, spoken
/// instructions in the app language) when a token is configured; public OSRM
/// otherwise — and as the fallback if Mapbox fails (it refuses long walks:
/// "Route exceeds maximum distance limitation").
class DirectionsApi {
  DirectionsApi({required Dio mapbox, required Dio osrm, required this.token})
      : _mapbox = mapbox,
        _osrm = osrm;

  /// An OSRM server routes the one profile it was built with and ignores the
  /// profile in the URL, so each mode needs its own instance. (The OSRM demo
  /// server is car-only — asking it to walk returned a car route at car
  /// speed, which made "Walk" faster than "Drive".)
  static const Map<TravelMode, String> osrmPaths = {
    TravelMode.drive: '/routed-car/route/v1/driving',
    // No two-wheeler router (and no motorway exclusion) here — the car road
    // route is the nearest fallback.
    TravelMode.bike: '/routed-car/route/v1/driving',
    TravelMode.walk: '/routed-foot/route/v1/foot',
  };

  /// Mapbox profile + extra query per mode. There is no two-wheeler profile:
  /// a bike takes the road route at free-flow speed (two-wheelers filter
  /// through traffic) and stays off expressways, which bar them in India.
  static const Map<TravelMode, (String, Map<String, String>)> mapboxProfiles = {
    TravelMode.drive: ('driving-traffic', {}),
    TravelMode.bike: ('driving', {'exclude': 'motorway'}),
    TravelMode.walk: ('walking', {}),
  };

  final Dio _mapbox;
  final Dio _osrm;
  final String token;

  Future<RoutePlan> route(LatLng from, LatLng to, TravelMode mode, {String language = 'en'}) async {
    if (token.isNotEmpty) {
      try {
        return await _viaMapbox(from, to, mode, language);
      } catch (_) {/* fall through to OSRM */}
    }
    return _viaOsrm(from, to, mode);
  }

  static String _coords(LatLng from, LatLng to) =>
      '${from.longitude},${from.latitude};${to.longitude},${to.latitude}';

  Future<RoutePlan> _viaMapbox(LatLng from, LatLng to, TravelMode mode, String language) async {
    final (profile, extra) = mapboxProfiles[mode]!;
    final res = await _mapbox.get<Map<String, dynamic>>(
      '/directions/v5/mapbox/$profile/${_coords(from, to)}',
      queryParameters: {
        ...extra,
        'geometries': 'geojson',
        'overview': 'full',
        'steps': 'true',
        'language': language,
        'access_token': token,
      },
    );
    return parseRoute(res.data ?? const {});
  }

  Future<RoutePlan> _viaOsrm(LatLng from, LatLng to, TravelMode mode) async {
    final res = await _osrm.get<Map<String, dynamic>>(
      '${osrmPaths[mode]}/${_coords(from, to)}',
      queryParameters: {'geometries': 'geojson', 'overview': 'full', 'steps': 'true'},
    );
    return parseRoute(res.data ?? const {});
  }

  /// Parses a Mapbox Directions / OSRM `route` response (same shape). Throws
  /// [StateError] when there is no route.
  static RoutePlan parseRoute(Map<String, dynamic> json) {
    final routes = json['routes'];
    if (routes is! List || routes.isEmpty) throw StateError('No route');
    final route = (routes.first as Map).cast<String, dynamic>();
    final coords = ((route['geometry'] as Map?)?['coordinates'] as List?) ?? const [];
    final legs = (route['legs'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    final steps = <RouteStep>[
      for (final leg in legs)
        for (final step in (leg['steps'] as List? ?? const []).cast<Map<String, dynamic>>())
          _step(step),
    ];
    final summary = legs.map((l) => l['summary']).whereType<String>().where((s) => s.isNotEmpty).join(', ');
    return RoutePlan(
      points: [
        for (final c in coords.cast<List<dynamic>>()) LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()),
      ],
      distanceMeters: (route['distance'] as num?)?.toDouble() ?? 0,
      durationSeconds: (route['duration'] as num?)?.toDouble() ?? 0,
      steps: steps.where((s) => s.instruction.isNotEmpty).toList(),
      summary: summary.isEmpty ? null : summary,
    );
  }

  static RouteStep _step(Map<String, dynamic> step) {
    final maneuver = (step['maneuver'] as Map?)?.cast<String, dynamic>() ?? const {};
    // Mapbox sends a localized instruction; OSRM sends none, so its steps are
    // dropped (the route line, distance and time still show).
    return RouteStep(
      instruction: maneuver['instruction'] as String? ?? '',
      distanceMeters: (step['distance'] as num?)?.toDouble() ?? 0,
      maneuver: maneuver['type'] as String?,
      modifier: maneuver['modifier'] as String?,
    );
  }
}

Dio _routingDio(String baseUrl) => Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        // The FOSSGIS routers' usage policy asks clients to identify themselves.
        headers: const {'Accept': 'application/json', 'User-Agent': 'MARG (com.techluminix.marg)'},
      ),
    );

final directionsApiProvider = Provider<DirectionsApi>((ref) {
  return DirectionsApi(
    mapbox: _routingDio('https://api.mapbox.com'),
    // FOSSGIS runs one OSRM instance per profile (car, foot) — the routers
    // openstreetmap.org itself uses.
    osrm: _routingDio('https://routing.openstreetmap.de'),
    token: ref.watch(appConfigProvider).mapboxToken,
  );
});
