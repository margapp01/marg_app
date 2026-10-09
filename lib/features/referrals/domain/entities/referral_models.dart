// Domain models for Referral, Community & Social Sharing. Hand-written,
// defensive parsing (matches the app convention). Every field degrades to a
// safe default instead of throwing on a reshaped payload.

String? _s(Object? v) => v is String && v.isNotEmpty ? v : null;
int _i(Object? v) => v is int ? v : (v is num ? v.toInt() : int.tryParse('$v') ?? 0);
int? _iN(Object? v) => v == null ? null : _i(v);
DateTime? _dt(Object? v) => v is String ? DateTime.tryParse(v) : null;
Map<String, dynamic>? _m(Object? v) => v is Map<dynamic, dynamic> ? v.cast<String, dynamic>() : null;

/// The base the invite link is composed from. The backend returns the referral
/// **code** only (no full URL), so the client wraps it with the app-owned base.
const String kReferralLinkBase = 'https://marg.app.link';

/// `GET /my/referral` — the dashboard summary.
class ReferralSummary {
  const ReferralSummary({
    required this.code,
    required this.totalInvites,
    required this.successfulInvites,
    required this.pointsEarned,
    this.nextMilestone,
    this.referralsToNextMilestone,
  });

  final String code;
  final int totalInvites;
  final int successfulInvites;
  final int pointsEarned;
  final int? nextMilestone;
  final int? referralsToNextMilestone;

  String get inviteLink => '$kReferralLinkBase/$code';

  /// Progress toward the next milestone (0–1); full when there is no next one.
  double get milestoneProgress {
    final next = nextMilestone;
    if (next == null || next <= 0) return 1;
    return (successfulInvites / next).clamp(0, 1);
  }

  factory ReferralSummary.fromJson(Map<String, dynamic> j) => ReferralSummary(
        code: _s(j['code']) ?? '',
        totalInvites: _i(j['totalInvites']),
        successfulInvites: _i(j['successfulInvites']),
        pointsEarned: _i(j['pointsEarned']),
        nextMilestone: _iN(j['nextMilestone']),
        referralsToNextMilestone: _iN(j['referralsToNextMilestone']),
      );
}

/// Backend `ReferralStatus`.
enum ReferralStatus {
  pending('PENDING'),
  completed('COMPLETED'),
  rewarded('REWARDED'),
  unknown('');

  const ReferralStatus(this.wire);
  final String wire;

  static ReferralStatus fromWire(String? v) {
    for (final s in ReferralStatus.values) {
      if (s.wire == v) return s;
    }
    return ReferralStatus.unknown;
  }
}

/// `GET /my/referrals` — one referral invite (no friend profile is returned).
class ReferralInvite {
  const ReferralInvite({
    required this.id,
    required this.status,
    this.source,
    this.createdAt,
    this.completedAt,
  });

  final String id;
  final ReferralStatus status;
  final String? source;
  final DateTime? createdAt;
  final DateTime? completedAt;

  factory ReferralInvite.fromJson(Map<String, dynamic> j) => ReferralInvite(
        id: _s(j['id']) ?? '',
        status: ReferralStatus.fromWire(_s(j['status'])),
        source: _s(j['source']),
        createdAt: _dt(j['createdAt']),
        completedAt: _dt(j['completedAt']),
      );
}

/// Backend `ReferralRewardType`.
enum ReferralRewardType { points, card, achievement, specialBadge, unknown }

ReferralRewardType rewardTypeFromWire(String? v) {
  switch (v) {
    case 'POINTS':
      return ReferralRewardType.points;
    case 'CARD':
      return ReferralRewardType.card;
    case 'ACHIEVEMENT':
      return ReferralRewardType.achievement;
    case 'SPECIAL_BADGE':
      return ReferralRewardType.specialBadge;
    default:
      return ReferralRewardType.unknown;
  }
}

