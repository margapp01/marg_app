/// A user's progress along one pilgrimage route, combined from
/// `/temples/:id/my-status` (route name + counts) and `/routes/:id/progress`
/// (the next temple to visit). Powers the Passport-Updated and
/// Continue-Journey screens.
class VisitRouteProgress {
  const VisitRouteProgress({
    required this.routeId,
    required this.name,
    required this.completedTemples,
    required this.totalTemples,
    required this.percent,
    this.slug,
    this.nextTemple,
  });

  final String routeId;
  final String name;
  final int completedTemples;
  final int totalTemples;
  final int percent;
  final String? slug;
  final NextTempleRef? nextTemple;

  int get remainingTemples => (totalTemples - completedTemples).clamp(0, totalTemples);
  bool get isComplete => totalTemples > 0 && completedTemples >= totalTemples;

  VisitRouteProgress withNextTemple(NextTempleRef? next) => VisitRouteProgress(
        routeId: routeId,
        name: name,
        completedTemples: completedTemples,
        totalTemples: totalTemples,
        percent: percent,
        slug: slug,
        nextTemple: next,
      );

  static int _i(Object? v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

  /// From a `my-status.routes[]` row.
  factory VisitRouteProgress.fromMyStatusRow(Map<String, dynamic> json) => VisitRouteProgress(
        routeId: (json['routeId'] as String?) ?? '',
        name: (json['name'] as String?) ?? '',
        slug: json['slug'] as String?,
        completedTemples: _i(json['completedTemples']),
        totalTemples: _i(json['templeCount']),
        percent: _i(json['percent']),
      );
}

/// The next temple in a route (`/routes/:id/progress` → `nextTemple`).
class NextTempleRef {
  const NextTempleRef({required this.id, required this.name, required this.slug, this.position});

  final String id;
  final String name;
  final String slug;
  final int? position;

  static NextTempleRef? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final id = json['id'] as String?;
    final slug = json['slug'] as String?;
    if (id == null || slug == null) return null;
    return NextTempleRef(
      id: id,
      name: (json['name'] as String?) ?? '',
      slug: slug,
      position: (json['position'] as num?)?.toInt(),
    );
  }
}
