// Immutable domain models for the Temple Detail screen. Hand-written parsing
// (matches AuthUser / HomeDashboard / SearchResults). Everything is
// null/empty-safe so a partial or reshaped payload degrades gracefully.

String? _s(Object? v) => v is String && v.isNotEmpty ? v : null;
int _i(Object? v) => v is int ? v : (v is num ? v.toInt() : int.tryParse('$v') ?? 0);
int? _iN(Object? v) => v == null ? null : _i(v);
double _d(Object? v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
bool _b(Object? v) => v == true;
DateTime? _dt(Object? v) => v is String ? DateTime.tryParse(v) : null;
Map<String, dynamic>? _m(Object? v) =>
    v is Map<dynamic, dynamic> ? v.cast<String, dynamic>() : null;
List<T> _l<T>(Object? v, T Function(Map<String, dynamic>) f) => v is List
    ? v.whereType<Map<dynamic, dynamic>>().map((e) => f(e.cast<String, dynamic>())).toList(growable: false)
    : const [];

class TempleDetail {
  const TempleDetail({
    required this.id,
    required this.name,
    required this.slug,
    required this.latitude,
    required this.longitude,
    required this.isVerified,
    this.description,
    this.history,
    this.mythology,
    this.architecture,
    this.deity,
    this.capacity,
    this.cityName,
    this.stateName,
    this.images = const [],
    this.timings = const [],
    this.facilities = const [],
    this.routes = const [],
    this.card,
    this.ratingAverage = 0,
    this.ratingCount = 0,
    this.visitorInfo = const VisitorInfo(),
  });

  final String id;
  final String name;
  final String slug;
  final double latitude;
  final double longitude;
  final bool isVerified;
  final String? description;
  final String? history;
  final String? mythology;
  final String? architecture;
  final String? deity;
  final int? capacity;
  final String? cityName;
  final String? stateName;
  final List<TempleImage> images;
  final List<TempleTiming> timings;
  final List<TempleFacility> facilities;
  final List<TempleRouteLink> routes;
  final TempleCard? card;
  final double ratingAverage;
  final int ratingCount;
  final VisitorInfo visitorInfo;

  String? get coverImage {
    if (images.isEmpty) return null;
    final cover = images.where((i) => i.isCover);
    return (cover.isNotEmpty ? cover.first : images.first).url;
  }

  String get location => [cityName, stateName].whereType<String>().where((e) => e.isNotEmpty).join(', ');

  factory TempleDetail.fromJson(Map<String, dynamic> j) {
    final city = _m(j['city']);
    final state = _m(city?['state']);
    return TempleDetail(
      id: _s(j['id']) ?? '',
      name: _s(j['name']) ?? '',
      slug: _s(j['slug']) ?? '',
      latitude: _d(j['latitude']),
      longitude: _d(j['longitude']),
      isVerified: _b(j['isVerified']),
      description: _s(j['description']),
      history: _s(j['history']),
      mythology: _s(j['mythology']),
      architecture: _s(j['architecture']),
      deity: _s(j['deity']),
      capacity: _iN(j['capacity']),
      cityName: _s(city?['name']),
      stateName: _s(state?['name']),
      images: _l(j['images'], TempleImage.fromJson),
      timings: _l(j['timings'], TempleTiming.fromJson),
      facilities: _l(j['facilities'], TempleFacility.fromJson),
      routes: _l(j['routeLinks'], TempleRouteLink.fromJson),
      card: _m(j['card']) == null ? null : TempleCard.fromJson(_m(j['card'])!),
      ratingAverage: _d(j['ratingAverage']),
      ratingCount: _i(j['ratingCount']),
      visitorInfo: VisitorInfo.fromJson(j),
    );
  }
}

/// "Plan Your Visit" — admin-authored visitor guidance (all optional).
class VisitorInfo {
  const VisitorInfo({
    this.dressCode,
    this.photographyPolicy,
    this.visitorRules,
    this.howToReach,
    this.parkingInfo,
    this.accommodationInfo,
    this.prasadInfo,
    this.bestSeason,
  });

  final String? dressCode;

  /// Backend `PhotographyPolicy`: ALLOWED / RESTRICTED / NOT_ALLOWED.
  final String? photographyPolicy;
  final String? visitorRules;
  final String? howToReach;
  final String? parkingInfo;
  final String? accommodationInfo;
  final String? prasadInfo;
  final String? bestSeason;

  bool get isEmpty => [
        dressCode, photographyPolicy, visitorRules, howToReach,
        parkingInfo, accommodationInfo, prasadInfo, bestSeason,
      ].every((v) => v == null);

  factory VisitorInfo.fromJson(Map<String, dynamic> j) => VisitorInfo(
        dressCode: _s(j['dressCode']),
        photographyPolicy: _s(j['photographyPolicy']),
        visitorRules: _s(j['visitorRules']),
        howToReach: _s(j['howToReach']),
        parkingInfo: _s(j['parkingInfo']),
        accommodationInfo: _s(j['accommodationInfo']),
        prasadInfo: _s(j['prasadInfo']),
        bestSeason: _s(j['bestSeason']),
      );
}

/// `GET /temples/:id/reviews/summary`.
class ReviewSummary {
  const ReviewSummary({this.average = 0, this.count = 0, this.distribution = const {}});

  final double average;
  final int count;

  /// Reviews per star value (1–5).
  final Map<int, int> distribution;

  double share(int stars) => count == 0 ? 0 : (distribution[stars] ?? 0) / count;

  factory ReviewSummary.fromJson(Map<String, dynamic> j) {
    final dist = _m(j['distribution']) ?? const {};
    return ReviewSummary(
      average: _d(j['average']),
      count: _i(j['count']),
      distribution: {for (var s = 1; s <= 5; s++) s: _i(dist['$s'])},
    );
  }
}

/// One devotee review (`/temples/:id/reviews`).
class TempleReview {
  const TempleReview({
    required this.id,
    required this.rating,
    this.comment = '',
    this.verifiedVisitor = false,
    this.createdAt,
    this.authorName,
    this.authorPhoto,
  });

  final String id;
  final int rating;
  final String comment;
  final bool verifiedVisitor;
  final DateTime? createdAt;
  final String? authorName;
  final String? authorPhoto;

  factory TempleReview.fromJson(Map<String, dynamic> j) {
    final author = _m(j['author']) ?? const {};
    return TempleReview(
      id: _s(j['id']) ?? '',
      rating: _i(j['rating']).clamp(1, 5),
      comment: _s(j['comment']) ?? '',
      verifiedVisitor: _b(j['isVerifiedVisitor']),
      createdAt: _dt(j['createdAt']),
      authorName: _s(author['name']),
      authorPhoto: _s(author['photo']),
    );
  }
}

class TempleImage {
  const TempleImage({required this.url, this.altText, this.caption, this.isCover = false, this.position = 0});

  final String url;
  final String? altText;
  final String? caption;
  final bool isCover;
  final int position;

  factory TempleImage.fromJson(Map<String, dynamic> j) => TempleImage(
        url: _s(j['url']) ?? '',
        altText: _s(j['altText']),
        caption: _s(j['caption']),
        isCover: _b(j['isCover']),
        position: _i(j['position']),
      );
}

class TempleTiming {
  const TempleTiming({required this.dayOfWeek, required this.openTime, required this.closeTime, this.note});

  final int dayOfWeek; // 0=Sun … 6=Sat
  final String openTime;
  final String closeTime;
  final String? note;

  factory TempleTiming.fromJson(Map<String, dynamic> j) => TempleTiming(
        dayOfWeek: _i(j['dayOfWeek']),
        openTime: _s(j['openTime']) ?? '',
        closeTime: _s(j['closeTime']) ?? '',
        note: _s(j['note']),
      );
}

class TempleFacility {
  const TempleFacility({required this.name, this.icon});

  final String name;
  final String? icon;

  factory TempleFacility.fromJson(Map<String, dynamic> j) {
    final facility = _m(j['facility']) ?? j;
    return TempleFacility(name: _s(facility['name']) ?? '', icon: _s(facility['icon']));
  }
}

class TempleRouteLink {
  const TempleRouteLink({required this.id, required this.name, required this.slug, this.templeCount = 0});

  final String id;
  final String name;
  final String slug;
  final int templeCount;

  factory TempleRouteLink.fromJson(Map<String, dynamic> j) {
    final route = _m(j['route']) ?? j;
    return TempleRouteLink(
      id: _s(route['id']) ?? '',
      name: _s(route['name']) ?? '',
      slug: _s(route['slug']) ?? '',
      templeCount: _i(route['templeCount']),
    );
  }
}

class TempleCard {
  const TempleCard({required this.id, required this.title, required this.imageUrl, required this.rarity, this.subtitle, this.description});

  final String id;
  final String title;
  final String imageUrl;
  final String rarity;
  final String? subtitle;
  final String? description;

  factory TempleCard.fromJson(Map<String, dynamic> j) => TempleCard(
        id: _s(j['id']) ?? '',
        title: _s(j['title']) ?? '',
        imageUrl: _s(j['imageUrl']) ?? '',
        rarity: _s(j['rarity']) ?? 'COMMON',
        subtitle: _s(j['subtitle']),
        description: _s(j['description']),
      );
}

/// Live crowd estimate from `GET /temples/:id/crowd`.
class CrowdInfo {
  const CrowdInfo({
    required this.occupancyPercent,
    required this.estimatedOccupancy,
    required this.capacity,
    required this.crowdLevel,
    required this.confidence,
    required this.festivalActive,
    this.waitMinutes,
    this.capturedAt,
  });

  final int occupancyPercent;
  final int estimatedOccupancy;
  final int capacity;
  final String crowdLevel; // LOW / MODERATE / HIGH / VERY_HIGH
  final double confidence;
  final bool festivalActive;
  final int? waitMinutes;
  final DateTime? capturedAt;

  factory CrowdInfo.fromJson(Map<String, dynamic> j) => CrowdInfo(
        occupancyPercent: _i(j['occupancyPercent']),
        estimatedOccupancy: _i(j['estimatedOccupancy']),
        capacity: _i(j['capacity']),
        crowdLevel: _s(j['crowdLevel']) ?? 'LOW',
        confidence: _d(j['confidenceScore']),
        festivalActive: _b(j['festivalActive']),
        waitMinutes: _iN(j['estimatedWaitMinutes']),
        capturedAt: _dt(j['capturedAt']),
      );
}

/// A best-time / peak slot; `hour` is 0–23 local.
class HourSlot {
  const HourSlot(this.hour);

  final int hour;

  static List<HourSlot> list(Object? v) => v is List
      ? v
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => HourSlot(_i(e['hour'])))
          .toList(growable: false)
      : const [];

  /// A contiguous "H1 AM – H2 AM" window over a set of slots, or null if empty.
  static String? window(List<HourSlot> slots) {
    if (slots.isEmpty) return null;
    final hours = slots.map((s) => s.hour).toList()..sort();
    return '${_fmt(hours.first)} – ${_fmt(hours.last + 1)}';
  }

  static String _fmt(int h) {
    final hour = h % 24;
    final period = hour < 12 ? 'AM' : 'PM';
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$h12:00 $period';
  }
}

