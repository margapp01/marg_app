import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/config/app_config.dart';
import '../network/dio_client.dart';
import '../storage/shared_prefs_store.dart';
import 'captured_location.dart';
import 'geo_place.dart';
import 'mapbox_geocoder.dart';

/// A city the devotee picked by name (when they'd rather not share GPS). Its
/// centre stands in for their location: Home and Nearby show the temples
/// around it until device location is allowed.
class ChosenCity {
  const ChosenCity({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.state,
    this.country,
  });

  final String name;
  final String? state;
  final String? country;
  final double latitude;
  final double longitude;

  /// "Varanasi, Uttar Pradesh, India" (whichever parts are known).
  String get subtitle => [state, country].where((p) => p != null && p.isNotEmpty).join(', ');

  GeoPlace get place => GeoPlace(city: name, state: state, country: country);

  /// For `PUT /my/location`: a hand-picked city, flagged as such.
  CapturedLocation toCaptured() => CapturedLocation(
        latitude: latitude,
        longitude: longitude,
        capturedAt: DateTime.now(),
        source: 'UNKNOWN',
        permissionStatus: 'MANUAL_CITY',
        place: place,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'state': ?state,
        'country': ?country,
        'latitude': latitude,
        'longitude': longitude,
      };

  static ChosenCity? fromJson(Map<String, dynamic> j) {
    final name = j['name'];
    final lat = j['latitude'];
    final lng = j['longitude'];
    if (name is! String || lat is! num || lng is! num) return null;
    return ChosenCity(
      name: name,
      state: j['state'] as String?,
      country: j['country'] as String?,
      latitude: lat.toDouble(),
      longitude: lng.toDouble(),
    );
  }
}

/// Remembers the [ChosenCity] on this device.
class ChosenCityStore {
  ChosenCityStore(this._ref);

  final Ref _ref;
  static const String _key = 'location.chosenCity';

  Future<ChosenCity?> read() async {
    try {
      final raw = await _ref.read(keyValueStoreProvider).getString(_key);
      if (raw == null) return null;
      return ChosenCity.fromJson((jsonDecode(raw) as Map).cast<String, dynamic>());
    } catch (_) {
      return null;
    }
  }

  Future<void> save(ChosenCity city) => _ref.read(keyValueStoreProvider).setString(_key, jsonEncode(city.toJson()));

  Future<void> clear() => _ref.read(keyValueStoreProvider).remove(_key);
}

final chosenCityStoreProvider = Provider<ChosenCityStore>(ChosenCityStore.new);

/// Finds cities by name: Mapbox place search (any city, anywhere) when a
/// token is configured, else MARG's own city list (`GET /cities?q=`).
class CitySearch {
  CitySearch(this._ref);

  final Ref _ref;

  Future<List<ChosenCity>> search(String query) async {
    final q = query.trim();
    if (q.length < 2) return const [];
    if (_ref.read(appConfigProvider).hasMapbox) {
      try {
        final places = await _ref.read(mapboxGeocoderProvider).searchPlaces(q);
        return [
          for (final p in places)
            if (p.place.city != null)
              ChosenCity(
                name: p.place.city!,
                state: p.place.state,
                country: p.place.country,
                latitude: p.latitude,
                longitude: p.longitude,
              ),
        ];
      } catch (_) {/* fall back to MARG's cities */}
    }
    return _margCities(q);
  }

  Future<List<ChosenCity>> _margCities(String q) async {
    final res = await _ref.read(dioProvider).get<dynamic>('/cities', queryParameters: {'q': q, 'limit': 20});
    final body = res.data;
    final rows = body is Map ? body['data'] : null;
    if (rows is! List) return const [];
    return [
      for (final r in rows.whereType<Map<dynamic, dynamic>>())
        if (r['latitude'] is num && r['longitude'] is num)
          ChosenCity(
            name: '${r['name']}',
            state: (r['state'] as Map?)?['name'] as String?,
            latitude: (r['latitude'] as num).toDouble(),
            longitude: (r['longitude'] as num).toDouble(),
          ),
    ];
  }
}

final citySearchProvider = Provider<CitySearch>(CitySearch.new);
