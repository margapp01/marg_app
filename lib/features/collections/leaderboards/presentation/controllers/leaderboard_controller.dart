import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/leaderboard_remote_datasource.dart';
import '../../domain/entities/leaderboard.dart';

typedef BoardKey = ({LeaderboardBoard board, LeaderboardWindow window});

/// One board + period, loaded a page at a time ([loadMore]).
class BoardController extends AutoDisposeFamilyAsyncNotifier<BoardPage, BoardKey> {
  static const _pageSize = 30;
  int _page = 1;

  @override
  Future<BoardPage> build(BoardKey arg) {
    _page = 1;
    return ref.watch(leaderboardRemoteDataSourceProvider).board(arg.board, arg.window, limit: _pageSize);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.loadingMore || !current.hasMore) return;
    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final next = await ref
          .read(leaderboardRemoteDataSourceProvider)
          .board(arg.board, arg.window, page: _page + 1, limit: _pageSize);
      _page++;
      state = AsyncData(BoardPage(entries: [...current.entries, ...next.entries], total: next.total));
    } catch (_) {
      state = AsyncData(current.copyWith(loadingMore: false));
    }
  }
}

final boardProvider =
    AsyncNotifierProvider.autoDispose.family<BoardController, BoardPage, BoardKey>(BoardController.new);

final myRankProvider = FutureProvider.autoDispose<MyRank>(
  (ref) => ref.watch(leaderboardRemoteDataSourceProvider).myRank(),
);