/// `GET /temples/:id/my-status` — the signed-in user's state for this temple.
class TempleMyStatus {
  const TempleMyStatus({
    required this.visited,
    required this.verified,
    required this.visitStatus,
    this.lastVisitAt,
    this.visitCount = 0,
    this.canCheckIn = true,
    this.nextCheckinAt,
    this.cardCollected = false,
    this.cardTitle,
    this.cardRarity,
    this.routes = const [],
    this.saved = false,
  });

  final bool visited;
  final bool verified;
  final String visitStatus;
  final DateTime? lastVisitAt;

  /// Verified visits to this temple, all time.
  final int visitCount;

  /// False once today's check-in is done (the backend's dedupe window).
  final bool canCheckIn;

  /// When the next check-in opens — set only while [canCheckIn] is false.
  final DateTime? nextCheckinAt;
  final bool cardCollected;
  final String? cardTitle;
  final String? cardRarity;
  final List<MyRouteProgress> routes;

  /// On the devotee's Saved Places list.
  final bool saved;

  factory TempleMyStatus.fromJson(Map<String, dynamic> j) {
    final visit = _m(j['visit']) ?? const {};
    final card = _m(j['card']);
    return TempleMyStatus(
      visited: _b(visit['visited']),
      verified: _b(visit['verified']),
      visitStatus: _s(visit['status']) ?? 'NONE',
      lastVisitAt: _dt(visit['lastVisitAt']),
      visitCount: _i(visit['visitCount']),
      // Older backends omit the flag — default to allowing the attempt; the
      // check-in endpoint still enforces the rule.
      canCheckIn: visit['canCheckIn'] != false,
      nextCheckinAt: _dt(visit['nextCheckinAt']),
      cardCollected: card != null && _b(card['collected']),
      cardTitle: _s(card?['title']),
      cardRarity: _s(card?['rarity']),
      routes: _l(j['routes'], MyRouteProgress.fromJson),
      saved: _b(j['saved']),
    );
  }

