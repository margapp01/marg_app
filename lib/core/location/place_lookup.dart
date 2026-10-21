import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart' as device;

import 'geo_place.dart';
import 'mapbox_geocoder.dart';

/// Names the place at a coordinate — "Pune, Maharashtra" — for showing and
/// saving the devotee's city. Mapbox when a token is configured, else (or if
/// Mapbox fails or knows no city there) the phone's own geocoder, so a build
/// without a Mapbox token still shows the city. Never throws: an empty
/// [GeoPlace] means neither could name it.
class PlaceLookup {
  PlaceLookup(this._ref);

  final Ref _ref;

  Future<GeoPlace> reverse({required double latitude, required double longitude}) async {
    final mapbox = _ref.read(mapboxGeocoderProvider);
    if (mapbox.token.isNotEmpty) {
      try {
        final place = await mapbox.reverse(latitude: latitude, longitude: longitude);
        if (place.city != null && place.city!.isNotEmpty) return place;
      } catch (_) {/* fall through to the device geocoder */}
    }
    try {
      final marks = await device.placemarkFromCoordinates(latitude, longitude);
      return marks.isEmpty ? const GeoPlace() : placeFromPlacemark(marks.first);
    } catch (_) {
      return const GeoPlace();
    }
  }

  /// A device placemark as a [GeoPlace]: the town (or, failing that, its
  /// district), state and country.
  static GeoPlace placeFromPlacemark(device.Placemark mark) {
    String? clean(String? s) => s == null || s.trim().isEmpty ? null : s.trim();
    return GeoPlace(
      city: clean(mark.locality) ?? clean(mark.subAdministrativeArea),
      state: clean(mark.administrativeArea),
      country: clean(mark.country),
    );
  }
}

final placeLookupProvider = Provider<PlaceLookup>(PlaceLookup.new);
