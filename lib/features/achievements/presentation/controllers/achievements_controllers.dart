import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repository/achievements_repository_impl.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/achievement_collection.dart';
import '../../domain/entities/achievement_summary.dart';

/// All achievements bucketed by status (the source for most screens).
final achievementCollectionProvider = FutureProvider.autoDispose<AchievementCollection>(
  (ref) => ref.watch(achievementsRepositoryProvider).collection(),
);

/// Trust score + passport completion + milestones.
final achievementSummaryProvider = FutureProvider.autoDispose<AchievementSummary>(
  (ref) => ref.watch(achievementsRepositoryProvider).summary(),
);

/// One achievement (from the collection) enriched with its reward card.
final achievementDetailProvider = FutureProvider.autoDispose.family<AchievementDetail, String>(
  (ref, id) async {
    final collection = await ref.watch(achievementCollectionProvider.future);
    final achievement = collection.all.firstWhere(
      (a) => a.id == id,
      orElse: () => throw StateError('Achievement not found'),
    );
    final reward = achievement.rewardCardId == null
        ? null
        : await ref.watch(achievementsRepositoryProvider).rewardCard(achievement.rewardCardId!);
    return AchievementDetail(achievement: achievement, reward: reward);
  },
);

class AchievementDetail {
  const AchievementDetail({required this.achievement, this.reward});
  final Achievement achievement;
  final AchievementReward? reward;
}
