/// Per-series or per-season collection progress
/// (`GET /my/passport/series` · `/seasons` → `CollectionProgress[]`).
class CollectionGroup {
  const CollectionGroup({
    required this.id,
    required this.name,
    required this.slug,
    required this.totalCards,
    required this.ownedCards,
    required this.completionPercent,
    required this.completed,
    this.missingCards = const [],
  });

  final String id;
  final String name;
  final String slug;
  final int totalCards;
  final int ownedCards;
  final double completionPercent;
  final bool completed;
  final List<GroupCardRef> missingCards;

  int get percent => completionPercent.round();

  static int _i(Object? v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
  static double _d(Object? v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;

  factory CollectionGroup.fromJson(Map<String, dynamic> json) => CollectionGroup(
        id: (json['id'] as String?) ?? '',
        name: (json['name'] as String?) ?? '',
        slug: (json['slug'] as String?) ?? '',
        totalCards: _i(json['totalCards']),
        ownedCards: _i(json['ownedCards']),
        completionPercent: _d(json['completionPercent']),
        completed: json['completed'] == true,
        missingCards: ((json['missingCards'] as List?) ?? const [])
            .whereType<Map<dynamic, dynamic>>()
            .map((m) => GroupCardRef.fromJson(m.cast<String, dynamic>()))
            .toList(growable: false),
      );
}

class GroupCardRef {
  const GroupCardRef({required this.id, required this.title, required this.rarity, this.templeName});

  final String id;
  final String title;
  final String rarity;
  final String? templeName;

  factory GroupCardRef.fromJson(Map<String, dynamic> json) {
    final temple = (json['temple'] as Map?)?.cast<String, dynamic>();
    return GroupCardRef(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      rarity: (json['rarity'] as String?) ?? 'COMMON',
      templeName: temple?['name'] as String?,
    );
  }
}
