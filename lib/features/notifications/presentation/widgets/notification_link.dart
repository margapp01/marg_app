import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/router/route_paths.dart';
import '../../domain/entities/app_notification.dart';

/// A resolved in-app destination for a notification.
class NotificationDestination {
  const NotificationDestination(this.routeName, [this.pathParameters = const {}]);
  final String routeName;
  final Map<String, String> pathParameters;
}

/// Resolves a notification's `actionUrl` (+ `metadata.screen`) to an app route.
/// Returns null when the payload points nowhere we can navigate — the caller
/// then keeps the user on the detail screen rather than guessing.
NotificationDestination? resolveDestination(AppNotification n) => resolveLink(actionUrl: n.actionUrl, screen: n.screen);

/// The same resolution for a raw payload — e.g. a push message's data.
NotificationDestination? resolveLink({String? actionUrl, String? screen}) {
  final url = actionUrl;
  if (url != null && url.isNotEmpty) {
    final segments = Uri.parse(url).pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.isNotEmpty) {
      switch (segments.first) {
        case 'temples':
          if (segments.length >= 2) {
            return NotificationDestination(RouteNames.templeDetail, {RoutePaths.templeIdParam: segments[1]});
          }
          return const NotificationDestination(RouteNames.explore);
        case 'cards':
          // /cards/series/:id and /cards/season/:id → the cards hub (series/season
          // deep detail isn't a standalone route); /cards/:id → the card detail.
          if (segments.length == 2) {
            return NotificationDestination(RouteNames.cardDetail, {RoutePaths.cardIdParam: segments[1]});
          }
          return const NotificationDestination(RouteNames.cards);
        case 'routes':
          if (segments.length >= 2) {
            return NotificationDestination(RouteNames.routeDetail, {RoutePaths.routeSlugParam: segments[1]});
          }
          return const NotificationDestination(RouteNames.routes);
        case 'achievements':
          return const NotificationDestination(RouteNames.achievements);
        case 'passport':
          return const NotificationDestination(RouteNames.passport);
        case 'my':
          if (segments.length >= 2 && segments[1] == 'referral') {
            return const NotificationDestination(RouteNames.referrals);
          }
      }
    }
  }

  // Fallback to the metadata screen hint when there's no usable actionUrl.
  switch (screen) {
    case 'passport':
      return const NotificationDestination(RouteNames.passport);
    case 'referral':
      return const NotificationDestination(RouteNames.referrals);
    case 'card':
    case 'series':
    case 'season':
      return const NotificationDestination(RouteNames.cards);
    case 'achievement':
      return const NotificationDestination(RouteNames.achievements);
    default:
      return null;
  }
}

/// Navigates to the notification's destination if one resolves. Returns whether
/// navigation happened (false → the caller shows a "nothing to open" hint).
bool openNotificationDestination(BuildContext context, AppNotification n) {
  final dest = resolveDestination(n);
  if (dest == null) return false;
  context.pushNamed(dest.routeName, pathParameters: dest.pathParameters);
  return true;
}
