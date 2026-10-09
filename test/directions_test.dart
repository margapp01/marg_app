import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:marg_app/app/localization/app_localizations.dart';
import 'package:marg_app/features/directions/data/directions_api.dart';
import 'package:marg_app/features/directions/domain/route_plan.dart';
import 'package:marg_app/features/directions/presentation/travel_mode_ui.dart';

/// Answers every request with [status] + [body] and records the paths asked.
class _Adapter implements HttpClientAdapter {
  _Adapter(this.status, this.body);
  final int status;
  final Map<String, dynamic> body;
  final List<String> paths = [];
  final List<Map<String, dynamic>> queries = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    paths.add(options.path);
    queries.add(options.queryParameters);
    return ResponseBody.fromString(jsonEncode(body), status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

Dio _dio(_Adapter adapter) => Dio()..httpClientAdapter = adapter;

Map<String, dynamic> _route({bool withInstructions = true}) => {
      'routes': [
        {
          'distance': 2000.0,
          'duration': 600.0,
          'geometry': {
            'coordinates': [
              [75.770, 23.180],
              [75.775, 23.180],
              [75.780, 23.180],
            ],
          },
          'legs': [
            {
              'summary': 'Mahakal Marg',
              'steps': [
                {
                  'distance': 1000.0,
                  'name': 'Mahakal Marg',
                  'maneuver': {
                    'type': 'turn',
                    'modifier': 'left',
                    if (withInstructions) 'instruction': 'Turn left onto Mahakal Marg',
                  },
                },
              ],
            },
          ],
        },
      ],
    };

void main() {
  test('parses a Mapbox route: points, totals, summary and steps', () {
    final plan = DirectionsApi.parseRoute(_route());
    expect(plan.points, hasLength(3));
    expect(plan.points.first, const LatLng(23.180, 75.770));
    expect(plan.distanceMeters, 2000);
    expect(plan.durationSeconds, 600);
    expect(plan.summary, 'Mahakal Marg');
    expect(plan.steps.single.instruction, 'Turn left onto Mahakal Marg');
    expect(plan.steps.single.modifier, 'left');
  });

  test('OSRM steps without instructions are dropped, the route kept', () {
    final plan = DirectionsApi.parseRoute(_route(withInstructions: false));
    expect(plan.steps, isEmpty);
    expect(plan.points, hasLength(3));
  });

  test('no route throws', () {
    expect(() => DirectionsApi.parseRoute({'routes': <dynamic>[]}), throwsStateError);
  });

  test('remaining distance and time shrink along the route', () {
    final plan = DirectionsApi.parseRoute(_route());
    const start = LatLng(23.180, 75.770);
    const middle = LatLng(23.180, 75.775);
    expect(plan.remainingMeters(middle), lessThan(plan.remainingMeters(start)));
    expect(plan.remainingSeconds(middle), lessThan(plan.durationSeconds));
    expect(plan.offRouteMeters(middle), lessThan(1));
  });

  group('OSRM fallback routes each mode on its own profile', () {
    // Mapbox refuses long walks ("Route exceeds maximum distance limitation").
    final refused = {'code': 'InvalidInput', 'message': 'Route exceeds maximum distance limitation'};
    const from = LatLng(19.07, 72.87);
    const to = LatLng(25.31, 83.01);

    Future<List<String>> fallbackPaths(TravelMode mode) async {
      final osrm = _Adapter(200, _route(withInstructions: false));
      final api = DirectionsApi(mapbox: _dio(_Adapter(422, refused)), osrm: _dio(osrm), token: 'token');
      await api.route(from, to, mode);
      return osrm.paths;
    }

    test('a walk falls back to the foot router, never the car one', () async {
      final paths = await fallbackPaths(TravelMode.walk);
      expect(paths.single, startsWith(DirectionsApi.osrmPaths[TravelMode.walk]!));
      expect(paths.single, isNot(contains('car')));
    });

    test('a drive falls back to the car router', () async {
      final paths = await fallbackPaths(TravelMode.drive);
      expect(paths.single, startsWith(DirectionsApi.osrmPaths[TravelMode.drive]!));
    });
  });

  test('walking is offered only for a nearby temple', () {
    expect(TravelMode.forDistance(1200), TravelMode.values);
    expect(TravelMode.forDistance(TravelMode.walkableMeters), contains(TravelMode.walk));
    expect(TravelMode.forDistance(1510000), [TravelMode.drive, TravelMode.bike]);
  });

  test('a bike rides the road route at free-flow speed, off expressways', () async {
    final mapbox = _Adapter(200, _route());
    final api = DirectionsApi(mapbox: _dio(mapbox), osrm: _dio(_Adapter(500, const {})), token: 'token');
    await api.route(const LatLng(19.07, 72.87), const LatLng(21.14, 79.08), TravelMode.bike);
    expect(mapbox.paths.single, contains('/mapbox/driving/'));
    expect(mapbox.queries.single['exclude'], 'motorway');
  });

  test('travel time reads in days past 24 hours', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(formatTravelTime(l10n, 25 * 60), '25 min');
    expect(formatTravelTime(l10n, (22 * 60 + 28) * 60), '22 h 28 min');
    expect(formatTravelTime(l10n, 369.2 * 3600), '15 d 9 h');
  });

  test('DirectionsArgs exposes its point', () {
    const args = DirectionsArgs(name: 'Mahakaleshwar', latitude: 23.18, longitude: 75.77);
    expect(args.point, const LatLng(23.18, 75.77));
    expect(args.returnOnArrival, isFalse);
  });
}
