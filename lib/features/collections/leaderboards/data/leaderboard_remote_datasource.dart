import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../domain/entities/leaderboard.dart';

/// Talks to `/leaderboards/:board` (public, paginated) and `/my/rank`.
class LeaderboardRemoteDataSource {
  LeaderboardRemoteDataSource(this._dio);

  final Dio _dio;

  Map<String, dynamic> _envelope(Response<dynamic> res) => (res.data as Map).cast<String, dynamic>();

  Future<BoardPage> board(LeaderboardBoard board, LeaderboardWindow window, {int page = 1, int limit = 30}) async {
    final res = await _dio.get<dynamic>('/leaderboards/${board.path}', queryParameters: {
      'period': window.wire,
      'page': page,
      'limit': limit,
    });
    final body = _envelope(res);
    final entries = ((body['data'] as List?) ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => BoardEntry.fromJson(e.cast<String, dynamic>()))
        .toList(growable: false);
    final total = ((body['pagination'] as Map?)?['total'] as num?)?.toInt() ?? entries.length;
    return BoardPage(entries: entries, total: total);
  }

  Future<MyRank> myRank() async {
    final res = await _dio.get<dynamic>('/my/rank');
    final data = _envelope(res)['data'];
    return MyRank.fromJson(data is Map ? data.cast<String, dynamic>() : const {});
  }
}

final leaderboardRemoteDataSourceProvider = Provider<LeaderboardRemoteDataSource>(
  (ref) => LeaderboardRemoteDataSource(ref.watch(dioProvider)),
);
