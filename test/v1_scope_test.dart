import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/app/router/route_names.dart';
import 'package:marg_app/app/router/route_paths.dart';
import 'package:marg_app/features/home/presentation/widgets/home_quick_actions.dart';
import 'package:marg_app/features/profile/domain/entities/profile.dart';
import 'package:marg_app/features/search/domain/entities/search_models.dart';

/// v1 scope guards. Temple/Darshan/Puja/Pandit booking is deferred to a later
/// module; these tests fail loudly if a placeholder surface creeps back in.
void main() {
  const banned = ['booking', 'darshan', 'puja', 'pandit', 'reservation', 'ticket'];

  bool mentionsBanned(String s) {
    final lower = s.toLowerCase();
    return banned.any(lower.contains);
  }

  test('no route path is a Booking/Pandit destination', () {
    // RoutePaths is a const-only holder; assert on the literal route table the
    // router registers (paths are the deep-link surface).
    const paths = <String>[
      RoutePaths.splash, RoutePaths.auth, RoutePaths.setup, RoutePaths.home,
      RoutePaths.search, RoutePaths.temples, RoutePaths.templeDetail,
      RoutePaths.templeVisit, RoutePaths.passport, RoutePaths.visits,
      RoutePaths.explore, RoutePaths.routes, RoutePaths.routeDetail,
      RoutePaths.cards, RoutePaths.achievements, RoutePaths.leaderboards,
      RoutePaths.referrals, RoutePaths.notifications, RoutePaths.profile,
      RoutePaths.knowledge, RoutePaths.settings, RoutePaths.exploreSaved,
    ];
    for (final p in paths) {
      expect(mentionsBanned(p), isFalse, reason: '$p looks like a booking route');
    }
  });

  test('no route name is a Booking/Pandit destination', () {
    const names = <String>[
      RouteNames.home, RouteNames.search, RouteNames.exploreSaved,
      RouteNames.templeDetail, RouteNames.templeVisit, RouteNames.passport,
      RouteNames.explore, RouteNames.routes, RouteNames.cards,
      RouteNames.achievements, RouteNames.referrals, RouteNames.notifications,
      RouteNames.profile, RouteNames.knowledge, RouteNames.leaderboards,
    ];
    for (final n in names) {
      expect(mentionsBanned(n), isFalse, reason: '$n looks like a booking route');
    }
  });

  test('Home quick actions contain no Booking/Pandit action', () {
    expect(HomeQuickAction.values, hasLength(6));
    for (final a in [...HomeQuickAction.values, ...HomeShortcut.values]) {
      expect(mentionsBanned(a.name), isFalse, reason: '${a.name} is out of v1 scope');
    }
  });

  test('SearchType has no pandit member (backend never returns one)', () {
    expect(SearchType.values.any((t) => t.name == 'pandit'), isFalse);
    // An unexpected wire value degrades to `unknown` rather than crashing.
    expect(SearchType.fromWire('pandit'), SearchType.unknown);
  });

  test('Puja & Pandit is not selectable but still parses for existing users', () {
    // Not offered in v1 pickers…
    expect(UserInterest.selectable.contains(UserInterest.pujaPandit), isFalse);
    expect(UserInterest.selectable, hasLength(UserInterest.values.length - 1));
    // …yet the backend wire value still round-trips, so saved data is intact.
    expect(UserInterest.fromWire('PUJA_PANDIT'), UserInterest.pujaPandit);
  });
}
