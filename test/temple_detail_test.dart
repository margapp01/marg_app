import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/app/localization/app_localizations.dart';
import 'package:marg_app/app/theme/app_theme.dart';
import 'package:marg_app/features/temple_detail/data/repository/temple_detail_repository_impl.dart';
import 'package:marg_app/features/temple_detail/domain/entities/temple_detail.dart';
import 'package:marg_app/features/temple_detail/domain/repository/temple_detail_repository.dart';
import 'package:marg_app/features/temple_detail/presentation/pages/temple_detail_page.dart';

TempleDetail _temple() => TempleDetail.fromJson(<String, dynamic>{
      'id': 't1',
      'name': 'Kashi Vishwanath Temple',
      'slug': 'kashi-vishwanath',
      'latitude': 25.31,
      'longitude': 83.01,
      'isVerified': true,
      'description': 'One of the 12 Jyotirlingas of Lord Shiva.',
      'deity': 'SHIVA',
      'city': {'name': 'Varanasi', 'state': {'name': 'Uttar Pradesh'}},
      'images': [
        {'url': 'https://x/1.jpg', 'isCover': true, 'position': 0},
        {'url': 'https://x/2.jpg', 'position': 1},
      ],
      'timings': [
        {'dayOfWeek': 1, 'openTime': '4:00 AM', 'closeTime': '11:30 PM'},
      ],
      'facilities': [
        {'facility': {'name': 'Drinking Water', 'icon': 'water'}},
      ],
      'routeLinks': [
        {'route': {'id': 'r1', 'name': 'Jyotirlinga Yatra', 'slug': 'jyotirlinga', 'templeCount': 12}},
      ],
      'card': {'id': 'c1', 'title': 'Kashi Card', 'imageUrl': 'https://x/c.jpg', 'rarity': 'RARE'},
    });

class _FakeRepo implements TempleDetailRepository {
  _FakeRepo({this.visit = _visitedEarlier});

  /// The `visit` block of `/temples/:id/my-status`.
  final Map<String, dynamic> visit;

  static const _visitedEarlier = <String, dynamic>{
    'visited': true, 'verified': true, 'status': 'VERIFIED', 'lastVisitAt': '2026-05-20T00:00:00.000Z',
    'visitCount': 3, 'canCheckIn': true, 'nextCheckinAt': null,
  };

  @override
  Future<TempleDetailBundle> loadBundle(String slug) async {
    return TempleDetailBundle(
      temple: _temple(),
      crowd: CrowdInfo.fromJson(const {
        'occupancyPercent': 62, 'estimatedOccupancy': 9300, 'capacity': 15000,
        'crowdLevel': 'MODERATE', 'confidenceScore': 0.8, 'festivalActive': false,
        'estimatedWaitMinutes': 40,
      }),
      bestTimeWindow: '6:00 AM – 9:00 AM',
      myStatus: TempleMyStatus.fromJson({
        'visit': visit,
        'card': {'collected': true, 'id': 'c1', 'title': 'Kashi Card', 'rarity': 'RARE'},
        'routes': [{'routeId': 'r1', 'slug': 'jyotirlinga', 'name': 'Jyotirlinga Yatra', 'templeCount': 12, 'completedTemples': 2, 'percent': 17}],
      }),
      nearby: const [],
    );
  }
}

void main() {
  group('Temple detail models', () {
    test('parses the /temples/:slug detail contract', () {
      final t = _temple();
      expect(t.name, 'Kashi Vishwanath Temple');
      expect(t.location, 'Varanasi, Uttar Pradesh');
      expect(t.coverImage, 'https://x/1.jpg');
      expect(t.images, hasLength(2));
      expect(t.timings.single.openTime, '4:00 AM');
      expect(t.facilities.single.name, 'Drinking Water');
      expect(t.routes.single.templeCount, 12);
      expect(t.card?.rarity, 'RARE');
    });

    test('best-time window formats a contiguous hour range', () {
      final slots = HourSlot.list(const [
        {'hour': 6}, {'hour': 7}, {'hour': 8},
      ]);
      expect(HourSlot.window(slots), '6:00 AM – 9:00 AM');
    });

    test('my-status parses visit / card / route progress', () {
      final s = TempleMyStatus.fromJson(const {
        'visit': {'visited': true, 'verified': true, 'status': 'VERIFIED'},
        'card': {'collected': true, 'title': 'Kashi Card', 'rarity': 'RARE'},
        'routes': [{'routeId': 'r1', 'slug': 'j', 'name': 'J', 'templeCount': 12, 'completedTemples': 2, 'percent': 17}],
      });
      expect(s.visited, isTrue);
      expect(s.cardCollected, isTrue);
      expect(s.routes.single.percent, 17);
    });

    test('my-status parses the repeat-visit fields, with safe defaults', () {
      final locked = TempleMyStatus.fromJson(const {
        'visit': {
          'visited': true, 'verified': true, 'status': 'VERIFIED',
          'visitCount': 5, 'canCheckIn': false, 'nextCheckinAt': '2026-10-09T00:00:00.000Z',
        },
      });
      expect(locked.visitCount, 5);
      expect(locked.canCheckIn, isFalse);
      expect(locked.nextCheckinAt, DateTime.utc(2026, 10, 9));

      // An older backend without the fields never blocks the attempt.
      final legacy = TempleMyStatus.fromJson(const {'visit': {'visited': true, 'status': 'VERIFIED'}});
      expect(legacy.visitCount, 0);
      expect(legacy.canCheckIn, isTrue);
      expect(legacy.nextCheckinAt, isNull);
    });
  });

  Future<void> pumpDetail(WidgetTester tester, _FakeRepo repo) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [templeDetailRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TempleDetailPage(slug: 'kashi-vishwanath'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a visited temple offers the next check-in and shows the visit count', (tester) async {
    await pumpDetail(tester, _FakeRepo());

    expect(find.text('Check in again'), findsOneWidget);
    expect(find.text('Visited 3 times'), findsOneWidget);
    expect(find.textContaining('Last visit · '), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets("once today's check-in is done the action reads Checked in today", (tester) async {
    await pumpDetail(
      tester,
      _FakeRepo(visit: const {
        'visited': true, 'verified': true, 'status': 'VERIFIED', 'lastVisitAt': '2026-10-08T04:30:00.000Z',
        'visitCount': 4, 'canCheckIn': false, 'nextCheckinAt': '2026-10-09T00:00:00.000Z',
      }),
    );

    expect(find.text('Check in again'), findsNothing);
    expect(find.text('Checked in today'), findsOneWidget);
    expect(find.text('Visited 4 times'), findsOneWidget);
    expect(find.textContaining('next check-in from'), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.ancestor(of: find.text('Checked in today'), matching: find.byType(FilledButton)),
    );
    expect(button.onPressed, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Temple Detail renders hero + intelligence from the bundle', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [templeDetailRepositoryProvider.overrideWithValue(_FakeRepo())],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TempleDetailPage(slug: 'kashi-vishwanath'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kashi Vishwanath Temple'), findsWidgets);
    expect(find.text('Temple Intelligence (Live)'), findsOneWidget);
    expect(find.text('Verified Temple'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
