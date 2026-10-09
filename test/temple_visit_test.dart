import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:marg_app/app/localization/app_localizations.dart';
import 'package:marg_app/app/theme/app_theme.dart';
import 'package:marg_app/core/location/captured_location.dart';
import 'package:marg_app/core/location/location_service.dart';
import 'package:marg_app/core/services/device_context_service.dart';
import 'package:marg_app/features/cards/presentation/widgets/card_reveal.dart';
import 'package:marg_app/features/directions/domain/route_plan.dart';
import 'package:marg_app/features/temple_visit/data/repository/temple_visit_repository_impl.dart';
import 'package:marg_app/features/temple_visit/domain/entities/checkin_failure.dart';
import 'package:marg_app/features/temple_visit/domain/entities/checkin_request.dart';
import 'package:marg_app/features/temple_visit/domain/entities/checkin_result.dart';
import 'package:marg_app/features/temple_visit/domain/entities/visit_route_progress.dart';
import 'package:marg_app/features/temple_visit/domain/entities/visit_temple.dart';
import 'package:marg_app/features/temple_visit/domain/repository/temple_visit_repository.dart';
import 'package:marg_app/features/temple_visit/presentation/controllers/visit_route_provider.dart';
import 'package:marg_app/features/temple_visit/presentation/pages/temple_visit_page.dart';
import 'package:marg_app/features/temple_visit/presentation/widgets/visit_outcome_phases.dart';
import 'package:marg_app/shared/design_system.dart';

VisitTemple _temple() => VisitTemple.fromJson(const {
      'id': 't1',
      'name': 'Kashi Vishwanath Temple',
      'slug': 'kashi-vishwanath',
      'latitude': 25.31,
      'longitude': 83.01,
      'geofenceRadius': 500,
      'city': {'name': 'Varanasi', 'state': {'name': 'Uttar Pradesh'}},
      'images': [
        {'url': 'https://x/a.jpg', 'position': 1},
        {'url': 'https://x/cover.jpg', 'isCover': true, 'position': 0},
      ],
    });

CheckinResult _verifiedResult() => CheckinResult.fromJson(const {
      'verified': true,
      'distanceMeters': 12,
      'trustScore': 90,
      'visit': {'id': 'v1', 'status': 'VERIFIED'},
      'rewards': {
        'card': {'id': 'c1', 'title': 'Kashi Card', 'imageUrl': 'https://x/c.jpg', 'rarity': 'RARE', 'unlocked': true, 'alreadyOwned': false},
        'achievements': [{'id': 'a1', 'slug': 'shiv-bhakt', 'name': 'Shiv Bhakt', 'points': 50, 'badgeImageUrl': null}],
        'seriesCompleted': <Object>[],
        'seasonsCompleted': <Object>[],
      },
    });

class _FakeRepo implements TempleVisitRepository {
  @override
  Future<VisitTemple> temple(String slug) async => _temple();

  @override
  Future<CheckinResult> checkIn(String templeId, CheckinRequest request) async => _verifiedResult();

  @override
  Future<VisitRouteProgress?> routeProgress(String templeId) async => null;
}

class _FakeLocation extends LocationService {
  const _FakeLocation();

  @override
  Future<LocationResult> capture() async => LocationResult(
        LocationStatus.success,
        CapturedLocation(latitude: 25.31, longitude: 83.01, accuracyMeters: 8, capturedAt: DateTime(2026)),
      );
}

/// Device details come over a platform channel tests never answer.
class _FakeDevice extends DeviceContextService {
  @override
  Future<DeviceContext> load() async => DeviceContext.unknown;
}

