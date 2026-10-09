import '../entities/my_route.dart';
import '../entities/route_detail_bundle.dart';
import '../entities/yatra_route.dart';

/// Data boundary for the pilgrimage-journey feature, over the existing route +
/// progress + visits endpoints.
abstract class RoutesRepository {
  /// Published routes for Discover, optionally filtered by [type] / [query].
  Future<List<YatraRoute>> discover({String? type, String? query});

  /// The user's routes with cached progress (My Yatras).
  Future<List<MyRouteProgress>> myRoutes();

  /// Route detail + live progress + visit dates, composed fail-soft.
  Future<RouteDetailBundle> loadDetail(String slug);

  /// Save a route to the user's journeys (adds it to Planned).
  Future<void> enroll(String routeId);

  /// Remove a not-yet-started route from the user's journeys.
  Future<void> unenroll(String routeId);

  /// The route's completion-certificate PDF bytes (completed routes only).
  Future<List<int>> certificate(String routeId);
}
