import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/app/localization/app_localizations.dart';
import 'package:marg_app/app/theme/app_theme.dart';
import 'package:marg_app/features/routes/data/repository/routes_repository_impl.dart';
import 'package:marg_app/features/routes/domain/entities/my_route.dart';
import 'package:marg_app/features/routes/domain/entities/route_detail_bundle.dart';
import 'package:marg_app/features/routes/domain/entities/route_progress.dart';
import 'package:marg_app/features/routes/domain/entities/yatra_route.dart';
import 'package:marg_app/features/routes/domain/repository/routes_repository.dart';
import 'package:marg_app/features/routes/presentation/pages/my_yatras_page.dart';

YatraRoute _route() => YatraRoute.fromJson(const {
      'id': 'r1',
      'name': '12 Jyotirlinga Yatra',
      'slug': 'jyotirlinga-yatra',
      'type': 'JYOTIRLINGA',
      'templeCount': 3,
      'description': 'The divine journey to the Jyotirlingas.',
      'coverImage': 'https://x/cover.jpg',
      'rewardCard': {'id': 'c1', 'title': 'Jyotirlinga Card', 'imageUrl': 'https://x/c.jpg', 'rarity': 'LEGENDARY'},
      'temples': [
        {'position': 1, 'temple': {'id': 't1', 'name': 'Somnath', 'slug': 'somnath', 'latitude': 20.88, 'longitude': 70.40, 'city': {'name': 'Veraval', 'state': {'name': 'Gujarat'}}, 'images': [{'url': 'https://x/1.jpg'}]}},
        {'position': 2, 'temple': {'id': 't2', 'name': 'Mallikarjuna', 'slug': 'mallikarjuna', 'latitude': 16.07, 'longitude': 78.86}},
        {'position': 3, 'temple': {'id': 't3', 'name': 'Mahakaleshwar', 'slug': 'mahakaleshwar', 'latitude': 23.18, 'longitude': 75.76}},
      ],
    });

class _FakeRepo implements RoutesRepository {
  @override
  Future<void> enroll(String routeId) async {}

  @override
  Future<void> unenroll(String routeId) async {}

  @override
  Future<List<int>> certificate(String routeId) async => const [37, 80, 68, 70]; // %PDF

  @override
  Future<List<YatraRoute>> discover({String? type, String? query}) async => [_route()];

  @override
  Future<List<MyRouteProgress>> myRoutes() async => [
        MyRouteProgress.fromJson(const {
          'routeId': 'r1', 'completedTemples': 2, 'totalTemples': 3, 'completionPercent': 66,
          'route': {'id': 'r1', 'name': '12 Jyotirlinga Yatra', 'slug': 'jyotirlinga-yatra', 'type': 'JYOTIRLINGA', 'coverImage': 'https://x/cover.jpg', 'templeCount': 3},
        }),
      ];

  @override
  Future<RouteDetailBundle> loadDetail(String slug) async => RouteDetailBundle(
        route: _route(),
        progress: RouteProgress.fromJson(const {
          'completedTemples': 1, 'totalTemples': 3, 'completionPercentage': 33,
          'nextTemple': {'id': 't2', 'name': 'Mallikarjuna', 'slug': 'mallikarjuna', 'position': 2},
          'remainingTemples': [{'id': 't2'}, {'id': 't3'}],
        }),
      );
}

void main() {
  group('routes models', () {
    test('YatraRoute detail parses temples (cover + city) + reward card', () {
      final r = _route();
      expect(r.temples, hasLength(3));
      expect(r.temples.first.temple.location, 'Veraval, Gujarat');
      expect(r.temples.first.temple.imageUrl, 'https://x/1.jpg');
      expect(r.rewardCard?.rarity, 'LEGENDARY');
      expect(r.totalDistanceKm, greaterThan(0));
    });

    test('MyRouteProgress classifies in-progress vs complete', () {
      final p = MyRouteProgress.fromJson(const {
        'routeId': 'r1', 'completedTemples': 2, 'totalTemples': 3, 'completionPercent': 66,
        'route': {'name': 'X', 'slug': 'x', 'type': 'CUSTOM'},
      });
      expect(p.inProgress, isTrue);
      expect(p.isComplete, isFalse);
      expect(p.planned, isFalse);
      expect(p.percent, 66);
    });

    test('MyRouteProgress with 0 completed is Planned', () {
      final p = MyRouteProgress.fromJson(const {
        'routeId': 'r1', 'completedTemples': 0, 'totalTemples': 12, 'completionPercent': 0,
        'route': {'name': 'X', 'slug': 'x', 'type': 'JYOTIRLINGA'},
      });
      expect(p.planned, isTrue);
      expect(p.inProgress, isFalse);
      expect(p.isComplete, isFalse);
    });

    test('RouteDetailBundle derives per-temple status from backend progress', () {
      final bundle = RouteDetailBundle(
        route: _route(),
        progress: RouteProgress.fromJson(const {
          'completedTemples': 1, 'totalTemples': 3, 'completionPercentage': 33,
          'nextTemple': {'id': 't2', 'name': 'Mallikarjuna', 'slug': 'mallikarjuna', 'position': 2},
          'remainingTemples': [{'id': 't2'}, {'id': 't3'}],
        }),
      );
      final temples = bundle.route.temples;
      expect(bundle.statusOf(temples[0]), TempleJourneyStatus.completed);
      expect(bundle.statusOf(temples[1]), TempleJourneyStatus.current);
      expect(bundle.statusOf(temples[2]), TempleJourneyStatus.remaining);
      expect(bundle.percent, 33);
      expect(bundle.isComplete, isFalse);
      expect(bundle.nextEntry?.temple.slug, 'mallikarjuna');
      expect(bundle.nextEntry?.temple.latitude, 16.07);
      expect(bundle.completedOn, isNull);
    });

    test('RouteDetailBundle dates completion by the last visit, not today', () {
      final bundle = RouteDetailBundle(
        route: _route(),
        progress: RouteProgress.fromJson(const {
          'completedTemples': 3, 'totalTemples': 3, 'completionPercentage': 100, 'remainingTemples': <Object>[],
        }),
        visitDateByTempleId: {
          't1': DateTime(2026, 1, 4),
          't2': DateTime(2026, 3, 9),
          't3': DateTime(2026, 2, 1),
        },
      );
      expect(bundle.isComplete, isTrue);
      expect(bundle.nextEntry, isNull);
      expect(bundle.completedOn, DateTime(2026, 3, 9));
    });
  });

  testWidgets('My Yatras renders the in-progress section + route card', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [routesRepositoryProvider.overrideWithValue(_FakeRepo())],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MyYatrasPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('12 Jyotirlinga Yatra'), findsWidgets);
    expect(find.text('In Progress'), findsWidgets);
    expect(find.text('Embark on a Divine Journey'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
