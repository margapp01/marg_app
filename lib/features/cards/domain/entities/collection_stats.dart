import '../../../../shared/components/rarity.dart';

/// The user's collection statistics (`GET /my/cards/stats`). Grouped by rarity
/// + overall completion. The backend does not expose by-deity/state/route
/// groupings, so those are not modelled here.
class CollectionStats {
  const CollectionStats({
    required this.totalCards,
    required this.ownedCards,
    required this.completionPercentage,
    required this.byRarity,
  });

  final int totalCards;
  final int ownedCards;
  final double completionPercentage;

  /// Owned counts keyed by rarity (COMMON/RARE/EPIC/LEGENDARY/MYTHIC).
  final Map<String, int> byRarity;

  int get percent => completionPercentage.round();
  int get missingCards => (totalCards - ownedCards).clamp(0, totalCards);
  int ownedOf(String rarity) => byRarity[rarity.toUpperCase()] ?? 0;

  static int _i(Object? v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
  static double _d(Object? v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;

  factory CollectionStats.fromJson(Map<String, dynamic> json) => CollectionStats(
        totalCards: _i(json['totalCards']),
        ownedCards: _i(json['ownedCards']),
        completionPercentage: _d(json['completionPercentage']),
        byRarity: {
          'COMMON': _i(json['commonCards']),
          'RARE': _i(json['rareCards']),
          'EPIC': _i(json['epicCards']),
          'LEGENDARY': _i(json['legendaryCards']),
          'MYTHIC': _i(json['mythicCards']),
        },
      );

  static const empty = CollectionStats(
    totalCards: 0, ownedCards: 0, completionPercentage: 0,
    byRarity: {'COMMON': 0, 'RARE': 0, 'EPIC': 0, 'LEGENDARY': 0, 'MYTHIC': 0},
  );

  /// Rarities in ascending order (for consistent chart ordering).
  List<String> get rarityOrder => kRarityOrder;
}
