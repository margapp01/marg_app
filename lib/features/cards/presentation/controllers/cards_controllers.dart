import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repository/cards_repository_impl.dart';
import '../../domain/entities/collection_group.dart';
import '../../domain/entities/collection_stats.dart';
import '../../domain/entities/sacred_card.dart';

/// Collection statistics (My Collection header + Statistics screen).
final collectionStatsProvider = FutureProvider.autoDispose<CollectionStats>(
  (ref) => ref.watch(cardsRepositoryProvider).stats(),
);

/// Recently unlocked cards (newest first).
final recentCardsProvider = FutureProvider.autoDispose<List<SacredCard>>(
  (ref) async => (await ref.watch(cardsRepositoryProvider).myCards(sortOrder: 'desc')).items,
);

/// Per-series collection progress.
final seriesProgressProvider = FutureProvider.autoDispose<List<CollectionGroup>>(
  (ref) => ref.watch(cardsRepositoryProvider).seriesProgress(),
);

/// Per-season collection progress.
final seasonProgressProvider = FutureProvider.autoDispose<List<CollectionGroup>>(
  (ref) => ref.watch(cardsRepositoryProvider).seasonProgress(),
);

/// One card, enriched with ownership when owned.
final cardDetailProvider = FutureProvider.autoDispose.family<SacredCard, String>(
  (ref, id) => ref.watch(cardsRepositoryProvider).cardDetail(id),
);

/// Gallery query — the family key. Value-equality so Riverpod caches per filter.
@immutable
class GalleryQuery {
  const GalleryQuery({this.rarity, this.seriesId, this.seasonId, this.query, this.missingOnly = false});

  final String? rarity;
  final String? seriesId;
  final String? seasonId;
  final String? query;
  final bool missingOnly;

  GalleryQuery copyWith({String? rarity, String? query, bool clearRarity = false}) => GalleryQuery(
        rarity: clearRarity ? null : (rarity ?? this.rarity),
        seriesId: seriesId,
        seasonId: seasonId,
        query: query ?? this.query,
        missingOnly: missingOnly,
      );

  @override
  bool operator ==(Object other) =>
      other is GalleryQuery &&
      other.rarity == rarity &&
      other.seriesId == seriesId &&
      other.seasonId == seasonId &&
      other.query == query &&
      other.missingOnly == missingOnly;

  @override
  int get hashCode => Object.hash(rarity, seriesId, seasonId, query, missingOnly);
}

@immutable
class GalleryState {
  const GalleryState({
    required this.cards,
    required this.page,
    required this.hasMore,
    this.loadingMore = false,
  });

  final List<SacredCard> cards;
  final int page;
  final bool hasMore;
  final bool loadingMore;

  GalleryState copyWith({List<SacredCard>? cards, int? page, bool? hasMore, bool? loadingMore}) =>
      GalleryState(
        cards: cards ?? this.cards,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        loadingMore: loadingMore ?? this.loadingMore,
      );
}

/// Paginated, infinite-scroll gallery for a given [GalleryQuery]. Marks
/// owned/locked and (for missing view) filters to locked cards.
class GalleryController extends AutoDisposeFamilyAsyncNotifier<GalleryState, GalleryQuery> {
  @override
  Future<GalleryState> build(GalleryQuery query) async {
    final page = await ref.watch(cardsRepositoryProvider).catalog(
          page: 1,
          query: query.query,
          rarity: query.rarity,
          seriesId: query.seriesId,
          seasonId: query.seasonId,
        );
    final cards = query.missingOnly ? page.items.where((c) => !c.owned).toList() : page.items;
    return GalleryState(cards: cards, page: 1, hasMore: page.hasMore);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.loadingMore) return;
    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final next = await ref.read(cardsRepositoryProvider).catalog(
            page: current.page + 1,
            query: arg.query,
            rarity: arg.rarity,
            seriesId: arg.seriesId,
            seasonId: arg.seasonId,
          );
      final more = arg.missingOnly ? next.items.where((c) => !c.owned).toList() : next.items;
      state = AsyncData(GalleryState(
        cards: [...current.cards, ...more],
        page: next.page,
        hasMore: next.hasMore,
      ));
    } catch (_) {
      state = AsyncData(current.copyWith(loadingMore: false));
    }
  }
}

final galleryControllerProvider =
    AsyncNotifierProvider.autoDispose.family<GalleryController, GalleryState, GalleryQuery>(
  GalleryController.new,
);
