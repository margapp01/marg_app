import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/core/location/geo_place.dart';

void main() {
  test('parses Mapbox v6 reverse features into city/state/country', () {
    final place = GeoPlace.fromMapboxV6({
      'features': [
        {'properties': {'feature_type': 'place', 'name': 'Mumbai'}},
        {'properties': {'feature_type': 'region', 'name': 'Maharashtra'}},
        {'properties': {'feature_type': 'country', 'name': 'India'}},
      ],
    });

    expect(place.city, 'Mumbai');
    expect(place.state, 'Maharashtra');
    expect(place.country, 'India');
    expect(place.label, 'Mumbai, Maharashtra');
    expect(place.isEmpty, isFalse);
  });

  test('no matching features yields an empty place', () {
    final place = GeoPlace.fromMapboxV6({'features': <dynamic>[]});
    expect(place.isEmpty, isTrue);
    expect(place.label, '');
  });
}
