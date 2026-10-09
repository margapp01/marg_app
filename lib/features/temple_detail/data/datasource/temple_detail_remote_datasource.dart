import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/entities/temple_detail.dart';

/// Talks to the temple + intelligence + my-status endpoints. Reuses the
/// authenticated Dio (public endpoints ignore the token; `/my-status` needs it).
class TempleDetailRemoteDataSource {
  TempleDetailRemoteDataSource(this._dio);

  final Dio _dio;

  Map<String, dynamic> _data(Response<dynamic> res) =>
      ((res.data as Map)['data'] as Map).cast<String, dynamic>();

  List<dynamic> _dataList(Response<dynamic> res) =>
      ((res.data as Map)['data'] as List?) ?? const [];

  /// Raw `/temples/:slug` `data` map — returned unparsed so the repository can
  /// cache it verbatim for offline reads.
  Future<Map<String, dynamic>> detailData(String slug) async {
    final res = await _dio.get<dynamic>('/temples/$slug');
    return _data(res);
  }

  Future<CrowdInfo> crowd(String id) async {
    final res = await _dio.get<dynamic>('/temples/$id/crowd');
    return CrowdInfo.fromJson(_data(res));
  }

  Future<String?> bestTimeWindow(String id) async {
    final res = await _dio.get<dynamic>('/temples/$id/best-time-to-visit');
    return HourSlot.window(HourSlot.list(_dataList(res)));
  }

  Future<String?> peakWindow(String id) async {
    final res = await _dio.get<dynamic>('/temples/$id/peak-hours');
    return HourSlot.window(HourSlot.list(_dataList(res)));
  }

  Future<TempleMyStatus> myStatus(String id) async {
    final res = await _dio.get<dynamic>('/temples/$id/my-status');
    return TempleMyStatus.fromJson(_data(res));
  }

  Future<ReviewSummary> reviewSummary(String id) async =>
      ReviewSummary.fromJson(_data(await _dio.get<dynamic>('/temples/$id/reviews/summary')));

  /// The most recent published reviews.
  Future<List<TempleReview>> reviews(String id, {int limit = 5}) async {
    final res = await _dio.get<dynamic>('/temples/$id/reviews', queryParameters: {'limit': limit, 'sort': 'recent'});
    return _dataList(res)
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => TempleReview.fromJson(e.cast<String, dynamic>()))
        .toList(growable: false);
  }

  /// The devotee's own review, or null when they haven't written one.
  Future<TempleReview?> myReview(String id) async {
    final data = (await _dio.get<dynamic>('/temples/$id/reviews/me')).data;
    final review = data is Map ? data['data'] : null;
    return review is Map ? TempleReview.fromJson(review.cast<String, dynamic>()) : null;
  }

  Future<void> saveReview(String id, {required int rating, String? comment}) =>
      _dio.put<dynamic>('/temples/$id/reviews', data: {'rating': rating, 'comment': ?comment});

  Future<void> saveTemple(String id) => _dio.put<dynamic>('/my/saved-temples/$id');

  Future<void> unsaveTemple(String id) => _dio.delete<dynamic>('/my/saved-temples/$id');

  /// Temples near [latitude],[longitude] (the temple's own coords), excluding
  /// [excludeId]. `/temples/nearby` returns `{ temple, distanceMeters }[]`.
  Future<List<NearbyTempleRef>> nearby(
    double latitude,
    double longitude,
    String excludeId,
  ) async {
    final res = await _dio.get<dynamic>(
      '/temples/nearby',
      queryParameters: {'latitude': latitude, 'longitude': longitude, 'radius': 15000, 'limit': 8},
    );
    return _dataList(res)
        .whereType<Map<dynamic, dynamic>>()
        .map((row) => row.cast<String, dynamic>())
        .map(_nearbyFromRow)
        .where((n) => n.id.isNotEmpty && n.id != excludeId)
        .take(6)
        .toList(growable: false);
  }

  NearbyTempleRef _nearbyFromRow(Map<String, dynamic> row) {
    final temple = (row['temple'] as Map?)?.cast<String, dynamic>() ?? const {};
    final city = (temple['city'] as Map?)?.cast<String, dynamic>();
    final meters = (row['distanceMeters'] as num?)?.round() ?? 0;
    final formatted = meters < 1000 ? '$meters m' : '${(meters / 1000).toStringAsFixed(1)} km';
    return NearbyTempleRef(
      id: (temple['id'] as String?) ?? '',
      name: (temple['name'] as String?) ?? '',
      slug: (temple['slug'] as String?) ?? '',
      city: city?['name'] as String?,
      formattedDistance: formatted,
      imageUrl: temple['coverImageUrl'] as String?,
      ratingAverage: (temple['ratingAverage'] as num?)?.toDouble() ?? 0,
      ratingCount: (temple['ratingCount'] as num?)?.toInt() ?? 0,
    );
  }
}

final templeDetailRemoteDataSourceProvider = Provider<TempleDetailRemoteDataSource>(
  (ref) => TempleDetailRemoteDataSource(ref.watch(dioProvider)),
);
