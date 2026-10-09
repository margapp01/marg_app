import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/app/localization/app_localizations.dart';
import 'package:marg_app/app/theme/app_theme.dart';
import 'package:marg_app/features/achievements/data/repository/achievements_repository_impl.dart';
import 'package:marg_app/features/achievements/domain/entities/achievement.dart';
import 'package:marg_app/features/achievements/domain/entities/achievement_collection.dart';
import 'package:marg_app/features/achievements/domain/entities/achievement_summary.dart';
import 'package:marg_app/features/achievements/domain/repository/achievements_repository.dart';
import 'package:marg_app/features/achievements/presentation/pages/achievements_dashboard_page.dart';

AchievementCollection _collection() => AchievementCollection.fromBuckets(const {
      'earned': [
        {
          'progress': 100, 'earnedAt': '2026-05-20T00:00:00.000Z',
          'achievement': {'id': 'a1', 'name': 'Jyotirlinga Explorer', 'slug': 'jyoti', 'category': 'TEMPLE', 'rarity': 'LEGENDARY', 'points': 500, 'rules': [{'ruleType': 'VISITED_TEMPLES', 'threshold': 12}]},
        },
      ],
      'inProgress': [
        {
          'progress': 50, 'earnedAt': null,
          'achievement': {'id': 'a2', 'name': 'Char Dham Yatri', 'slug': 'char', 'category': 'ROUTE', 'rarity': 'EPIC', 'points': 300, 'rules': [{'ruleType': 'COMPLETED_ROUTES', 'threshold': 4}]},
        },
      ],
      'locked': [
        {
          'progress': 0, 'earnedAt': null,
          'achievement': {'id': 'a3', 'name': 'Shaktipeeth Seeker', 'slug': 'shakti', 'category': 'SPECIAL', 'rarity': 'RARE', 'points': 200, 'rules': <Object>[]},
        },
      ],
    });

class _FakeRepo implements AchievementsRepository {
  @override
  Future<AchievementCollection> collection() async => _collection();

  @override
  Future<AchievementSummary> summary() async => const AchievementSummary(trustScore: 850, passportCompletion: 68, milestones: []);

  @override
  Future<AchievementReward?> rewardCard(String cardId) async => null;
}

void main() {
  group('achievements models', () {
    test('collection buckets + counts + points', () {
      final c = _collection();
      expect(c.total, 3);
      expect(c.earnedCount, 1);
      expect(c.inProgressCount, 1);
      expect(c.lockedCount, 1);
      expect(c.pointsEarned, 500);
      expect(c.completionPercent, 33);
    });

    test('derives X/Y count from percent × threshold', () {
      final inProgress = _collection().inProgress.single;
      expect(inProgress.threshold, 4);
      expect(inProgress.currentCount, 2); // 50% of 4
      expect(inProgress.status, AchievementStatus.inProgress);
    });

    test('earned achievement reports full count + earnedAt', () {
      final earned = _collection().earned.single;
      expect(earned.earned, isTrue);
      expect(earned.currentCount, 12);
      expect(earned.earnedAt, isNotNull);
    });

    test('categories + per-category progress', () {
      final c = _collection();
      expect(c.categories, containsAll(['TEMPLE', 'ROUTE', 'SPECIAL']));
      final temple = c.categoryProgress('TEMPLE');
      expect(temple.earned, 1);
      expect(temple.total, 1);
    });
  });

  testWidgets('Dashboard renders progress, points and trust score', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [achievementsRepositoryProvider.overrideWithValue(_FakeRepo())],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AchievementsDashboardPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Achievements'), findsWidgets);
    // earned (animated) / total
    expect(find.text('1'), findsWidgets);
    expect(find.text(' / 3'), findsOneWidget);
    expect(find.text('500'), findsOneWidget); // points earned
    expect(find.text('850'), findsOneWidget); // trust score
    expect(tester.takeException(), isNull);
  });
}
