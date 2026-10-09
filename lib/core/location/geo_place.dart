/// A reverse-geocoded place — the city/state/country for a coordinate.
class GeoPlace {
  const GeoPlace({this.city, this.state, this.country});

  final String? city;
  final String? state;
  final String? country;

  /// "Mumbai, Maharashtra" — city + state when both are known, otherwise
  /// whichever parts exist.
  String get label => [city, state].where((p) => p != null && p.isNotEmpty).join(', ');

  bool get isEmpty => (city ?? state ?? country) == null;

  /// Parses Mapbox Geocoding v6 `/reverse` features, picking one name per
  /// feature type (`place` → city, `region` → state, `country` → country).
  factory GeoPlace.fromMapboxV6(Map<String, dynamic> body) {
    final features = (body['features'] as List?) ?? const [];
    String? pick(String type) {
      for (final f in features) {
        final props = (f as Map)['properties'] as Map?;
        if (props?['feature_type'] == type) return props?['name'] as String?;
      }
      return null;
    }

    return GeoPlace(
      city: pick('place'),
      state: pick('region'),
      country: pick('country'),
    );
  }
}
