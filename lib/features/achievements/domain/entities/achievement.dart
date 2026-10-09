/// Earned / in-progress / locked status of an achievement for the user.
enum AchievementStatus { earned, inProgress, locked }

/// A spiritual achievement. Parsed from `/my/achievements/progress` buckets
/// (achievement + progress% + earnedAt + status) and `/achievements/:slug`.
class Achievement {
  const Achievement({
    required this.id,
    required this.name,
    required this.slug,
    required this.category,
    required this.rarity,
    required this.points,
    required this.status,
    this.description,
    this.iconUrl,
    this.badgeImageUrl,
    this.rewardCardId,
    this.rules = const [],
    this.progress = 0,
    this.earnedAt,
  });

  final String id;
  final String name;
  final String slug;

  /// Backend `AchievementCategory`: TEMPLE/ROUTE/CARD/SERIES/SEASON/TRUST/SPECIAL.
  final String category;

  /// `CardRarity`: COMMON/RARE/EPIC/LEGENDARY/MYTHIC.
  final String rarity;
  final int points;
  final AchievementStatus status;
  final String? description;
  final String? iconUrl;
  final String? badgeImageUrl;
  final String? rewardCardId;
  final List<AchievementRule> rules;

  /// 0–100 progress toward earning.
  final double progress;
  final DateTime? earnedAt;

  bool get earned => status == AchievementStatus.earned;
  bool get locked => status == AchievementStatus.locked;
  int get percent => progress.round();

  /// The primary rule's threshold (for "X / Y" display on single-rule achievements).
  int? get threshold => rules.isEmpty ? null : rules.first.threshold;

  /// Derived current count from percent × threshold (single-rule achievements).
  int? get currentCount {
    final t = threshold;
    if (t == null) return null;
    return earned ? t : (progress / 100 * t).round().clamp(0, t);
  }

  /// The medal artwork: badge preferred, then icon.
  String? get artwork => (badgeImageUrl != null && badgeImageUrl!.isNotEmpty) ? badgeImageUrl : iconUrl;

  static int _i(Object? v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
  static double _d(Object? v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
  static DateTime? _dt(Object? v) => v is String ? DateTime.tryParse(v) : null;

  /// Parse the achievement scalar fields from a raw achievement map.
  factory Achievement._fromAchievementMap(
    Map<String, dynamic> a, {
    required AchievementStatus status,
    double progress = 0,
    DateTime? earnedAt,
  }) {
    return Achievement(
      id: (a['id'] as String?) ?? '',
      name: (a['name'] as String?) ?? '',
      slug: (a['slug'] as String?) ?? '',
      category: (a['category'] as String?) ?? 'SPECIAL',
      rarity: (a['rarity'] as String?) ?? 'COMMON',
      points: _i(a['points']),
      status: status,
      description: a['description'] as String?,
      iconUrl: a['iconUrl'] as String?,
      badgeImageUrl: a['badgeImageUrl'] as String?,
      rewardCardId: a['rewardCardId'] as String?,
      rules: ((a['rules'] as List?) ?? const [])
          .whereType<Map<dynamic, dynamic>>()
          .map((r) => AchievementRule.fromJson(r.cast<String, dynamic>()))
          .toList(growable: false),
      progress: progress,
      earnedAt: earnedAt,
    );
  }

  /// From a `/my/achievements/progress` bucket entry `{achievement, progress, earnedAt}`.
  factory Achievement.fromProgressEntry(Map<String, dynamic> json, AchievementStatus status) {
    final a = (json['achievement'] as Map?)?.cast<String, dynamic>() ?? const {};
    return Achievement._fromAchievementMap(
      a,
      status: status,
      progress: _d(json['progress']),
      earnedAt: _dt(json['earnedAt']),
    );
  }

  /// From the public catalog (`/achievements/:slug`) — no per-user progress.
  factory Achievement.fromCatalog(Map<String, dynamic> a) =>
      Achievement._fromAchievementMap(a, status: AchievementStatus.locked);
}

class AchievementRule {
  const AchievementRule({required this.ruleType, required this.threshold});

  /// Backend `AchievementRuleType` (VISITED_TEMPLES, COLLECTED_CARDS, …).
  final String ruleType;
  final int threshold;

  factory AchievementRule.fromJson(Map<String, dynamic> json) => AchievementRule(
        ruleType: (json['ruleType'] as String?) ?? '',
        threshold: (json['threshold'] as num?)?.toInt() ?? 1,
      );
}
