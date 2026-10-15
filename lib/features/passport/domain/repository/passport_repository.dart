import '../entities/passport.dart';
import '../entities/passport_lists.dart';
import '../entities/passport_share.dart';
import '../entities/timeline_event.dart';

/// Data boundary for the Spiritual Passport, over the existing passport + rank +
/// referral + visits endpoints.
abstract class PassportRepository {
  /// Dashboard bundle: overview (hard) + rank + referral (soft, fail-soft).
  Future<PassportBundle> dashboard();

  /// The merged journey timeline (visits + achievements + routes), newest first.
  Future<List<TimelineEvent>> timeline();

  /// Verified visit coordinates for the map.
  Future<List<VisitPoint>> visitPoints();

  Future<CardsSummary> cards();
  Future<List<PassportGroup>> series();
  Future<List<PassportGroup>> seasons();
  Future<List<TempleHistoryItem>> temples();
  Future<List<RouteHistoryItem>> routes();

  /// The shareable passport summary.
  Future<PassportShare> share();

  /// The public share link (minted on first use), returning the public path.
  Future<String> shareLink();

  /// Rotate the public share link, retiring links already shared.
  Future<String> resetShareLink();

  /// Route completion-certificate PDF bytes (completed routes only).
  Future<List<int>> certificate(String routeId);
}
