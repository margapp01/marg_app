import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/entities/referral_models.dart';

/// Talks to `/my/referral`, `/my/referral/rewards`, `/my/referrals`,
/// `/referrals/leaderboard`, and `/cms/faqs`.
class ReferralRemoteDataSource {
  ReferralRemoteDataSource(this._dio);
  final Dio _dio;

  Map<String, dynamic> _env(Response<dynamic> res) => (res.data as Map).cast<String, dynamic>();
  Map<String, dynamic> _data(Response<dynamic> res) => (_env(res)['data'] as Map).cast<String, dynamic>();
  List<dynamic> _list(Response<dynamic> res) => (_env(res)['data'] as List?) ?? const [];

  Future<ReferralSummary> summary() async {
    final res = await _dio.get<dynamic>('/my/referral');
    return ReferralSummary.fromJson(_data(res));
  }

  Future<Paged<ReferralReward>> rewards({int page = 1, int limit = 20}) async {
    final res = await _dio.get<dynamic>('/my/referral/rewards', queryParameters: {'page': page, 'limit': limit});
    return Paged.fromEnvelope(_env(res), ReferralReward.fromJson);
  }

  Future<Paged<ReferralInvite>> invites({int page = 1, int limit = 20}) async {
    final res = await _dio.get<dynamic>('/my/referrals', queryParameters: {'page': page, 'limit': limit});
    return Paged.fromEnvelope(_env(res), ReferralInvite.fromJson);
  }

  Future<List<LeaderRow>> leaderboard({int page = 1, int limit = 50}) async {
    final res = await _dio.get<dynamic>('/referrals/leaderboard', queryParameters: {'page': page, 'limit': limit});
    return _list(res).whereType<Map<dynamic, dynamic>>().map((e) => LeaderRow.fromJson(e.cast<String, dynamic>())).toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> faqs() async {
    final res = await _dio.get<dynamic>('/cms/faqs', queryParameters: const {'page': 1, 'limit': 100});
    return _list(res).whereType<Map<dynamic, dynamic>>().map((e) => e.cast<String, dynamic>()).toList(growable: false);
  }
}

final referralRemoteDataSourceProvider = Provider<ReferralRemoteDataSource>(
  (ref) => ReferralRemoteDataSource(ref.watch(dioProvider)),
);
