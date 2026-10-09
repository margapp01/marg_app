import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/entities/search_models.dart';

/// Calls `GET /search`. Accepts a [CancelToken] so the controller can cancel a
/// stale in-flight request when the query changes (latest-wins).
class SearchRemoteDataSource {
  SearchRemoteDataSource(this._dio);

  final Dio _dio;

  Future<SearchResults> search({
    required String query,
    SearchScope scope = SearchScope.all,
    SearchSort sort = SearchSort.relevance,
    int limit = 8,
    CancelToken? cancelToken,
  }) async {
    final res = await _dio.get<dynamic>(
      '/search',
      queryParameters: {
        'q': query,
        'limit': limit,
        if (scope.wireType != null) 'types': scope.wireType,
      },
      cancelToken: cancelToken,
    );
    final data = (res.data as Map)['data'] as Map;
    return SearchResults.fromJson(data.cast<String, dynamic>(), sort: sort);
  }
}

final searchRemoteDataSourceProvider = Provider<SearchRemoteDataSource>(
  (ref) => SearchRemoteDataSource(ref.watch(dioProvider)),
);
