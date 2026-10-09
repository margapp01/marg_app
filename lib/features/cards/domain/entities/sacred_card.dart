/// A sacred temple card. Parsed from the catalog (`GET /cards`, `/cards/:id`)
/// and the user collection (`GET /my/cards`, `/my/cards/:id`). [owned] is set by
/// the repository against the user's owned-card-id set; [ownership] is present
/// only for a card in the user's collection.
class SacredCard {
  const SacredCard({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.rarity,
    this.subtitle,
    this.shareImageUrl,
    this.description,
    this.isLimited = false,
    this.editionName,
    this.seriesId,
    this.seasonId,
    this.temple,
    this.series,
    this.season,
    this.owned = false,
    this.ownership,
  });

  final String id;
  final String title;
  final String imageUrl;

  /// Backend `CardRarity`.
  final String rarity;
  final String? subtitle;
  final String? shareImageUrl;
  final String? description;
  final bool isLimited;
  final String? editionName;
  final String? seriesId;
  final String? seasonId;
  final CardTempleRef? temple;
  final CardGroupRef? series;
  final CardGroupRef? season;
  final bool owned;
  final CardOwnership? ownership;

  /// How long a newly unlocked card wears its "NEW" tag.
  static const Duration freshWindow = Duration(days: 7);

  /// Unlocked within [freshWindow].
  bool get isFresh {
    final at = ownership?.unlockedAt;
    return owned && at != null && DateTime.now().difference(at) < freshWindow;
  }

  SacredCard copyWith({bool? owned, CardOwnership? ownership}) => SacredCard(
        id: id, title: title, imageUrl: imageUrl, rarity: rarity,
        subtitle: subtitle, shareImageUrl: shareImageUrl, description: description,
        isLimited: isLimited, editionName: editionName, seriesId: seriesId, seasonId: seasonId,
        temple: temple, series: series, season: season,
        owned: owned ?? this.owned, ownership: ownership ?? this.ownership,
      );

  /// From a catalog card (`/cards`, `/cards/:id`).
  factory SacredCard.fromCatalog(Map<String, dynamic> json) {
    final temple = (json['temple'] as Map?)?.cast<String, dynamic>();
    final series = (json['series'] as Map?)?.cast<String, dynamic>();
    final season = (json['season'] as Map?)?.cast<String, dynamic>();
    return SacredCard(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      imageUrl: (json['imageUrl'] as String?) ?? '',
      rarity: (json['rarity'] as String?) ?? 'COMMON',
      subtitle: json['subtitle'] as String?,
      shareImageUrl: json['shareImageUrl'] as String?,
      description: json['description'] as String?,
      isLimited: json['isLimited'] == true,
      editionName: json['editionName'] as String?,
      seriesId: json['seriesId'] as String?,
      seasonId: json['seasonId'] as String?,
      temple: temple == null ? null : CardTempleRef.fromJson(temple),
      series: series == null ? null : CardGroupRef.fromJson(series),
      season: season == null ? null : CardGroupRef.fromJson(season),
    );
  }

  /// From a user-collection row (`/my/cards`, `/my/cards/:id`): the card is
  /// nested under `card`, plus ownership fields on the row.
  factory SacredCard.fromUserCard(Map<String, dynamic> json) {
    final card = (json['card'] as Map?)?.cast<String, dynamic>() ?? const {};
    final base = SacredCard.fromCatalog(card);
    return SacredCard(
      id: base.id, title: base.title, imageUrl: base.imageUrl, rarity: base.rarity,
      subtitle: base.subtitle, shareImageUrl: base.shareImageUrl, description: base.description,
      isLimited: base.isLimited, editionName: base.editionName, seriesId: base.seriesId, seasonId: base.seasonId,
      temple: base.temple, series: base.series, season: base.season,
      owned: true,
      ownership: CardOwnership.fromJson(json),
    );
  }
}

class CardTempleRef {
  const CardTempleRef({
    required this.id,
    required this.name,
    required this.slug,
    this.deity,
    this.history,
    this.description,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String name;
  final String slug;
  final String? deity;
  final String? history;
  final String? description;
  final double? latitude;
  final double? longitude;

  static double? _d(Object? v) => v is num ? v.toDouble() : double.tryParse('$v');

  factory CardTempleRef.fromJson(Map<String, dynamic> json) => CardTempleRef(
        id: (json['id'] as String?) ?? '',
        name: (json['name'] as String?) ?? '',
        slug: (json['slug'] as String?) ?? '',
        deity: json['deity'] as String?,
        history: json['history'] as String?,
        description: json['description'] as String?,
        latitude: _d(json['latitude']),
        longitude: _d(json['longitude']),
      );
}

class CardGroupRef {
  const CardGroupRef({required this.id, required this.name, this.slug});

  final String id;
  final String name;
  final String? slug;

  factory CardGroupRef.fromJson(Map<String, dynamic> json) => CardGroupRef(
        id: (json['id'] as String?) ?? '',
        name: (json['name'] as String?) ?? '',
        slug: json['slug'] as String?,
      );
}

class CardOwnership {
  const CardOwnership({this.userCardId, this.mintNumber, this.unlockedAt, this.unlockMethod});

  final String? userCardId;
  final int? mintNumber;
  final DateTime? unlockedAt;

  /// Backend `CardUnlockMethod` (VISIT / ROUTE / ACHIEVEMENT / ADMIN …).
  final String? unlockMethod;

  factory CardOwnership.fromJson(Map<String, dynamic> json) => CardOwnership(
        userCardId: json['id'] as String?,
        mintNumber: (json['mintNumber'] as num?)?.toInt(),
        unlockedAt: json['unlockedAt'] is String ? DateTime.tryParse(json['unlockedAt'] as String) : null,
        unlockMethod: json['unlockMethod'] as String?,
      );
}
