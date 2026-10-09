import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/entities/achievement_collection.dart';
import '../../domain/entities/achievement_summary.dart';

/// Talks to `/my/achievements/progress`, `/my/passport`, `/cards/:id`.
class AchievementsRemoteDataSource {
  AchievementsRemoteDataSource(this._dio);

  final Dio _dio;

  Map<String, dynamic> _data(Response<dynamic> res) =>
      ((res.data as Map)['data'] as Map).cast<String, dynamic>();

  Future<AchievementCollection> collection() async {
    final res = await _dio.get<dynamic>('/my/achievements/progress');
    return AchievementCollection.fromBuckets(_data(res));
  }

  Future<AchievementSummary> summary() async {
    final res = await _dio.get<dynamic>('/my/passport');
    return AchievementSummary.fromOverview(_data(res));
  }

  Future<AchievementReward?> rewardCard(String cardId) async {
    final res = await _dio.get<dynamic>('/cards/$cardId');
    return AchievementReward.fromCard(_data(res));
  }
}

final achievementsRemoteDataSourceProvider = Provider<AchievementsRemoteDataSource>(
  (ref) => AchievementsRemoteDataSource(ref.watch(dioProvider)),
);
