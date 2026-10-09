import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/recent_searches_store.dart';
import '../../data/repository/search_repository_impl.dart';
import '../../domain/entities/search_models.dart';
import '../states/search_state.dart';

/// Type-ahead search: 300 ms debounce, cancels the previous in-flight request,
/// and a sequence guard so the latest response always wins. Recent searches are
/// persisted locally and shown on the discovery (pre-typing) view.
class SearchController extends AutoDisposeNotifier<SearchState> {
  Timer? _debounce;
  CancelToken? _inFlight;
  int _seq = 0;

  static const _debounceMs = 300;

  @override
  SearchState build() {
    ref.onDispose(() {
      _debounce?.cancel();
      _inFlight?.cancel('controller disposed');
    });
    _loadRecent();
    return SearchState.initial();
  }

  Future<void> _loadRecent() async {
    final recent = await ref.read(recentSearchesStoreProvider).load();
    state = state.copyWith(recent: recent);
  }

  /// Called on every keystroke — never hits the network directly.
  void onQueryChanged(String q) {
    _debounce?.cancel();
    final trimmed = q.trim();
    if (trimmed.isEmpty) {
      _inFlight?.cancel('query cleared');
      state = state.copyWith(query: q, status: SearchStatus.idle, results: null);
      return;
    }
    state = state.copyWith(query: q, status: SearchStatus.loading);
    _debounce = Timer(const Duration(milliseconds: _debounceMs), () => _run(trimmed));
  }

  /// Explicit submit (keyboard action or tapping a recent/trending chip):
  /// records history and runs immediately.
  Future<void> submit(String q) async {
    final t = q.trim();
    if (t.isEmpty) return;
    final recent = await ref.read(recentSearchesStoreProvider).add(t);
    _debounce?.cancel();
    state = state.copyWith(query: t, recent: recent, status: SearchStatus.loading);
    await _run(t);
  }

  void applyFilter(SearchFilter filter) {
    state = state.copyWith(filter: filter);
    final q = state.query.trim();
    if (q.isNotEmpty) {
      state = state.copyWith(status: SearchStatus.loading);
      _run(q);
    }
  }

  Future<void> retry() async {
    final q = state.query.trim();
    if (q.isEmpty) return;
    state = state.copyWith(status: SearchStatus.loading);
    await _run(q);
  }

  Future<void> removeRecent(String term) async {
    final recent = await ref.read(recentSearchesStoreProvider).remove(term);
    state = state.copyWith(recent: recent);
  }

  Future<void> clearRecent() async {
    final recent = await ref.read(recentSearchesStoreProvider).clear();
    state = state.copyWith(recent: recent);
  }

  Future<void> _run(String q) async {
    _inFlight?.cancel('superseded');
    final token = CancelToken();
    _inFlight = token;
    final seq = ++_seq;

    try {
      final results = await ref.read(searchRepositoryProvider).search(
            query: q,
            scope: state.filter.scope,
            sort: state.filter.sort,
            cancelToken: token,
          );
      if (seq != _seq) return; // a newer request superseded this one
      state = state.copyWith(
        results: results,
        status: results.isEmpty ? SearchStatus.empty : SearchStatus.results,
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e) || seq != _seq) return;
      state = state.copyWith(status: _isOffline(e) ? SearchStatus.offline : SearchStatus.error);
    } catch (_) {
      if (seq != _seq) return;
      state = state.copyWith(status: SearchStatus.error);
    }
  }

  bool _isOffline(DioException e) =>
      e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout;
}

final searchControllerProvider =
    AutoDisposeNotifierProvider<SearchController, SearchState>(SearchController.new);
