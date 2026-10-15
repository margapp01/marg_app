import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/states/auth_state.dart';
import '../../features/referrals/data/referral_attribution.dart';
import 'route_guards.dart';
import 'route_paths.dart';

/// Shared margapp.in links (App Links) arrive as router locations. Most
/// website paths differ from the app's, so they are mapped here; a few
/// (`/temples/:slug`) are the same on both.

final _uuid = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false);

/// Route sub-paths the app owns under `/routes` — never a website route slug.
const _appRouteSegments = {'discover', 'view'};

/// The app location showing what a website link shows, or null when [uri]
/// is not a website-only path (an app path, or one the app has no screen for).
String? appLocationForWebLink(Uri uri) {
  var segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  final localized = segments.isNotEmpty && segments.first == 'hi';
  if (localized) segments = segments.sublist(1);

  final mapped = switch (segments) {
    ['invite', _] => RoutePaths.home,
    ['routes', final slug] when !_appRouteSegments.contains(slug) => '/routes/view/$slug',
    ['cards', final id] when _uuid.hasMatch(id) => '/cards/view/$id',
    ['festivals'] => RoutePaths.knowledgeFestivals,
    ['festivals', final slug] => '${RoutePaths.knowledgeFestivals}/$slug',
    ['blogs'] => RoutePaths.knowledgeBlogs,
    ['blogs', final slug] => '${RoutePaths.knowledgeBlogs}/$slug',
    // Same path in the app; only the language prefix needs dropping.
    ['temples', final slug] when localized => '/temples/$slug',
    [] when localized => RoutePaths.home,
    _ => null,
  };
  return mapped;
}

/// The referral code a shared link carries: an invite page's code, or the
/// `?ref=` every link shared from the app is tagged with.
String? referralCodeOfWebLink(Uri uri) {
  final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  final path = segments.isNotEmpty && segments.first == 'hi' ? segments.sublist(1) : segments;
  final invite = path.length == 2 && path.first == 'invite' ? path[1] : null;
  return ReferralAttribution.codeFrom(invite ?? uri.queryParameters['ref']);
}

/// A link that arrived before the session was ready (cold start, signed out);
/// the signed-in shell opens it once (see `SessionHost`).
final pendingWebLinkProvider = StateProvider<String?>((ref) => null);

/// Maps website links onto app screens, and holds a link until the pilgrim
/// is signed in. A referral code on a link is kept while the session isn't
/// ready; it only ever counts for a new account (see [ReferralAttribution]).
RouteGuard webLinkGuard(Ref ref) {
  return (BuildContext context, GoRouterState state) {
    final uri = state.uri;
    final mapped = appLocationForWebLink(uri);
    final code = referralCodeOfWebLink(uri);
    final auth = ref.read(authControllerProvider);
    final ready = auth.status == AuthStatus.authenticated && auth.user?.isOnboarded == true;

    if (ready) return mapped;
    if (code != null) ref.read(referralAttributionProvider).remember(code, source: 'link');

    // A website-only path or a tagged share always came from outside; on a
    // cold start (session unknown) any non-public location did. Keep it for
    // after sign-in — but never the page someone was on when signing out.
    final external = auth.status == AuthStatus.unknown || mapped != null || code != null;
    if (external && !isPublicLocation(uri.path)) {
      final target = mapped ?? uri.path;
      if (target != RoutePaths.home) ref.read(pendingWebLinkProvider.notifier).state = target;
    }
    // The splash restores the session; until then nothing else may build.
    if (auth.status == AuthStatus.unknown && uri.path != RoutePaths.splash) return RoutePaths.splash;
    return mapped;
  };
}
