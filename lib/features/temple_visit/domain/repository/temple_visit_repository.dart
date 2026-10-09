import '../entities/checkin_request.dart';
import '../entities/checkin_result.dart';
import '../entities/visit_route_progress.dart';
import '../entities/visit_temple.dart';

/// The visit journey's data boundary. Implemented over the existing backend
/// endpoints (temple detail, check-in, my-status, route progress).
abstract class TempleVisitRepository {
  /// Temple reference (coords + geofence + header info) for [slug].
  Future<VisitTemple> temple(String slug);

  /// Submit a geofence check-in. Throws [CheckinFailure] on a rejected verdict
  /// or transport error; returns the backend result on success.
  Future<CheckinResult> checkIn(String templeId, CheckinRequest request);

  /// The user's primary route progress for [templeId] after a visit, enriched
  /// with the next temple to visit. Null when the temple is on no route.
  Future<VisitRouteProgress?> routeProgress(String templeId);
}