/// `GET /my/referral/rewards` — a granted reward (includes the friend's name).
class ReferralReward {
  const ReferralReward({
    required this.id,
    required this.type,
    required this.value,
    this.awardedAt,
    this.friendName,
    this.friendPhoto,
  });

  final String id;
  final ReferralRewardType type;
  final String value; // e.g. "150" (points) or a card/badge slug
  final DateTime? awardedAt;
  final String? friendName;
  final String? friendPhoto;

  /// Points value when this reward is a POINTS reward, else null.
  int? get points => type == ReferralRewardType.points ? int.tryParse(value) : null;

  factory ReferralReward.fromJson(Map<String, dynamic> j) {
    final friend = _m(j['referredUser']);
    return ReferralReward(
      id: _s(j['id']) ?? '',
      type: rewardTypeFromWire(_s(j['rewardType'])),
      value: _s(j['rewardValue']) ?? '',
      awardedAt: _dt(j['awardedAt']),
      friendName: _s(friend?['name']),
      friendPhoto: _s(friend?['profilePhoto']),
    );
  }
}

/// A page of items + pagination cursor state (shared by invites/rewards).
class Paged<T> {
  const Paged({required this.items, required this.page, required this.totalPages, required this.total});
  final List<T> items;
  final int page;
  final int totalPages;
  final int total;

  bool get hasMore => page < totalPages;

  factory Paged.fromEnvelope(Map<String, dynamic> env, T Function(Map<String, dynamic>) fromJson) {
    final data = (env['data'] as List?) ?? const [];
    final p = _m(env['pagination']) ?? const {};
    return Paged(
      items: data.whereType<Map<dynamic, dynamic>>().map((e) => fromJson(e.cast<String, dynamic>())).toList(growable: false),
      page: (p['page'] as num?)?.toInt() ?? 1,
      totalPages: (p['totalPages'] as num?)?.toInt() ?? 1,
      total: (p['total'] as num?)?.toInt() ?? data.length,
    );
  }
}

/// One row of the referral leaderboard (`GET /referrals/leaderboard`).
class LeaderRow {
  const LeaderRow({required this.position, required this.userId, required this.points, this.displayName, this.avatarUrl, this.tier});
  final int position;
  final String userId;
  final int points;
  final String? displayName;
  final String? avatarUrl;
  final String? tier;

  factory LeaderRow.fromJson(Map<String, dynamic> j) => LeaderRow(
        position: _i(j['position']),
        userId: _s(j['userId']) ?? '',
        points: _i(j['points']),
        displayName: _s(j['displayName']),
        avatarUrl: _s(j['avatarUrl']),
        tier: _s(j['tier']),
      );
}

/// Referral analytics derived client-side from the summary + invite history
/// (the user-facing analytics endpoint isn't exposed; nothing is fabricated).
class ReferralAnalytics {
  const ReferralAnalytics({
    required this.invitesSent,
    required this.joined,
    required this.conversionPercent,
    required this.monthly,
    this.topSource,
    this.topSourcePercent,
  });

  final int invitesSent;
  final int joined;
  final double conversionPercent;

  /// (label, count) for the trailing 6 months, oldest → newest.
  final List<(String, int)> monthly;
  final String? topSource;
  final int? topSourcePercent;
}

/// The app's real milestone reward program (mirrors the backend
/// `MILESTONE_REWARDS` constants — the "How it works" table).
class MilestoneRule {
  const MilestoneRule(this.milestone, this.points, this.bonusKey);
  final int milestone;
  final int points;

  /// A localization key for the non-points bonus (card/badge), or null.
  final String? bonusKey;
}

const kMilestoneRules = <MilestoneRule>[
  MilestoneRule(1, 50, null),
  MilestoneRule(5, 150, 'rfBonusRareCard'),
  MilestoneRule(10, 300, 'rfBonusEpicCard'),
  MilestoneRule(25, 750, 'rfBonusLegendaryCard'),
  MilestoneRule(50, 1500, 'rfBonusBadge'),
  MilestoneRule(100, 3500, 'rfBonusBadge'),
];
