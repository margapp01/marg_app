import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/core/location/chosen_city.dart';
import 'package:marg_app/core/location/geo_place.dart';

void main() {
  test('a chosen city round-trips and stands in as a manual location', () {
    const city = ChosenCity(name: 'Pune', state: 'Maharashtra', country: 'India', latitude: 18.52, longitude: 73.85);
    final back = ChosenCity.fromJson(city.toJson())!;
    expect(back.name, 'Pune');
    expect(back.subtitle, 'Maharashtra, India');
    final captured = back.toCaptured();
    expect(captured.latitude, 18.52);
    expect(captured.permissionStatus, 'MANUAL_CITY');
    expect(captured.toJson()['city'], 'Pune');
  });

  test('a Mapbox forward-search feature yields the city, region and country', () {
    final place = GeoPlace.fromMapboxV6Feature(const {
      'properties': {
        'name': 'Varanasi',
        'context': {
          'region': {'name': 'Uttar Pradesh'},
          'country': {'name': 'India'},
        },
      },
    });
    expect(place.city, 'Varanasi');
    expect(place.label, 'Varanasi, Uttar Pradesh');
  });
}
