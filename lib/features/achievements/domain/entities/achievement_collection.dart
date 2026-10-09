import '../../../../shared/components/rarity.dart';
import 'achievement.dart';

/// The full set of published achievements bucketed by status for the user
/// (`/my/achievements/progress`). All dashboard/gallery/stats views derive from
/// this — counts, points, completion, and per-category / per-rarity breakdowns.
class AchievementCollection {
  const AchievementCollection(this.all);

  final List<Achievement> all;

  List<Achievement> get earned => all.where((a) => a.status == AchievementStatus.earned).toList();
  List<Achievement> get inProgress => all.where((a) => a.status == AchievementStatus.inProgress).toList();
  List<Achievement> get locked => all.where((a) => a.status == AchievementStatus.locked).toList();

  int get total => all.length;
  int get earnedCount => earned.length;
  int get inProgressCount => inProgress.length;
  int get lockedCount => locked.length;

  int get completionPercent => total == 0 ? 0 : (earnedCount * 100 / total).round();
  int get pointsEarned => earned.fold(0, (sum, a) => sum + a.points);

  /// Distinct categories present, in a stable order.
  List<String> get categories {
    const order = ['TEMPLE', 'ROUTE', 'CARD', 'SERIES', 'SEASON', 'TRUST', 'SPECIAL'];
    final present = all.map((a) => a.category).toSet();
    return order.where(present.contains).toList();
  }

  /// Earned achievements, newest first.
  List<Achievement> get recent {
    final list = earned.where((a) => a.earnedAt != null).toList()
      ..sort((a, b) => b.earnedAt!.compareTo(a.earnedAt!));
    return list;
  }

  List<Achievement> inCategory(String category) => all.where((a) => a.category == category).toList();

  ({int earned, int total}) categoryProgress(String category) {
    final items = inCategory(category);
    return (earned: items.where((a) => a.earned).length, total: items.length);
  }

  /// (earned, total) counts per rarity, in ascending rarity order.
  Map<String, ({int earned, int total})> get byRarity {
    final map = <String, ({int earned, int total})>{};
    for (final r in kRarityOrder) {
      final items = all.where((a) => a.rarity.toUpperCase() == r).toList();
      if (items.isNotEmpty) {
        map[r] = (earned: items.where((a) => a.earned).length, total: items.length);
      }
    }
    return map;
  }

  factory AchievementCollection.fromBuckets(Map<String, dynamic> json) {
    List<Achievement> parse(String key, AchievementStatus status) =>
        ((json[key] as List?) ?? const [])
            .whereType<Map<dynamic, dynamic>>()
            .map((e) => Achievement.fromProgressEntry(e.cast<String, dynamic>(), status))
            .where((a) => a.id.isNotEmpty)
            .toList();
    return AchievementCollection([
      ...parse('earned', AchievementStatus.earned),
      ...parse('inProgress', AchievementStatus.inProgress),
      ...parse('locked', AchievementStatus.locked),
    ]);
  }
}
