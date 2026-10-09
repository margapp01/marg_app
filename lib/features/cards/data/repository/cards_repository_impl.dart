import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/card_page.dart';
import '../../domain/entities/collection_group.dart';
import '../../domain/entities/collection_stats.dart';
import '../../domain/entities/sacred_card.dart';
import '../../domain/repository/cards_repository.dart';
import '../datasource/cards_remote_datasource.dart';

class CardsRepositoryImpl implements CardsRepository {
  CardsRepositoryImpl(this._remote);

  final CardsRemoteDataSource _remote;

  @override
  Future<CardPage> catalog({
    int page = 1,
    String? query,
    String? rarity,
    String? seriesId,
    String? seasonId,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    final results = await Future.wait([
      _remote.catalog(
        page: page, query: query, rarity: rarity, seriesId: seriesId, seasonId: seasonId,
        sortBy: sortBy, sortOrder: sortOrder,
      ),
      _ownedSoft(),
    ]);
    final catalog = results[0] as CardPage;
    final owned = results[1] as Map<String, CardOwnership>;
    return CardPage(
      items: [for (final c in catalog.items) c.copyWith(owned: owned.containsKey(c.id), ownership: owned[c.id])],
      page: catalog.page,
      totalPages: catalog.totalPages,
    );
  }

  @override
  Future<CardPage> myCards({int page = 1, String sortOrder = 'desc'}) =>
      _remote.myCards(page: page, sortOrder: sortOrder);

  @override
  Future<CollectionStats> stats() => _remote.stats();

  @override
  Future<Set<String>> ownedCardIds() => _remote.ownedCardIds();

  @override
  Future<SacredCard> cardDetail(String id) async {
    // [id] is a catalog card id: load the card and the user's ownership map
    // together, then mark it owned (with unlock date / mint) if collected.
    final owned = _ownedSoft();
    final SacredCard card;
    try {
      card = await _remote.catalogDetail(id);
    } catch (_) {
      // Links that carry a user-card id resolve through the collection.
      return _remote.myCardDetail(id);
    }
    final ownership = (await owned)[card.id];
    return ownership == null ? card : card.copyWith(owned: true, ownership: ownership);
  }

  @override
  Future<String?> shareText(String userCardId) async {
    try {
      return await _remote.shareText(userCardId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<CollectionGroup>> seriesProgress() => _remote.seriesProgress();

  @override
  Future<List<CollectionGroup>> seasonProgress() => _remote.seasonProgress();

  Future<Map<String, CardOwnership>> _ownedSoft() async {
    try {
      return await _remote.ownedCards();
    } catch (_) {
      return const {};
    }
  }
}

final cardsRepositoryProvider = Provider<CardsRepository>(
  (ref) => CardsRepositoryImpl(ref.watch(cardsRemoteDataSourceProvider)),
);
