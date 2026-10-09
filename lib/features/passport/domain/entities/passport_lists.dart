String? _place(String? city, String? state) {
  final parts = [city, state].whereType<String>().where((p) => p.isNotEmpty).toList();
  return parts.isEmpty ? null : parts.join(', ');
}

/// A visited temple (`GET /my/passport/temples`).
class TempleHistoryItem {
  const TempleHistoryItem({
    required this.id,
    required this.name,
    required this.slug,
    required this.status,
    this.visitedAt,
    this.imageUrl,
    this.place,
    this.state,
  });

  final String id;
  final String name;
  final String slug;

  /// Backend `VisitStatus` (VERIFIED / PENDING / FRAUD_SUSPECTED / …).
  final String status;
  final DateTime? visitedAt;
  final String? imageUrl;

  /// "City, State".
  final String? place;
  final String? state;

  bool get verified => status.toUpperCase() == 'VERIFIED';
  bool get pending => status.toUpperCase() == 'PENDING';

  factory TempleHistoryItem.fromJson(Map<String, dynamic> j) {
    final t = (j['temple'] as Map?)?.cast<String, dynamic>() ?? const {};
    return TempleHistoryItem(
      id: (t['id'] as String?) ?? '',
      name: (t['name'] as String?) ?? '',
      slug: (t['slug'] as String?) ?? '',
      status: (j['status'] as String?) ?? 'PENDING',
      visitedAt: j['visitedAt'] is String ? DateTime.tryParse(j['visitedAt'] as String) : null,
      imageUrl: t['imageUrl'] as String?,
      place: _place(t['city'] as String?, t['state'] as String?),
      state: t['state'] as String?,
    );
  }
}

/// A route in the user's history (`GET /my/passport/routes`).
class RouteHistoryItem {
  const RouteHistoryItem({
    required this.routeId,
    required this.name,
    required this.slug,
    required this.type,
    required this.completionPercent,
    this.coverImage,
    this.completedTemples = 0,
    this.totalTemples = 0,
    this.completedAt,
    this.nextTempleName,
  });

  final String routeId;
  final String name;
  final String slug;
  final String type;
  final double completionPercent;
  final String? coverImage;
  final int completedTemples;
  final int totalTemples;
  final DateTime? completedAt;

  /// The next temple on the route, while it's in progress.
  final String? nextTempleName;

  int get percent => completionPercent.round();
  bool get completed => completionPercent >= 100;
  bool get inProgress => completionPercent > 0 && completionPercent < 100;

  factory RouteHistoryItem.fromJson(Map<String, dynamic> j) {
    final r = (j['route'] as Map?)?.cast<String, dynamic>();
    return RouteHistoryItem(
      routeId: (j['routeId'] as String?) ?? (r?['id'] as String?) ?? '',
      name: (r?['name'] as String?) ?? '',
      slug: (r?['slug'] as String?) ?? '',
      type: (r?['type'] as String?) ?? 'CUSTOM',
      completionPercent: (j['completionPercent'] as num?)?.toDouble() ?? 0,
      coverImage: r?['coverImage'] as String?,
      completedTemples: (j['completedTemples'] as num?)?.toInt() ?? 0,
      totalTemples: (j['totalTemples'] as num?)?.toInt() ?? 0,
      completedAt: j['completedAt'] is String ? DateTime.tryParse(j['completedAt'] as String) : null,
      nextTempleName: (j['nextTemple'] as Map?)?['name'] as String?,
    );
  }
}

/// Owned cards grouped by rarity (`GET /my/passport/cards`).
class CardsSummary {
  const CardsSummary({required this.totalOwned, required this.counts, this.recent = const []});

  final int totalOwned;
  final Map<String, int> counts;
  final List<RecentCard> recent;

  int countOf(String rarity) => counts[rarity.toUpperCase()] ?? 0;

  factory CardsSummary.fromJson(Map<String, dynamic> j) {
    final counts = (j['counts'] as Map?)?.cast<String, dynamic>() ?? const {};
    final grouped = (j['grouped'] as Map?)?.cast<String, dynamic>() ?? const {};
    final recent = <RecentCard>[];
    for (final list in grouped.values) {
      if (list is! List) continue;
      for (final row in list.whereType<Map<dynamic, dynamic>>()) {
        recent.add(RecentCard.fromJson(row.cast<String, dynamic>()));
      }
    }
    recent.sort((a, b) => (b.unlockedAt ?? DateTime(2000)).compareTo(a.unlockedAt ?? DateTime(2000)));
    int c(String k) => (counts[k] as num?)?.toInt() ?? 0;
    return CardsSummary(
      totalOwned: (j['totalOwned'] as num?)?.toInt() ?? 0,
      counts: {
        'COMMON': c('common'), 'RARE': c('rare'), 'EPIC': c('epic'),
        'LEGENDARY': c('legendary'), 'MYTHIC': c('mythic'),
      },
      recent: recent,
    );
  }

  static const empty = CardsSummary(totalOwned: 0, counts: {'COMMON': 0, 'RARE': 0, 'EPIC': 0, 'LEGENDARY': 0, 'MYTHIC': 0});
}

class RecentCard {
  const RecentCard({
    required this.title,
    required this.rarity,
    this.cardId,
    this.userCardId,
    this.mintNumber,
    this.imageUrl,
    this.templeName,
    this.unlockedAt,
  });
  final String? cardId;
  final String? userCardId;
  final int? mintNumber;
  final String title;
  final String rarity;
  final String? imageUrl;
  final String? templeName;
  final DateTime? unlockedAt;

  factory RecentCard.fromJson(Map<String, dynamic> j) => RecentCard(
        cardId: j['cardId'] as String?,
        userCardId: j['userCardId'] as String?,
        mintNumber: (j['mintNumber'] as num?)?.toInt(),
        title: (j['title'] as String?) ?? '',
        rarity: (j['rarity'] as String?) ?? 'COMMON',
        imageUrl: j['imageUrl'] as String?,
        templeName: (j['temple'] as Map?)?.cast<String, dynamic>()['name'] as String?,
        unlockedAt: j['unlockedAt'] is String ? DateTime.tryParse(j['unlockedAt'] as String) : null,
      );
}

/// A series/season completion group (`GET /my/passport/series|seasons`).
class PassportGroup {
  const PassportGroup({
    required this.name,
    required this.ownedCards,
    required this.totalCards,
    required this.completionPercent,
    required this.completed,
    this.id = '',
  });
  final String id;
  final String name;
  final int ownedCards;
  final int totalCards;
  final double completionPercent;
  final bool completed;
  int get percent => completionPercent.round();

  factory PassportGroup.fromJson(Map<String, dynamic> j) => PassportGroup(
        id: (j['id'] as String?) ?? '',
        name: (j['name'] as String?) ?? '',
        ownedCards: (j['ownedCards'] as num?)?.toInt() ?? 0,
        totalCards: (j['totalCards'] as num?)?.toInt() ?? 0,
        completionPercent: (j['completionPercent'] as num?)?.toDouble() ?? 0,
        completed: j['completed'] == true,
      );
}

/// A visit location for the map (`GET /my/visits`).
class VisitPoint {
  const VisitPoint({
    required this.latitude,
    required this.longitude,
    required this.verified,
    this.name,
    this.slug,
    this.imageUrl,
    this.city,
    this.state,
  });
  final double latitude;
  final double longitude;
  final bool verified;
  final String? name;
  final String? slug;
  final String? imageUrl;
  final String? city;
  final String? state;

  String? get place => _place(city, state);
}
