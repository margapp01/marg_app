/// The passport overview (`GET /my/passport`) — identity, trust, completion,
/// aggregate statistics and journey milestones.
class PassportOverview {
  const PassportOverview({
    required this.userId,
    required this.name,
    required this.trustScore,
    required this.passportCompletion,
    required this.statistics,
    required this.milestones,
    this.profilePhoto,
    this.memberSince,
    this.templesPercent = 0,
    this.cardsPercent = 0,
    this.routesPercent = 0,
  });

  final String userId;
  final String name;
  final int trustScore;
  final int passportCompletion;
  final PassportStatistics statistics;
  final List<PassportMilestone> milestones;
  final String? profilePhoto;
  final DateTime? memberSince;
  final int templesPercent;
  final int cardsPercent;
  final int routesPercent;

  /// A stable, human display id derived from the user id (not a backend field).
  String get passportId {
    final hex = userId.replaceAll('-', '');
    final a = hex.length >= 4 ? hex.substring(0, 4) : hex.padRight(4, '0');
    final b = hex.length >= 6 ? hex.substring(4, 6) : '00';
    return 'MARG-${a.toUpperCase()}-${b.toUpperCase()}';
  }

  static int _i(Object? v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
  static DateTime? _dt(Object? v) => v is String ? DateTime.tryParse(v) : null;

  factory PassportOverview.fromJson(Map<String, dynamic> json) {
    final user = (json['user'] as Map?)?.cast<String, dynamic>() ?? const {};
    final completion = (json['completion'] as Map?)?.cast<String, dynamic>() ?? const {};
    final breakdown = (completion['breakdown'] as Map?)?.cast<String, dynamic>() ?? const {};
    return PassportOverview(
      userId: (user['id'] as String?) ?? '',
      name: (user['name'] as String?) ?? 'Pilgrim',
      profilePhoto: user['profilePhoto'] as String?,
      memberSince: _dt(user['memberSince']),
      trustScore: _i(json['trustScore']),
      passportCompletion: (completion['passportCompletion'] as num?)?.round() ?? 0,
      templesPercent: (breakdown['templesPercent'] as num?)?.round() ?? 0,
      cardsPercent: (breakdown['cardsPercent'] as num?)?.round() ?? 0,
      routesPercent: (breakdown['routesPercent'] as num?)?.round() ?? 0,
      statistics: PassportStatistics.fromJson((json['statistics'] as Map?)?.cast<String, dynamic>() ?? const {}),
      milestones: ((json['milestones'] as List?) ?? const [])
          .whereType<Map<dynamic, dynamic>>()
          .map((m) => PassportMilestone.fromJson(m.cast<String, dynamic>()))
          .toList(growable: false),
    );
  }
}

class PassportStatistics {
  const PassportStatistics({
    required this.totalVisitedTemples,
    required this.verifiedVisits,
    required this.cardsCollected,
    required this.routesStarted,
    required this.routesCompleted,
  });

  final int totalVisitedTemples;
  final int verifiedVisits;
  final int cardsCollected;
  final int routesStarted;
  final int routesCompleted;

  static int _i(Object? v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

  factory PassportStatistics.fromJson(Map<String, dynamic> j) => PassportStatistics(
        totalVisitedTemples: _i(j['totalVisitedTemples']),
        verifiedVisits: _i(j['verifiedVisits']),
        cardsCollected: _i(j['cardsCollected']),
        routesStarted: _i(j['routesStarted']),
        routesCompleted: _i(j['routesCompleted']),
      );

  static const empty = PassportStatistics(
    totalVisitedTemples: 0, verifiedVisits: 0, cardsCollected: 0, routesStarted: 0, routesCompleted: 0);
}

class PassportMilestone {
  const PassportMilestone({required this.label, required this.achieved, required this.progress, required this.target, required this.current});
  final String label;
  final bool achieved;
  final double progress;
  final int target;
  final int current;
  int get percent => progress.round();

  factory PassportMilestone.fromJson(Map<String, dynamic> j) => PassportMilestone(
        label: (j['label'] as String?) ?? '',
        achieved: j['achieved'] == true,
        progress: (j['progress'] as num?)?.toDouble() ?? 0,
        target: (j['target'] as num?)?.toInt() ?? 0,
        current: (j['current'] as num?)?.toInt() ?? 0,
      );
}

/// The user's leaderboard rank + tier (`GET /my/rank`) — the "Passport Level".
class PassportRank {
  const PassportRank({
    required this.tier,
    required this.points,
    this.nextTier,
    this.pointsToNextTier,
    this.globalRank,
    this.direction,
  });

  /// RankTier: SEEKER / EXPLORER / PILGRIM / DEVOTEE / SAGE / SAINT / MAHAYOGI.
  final String tier;
  final int points;
  final String? nextTier;
  final int? pointsToNextTier;
  final int? globalRank;

  /// UP / DOWN / SAME / NEW.
  final String? direction;

  /// Progress toward the next tier (0–1).
  double get tierProgress {
    final toNext = pointsToNextTier;
    if (toNext == null || toNext <= 0) return 1;
    return (points / (points + toNext)).clamp(0, 1);
  }

  bool get rising => direction == 'UP' || direction == 'NEW';

  factory PassportRank.fromJson(Map<String, dynamic> j) => PassportRank(
        tier: (j['tier'] as String?) ?? 'SEEKER',
        points: (j['points'] as num?)?.toInt() ?? 0,
        nextTier: j['nextTier'] as String?,
        pointsToNextTier: (j['pointsToNextTier'] as num?)?.toInt(),
        globalRank: (j['globalRank'] as num?)?.toInt() ?? (j['rank'] as num?)?.toInt(),
        direction: j['direction'] as String?,
      );
}

/// Referral summary (`GET /referrals`).
class PassportReferral {
  const PassportReferral({required this.successfulInvites, required this.totalInvites, required this.pointsEarned});
  final int successfulInvites;
  final int totalInvites;
  final int pointsEarned;

  factory PassportReferral.fromJson(Map<String, dynamic> j) => PassportReferral(
        successfulInvites: (j['successfulInvites'] as num?)?.toInt() ?? 0,
        totalInvites: (j['totalInvites'] as num?)?.toInt() ?? 0,
        pointsEarned: (j['pointsEarned'] as num?)?.toInt() ?? 0,
      );

  static const empty = PassportReferral(successfulInvites: 0, totalInvites: 0, pointsEarned: 0);
}

/// The dashboard bundle: overview (hard) + rank + referral (soft).
class PassportBundle {
  const PassportBundle({required this.overview, this.rank, this.referral});
  final PassportOverview overview;
  final PassportRank? rank;
  final PassportReferral? referral;
}
