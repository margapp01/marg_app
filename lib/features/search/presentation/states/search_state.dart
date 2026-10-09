import '../../domain/entities/search_models.dart';

enum SearchStatus { idle, loading, results, empty, error, offline }

class SearchState {
  const SearchState({
    required this.query,
    required this.filter,
    required this.status,
    required this.results,
    required this.recent,
  });

  factory SearchState.initial() => const SearchState(
        query: '',
        filter: SearchFilter(),
        status: SearchStatus.idle,
        results: null,
        recent: [],
      );

  final String query;
  final SearchFilter filter;
  final SearchStatus status;
  final SearchResults? results;
  final List<String> recent;

  /// True once the user has typed something (drives discovery-vs-results view).
  bool get isSearching => query.trim().isNotEmpty;

  static const Object _keep = Object();

  SearchState copyWith({
    String? query,
    SearchFilter? filter,
    SearchStatus? status,
    Object? results = _keep,
    List<String>? recent,
  }) {
    return SearchState(
      query: query ?? this.query,
      filter: filter ?? this.filter,
      status: status ?? this.status,
      results: identical(results, _keep) ? this.results : results as SearchResults?,
      recent: recent ?? this.recent,
    );
  }
}
