/// The outcome of `POST /temples/:id/checkin`. Everything here is computed and
/// returned by the backend — the client never fabricates a verification or an
/// unlock.
class CheckinResult {
  const CheckinResult({
    required this.verified,
    required this.distanceMeters,
    required this.trustScore,
    required this.status,
    required this.rewards,
  });

  final bool verified;
  final int distanceMeters;
  final int trustScore;

  /// Backend `VisitStatus` (e.g. VERIFIED / FRAUD_SUSPECTED).
  final String status;
  final VisitRewards rewards;

  static int _i(Object? v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

  factory CheckinResult.fromJson(Map<String, dynamic> json) {
    final visit = (json['visit'] as Map?)?.cast<String, dynamic>();
    return CheckinResult(
      verified: json['verified'] == true,
      distanceMeters: _i(json['distanceMeters']),
      trustScore: _i(json['trustScore']),
      status: (visit?['status'] as String?) ?? (json['verified'] == true ? 'VERIFIED' : 'PENDING'),
      rewards: VisitRewards.fromJson((json['rewards'] as Map?)?.cast<String, dynamic>()),
    );
  }
}

/// Rewards produced by a verified visit. Empty for an unverified check-in.
class VisitRewards {
  const VisitRewards({
    this.card,
    this.achievements = const [],
    this.seriesCompleted = const [],
    this.seasonsCompleted = const [],
  });

  final VisitRewardCard? card;
  final List<VisitRewardAchievement> achievements;
  final List<String> seriesCompleted;
  final List<String> seasonsCompleted;

  bool get hasNewCard => card?.unlocked == true;
  bool get hasAchievements => achievements.isNotEmpty;

  factory VisitRewards.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const VisitRewards();
    final cardMap = (json['card'] as Map?)?.cast<String, dynamic>();
    return VisitRewards(
      card: cardMap == null ? null : VisitRewardCard.fromJson(cardMap),
      achievements: ((json['achievements'] as List?) ?? const [])
          .whereType<Map<dynamic, dynamic>>()
          .map((m) => VisitRewardAchievement.fromJson(m.cast<String, dynamic>()))
          .toList(growable: false),
      seriesCompleted: _names(json['seriesCompleted']),
      seasonsCompleted: _names(json['seasonsCompleted']),
    );
  }

  static List<String> _names(Object? list) {
    if (list is! List) return const [];
    return list
        .whereType<Map<dynamic, dynamic>>()
        .map((m) => m['name'])
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
  }
}

/// A temple card surfaced by the visit (for the unlock reveal screen).
class VisitRewardCard {
  const VisitRewardCard({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.rarity,
    required this.unlocked,
    required this.alreadyOwned,
  });

  final String id;
  final String title;
  final String imageUrl;

  /// Backend `CardRarity` (COMMON / RARE / EPIC / LEGENDARY / MYTHIC).
  final String rarity;

  /// True when THIS visit newly unlocked the card (drives the reveal).
  final bool unlocked;
  final bool alreadyOwned;

  factory VisitRewardCard.fromJson(Map<String, dynamic> json) => VisitRewardCard(
        id: (json['id'] as String?) ?? '',
        title: (json['title'] as String?) ?? '',
        imageUrl: (json['imageUrl'] as String?) ?? '',
        rarity: (json['rarity'] as String?) ?? 'COMMON',
        unlocked: json['unlocked'] == true,
        alreadyOwned: json['alreadyOwned'] == true,
      );
}

/// An achievement newly earned by the visit.
class VisitRewardAchievement {
  const VisitRewardAchievement({
    required this.id,
    required this.slug,
    required this.name,
    required this.points,
    this.badgeImageUrl,
  });

  final String id;
  final String slug;
  final String name;
  final int points;
  final String? badgeImageUrl;

  factory VisitRewardAchievement.fromJson(Map<String, dynamic> json) => VisitRewardAchievement(
        id: (json['id'] as String?) ?? '',
        slug: (json['slug'] as String?) ?? '',
        name: (json['name'] as String?) ?? '',
        points: (json['points'] as num?)?.toInt() ?? 0,
        badgeImageUrl: json['badgeImageUrl'] as String?,
      );
}
