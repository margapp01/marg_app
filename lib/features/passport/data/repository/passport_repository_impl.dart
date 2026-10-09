import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/passport.dart';
import '../../domain/entities/passport_lists.dart';
import '../../domain/entities/passport_share.dart';
import '../../domain/entities/timeline_event.dart';
import '../../domain/repository/passport_repository.dart';
import '../datasource/passport_remote_datasource.dart';

class PassportRepositoryImpl implements PassportRepository {
  PassportRepositoryImpl(this._remote);

  final PassportRemoteDataSource _remote;

  @override
  Future<PassportBundle> dashboard() async {
    // Overview is the hard dependency; rank + referral are best-effort so the
    // passport still renders if the leaderboard/referral service hiccups.
    final overview = await _remote.overview();
    final results = await Future.wait([
      _soft(_remote.rank),
      _soft(_remote.referral),
    ]);
    return PassportBundle(
      overview: overview,
      rank: results[0] as PassportRank?,
      referral: results[1] as PassportReferral?,
    );
  }

  @override
  Future<List<TimelineEvent>> timeline() async {
    final lists = await Future.wait([
      _softList(_remote.visitEvents),
      _softList(_remote.achievementEvents),
      _softList(_remote.routeEvents),
    ]);
    final all = [for (final l in lists) ...l]..sort((a, b) => b.date.compareTo(a.date));
    return all;
  }

  @override
  Future<List<VisitPoint>> visitPoints() => _remote.visitPoints();

  @override
  Future<CardsSummary> cards() => _remote.cards();

  @override
  Future<List<PassportGroup>> series() => _remote.series();

  @override
  Future<List<PassportGroup>> seasons() => _remote.seasons();

  @override
  Future<List<TempleHistoryItem>> temples() => _remote.temples();

  @override
  Future<List<RouteHistoryItem>> routes() => _remote.routes();

  @override
  Future<PassportShare> share() => _remote.share();

  @override
  Future<String> mintShareLink() => _remote.mintShareLink();

  @override
  Future<List<int>> certificate(String routeId) => _remote.certificate(routeId);

  Future<Object?> _soft(Future<Object?> Function() task) async {
    try {
      return await task();
    } catch (_) {
      return null;
    }
  }

  Future<List<TimelineEvent>> _softList(Future<List<TimelineEvent>> Function() task) async {
    try {
      return await task();
    } catch (_) {
      return const [];
    }
  }
}

final passportRepositoryProvider = Provider<PassportRepository>(
  (ref) => PassportRepositoryImpl(ref.watch(passportRemoteDataSourceProvider)),
);