void main() {
  group('temple_visit models', () {
    test('VisitTemple parses geofence + cover image', () {
      final t = _temple();
      expect(t.geofenceRadius, 500);
      expect(t.location, 'Varanasi, Uttar Pradesh');
      expect(t.imageUrl, 'https://x/cover.jpg');
    });

    test('CheckinResult surfaces backend rewards', () {
      final r = _verifiedResult();
      expect(r.verified, isTrue);
      expect(r.trustScore, 90);
      expect(r.rewards.hasNewCard, isTrue);
      expect(r.rewards.card!.rarity, 'RARE');
      expect(r.rewards.achievements.single.points, 50);
    });

    test('empty rewards for a bare (unverified) response', () {
      final r = CheckinResult.fromJson(const {'verified': false, 'distanceMeters': 300, 'trustScore': 40, 'visit': {'status': 'FRAUD_SUSPECTED'}});
      expect(r.verified, isFalse);
      expect(r.rewards.card, isNull);
      expect(r.rewards.achievements, isEmpty);
    });

    test('CheckinFailure classifies backend messages', () {
      expect(CheckinFailure.fromResponse(statusCode: 400, message: 'You are 340m away. Check in within 100m.').kind,
          CheckinFailureKind.outOfGeofence);
      expect(CheckinFailure.fromResponse(statusCode: 400, message: 'Mock location detected').kind,
          CheckinFailureKind.mockLocation);
      expect(CheckinFailure.fromResponse(statusCode: 409, message: 'Already checked in for this temple today').kind,
          CheckinFailureKind.alreadyCheckedIn);
      expect(const CheckinFailure.offline('no net').kind, CheckinFailureKind.offline);
    });

    test('VisitRouteProgress derives remaining + completion', () {
      final p = VisitRouteProgress.fromMyStatusRow(const {
        'routeId': 'r1', 'slug': 'jyotirlinga', 'name': 'Jyotirlinga Yatra',
        'templeCount': 12, 'completedTemples': 3, 'percent': 25,
      });
      expect(p.remainingTemples, 9);
      expect(p.isComplete, isFalse);
      expect(p.percent, 25);
    });
  });

  /// The visit page (opened over a home page) with fakes for the repository,
  /// GPS and router. Reduced motion keeps the looping celebrations still so
  /// frames can settle.
  Future<void> pumpVisit(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/visit',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('HOME')),
          routes: [GoRoute(path: 'visit', builder: (_, _) => const TempleVisitPage(slug: 'kashi-vishwanath'))],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          templeVisitRepositoryProvider.overrideWithValue(_FakeRepo()),
          locationServiceProvider.overrideWithValue(const _FakeLocation()),
          deviceContextServiceProvider.overrideWithValue(_FakeDevice()),
          visitRouteProvider.overrideWith(
            (ref, q) async => RoutePlan(points: [q.from, q.to], distanceMeters: 1200, durationSeconds: 360),
          ),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) =>
              MediaQuery(data: MediaQuery.of(context).copyWith(disableAnimations: true), child: child!),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('visit flow opens on the Navigation phase with the route times', (tester) async {
    await pumpVisit(tester);

    expect(find.text('Kashi Vishwanath Temple'), findsWidgets);
    expect(find.text('1.2 km'), findsOneWidget);
    expect(find.text('6 min'), findsOneWidget);
    // At the temple, every mode is offered — walking included.
    expect(find.text('Walking'), findsOneWidget);
    expect(find.text('Bike'), findsOneWidget);
    expect(find.text('Start Navigation'), findsOneWidget);
    expect(find.text("I've Arrived"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('arrive → check in → verified summary; card and achievement are optional', (tester) async {
    await pumpVisit(tester);

    await tester.tap(find.text("I've Arrived"));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to'), findsOneWidget);
    expect(find.text('Temple geofence detected'), findsOneWidget);

    await tester.tap(find.text('I am at the Temple'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm Your Arrival'), findsOneWidget);

    await tester.tap(find.text('Check-In Now'));
    await tester.pumpAndSettle();

    // The summary: record, every reward as a row, the card reveal offered
    // first — and Done right there.
    expect(find.text('Visit Verified!'), findsOneWidget);
    expect(find.text('May your journey be blessed!'), findsOneWidget);
    expect(find.text('DARSHAN VERIFIED'), findsOneWidget);
    expect(find.text('Card Unlocked'), findsOneWidget);
    expect(find.text('Shiv Bhakt · +50 Points'), findsOneWidget);
    expect(find.text('Reveal Your Card'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    // The card, then Back to the summary — the reveal is no longer pressed.
    await tester.tap(find.text('Reveal Your Card'));
    await tester.pumpAndSettle();
    expect(find.text('Temple Card Unlocked'), findsOneWidget);
    expect(find.text('Share Card'), findsOneWidget);
    expect(find.text('Done'), findsNWidgets(2)); // the card's, over the summary's
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Temple Card Unlocked'), findsNothing);
    expect(find.text('Reveal Your Card'), findsNothing);

    // The achievement opens only when asked, and Back returns.
    await tester.ensureVisible(find.text('Achievement Unlocked'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Achievement Unlocked'));
    await tester.pumpAndSettle();
    expect(find.text('New Achievement!'), findsOneWidget);
    expect(find.text('View All Achievements'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('New Achievement!'), findsNothing);

    // Done ends the visit.
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a card already revealed shows its face at once', (tester) async {
    var revealed = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 240,
              child: CardReveal(front: const Text('FACE'), animate: false, onRevealed: () => revealed++),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('FACE'), findsOneWidget);
    expect(revealed, 1);
  });

  testWidgets('the card rises, flips and announces its face once', (tester) async {
    var revealed = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 240,
              child: CardReveal(front: const Text('FACE'), onRevealed: () => revealed++),
            ),
          ),
        ),
      ),
    );
    // Face-down while it rises and gathers light.
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('FACE'), findsNothing);
    expect(find.byType(SacredCardBack), findsOneWidget);

    // Past the flip the face is up and the reveal is announced — once.
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('FACE'), findsOneWidget);
    expect(revealed, 1);
    expect(tester.takeException(), isNull);
  });

  test('the greeting follows the deity', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(deityGreeting(l10n, 'SHIVA'), 'Jai Bholenath!');
    expect(deityGreeting(l10n, 'DEVI'), 'Jai Mata Di!');
    expect(deityGreeting(l10n, null), 'May your journey be blessed!');
  });
}
