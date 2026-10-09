import 'dart:math' as math;

/// A pilgrimage route (Yatra). Parsed from `GET /routes` (list — scalars only)
/// and `GET /routes/:slug` (detail — adds ordered [temples] + [rewardCard]).
class YatraRoute {
  const YatraRoute({
    required this.id,
    required this.name,
    required this.slug,
    required this.type,
    required this.templeCount,
    this.description,
    this.coverImage,
    this.rewardCard,
    this.temples = const [],
  });

  final String id;
  final String name;
  final String slug;

  /// Backend `RouteType`: JYOTIRLINGA / SHAKTI_PEETH / CHAR_DHAM / CUSTOM.
  final String type;
  final int templeCount;
  final String? description;
  final String? coverImage;
  final RouteRewardCard? rewardCard;

  /// Ordered temples (detail only).
  final List<RouteTempleEntry> temples;

  /// Total route distance (km) as the sum of great-circle hops between
  /// consecutive temples. Derived from real coordinates — 0 when < 2 temples
  /// carry coordinates. The backend does not store a route distance.
  double get totalDistanceKm {
    var meters = 0.0;
    for (var i = 1; i < temples.length; i++) {
      final a = temples[i - 1].temple;
      final b = temples[i].temple;
      meters += _haversineMeters(a.latitude, a.longitude, b.latitude, b.longitude);
    }
    return meters / 1000;
  }

  static int _i(Object? v, [int fallback = 0]) => v is num ? v.toInt() : int.tryParse('$v') ?? fallback;

  factory YatraRoute.fromJson(Map<String, dynamic> json) {
    final rewardCard = (json['rewardCard'] as Map?)?.cast<String, dynamic>();
    final temples = (json['temples'] as List?) ?? const [];
    return YatraRoute(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      slug: (json['slug'] as String?) ?? '',
      type: (json['type'] as String?) ?? 'CUSTOM',
      templeCount: _i(json['templeCount']),
      description: json['description'] as String?,
      coverImage: json['coverImage'] as String?,
      rewardCard: rewardCard == null ? null : RouteRewardCard.fromJson(rewardCard),
      temples: temples
          .whereType<Map<dynamic, dynamic>>()
          .map((m) => RouteTempleEntry.fromJson(m.cast<String, dynamic>()))
          .where((e) => e.temple.id.isNotEmpty)
          .toList(growable: false),
    );
  }
}

/// A temple's position within a route.
class RouteTempleEntry {
  const RouteTempleEntry({required this.position, required this.temple});

  final int position;
  final RouteTempleInfo temple;

  factory RouteTempleEntry.fromJson(Map<String, dynamic> json) {
    final temple = (json['temple'] as Map?)?.cast<String, dynamic>() ?? const {};
    return RouteTempleEntry(
      position: (json['position'] as num?)?.toInt() ?? 0,
      temple: RouteTempleInfo.fromJson(temple),
    );
  }
}

/// The temple fields carried inside a route detail (enriched with cover image
/// + city/state by the Phase 21.8 backend change).
class RouteTempleInfo {
  const RouteTempleInfo({
    required this.id,
    required this.name,
    required this.slug,
    required this.latitude,
    required this.longitude,
    this.city,
    this.state,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String slug;
  final double latitude;
  final double longitude;
  final String? city;
  final String? state;
  final String? imageUrl;

  String? get location {
    final parts = [city, state].whereType<String>().where((p) => p.isNotEmpty).toList();
    return parts.isEmpty ? null : parts.join(', ');
  }

  static double _d(Object? v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;

  factory RouteTempleInfo.fromJson(Map<String, dynamic> json) {
    final cityMap = (json['city'] as Map?)?.cast<String, dynamic>();
    final stateMap = (cityMap?['state'] as Map?)?.cast<String, dynamic>();
    final images = (json['images'] as List?) ?? const [];
    final firstImage = images.whereType<Map<dynamic, dynamic>>().map((m) => m.cast<String, dynamic>()).firstOrNull;
    return RouteTempleInfo(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      slug: (json['slug'] as String?) ?? '',
      latitude: _d(json['latitude']),
      longitude: _d(json['longitude']),
      city: cityMap?['name'] as String?,
      state: stateMap?['name'] as String?,
      imageUrl: firstImage?['url'] as String?,
    );
  }
}

/// The reward card granted on route completion.
class RouteRewardCard {
  const RouteRewardCard({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.rarity,
    this.subtitle,
    this.seriesId,
    this.seasonId,
  });

  final String id;
  final String title;
  final String imageUrl;
  final String rarity;
  final String? subtitle;
  final String? seriesId;
  final String? seasonId;

  factory RouteRewardCard.fromJson(Map<String, dynamic> json) => RouteRewardCard(
        id: (json['id'] as String?) ?? '',
        title: (json['title'] as String?) ?? '',
        imageUrl: (json['imageUrl'] as String?) ?? '',
        rarity: (json['rarity'] as String?) ?? 'EPIC',
        subtitle: json['subtitle'] as String?,
        seriesId: json['seriesId'] as String?,
        seasonId: json['seasonId'] as String?,
      );
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}

double _haversineMeters(double lat1, double lon1, double lat2, double lon2) {
  if (lat1 == 0 && lon1 == 0) return 0;
  if (lat2 == 0 && lon2 == 0) return 0;
  const r = 6371000.0;
  final dLat = _rad(lat2 - lat1);
  final dLon = _rad(lon2 - lon1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_rad(lat1)) * math.cos(_rad(lat2)) * math.sin(dLon / 2) * math.sin(dLon / 2);
  return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}

double _rad(double deg) => deg * math.pi / 180;
