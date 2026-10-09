/// A user's live progress along a route (`GET /routes/:id/progress`).
class RouteProgress {
  const RouteProgress({
    required this.completedTemples,
    required this.totalTemples,
    required this.completionPercentage,
    this.nextTemple,
    this.remainingTempleIds = const {},
  });

  final int completedTemples;
  final int totalTemples;
  final double completionPercentage;
  final RouteNextTemple? nextTemple;

  /// Ids of temples not yet visited (from `remainingTemples[]`).
  final Set<String> remainingTempleIds;

  bool get isComplete => totalTemples > 0 && completedTemples >= totalTemples;
  int get percent => completionPercentage.round();

  static int _i(Object? v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
  static double _d(Object? v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;

  factory RouteProgress.fromJson(Map<String, dynamic> json) {
    final next = (json['nextTemple'] as Map?)?.cast<String, dynamic>();
    final remaining = (json['remainingTemples'] as List?) ?? const [];
    return RouteProgress(
      completedTemples: _i(json['completedTemples']),
      totalTemples: _i(json['totalTemples']),
      completionPercentage: _d(json['completionPercentage']),
      nextTemple: RouteNextTemple.fromJson(next),
      remainingTempleIds: remaining
          .whereType<Map<dynamic, dynamic>>()
          .map((m) => m['id'])
          .whereType<String>()
          .toSet(),
    );
  }
}

/// The next temple to visit on a route.
class RouteNextTemple {
  const RouteNextTemple({required this.id, required this.name, required this.slug, this.position});

  final String id;
  final String name;
  final String slug;
  final int? position;

  static RouteNextTemple? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final id = json['id'] as String?;
    final slug = json['slug'] as String?;
    if (id == null || slug == null) return null;
    return RouteNextTemple(
      id: id,
      name: (json['name'] as String?) ?? '',
      slug: slug,
      position: (json['position'] as num?)?.toInt(),
    );
  }
}
