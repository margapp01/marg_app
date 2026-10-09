import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/app/localization/app_localizations.dart';
import 'package:marg_app/app/theme/app_theme.dart';
import 'package:marg_app/features/home/data/repository/home_repository_impl.dart';
import 'package:marg_app/features/home/domain/entities/home_dashboard.dart';
import 'package:marg_app/features/home/domain/repository/home_repository.dart';
import 'package:marg_app/features/home/presentation/controllers/home_controller.dart';
import 'package:marg_app/features/home/presentation/pages/home_page.dart';
import 'package:marg_app/features/home/presentation/widgets/home_quick_actions.dart';

class _FakeHomeRepository implements HomeRepository {
  @override
  Future<HomeDashboard> loadDashboard({double? latitude, double? longitude}) async {
    return HomeDashboard.fromJson(const <String, dynamic>{
      'profile': {'id': 'u1', 'name': 'Aarav', 'preferredLanguage': 'EN'},
      'greeting': {'salutation': 'Namaste', 'timeOfDay': 'MORNING'},
      'banners': [
        {'id': 'b1', 'title': 'Kashi Vishwanath', 'subtitle': 'Morning Darshan'},
      ],
      'dailyQuote': {'id': 'q1', 'text': 'Do your duty', 'reference': 'Gita 2.47'},
      'passport': {
        'trustScore': 80,
        'statistics': {'totalVisitedTemples': 6},
        'completion': {
          'passportCompletion': 42,
          'breakdown': {'templesPercent': 50, 'cardsPercent': 17, 'routesPercent': 32},
        },
      },
      'leaderboardRank': {'rank': 2, 'points': 2450, 'direction': 'UP'},
      'referral': {'code': 'MARG123', 'successfulReferrals': 4},
      'unreadNotifications': 3,
      'recentActivity': [
        {'id': 'a1', 'type': 'VISIT', 'title': 'Visited Kashi'},
      ],
      'nearbyTemples': <dynamic>[],
      'explore': {'promotions': <dynamic>[], 'blogs': <dynamic>[]},
    });
  }
}

void main() {
  testWidgets('Home renders greeting and sections from one dashboard payload',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeRepositoryProvider.overrideWithValue(_FakeHomeRepository()),
          homeLocationProvider.overrideWithValue(() async => null),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The dashboard resolved from one call and rendered its above-the-fold
    // content (greeting + search + quick actions) with no exceptions. Section
    // parsing for every block is covered by home_dashboard_test.dart.
    expect(find.text('Namaste, Aarav 🙏'), findsOneWidget);
    expect(find.text('Search temples, places, routes...'), findsOneWidget);
    expect(find.text('My Yatra Routes'), findsOneWidget);
    expect(find.byType(HomePage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // v1 scope guard: Booking/Pandit is deferred to a later module, so Home must
  // expose no booking quick action, no booking CTA and no Bookings/Pujas tab.
  testWidgets('Home exposes no Booking or Pandit surface', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeRepositoryProvider.overrideWithValue(_FakeHomeRepository()),
          homeLocationProvider.overrideWithValue(() async => null),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (final banned in [
      'Book Temple Tickets',
      'Book Pandits',
      'Book Ticket',
      'Bookings',
      'Pujas',
    ]) {
      expect(find.text(banned), findsNothing, reason: '"$banned" is out of v1 scope');
    }
    // The quick-action grid renders its six real v1 destinations.
    expect(find.byType(QuickActionsGrid), findsOneWidget);
    expect(HomeQuickAction.values, hasLength(6));
  });
}
