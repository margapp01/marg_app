import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/app/localization/app_localizations.dart';
import 'package:marg_app/app/theme/app_theme.dart';
import 'package:marg_app/features/explore/data/datasource/explore_remote_datasource.dart';
import 'package:marg_app/features/explore/data/repository/explore_repository_impl.dart';
import 'package:marg_app/features/explore/domain/entities/explore_models.dart';
import 'package:marg_app/features/explore/presentation/widgets/explore_widgets.dart';

/// A fake datasource that returns canned rows without touching the network.
class _FakeDataSource extends ExploreRemoteDataSource {
  _FakeDataSource() : super(Dio());

  @override
  Future<List<VisitRecord>> visits() async => [
        VisitRecord(templeName: 'Kashi Vishwanath', latitude: 25.3109, longitude: 83.0107, visitedAt: DateTime.now()),
        VisitRecord(templeName: 'Somnath', latitude: 20.888, longitude: 70.401, visitedAt: DateTime(2026, 1, 5)),
      ];
}

void main() {
  group('ExploreTemple parsing', () {
    test('parses a nearby row with distanceMeters', () {
      final t = ExploreTemple.fromJson(const {
        'distanceMeters': 800.0,
        'temple': {
          'id': 't1', 'name': 'Mahakaleshwar', 'slug': 'mahakaleshwar', 'deity': 'SHIVA',
          'latitude': 23.18, 'longitude': 75.76, 'isVerified': true, 'viewCount': 12600,
          'card': {'imageUrl': 'https://x/card.png'},
          'city': {'name': 'Ujjain', 'state': {'name': 'Madhya Pradesh'}},
        },
      });
      expect(t.name, 'Mahakaleshwar');
      expect(t.deity, 'SHIVA');
      expect(t.location, 'Ujjain, Madhya Pradesh');
      expect(t.cardImageUrl, 'https://x/card.png');
      expect(t.isVerified, isTrue);
      expect(t.distanceMeters, 800.0);
      expect(t.formattedDistance, '800 m');
    });

    test('parses a bare list temple with no distance and formats km', () {
      final t = ExploreTemple.fromJson(const {
        'id': 't2', 'name': 'Somnath', 'slug': 'somnath', 'latitude': 20.9, 'longitude': 70.4,
        'city': {'name': 'Prabhas Patan', 'state': {'name': 'Gujarat'}},
      });
      expect(t.distanceMeters, isNull);
      expect(t.formattedDistance, isNull);
      expect(t.location, 'Prabhas Patan, Gujarat');
    });

    test('formats a kilometre distance', () {
      final t = ExploreTemple.fromJson(const {'distanceMeters': 5400.0, 'temple': {'id': 'x', 'name': 'A', 'slug': 'a', 'latitude': 1, 'longitude': 1}});
      expect(t.formattedDistance, '5.4 km');
    });
  });

  group('ExploreFilter', () {
    test('copyWith can clear the deity via the sentinel', () {
      const f = ExploreFilter(deity: ExploreDeity.shiva);
      expect(f.copyWith(deity: null).deity, isNull);
      expect(f.copyWith(radiusKm: 50).deity, ExploreDeity.shiva); // deity preserved
    });

    test('default filter is popular + 25km + no deity', () {
      const f = ExploreFilter();
      expect(f.isDefault, isTrue);
      expect(f.sort, ExploreSort.popular);
    });
  });

  test('ExploreRepository derives statistics from visits + location', () async {
    final repo = ExploreRepository(_FakeDataSource());
    final stats = await repo.statistics(current: (25.31, 83.01)); // near Kashi
    expect(stats.templesExplored, 2);
    expect(stats.thisMonth, 1);
    expect(stats.monthly.length, 6);
    expect(stats.nearestName, 'Kashi Vishwanath'); // essentially at the current point
    expect(stats.farthestName, 'Somnath');
  });

  testWidgets('ExploreTempleCard shows name, location and distance', (tester) async {
    final temple = ExploreTemple.fromJson(const {
      'distanceMeters': 1200.0,
      'temple': {'id': 't', 'name': 'Harsiddhi Temple', 'slug': 'harsiddhi', 'deity': 'DEVI', 'latitude': 23.1, 'longitude': 75.7, 'city': {'name': 'Ujjain', 'state': {'name': 'MP'}}},
    });
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: ExploreTempleCard(temple: temple, onTap: () {})),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Harsiddhi Temple'), findsOneWidget);
    expect(find.text('Ujjain, MP'), findsOneWidget);
    expect(find.text('1.2 km'), findsOneWidget);
    expect(find.text('Devi Temples'), findsOneWidget); // deity label pill
    expect(tester.takeException(), isNull);
  });
}
