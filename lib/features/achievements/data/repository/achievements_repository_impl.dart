import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/achievement_collection.dart';
import '../../domain/entities/achievement_summary.dart';
import '../../domain/repository/achievements_repository.dart';
import '../datasource/achievements_remote_datasource.dart';

class AchievementsRepositoryImpl implements AchievementsRepository {
  AchievementsRepositoryImpl(this._remote);

  final AchievementsRemoteDataSource _remote;

  @override
  Future<AchievementCollection> collection() => _remote.collection();

  @override
  Future<AchievementSummary> summary() => _remote.summary();

  @override
  Future<AchievementReward?> rewardCard(String cardId) async {
    try {
      return await _remote.rewardCard(cardId);
    } catch (_) {
      return null; // reward art is a nice-to-have; never break the detail page.
    }
  }
}

final achievementsRepositoryProvider = Provider<AchievementsRepository>(
  (ref) => AchievementsRepositoryImpl(ref.watch(achievementsRemoteDataSourceProvider)),
);
