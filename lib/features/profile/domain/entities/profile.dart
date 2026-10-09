// Self profile (`GET /my/profile`). Mirrors the backend user profile select.
// Hand-written defensive parsing, matching the app convention.

String? _s(Object? v) => v is String && v.isNotEmpty ? v : null;
bool _b(Object? v) => v == true;
DateTime? _dt(Object? v) => v is String ? DateTime.tryParse(v) : null;
List<String> _strings(Object? v) => ((v as List?) ?? const []).whereType<String>().toList();

class Profile {
  const Profile({
    required this.id,
    this.email,
    this.phone,
    this.name,
    this.profilePhoto,
    this.dob,
    this.gender,
    this.city,
    this.preferredLanguage = 'EN',
    this.interests = const [],
    this.isPhoneVerified = false,
    this.memberSince,
    this.favoriteDeities = const [],
    this.visitFrequency,
    this.preferredRouteTypes = const [],
    this.festivalInterests = const [],
    this.nearbyRadiusKm = defaultNearbyRadiusKm,
  });

  /// Backend default for `nearbyRadiusKm`.
  static const int defaultNearbyRadiusKm = 25;

  final String id;
  final String? email;
  final String? phone;
  final String? name;
  final String? profilePhoto;
  final DateTime? dob;
  final String? gender; // Gender enum wire value
  final String? city;
  final String preferredLanguage; // EN | HI
  final List<String> interests; // UserInterestType wire values
  final bool isPhoneVerified;
  final DateTime? memberSince;

  // Spiritual preferences (onboarding step 4 + Profile → Spiritual Preferences).
  final List<String> favoriteDeities; // DeityType wire values
  final String? visitFrequency; // VisitFrequency wire value
  final List<String> preferredRouteTypes; // RouteType wire values
  final List<String> festivalInterests; // festival slugs
  final int nearbyRadiusKm;

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
        id: _s(j['id']) ?? '',
        email: _s(j['email']),
        phone: _s(j['phone']),
        name: _s(j['name']),
        profilePhoto: _s(j['profilePhoto']),
        dob: _dt(j['dob']),
        gender: _s(j['gender']),
        city: _s(j['city']),
        preferredLanguage: _s(j['preferredLanguage']) ?? 'EN',
        interests: _strings(j['interests']),
        isPhoneVerified: _b(j['isPhoneVerified']),
        memberSince: _dt(j['createdAt']),
        favoriteDeities: _strings(j['favoriteDeities']),
        visitFrequency: _s(j['visitFrequency']),
        preferredRouteTypes: _strings(j['preferredRouteTypes']),
        festivalInterests: _strings(j['festivalInterests']),
        nearbyRadiusKm: (j['nearbyRadiusKm'] as num?)?.toInt() ?? defaultNearbyRadiusKm,
      );
}

/// The eight backend `UserInterestType` values ("What brings you here").
enum UserInterest {
  templeVisits('TEMPLE_VISITS'),
  routeCompletion('ROUTE_COMPLETION'),
  pujaPandit('PUJA_PANDIT'),
  collectCards('COLLECT_CARDS'),
  achievements('ACHIEVEMENTS'),
  eventsFestivals('EVENTS_FESTIVALS'),
  nearbyTemples('NEARBY_TEMPLES'),
  others('OTHERS');

  const UserInterest(this.wire);
  final String wire;

  /// Interests a user can pick in v1. [pujaPandit] is excluded because MARG v1
  /// ships no puja/pandit experience — but the value stays in this enum so a
  /// previously-saved `PUJA_PANDIT` still parses and displays correctly.
  static List<UserInterest> get selectable =>
      values.where((i) => i != UserInterest.pujaPandit).toList(growable: false);

  static UserInterest? fromWire(String v) {
    for (final i in UserInterest.values) {
      if (i.wire == v) return i;
    }
    return null;
  }
}

/// Backend `Gender` values.
enum ProfileGender {
  male('MALE'),
  female('FEMALE'),
  other('OTHER'),
  preferNotToSay('PREFER_NOT_TO_SAY');

  const ProfileGender(this.wire);
  final String wire;

  static ProfileGender? fromWire(String? v) {
    for (final g in ProfileGender.values) {
      if (g.wire == v) return g;
    }
    return null;
  }
}
