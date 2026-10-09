import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/entities/passport.dart';
import '../../domain/entities/passport_lists.dart';
import '../../domain/entities/passport_share.dart';
import '../../domain/entities/timeline_event.dart';

/// Talks to `/my/passport/*`, `/my/rank`, `/referrals`, `/my/visits`,
/// `/my/achievements`, `/my/routes`.
class PassportRemoteDataSource {
  PassportRemoteDataSource(this._dio);

  final Dio _dio;

  Map<String, dynamic> _data(Response<dynamic> res) =>
      ((res.data as Map)['data'] as Map).cast<String, dynamic>();

  List<dynamic> _dataList(Response<dynamic> res) =>
      ((res.data as Map)['data'] as List?) ?? const [];

  List<Map<String, dynamic>> _rows(Response<dynamic> res) => _dataList(res)
      .whereType<Map<dynamic, dynamic>>()
      .map((m) => m.cast<String, dynamic>())
      .toList(growable: false);

  Future<PassportOverview> overview() async =>
      PassportOverview.fromJson(_data(await _dio.get<dynamic>('/my/passport')));

  Future<PassportRank> rank() async =>
      PassportRank.fromJson(_data(await _dio.get<dynamic>('/my/rank')));

  Future<PassportReferral> referral() async =>
      PassportReferral.fromJson(_data(await _dio.get<dynamic>('/referrals')));

  Future<PassportShare> share() async =>
      PassportShare.fromJson(_data(await _dio.get<dynamic>('/my/passport/share')));

  /// Mint a public share link; returns the public path (e.g. `/passport/{token}`).
  Future<String> mintShareLink() async {
    final data = _data(await _dio.post<dynamic>('/my/passport/share-link'));
    return (data['publicPath'] as String?) ?? '';
  }

  Future<CardsSummary> cards() async =>
      CardsSummary.fromJson(_data(await _dio.get<dynamic>('/my/passport/cards')));

  Future<List<TempleHistoryItem>> temples({String? status}) async {
    final res = await _dio.get<dynamic>('/my/passport/temples', queryParameters: {'page': 1, 'limit': 100, 'status': ?status});
    return _rows(res).map(TempleHistoryItem.fromJson).where((t) => t.id.isNotEmpty).toList(growable: false);
  }

  Future<List<RouteHistoryItem>> routes() async {
    final res = await _dio.get<dynamic>('/my/passport/routes', queryParameters: const {'page': 1, 'limit': 100});
    return _rows(res).map(RouteHistoryItem.fromJson).where((r) => r.routeId.isNotEmpty).toList(growable: false);
  }

  Future<List<PassportGroup>> series() => _groups('/my/passport/series');
  Future<List<PassportGroup>> seasons() => _groups('/my/passport/seasons');

  Future<List<PassportGroup>> _groups(String path) async {
    final res = await _dio.get<dynamic>(path);
    return _rows(res).map(PassportGroup.fromJson).toList(growable: false);
  }

  /// Verified visit coordinates for the map.
  Future<List<VisitPoint>> visitPoints() async {
    final res = await _dio.get<dynamic>('/my/visits', queryParameters: const {'page': 1, 'limit': 100, 'sortOrder': 'desc'});
    final points = <VisitPoint>[];
    for (final r in _rows(res)) {
      final lat = (r['latitude'] as num?)?.toDouble();
      final lng = (r['longitude'] as num?)?.toDouble();
      if (lat == null || lng == null) continue;
      final temple = (r['temple'] as Map?)?.cast<String, dynamic>();
      final city = (temple?['city'] as Map?)?.cast<String, dynamic>();
      points.add(VisitPoint(
        latitude: lat, longitude: lng,
        verified: (r['status'] as String?)?.toUpperCase() == 'VERIFIED',
        name: temple?['name'] as String?,
        slug: temple?['slug'] as String?,
        imageUrl: _coverOf(temple),
        city: city?['name'] as String?,
        state: (city?['state'] as Map?)?['name'] as String?,
      ));
    }
    return points;
  }

  /// Visit timeline events (verified visits).
  Future<List<TimelineEvent>> visitEvents() async {
    final res = await _dio.get<dynamic>('/my/visits', queryParameters: const {'page': 1, 'limit': 100, 'sortOrder': 'desc'});
    final events = <TimelineEvent>[];
    for (final r in _rows(res)) {
      final date = _dt(r['visitedAt'] ?? r['visitDate']);
      if (date == null) continue;
      final temple = (r['temple'] as Map?)?.cast<String, dynamic>();
      final city = (temple?['city'] as Map?)?.cast<String, dynamic>();
      events.add(TimelineEvent(
        type: TimelineEventType.visit,
        title: (temple?['name'] as String?) ?? 'Temple visit',
        date: date,
        subtitle: [city?['name'], (city?['state'] as Map?)?['name']].whereType<String>().join(', '),
        imageUrl: _coverOf(temple),
        slug: temple?['slug'] as String?,
      ));
    }
    return events;
  }

  Future<List<TimelineEvent>> achievementEvents() async {
    final res = await _dio.get<dynamic>('/my/achievements');
    final events = <TimelineEvent>[];
    for (final r in _rows(res)) {
      final date = _dt(r['earnedAt']);
      if (date == null) continue;
      final a = (r['achievement'] as Map?)?.cast<String, dynamic>() ?? const {};
      events.add(TimelineEvent(
        type: TimelineEventType.achievement,
        title: (a['name'] as String?) ?? 'Achievement',
        date: date,
        points: (a['points'] as num?)?.toInt(),
      ));
    }
    return events;
  }

  Future<List<TimelineEvent>> routeEvents() async {
    final res = await _dio.get<dynamic>('/my/routes');
    final events = <TimelineEvent>[];
    for (final r in _rows(res)) {
      final date = _dt(r['completedAt']);
      if (date == null) continue;
      final route = (r['route'] as Map?)?.cast<String, dynamic>();
      events.add(TimelineEvent(
        type: TimelineEventType.route,
        title: (route?['name'] as String?) ?? 'Route completed',
        date: date,
        imageUrl: route?['coverImage'] as String?,
        slug: route?['slug'] as String?,
      ));
    }
    return events;
  }

  /// Route completion-certificate PDF bytes (Phase 21.10 endpoint).
  Future<List<int>> certificate(String routeId) async {
    final res = await _dio.get<List<int>>(
      '/my/routes/$routeId/certificate',
      options: Options(responseType: ResponseType.bytes),
    );
    return res.data ?? const [];
  }

  static DateTime? _dt(Object? v) => v is String ? DateTime.tryParse(v) : null;

  /// A temple's cover photo from an embedded `images` list, if any.
  static String? _coverOf(Map<String, dynamic>? temple) {
    final images = temple?['images'];
    if (images is! List || images.isEmpty) return null;
    final first = images.first;
    return first is Map ? first['url'] as String? : null;
  }
}

final passportRemoteDataSourceProvider = Provider<PassportRemoteDataSource>(
  (ref) => PassportRemoteDataSource(ref.watch(dioProvider)),
);