  static const empty = TempleMyStatus(visited: false, verified: false, visitStatus: 'NONE');
}

class MyRouteProgress {
  const MyRouteProgress({
    required this.routeId,
    required this.slug,
    required this.name,
    required this.templeCount,
    required this.completedTemples,
    required this.percent,
  });

  final String routeId;
  final String slug;
  final String name;
  final int templeCount;
  final int completedTemples;
  final int percent;

  factory MyRouteProgress.fromJson(Map<String, dynamic> j) => MyRouteProgress(
        routeId: _s(j['routeId']) ?? '',
        slug: _s(j['slug']) ?? '',
        name: _s(j['name']) ?? '',
        templeCount: _i(j['templeCount']),
        completedTemples: _i(j['completedTemples']),
        percent: _i(j['percent']),
      );
}

/// Everything the detail screen needs, composed from parallel calls.
class TempleDetailBundle {
  const TempleDetailBundle({
    required this.temple,
    this.crowd,
    this.bestTimeWindow,
    this.peakWindow,
    this.myStatus,
    this.nearby = const [],
    this.reviewSummary,
    this.reviews = const [],
    this.myReview,
  });

  final TempleDetail temple;
  final CrowdInfo? crowd;
  final String? bestTimeWindow;
  final String? peakWindow;
  final TempleMyStatus? myStatus;
  final List<NearbyTempleRef> nearby;
  final ReviewSummary? reviewSummary;
  final List<TempleReview> reviews;

  /// The signed-in devotee's own review, if any (drives Write vs Edit).
  final TempleReview? myReview;
}

class NearbyTempleRef {
  const NearbyTempleRef({
    required this.id,
    required this.name,
    required this.slug,
    this.city,
    required this.formattedDistance,
    this.imageUrl,
    this.ratingAverage = 0,
    this.ratingCount = 0,
  });

  final String id;
  final String name;
  final String slug;
  final String? city;
  final String formattedDistance;
  final String? imageUrl;
  final double ratingAverage;
  final int ratingCount;

  factory NearbyTempleRef.fromJson(Map<String, dynamic> j) => NearbyTempleRef(
        id: _s(j['id']) ?? '',
        name: _s(j['name']) ?? '',
        slug: _s(j['slug']) ?? '',
        city: _s(j['city']),
        formattedDistance: _s(j['formattedDistance']) ?? '',
      );
}
