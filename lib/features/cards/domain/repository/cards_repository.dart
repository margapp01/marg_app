import '../entities/card_page.dart';
import '../entities/collection_group.dart';
import '../entities/collection_stats.dart';
import '../entities/sacred_card.dart';

/// Data boundary for the Sacred Cards feature, over the existing card + series +
/// season + passport-collection endpoints.
abstract class CardsRepository {
  /// The public card catalog (paginated, filterable). Cards are marked [owned]
  /// against the user's owned-card-id set.
  Future<CardPage> catalog({
    int page,
    String? query,
    String? rarity,
    String? seriesId,
    String? seasonId,
    String sortBy,
    String sortOrder,
  });

  /// The user's owned cards (recent first), with ownership metadata.
  Future<CardPage> myCards({int page, String sortOrder});

  /// Collection statistics (by rarity + completion).
  Future<CollectionStats> stats();

  /// The set of card ids the user owns.
  Future<Set<String>> ownedCardIds();

  /// A single card, enriched with ownership when the user owns it.
  Future<SacredCard> cardDetail(String id);

  /// Backend share text for an owned card (null if not owned / unavailable).
  Future<String?> shareText(String userCardId);

  /// Per-series collection progress.
  Future<List<CollectionGroup>> seriesProgress();

  /// Per-season collection progress.
  Future<List<CollectionGroup>> seasonProgress();
}
