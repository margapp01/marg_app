import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/app/localization/app_localizations.dart';
import 'package:marg_app/app/theme/app_theme.dart';
import 'package:marg_app/features/passport/data/repository/passport_repository_impl.dart';
import 'package:marg_app/features/passport/domain/entities/passport.dart';
import 'package:marg_app/features/passport/domain/entities/passport_lists.dart';
import 'package:marg_app/features/passport/domain/entities/passport_share.dart';
import 'package:marg_app/features/passport/domain/entities/timeline_event.dart';
import 'package:marg_app/features/passport/domain/repository/passport_repository.dart';
import 'package:marg_app/features/passport/presentation/pages/passport_dashboard_page.dart';

PassportOverview _overview() => PassportOverview.fromJson(const {
      'user': {'id': 'ab12cd34-0000-0000-0000-000000000000', 'name': 'Arjun Rao', 'memberSince': '2025-01-10T00:00:00.000Z'},
      'trustScore': 780,
      'completion': {
        'passportCompletion': 62,
        'breakdown': {'templesPercent': 40, 'cardsPercent': 55, 'routesPercent': 30},
      },
      'statistics': {
        'totalVisitedTemples': 18, 'verifiedVisits': 15, 'cardsCollected': 24,
        'routesStarted': 3, 'routesCompleted': 2,
      },
      'milestones': <Object>[],
    });

PassportRank _rank() => PassportRank.fromJson(const {
      'tier': 'PILGRIM', 'points': 900, 'nextTier': 'DEVOTEE',
      'pointsToNextTier': 300, 'globalRank': 42, 'direction': 'UP',
    });

class _FakeRepo implements PassportRepository {
  @override
  Future<PassportBundle> dashboard() async => PassportBundle(overview: _overview(), rank: _rank(), referral: PassportReferral.empty);
  @override
  Future<List<TimelineEvent>> timeline() async => const [];
  @override
  Future<List<VisitPoint>> visitPoints() async => const [];
  @override
  Future<CardsSummary> cards() async => CardsSummary.empty;
  @override
  Future<List<PassportGroup>> series() async => const [];
  @override
  Future<List<PassportGroup>> seasons() async => const [];
  @override
  Future<List<TempleHistoryItem>> temples() async => const [];
  @override
  Future<List<RouteHistoryItem>> routes() async => const [];
  @override
  Future<PassportShare> share() async => PassportShare.fromJson(const {});
  @override
  Future<String> mintShareLink() async => 'https://marg.app/p/token123';
  @override
  Future<List<int>> certificate(String routeId) async => const [];
}

void main() {
  group('passport models', () {
    test('overview derives a stable display passport id from the user id', () {
      expect(_overview().passportId, 'MARG-AB12-CD');
    });

    test('overview parses statistics + completion breakdown', () {
      final o = _overview();
      expect(o.name, 'Arjun Rao');
      expect(o.trustScore, 780);
      expect(o.passportCompletion, 62);
      expect(o.statistics.totalVisitedTemples, 18);
      expect(o.statistics.routesCompleted, 2);
      expect(o.templesPercent, 40);
      expect(o.memberSince, isNotNull);
    });

    test('rank exposes tier progress + rising direction', () {
      final r = _rank();
      expect(r.tier, 'PILGRIM');
      expect(r.rising, isTrue); // direction UP
      expect(r.tierProgress, closeTo(900 / 1200, 0.001));
    });

    test('temple + route history getters classify status/progress', () {
      final temple = TempleHistoryItem.fromJson(const {
        'status': 'VERIFIED', 'visitedAt': '2026-03-01T00:00:00.000Z',
        'temple': {'id': 't1', 'name': 'Kedarnath', 'slug': 'kedarnath'},
      });
      expect(temple.verified, isTrue);
      expect(temple.pending, isFalse);

      final route = RouteHistoryItem.fromJson(const {
        'routeId': 'r1', 'completionPercent': 100,
        'route': {'id': 'r1', 'name': 'Char Dham', 'slug': 'char-dham', 'type': 'PILGRIMAGE'},
      });
      expect(route.completed, isTrue);
      expect(route.percent, 100);

      final partial = RouteHistoryItem.fromJson(const {'routeId': 'r2', 'completionPercent': 45, 'route': {'name': 'X'}});
      expect(partial.inProgress, isTrue);
    });

    test('share summary reads stats + profile summary', () {
      final s = PassportShare.fromJson(const {
        'profileSummary': {'name': 'Meera', 'memberSince': '2025-06-01T00:00:00.000Z'},
        'stats': {'trustScore': 640, 'passportCompletion': 50, 'visitedTemples': 12, 'cardsCollected': 20, 'routesCompleted': 1},
        'shareText': 'My spiritual journey on MARG',
      });
      expect(s.name, 'Meera');
      expect(s.trustScore, 640);
      expect(s.visitedTemples, 12);
      expect(s.shareText, 'My spiritual journey on MARG');
    });
  });

  testWidgets('Dashboard renders identity, completion and trust score', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [passportRepositoryProvider.overrideWithValue(_FakeRepo())],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const PassportDashboardPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Arjun Rao'), findsOneWidget);
    expect(find.text('62%'), findsWidgets); // completion ring
    expect(find.text('780'), findsWidgets); // trust score
    expect(find.text('MARG-AB12-CD'), findsOneWidget); // passport id
    expect(tester.takeException(), isNull);
  });
}
