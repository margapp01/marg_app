// Immutable domain models for Explore Bharat. Hand-written, defensive parsing
// matches the app convention (AuthUser / HomeDashboard / TempleDetail). Every
// section degrades to null/0/[] instead of throwing on a reshaped payload.

import '../../../../core/models/temple_summary.dart';
import '../../../directions/domain/route_plan.dart';

export '../../../../core/models/temple_summary.dart';

String? _s(Object? v) => v is String && v.isNotEmpty ? v : null;
int _i(Object? v) => v is int ? v : (v is num ? v.toInt() : int.tryParse('$v') ?? 0);
double _d(Object? v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
bool _b(Object? v) => v == true;
DateTime? _dt(Object? v) => v is String ? DateTime.tryParse(v) : null;
Map<String, dynamic>? _m(Object? v) => v is Map<dynamic, dynamic> ? v.cast<String, dynamic>() : null;

/// A temple on the devotee's Saved Places list (`/my/saved-temples`).
class SavedTemple {
  const SavedTemple({required this.temple, this.savedAt, this.visited = false});

  final TempleSummary temple;
  final DateTime? savedAt;

  /// The devotee already has a verified visit here.
  final bool visited;

  factory SavedTemple.fromJson(Map<String, dynamic> j) => SavedTemple(
    temple: TempleSummary.fromJson(_m(j['temple']) ?? const {}),
    savedAt: _dt(j['savedAt']),
    visited: _b(j['visited']),
  );
}

/// A temple as returned by `/temples`, `/temples/search` and `/temples/nearby`:
/// `city.state`, `card`, plus the card extras (cover photo, rating, live open
/// status). The image falls back to the Sacred Card art when there's no photo.
class ExploreTemple {
  const ExploreTemple({
    required this.id,
    required this.name,
    required this.slug,
    required this.latitude,
    required this.longitude,
    this.deity,
    this.cityName,
    this.stateName,
    this.cardImageUrl,
    this.viewCount = 0,
    this.isVerified = false,
    this.distanceMeters,
    this.coverImageUrl,
    this.ratingAverage = 0,
    this.ratingCount = 0,
    this.openStatus = const OpenStatus(),
  });

  final String id;
  final String name;
  final String slug;
  final double latitude;
  final double longitude;
  final String? deity;
  final String? cityName;
  final String? stateName;
  final String? cardImageUrl;
  final int viewCount;
  final bool isVerified;

  /// Where in-app directions lead for this temple.
  DirectionsArgs get directionsArgs => DirectionsArgs(
        name: name,
        latitude: latitude,
        longitude: longitude,
        place: [cityName, stateName].whereType<String>().join(', '),
        imageUrl: cardImageUrl,
        templeSlug: slug,
      );

  /// Present only for the nearby contract (`{ temple, distanceMeters }`).
  final double? distanceMeters;

  /// The temple's cover photo (list + nearby contracts).
  final String? coverImageUrl;
  final double ratingAverage;
  final int ratingCount;
  final OpenStatus openStatus;

  /// Best available image: the cover photo, else the Sacred Card art.
  String? get imageUrl => coverImageUrl ?? cardImageUrl;

  String get location => [cityName, stateName].whereType<String>().where((e) => e.isNotEmpty).join(', ');

  String? get formattedDistance {
    final m = distanceMeters;
    if (m == null) return null;
    return m < 1000 ? '${m.round()} m' : '${(m / 1000).toStringAsFixed(1)} km';
  }

  /// Parses a bare temple object (list/search) or a nearby row that wraps it.
  factory ExploreTemple.fromJson(Map<String, dynamic> json) {
    final nested = _m(json['temple']);
    if (nested != null) {
      return ExploreTemple._fromTemple(nested, distanceMeters: (json['distanceMeters'] as num?)?.toDouble());
    }
    return ExploreTemple._fromTemple(json);
  }

  factory ExploreTemple._fromTemple(Map<String, dynamic> t, {double? distanceMeters}) {
    final city = _m(t['city']);
    final state = _m(city?['state']);
    final card = _m(t['card']);
    return ExploreTemple(
      id: _s(t['id']) ?? '',
      name: _s(t['name']) ?? '',
      slug: _s(t['slug']) ?? '',
      latitude: _d(t['latitude']),
      longitude: _d(t['longitude']),
      deity: _s(t['deity']),
      cityName: _s(city?['name']),
      stateName: _s(state?['name']),
      cardImageUrl: _s(card?['imageUrl']),
      viewCount: _i(t['viewCount']),
      isVerified: _b(t['isVerified']),
      distanceMeters: distanceMeters,
      coverImageUrl: _s(t['coverImageUrl']),
      ratingAverage: _d(t['ratingAverage']),
      ratingCount: _i(t['ratingCount']),
      openStatus: OpenStatus.fromJson(_m(t['openStatus'])),
    );
  }
}

/// The temple `DeityType` values that back the Category screen. These are the
/// ONLY categories the backend models — the mockup's Jyotirlinga / Shakti Peeth
/// / Jain / Buddhist / Sikh / Historic categories are intentionally omitted.
enum ExploreDeity {
  shiva('SHIVA'),
  vishnu('VISHNU'),
  devi('DEVI'),
  hanuman('HANUMAN'),
  ganesha('GANESHA');

  const ExploreDeity(this.wire);
  final String wire;
}

/// A deity category with a live temple count (from `/temples?deity=X`).
class TempleCategory {
  const TempleCategory({required this.deity, required this.count, this.coverImage, this.topTemple});
  final ExploreDeity deity;
  final int count;

  /// Photo of the category's most-viewed temple, and its name.
  final String? coverImage;
  final String? topTemple;
}

/// A state with its published-temple count (`/states` + `/temples?stateId=X`)
/// and, like a category, the photo and name of its most-viewed temple.
class ExploreStateItem {
  const ExploreStateItem({
    required this.id,
    required this.name,
    required this.slug,
    this.templeCount,
    this.coverImage,
    this.topTemple,
  });
  final String id;
  final String name;
  final String slug;
  final int? templeCount;
  final String? coverImage;
  final String? topTemple;

  ExploreStateItem withSummary({required int count, String? coverImage, String? topTemple}) => ExploreStateItem(
    id: id,
    name: name,
    slug: slug,
    templeCount: count,
    coverImage: coverImage,
    topTemple: topTemple,
  );

  factory ExploreStateItem.fromJson(Map<String, dynamic> j) =>
      ExploreStateItem(id: _s(j['id']) ?? '', name: _s(j['name']) ?? '', slug: _s(j['slug']) ?? '');
}

/// How Explore lists order temples — all backed by real `sortBy` values.
enum ExploreSort {
  popular('viewCount', 'desc'),
  newest('createdAt', 'desc'),
  nameAsc('name', 'asc');

  const ExploreSort(this.sortBy, this.sortOrder);
  final String sortBy;
  final String sortOrder;
}

/// The list filter Explore actually supports server-side: radius is nearby-only;
/// deity + sort map straight to `/temples` query params. (Open-now / crowd /
/// facilities are detail-only on the backend and are intentionally excluded.)
class ExploreFilter {
  const ExploreFilter({this.deity, this.sort = ExploreSort.popular, this.radiusKm = 25});

  final ExploreDeity? deity;
  final ExploreSort sort;
  final int radiusKm;

  ExploreFilter copyWith({Object? deity = _keep, ExploreSort? sort, int? radiusKm}) => ExploreFilter(
    deity: identical(deity, _keep) ? this.deity : deity as ExploreDeity?,
    sort: sort ?? this.sort,
    radiusKm: radiusKm ?? this.radiusKm,
  );

  bool get isDefault => deity == null && sort == ExploreSort.popular && radiusKm == 25;

  static const _keep = Object();
}

/// A query-backed collection (there is no backend Collection model, so each
/// collection is just a real temple query with a friendly identity).
class ExploreCollection {
  const ExploreCollection({required this.id, required this.sort, this.deity});
  final String id;
  final ExploreSort sort;
  final ExploreDeity? deity;
}

/// A collection with its live temple count and its lead temple's photo/name.
class CollectionSummary {
  const CollectionSummary({required this.collection, required this.count, this.coverImage, this.topTemple});
  final ExploreCollection collection;
  final int count;
  final String? coverImage;
  final String? topTemple;
}

const kExploreCollections = <ExploreCollection>[
  ExploreCollection(id: 'popular', sort: ExploreSort.popular),
  ExploreCollection(id: 'newest', sort: ExploreSort.newest),
  ExploreCollection(id: 'shiva', sort: ExploreSort.popular, deity: ExploreDeity.shiva),
  ExploreCollection(id: 'vishnu', sort: ExploreSort.popular, deity: ExploreDeity.vishnu),
  ExploreCollection(id: 'devi', sort: ExploreSort.popular, deity: ExploreDeity.devi),
];

/// One verified visit, from `/my/visits` (visit-level coords + the temple's
/// name, slug, cover image and city/state).
class VisitRecord {
  const VisitRecord({
    required this.templeName,
    this.templeSlug,
    this.imageUrl,
    this.place,
    this.city,
    this.state,
    this.latitude,
    this.longitude,
    this.visitedAt,
  });
  final String templeName;
  final String? templeSlug;
  final String? imageUrl;

  /// "City, State" when known.
  final String? place;
  final String? city;
  final String? state;
  final double? latitude;
  final double? longitude;
  final DateTime? visitedAt;

  factory VisitRecord.fromJson(Map<String, dynamic> j) {
    final temple = _m(j['temple']);
    final images = temple?['images'];
    final cover = images is List && images.isNotEmpty ? _m(images.first) : null;
    final city = _m(temple?['city']);
    final state = _m(city?['state']);
    final place = [_s(city?['name']), _s(state?['name'])].whereType<String>().join(', ');
    return VisitRecord(
      templeName: _s(temple?['name']) ?? 'Temple',
      templeSlug: _s(temple?['slug']),
      imageUrl: _s(cover?['url']),
      place: place.isEmpty ? null : place,
      city: _s(city?['name']),
      state: _s(state?['name']),
      latitude: (j['latitude'] as num?)?.toDouble() ?? (temple?['latitude'] as num?)?.toDouble(),
      longitude: (j['longitude'] as num?)?.toDouble() ?? (temple?['longitude'] as num?)?.toDouble(),
      visitedAt: _dt(j['visitedAt'] ?? j['visitDate']),
    );
  }
}

/// Exploration statistics honestly derived from `/my/visits` (+ the user's
/// current location for nearest/farthest). States and cities come from each
/// visited temple's city; distance travelled is NOT derivable and is omitted.
class ExploreStatistics {
  const ExploreStatistics({
    required this.templesExplored,
    required this.thisMonth,
    required this.monthly,
    this.statesVisited = 0,
    this.citiesVisited = 0,
    this.topStates = const [],
    this.firstVisit,
    this.lastVisit,
    this.nearestName,
    this.nearestKm,
    this.farthestName,
    this.farthestKm,
  });

  final int templesExplored;
  final int thisMonth;

  /// (label, count) for the trailing 6 months, oldest → newest.
  final List<(String, int)> monthly;
  final int statesVisited;
  final int citiesVisited;

  /// (state, visits) for the most-visited states, most first.
  final List<(String, int)> topStates;
  final DateTime? firstVisit;
  final DateTime? lastVisit;
  final String? nearestName;
  final double? nearestKm;
  final String? farthestName;
  final double? farthestKm;

  bool get isEmpty => templesExplored == 0;
}
