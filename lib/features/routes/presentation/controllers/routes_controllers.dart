import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repository/routes_repository_impl.dart';
import '../../domain/entities/my_route.dart';
import '../../domain/entities/route_detail_bundle.dart';
import '../../domain/entities/yatra_route.dart';

/// The user's routes with progress (My Yatras).
final myRoutesProvider = FutureProvider.autoDispose<List<MyRouteProgress>>(
  (ref) => ref.watch(routesRepositoryProvider).myRoutes(),
);

/// Published routes for Discover, filtered by [type] (null = all). The family
/// arg is the backend RouteType value or null.
final discoverRoutesProvider = FutureProvider.autoDispose.family<List<YatraRoute>, String?>(
  (ref, type) => ref.watch(routesRepositoryProvider).discover(type: type),
);

/// Route detail bundle (detail + progress + visit dates) for a slug.
final routeDetailProvider = FutureProvider.autoDispose.family<RouteDetailBundle, String>(
  (ref, slug) => ref.watch(routesRepositoryProvider).loadDetail(slug),
);
