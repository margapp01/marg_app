import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/search_models.dart';
import '../../domain/repository/search_repository.dart';
import '../datasource/search_remote_datasource.dart';

class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl(this._remote);

  final SearchRemoteDataSource _remote;

  @override
  Future<SearchResults> search({
    required String query,
    SearchScope scope = SearchScope.all,
    SearchSort sort = SearchSort.relevance,
    int limit = 8,
    CancelToken? cancelToken,
  }) {
    return _remote.search(
      query: query,
      scope: scope,
      sort: sort,
      limit: limit,
      cancelToken: cancelToken,
    );
  }
}

final searchRepositoryProvider = Provider<SearchRepository>(
  (ref) => SearchRepositoryImpl(ref.watch(searchRemoteDataSourceProvider)),
);
