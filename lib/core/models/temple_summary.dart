// The backend's lean "temple card" projection (`temples/services/temple-card.ts`)
// used wherever temples are listed outside the detail screen — saved places,
// Home, reviews. Defensive parsing: a reshaped payload degrades, never throws.

String? _s(Object? v) => v is String && v.isNotEmpty ? v : null;
int _i(Object? v) => v is int ? v : (v is num ? v.toInt() : int.tryParse('$v') ?? 0);
double _d(Object? v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
Map<String, dynamic>? _m(Object? v) => v is Map<dynamic, dynamic> ? v.cast<String, dynamic>() : null;

/// Whether a temple is open right now (IST timings). [isOpen] is null when
/// the temple has no timing for today.
class OpenStatus {
  const OpenStatus({this.isOpen, this.opensAt, this.closesAt});

  final bool? isOpen;

  /// Today's opening / closing time ("HH:mm", IST).
  final String? opensAt;
  final String? closesAt;

  factory OpenStatus.fromJson(Map<String, dynamic>? j) => OpenStatus(
        isOpen: j?['isOpen'] is bool ? j!['isOpen'] as bool : null,
        opensAt: _s(j?['opensAt']),
        closesAt: _s(j?['closesAt']),
      );
}

class TempleSummary {
  const TempleSummary({
    required this.id,
    required this.name,
    required this.slug,
    this.deity,
    this.city,
    this.state,
    this.latitude = 0,
    this.longitude = 0,
    this.imageUrl,
    this.ratingAverage = 0,
    this.ratingCount = 0,
    this.openStatus = const OpenStatus(),
  });

  final String id;
  final String name;
  final String slug;
  final String? deity;
  final String? city;
  final String? state;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final double ratingAverage;
  final int ratingCount;
  final OpenStatus openStatus;

  /// "Varanasi, Uttar Pradesh" (whichever parts are known).
  String get place => [?city, ?state].join(', ');

  factory TempleSummary.fromJson(Map<String, dynamic> j) => TempleSummary(
        id: _s(j['id']) ?? '',
        name: _s(j['name']) ?? '',
        slug: _s(j['slug']) ?? '',
        deity: _s(j['deity']),
        city: _s(j['city']),
        state: _s(j['state']),
        latitude: _d(j['latitude']),
        longitude: _d(j['longitude']),
        imageUrl: _s(j['imageUrl']),
        ratingAverage: _d(j['ratingAverage']),
        ratingCount: _i(j['ratingCount']),
        openStatus: OpenStatus.fromJson(_m(j['openStatus'])),
      );
}
