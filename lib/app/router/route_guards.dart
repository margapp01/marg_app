import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/states/auth_state.dart';
import 'route_paths.dart';

/// A guard inspects the target location and returns a redirect path, or
/// `null` to allow navigation. Guards compose left-to-right; the first
/// non-null redirect wins (matching GoRouter's `redirect` contract).
typedef RouteGuard = String? Function(BuildContext context, GoRouterState state);

/// Compose an ordered list of guards into a single GoRouter `redirect`.
GoRouterRedirect composeGuards(List<RouteGuard> guards) {
  return (BuildContext context, GoRouterState state) {
    for (final guard in guards) {
      final redirect = guard(context, state);
      if (redirect != null) return redirect;
    }
    return null;
  };
}

/// Splash, sign-in, setup and the legal pages linked from sign-in: reachable
/// without a session.
bool isPublicLocation(String location) =>
    location == RoutePaths.splash ||
    location == RoutePaths.auth ||
    location == RoutePaths.setup ||
    location.startsWith(RoutePaths.legalPrefix);

/// Keeps unauthenticated users out of the app and un-onboarded users in setup.
///
/// The public locations (splash, auth, setup, and the legal pages linked from
/// sign-in) own their own navigation —
/// the splash resolves the session and routes returning users straight home,
/// and the sign-in page drives the Google flow — so the guard only *protects*
/// the authenticated area; it never yanks a user off a public page.
RouteGuard authGuard(Ref ref) {
  return (BuildContext context, GoRouterState state) {
    final auth = ref.read(authControllerProvider);
    final isPublic = isPublicLocation(state.matchedLocation);

    switch (auth.status) {
      case AuthStatus.unknown:
      case AuthStatus.authenticating:
        return null;
      case AuthStatus.unauthenticated:
        return isPublic ? null : RoutePaths.auth;
      case AuthStatus.needsMobile:
        return isPublic ? null : RoutePaths.setup;
      case AuthStatus.authenticated:
        if (auth.user?.isOnboarded != true) {
          return isPublic ? null : RoutePaths.setup;
        }
        return null;
    }
  };
}
