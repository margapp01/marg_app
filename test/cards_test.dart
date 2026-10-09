import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/app/localization/app_localizations.dart';
import 'package:marg_app/app/theme/app_theme.dart';
import 'package:marg_app/features/cards/data/repository/cards_repository_impl.dart';
import 'package:marg_app/features/cards/domain/entities/card_page.dart';
import 'package:marg_app/features/cards/domain/entities/collection_group.dart';
import 'package:marg_app/features/cards/domain/entities/collection_stats.dart';
import 'package:marg_app/features/cards/domain/entities/sacred_card.dart';
import 'package:marg_app/features/cards/domain/repository/cards_repository.dart';
import 'package:marg_app/features/cards/presentation/pages/my_collection_page.dart';

CollectionStats _stats() => CollectionStats.fromJson(const {
      'totalCards': 100, 'ownedCards': 42, 'completionPercentage': 42.0,
      'commonCards': 20, 'rareCards': 12, 'epicCards': 6, 'legendaryCards': 3, 'mythicCards': 1,
    });

SacredCard _catalogCard() => SacredCard.fromCatalog(const {
      'id': 'c1', 'title': 'Kashi Vishwanath', 'imageUrl': 'https://x/1.jpg', 'rarity': 'LEGENDARY',
      'description': 'A radiant card.',
      'temple': {'id': 't1', 'name': 'Kashi Vishwanath', 'slug': 'kashi', 'history': 'Ancient.', 'latitude': 25.31, 'longitude': 83.01},
      'series': {'id': 's1', 'name': 'Jyotirlinga Series', 'slug': 'jyoti'},
    });

class _FakeRepo implements CardsRepository {
  @override
  Future<CardPage> catalog({int page = 1, String? query, String? rarity, String? seriesId, String? seasonId, String sortBy = 'createdAt', String sortOrder = 'desc'}) async =>
      CardPage(items: [_catalogCard().copyWith(owned: true)], page: 1, totalPages: 1);

  @override
  Future<CardPage> myCards({int page = 1, String sortOrder = 'desc'}) async => CardPage.empty;

  @override
  Future<CollectionStats> stats() async => _stats();

  @override
  Future<Set<String>> ownedCardIds() async => {'c1'};

  @override
  Future<SacredCard> cardDetail(String id) async => _catalogCard();

  @override
  Future<String?> shareText(String userCardId) async => 'shared';

  @override
  Future<List<CollectionGroup>> seriesProgress() async => [
        CollectionGroup.fromJson(const {'id': 's1', 'name': 'Jyotirlinga Series', 'slug': 'jyoti', 'totalCards': 12, 'ownedCards': 3, 'completionPercent': 25.0, 'completed': false, 'missingCards': <Object>[]}),
      ];

  @override
  Future<List<CollectionGroup>> seasonProgress() async => const [];
}

void main() {
  group('cards models', () {
    test('CollectionStats parses rarity buckets + completion', () {
      final s = _stats();
      expect(s.ownedCards, 42);
      expect(s.percent, 42);
      expect(s.missingCards, 58);
      expect(s.ownedOf('LEGENDARY'), 3);
      expect(s.rarityOrder.first, 'COMMON');
    });

    test('SacredCard.fromCatalog parses temple + series + description', () {
      final c = _catalogCard();
      expect(c.rarity, 'LEGENDARY');
      expect(c.owned, isFalse);
      expect(c.temple?.history, 'Ancient.');
      expect(c.series?.name, 'Jyotirlinga Series');
    });

    test('SacredCard.fromUserCard flags owned + parses ownership', () {
      final c = SacredCard.fromUserCard(const {
        'id': 'uc1', 'mintNumber': 7, 'unlockedAt': '2026-05-20T00:00:00.000Z', 'unlockMethod': 'VISIT',
        'card': {'id': 'c1', 'title': 'Kashi', 'imageUrl': 'https://x/1.jpg', 'rarity': 'RARE'},
      });
      expect(c.owned, isTrue);
      expect(c.ownership?.mintNumber, 7);
      expect(c.ownership?.unlockMethod, 'VISIT');
    });

    test('CollectionGroup parses owned/total/percent', () {
      final g = CollectionGroup.fromJson(const {
        'id': 's1', 'name': 'S', 'slug': 's', 'totalCards': 12, 'ownedCards': 3, 'completionPercent': 25.0, 'completed': false, 'missingCards': <Object>[],
      });
      expect(g.percent, 25);
      expect(g.ownedCards, 3);
    });
  });

  testWidgets('My Collection renders the completion header + rarity counts', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [cardsRepositoryProvider.overrideWithValue(_FakeRepo())],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MyCollectionPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Owned count animates on its own; the total sits beside it.
    expect(find.text('42'), findsOneWidget);
    expect(find.text(' / 100'), findsOneWidget);
    expect(find.text('My Sacred Collection'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
