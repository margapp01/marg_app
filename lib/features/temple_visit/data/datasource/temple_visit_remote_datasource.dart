import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/entities/checkin_failure.dart';
import '../../domain/entities/checkin_request.dart';
import '../../domain/entities/checkin_result.dart';
import '../../domain/entities/visit_route_progress.dart';
import '../../domain/entities/visit_temple.dart';

/// Talks to the temple + check-in + progress endpoints over the authenticated
/// Dio. Backend messages are surfaced verbatim on failure.
class TempleVisitRemoteDataSource {
  TempleVisitRemoteDataSource(this._dio);

  final Dio _dio;

  Map<String, dynamic> _data(Response<dynamic> res) =>
      ((res.data as Map)['data'] as Map).cast<String, dynamic>();

  Future<VisitTemple> temple(String slug) async {
    final res = await _dio.get<dynamic>('/temples/$slug');
    return VisitTemple.fromJson(_data(res));
  }

  /// POST the check-in. Translates any Dio error into a [CheckinFailure]
  /// carrying the backend's own message.
  Future<CheckinResult> checkIn(String templeId, CheckinRequest request) async {
    try {
      final res = await _dio.post<dynamic>('/temples/$templeId/checkin', data: request.toJson());
      return CheckinResult.fromJson(_data(res));
    } on DioException catch (e) {
      throw _failure(e);
    }
  }

  /// The user's route status for [templeId] (`/temples/:id/my-status`), taking
  /// the primary route and enriching it with the next temple from
  /// `/routes/:id/progress`. Returns null if the temple is on no route.
  Future<VisitRouteProgress?> routeProgress(String templeId) async {
    final res = await _dio.get<dynamic>('/temples/$templeId/my-status');
    final routes = (_data(res)['routes'] as List?) ?? const [];
    final rows = routes
        .whereType<Map<dynamic, dynamic>>()
        .map((r) => VisitRouteProgress.fromMyStatusRow(r.cast<String, dynamic>()))
        .where((r) => r.routeId.isNotEmpty)
        .toList();
    if (rows.isEmpty) return null;

    // Prefer a route the user has started but not finished; else the first.
    final primary = rows.firstWhere(
      (r) => !r.isComplete && r.completedTemples > 0,
      orElse: () => rows.first,
    );

    final next = await _nextTemple(primary.routeId);
    return primary.withNextTemple(next);
  }

  Future<NextTempleRef?> _nextTemple(String routeId) async {
    try {
      final res = await _dio.get<dynamic>('/routes/$routeId/progress');
      final next = (_data(res)['nextTemple'] as Map?)?.cast<String, dynamic>();
      return NextTempleRef.fromJson(next);
    } catch (_) {
      return null; // next-temple is a nice-to-have; never block the reward flow.
    }
  }

  CheckinFailure _failure(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return CheckinFailure.offline(
        e.message ?? 'No connection. Please check your internet and try again.',
      );
    }
    final data = e.response?.data;
    final message = data is Map && data['message'] is String
        ? data['message'] as String
        : (e.message ?? 'Check-in failed. Please try again.');
    return CheckinFailure.fromResponse(statusCode: e.response?.statusCode, message: message);
  }
}

final templeVisitRemoteDataSourceProvider = Provider<TempleVisitRemoteDataSource>(
  (ref) => TempleVisitRemoteDataSource(ref.watch(dioProvider)),
);
