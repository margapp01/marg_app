import 'package:dio/dio.dart';

import '../entities/search_models.dart';

abstract interface class SearchRepository {
  Future<SearchResults> search({
    required String query,
    SearchScope scope,
    SearchSort sort,
    int limit,
    CancelToken? cancelToken,
  });
}
