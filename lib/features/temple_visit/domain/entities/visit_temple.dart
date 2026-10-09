/// A lightweight temple reference used by the visit journey: enough to render
/// the header, compute geofence distance, and launch external navigation.
/// Parsed from the `/temples/:slug` detail contract (the same source the
/// Temple Detail screen uses).
class VisitTemple {
  const VisitTemple({
    required this.id,
    required this.name,
    required this.slug,
    required this.latitude,
    required this.longitude,
    required this.geofenceRadius,
    this.city,
    this.state,
    this.imageUrl,
    this.deity,
  });

  final String id;
  final String name;
  final String slug;
  final double latitude;
  final double longitude;

  /// Radius (metres) of the temple's check-in geofence circle.
  final int geofenceRadius;
  final String? city;
  final String? state;
  final String? imageUrl;

  /// Backend `DeityType` (SHIVA, DEVI…) — picks the greeting on success.
  final String? deity;

  String? get location {
    final parts = [city, state].where((p) => p != null && p.isNotEmpty).toList();
    return parts.isEmpty ? null : parts.join(', ');
  }

  static double _d(Object? v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
  static int _i(Object? v, int fallback) => v is num ? v.toInt() : int.tryParse('$v') ?? fallback;
  static String _s(Object? v) => v is String ? v : '';

  factory VisitTemple.fromJson(Map<String, dynamic> json) {
    final cityMap = (json['city'] as Map?)?.cast<String, dynamic>();
    final stateMap = (cityMap?['state'] as Map?)?.cast<String, dynamic>();
    return VisitTemple(
      id: _s(json['id']),
      name: _s(json['name']),
      slug: _s(json['slug']),
      latitude: _d(json['latitude']),
      longitude: _d(json['longitude']),
      geofenceRadius: _i(json['geofenceRadius'], 100),
      city: cityMap?['name'] as String?,
      state: stateMap?['name'] as String?,
      imageUrl: _coverImage(json['images']),
      deity: json['deity'] as String?,
    );
  }

  static String? _coverImage(Object? images) {
    if (images is! List || images.isEmpty) return null;
    final maps = images.whereType<Map<dynamic, dynamic>>().map((m) => m.cast<String, dynamic>()).toList();
    if (maps.isEmpty) return null;
    final cover = maps.firstWhere(
      (m) => m['isCover'] == true,
      orElse: () => maps.first,
    );
    final url = cover['url'];
    return url is String && url.isNotEmpty ? url : null;
  }
}
