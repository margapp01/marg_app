import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart';
import 'package:marg_app/core/location/place_lookup.dart';

void main() {
  test('a device placemark names the town, state and country', () {
    final place = PlaceLookup.placeFromPlacemark(
      Placemark(locality: 'Pune', administrativeArea: 'Maharashtra', country: 'India'),
    );
    expect(place.label, 'Pune, Maharashtra');
    expect(place.country, 'India');
  });

  test('without a town it falls back to the district; blanks are ignored', () {
    final place = PlaceLookup.placeFromPlacemark(
      Placemark(locality: '  ', subAdministrativeArea: 'Rudraprayag', administrativeArea: 'Uttarakhand'),
    );
    expect(place.city, 'Rudraprayag');
    expect(PlaceLookup.placeFromPlacemark(Placemark()).isEmpty, isTrue);
  });
}
