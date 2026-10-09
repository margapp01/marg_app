import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/features/search/data/repository/search_repository_impl.dart';
import 'package:marg_app/features/search/domain/entities/search_models.dart';
import 'package:marg_app/features/search/domain/repository/search_repository.dart';
import 'package:marg_app/features/search/presentation/controllers/search_controller.dart';
import 'package:marg_app/features/search/presentation/states/search_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Records the queries it was asked to run and returns a single temple hit.
class _RecordingRepo implements SearchRepository {
  final List<String> queries = [];

  @override
  Future<SearchResults> search({
    required String query,
    SearchScope scope = SearchScope.all,
    SearchSort sort = SearchSort.relevance,
    int limit = 8,
    CancelToken? cancelToken,
  }) async {
    queries.add(query);
    return SearchResults.fromJson({
      'query': query,
      'results': {
        'temples': [
          {'type': 'temple', 'id': 't1', 'title': 'Kashi', 'slug': 'kashi'},
        ],
      },
    }, sort: sort);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  ProviderContainer makeContainer(_RecordingRepo repo) {
    final container = ProviderContainer(
      overrides: [searchRepositoryProvider.overrideWithValue(repo)],
    );
    // Keep the auto-dispose controller alive for the test.
    container.listen(searchControllerProvider, (_, _) {}, fireImmediately: true);
    return container;
  }

  test('debounces keystrokes and only searches the latest query', () async {
    final repo = _RecordingRepo();
    final container = makeContainer(repo);
    addTearDown(container.dispose);
    final notifier = container.read(searchControllerProvider.notifier);

    notifier.onQueryChanged('k');
    notifier.onQueryChanged('ka');
    notifier.onQueryChanged('kas'); // all within one debounce window

    // Before the debounce fires, no request has gone out.
    expect(repo.queries, isEmpty);

    await Future<void>.delayed(const Duration(milliseconds: 400));

    expect(repo.queries, ['kas']); // latest wins, earlier keystrokes coalesced
    expect(container.read(searchControllerProvider).status, SearchStatus.results);
  });

  test('clearing the query returns to the idle discovery state', () async {
    final repo = _RecordingRepo();
    final container = makeContainer(repo);
    addTearDown(container.dispose);
    final notifier = container.read(searchControllerProvider.notifier);

    notifier.onQueryChanged('kashi');
    await Future<void>.delayed(const Duration(milliseconds: 400));
    expect(container.read(searchControllerProvider).status, SearchStatus.results);

    notifier.onQueryChanged('');
    final state = container.read(searchControllerProvider);
    expect(state.status, SearchStatus.idle);
    expect(state.results, isNull);
    expect(state.isSearching, isFalse);
  });

  test('submit records the term in recent searches', () async {
    final repo = _RecordingRepo();
    final container = makeContainer(repo);
    addTearDown(container.dispose);
    final notifier = container.read(searchControllerProvider.notifier);

    await notifier.submit('Somnath Temple');

    expect(repo.queries, contains('Somnath Temple'));
    expect(container.read(searchControllerProvider).recent, contains('Somnath Temple'));
  });
}
