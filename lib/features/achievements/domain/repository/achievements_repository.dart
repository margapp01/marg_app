import '../entities/achievement_collection.dart';
import '../entities/achievement_summary.dart';

/// Data boundary for the Achievements feature, over the existing achievements +
/// passport + cards endpoints.
abstract class AchievementsRepository {
  /// All published achievements bucketed by status, with per-user progress.
  Future<AchievementCollection> collection();

  /// Trust score, passport completion, and journey milestones.
  Future<AchievementSummary> summary();

  /// The reward card for an achievement (null when none / unavailable).
  Future<AchievementReward?> rewardCard(String cardId);
}
