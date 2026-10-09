/// A journey milestone from the passport overview (`GET /my/passport`).
class Milestone {
  const Milestone({
    required this.code,
    required this.label,
    required this.achieved,
    required this.progress,
    required this.target,
    required this.current,
  });

  final String code;
  final String label;
  final bool achieved;

  /// 0–100 toward this milestone.
  final double progress;
  final int target;
  final int current;

  int get percent => progress.round();

  static int _i(Object? v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
  static double _d(Object? v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;

  factory Milestone.fromJson(Map<String, dynamic> json) => Milestone(
        code: (json['code'] as String?) ?? '',
        label: (json['label'] as String?) ?? '',
        achieved: json['achieved'] == true,
        progress: _d(json['progress']),
        target: _i(json['target']),
        current: _i(json['current']),
      );
}

/// Cross-cutting figures for the achievements dashboard, from the passport
/// overview: the user's real trust score, passport completion, and milestones.
class AchievementSummary {
  const AchievementSummary({
    required this.trustScore,
    required this.passportCompletion,
    required this.milestones,
  });

  final int trustScore;
  final int passportCompletion;
  final List<Milestone> milestones;

  static const empty = AchievementSummary(trustScore: 0, passportCompletion: 0, milestones: []);

  factory AchievementSummary.fromOverview(Map<String, dynamic> json) {
    final completion = (json['completion'] as Map?)?.cast<String, dynamic>();
    return AchievementSummary(
      trustScore: (json['trustScore'] as num?)?.toInt() ?? 0,
      passportCompletion: (completion?['passportCompletion'] as num?)?.round() ?? 0,
      milestones: ((json['milestones'] as List?) ?? const [])
          .whereType<Map<dynamic, dynamic>>()
          .map((m) => Milestone.fromJson(m.cast<String, dynamic>()))
          .toList(growable: false),
    );
  }
}

/// The reward card an achievement grants (fetched from `/cards/:id`).
class AchievementReward {
  const AchievementReward({required this.title, required this.imageUrl, required this.rarity});

  final String title;
  final String imageUrl;
  final String rarity;

  factory AchievementReward.fromCard(Map<String, dynamic> json) => AchievementReward(
        title: (json['title'] as String?) ?? '',
        imageUrl: (json['imageUrl'] as String?) ?? '',
        rarity: (json['rarity'] as String?) ?? 'EPIC',
      );
}
