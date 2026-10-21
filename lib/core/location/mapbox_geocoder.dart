import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/config/app_config.dart';
import 'geo_place.dart';

/// Reverse-geocodes coordinates to a city/state/country via the Mapbox
/// Geocoding v6 `/reverse` endpoint. The token is URL-restricted and supplied
/// through [AppConfig] (never hardcoded).
class MapboxGeocoder {
  MapboxGeocoder({required Dio dio, required this.token}) : _dio = dio;

  final Dio _dio;
  final String token;

  static const String _reversePath = '/search/geocode/v6/reverse';
  static const String _forwardPath = '/search/geocode/v6/forward';

  /// Returns the place for [latitude]/[longitude], or an empty [GeoPlace] if
  /// nothing matched. Throws [DioException] on network/HTTP failure.
  Future<GeoPlace> reverse({
    required double latitude,
    required double longitude,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      _reversePath,
      queryParameters: {
        'longitude': longitude,
        'latitude': latitude,
        'types': 'place,region,country',
        'limit': 1,
        'access_token': token,
      },
    );
    return GeoPlace.fromMapboxV6(res.data ?? const {});
  }

  /// Cities and towns matching [query] (autocomplete), best match first, each
  /// with its centre coordinates.
  Future<List<({GeoPlace place, double latitude, double longitude})>> searchPlaces(String query) async {
    final res = await _dio.get<Map<String, dynamic>>(
      _forwardPath,
      queryParameters: {
        'q': query,
        'types': 'place,locality',
        'autocomplete': true,
        'limit': 8,
        'access_token': token,
      },
    );
    final features = (res.data?['features'] as List?) ?? const [];
    return [
      for (final f in features.whereType<Map<dynamic, dynamic>>())
        if (_point(f) case (final double lat, final double lng))
          (place: GeoPlace.fromMapboxV6Feature(f), latitude: lat, longitude: lng),
    ];
  }

  static (double, double)? _point(Map<dynamic, dynamic> feature) {
    final coords = (feature['properties'] as Map?)?['coordinates'] as Map?;
    final lat = coords?['latitude'];
    final lng = coords?['longitude'];
    return lat is num && lng is num ? (lat.toDouble(), lng.toDouble()) : null;
  }
}

/// Dedicated Dio for Mapbox (separate base URL from the app API).
final _mapboxDioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: 'https://api.mapbox.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: const {'Accept': 'application/json'},
    ),
  );
});

final mapboxGeocoderProvider = Provider<MapboxGeocoder>((ref) {
  return MapboxGeocoder(
    dio: ref.watch(_mapboxDioProvider),
    token: ref.watch(appConfigProvider).mapboxToken,
  );
});
