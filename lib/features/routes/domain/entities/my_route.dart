/// A row from `GET /my/routes` — the user's cached progress on a route, with
/// the route summary embedded (name, cover, type, templeCount).
class MyRouteProgress {
  const MyRouteProgress({
    required this.routeId,
    required this.name,
    required this.slug,
    required this.type,
    required this.completedTemples,
    required this.totalTemples,
    required this.completionPercent,
    this.coverImage,
    this.completedAt,
  });

  final String routeId;
  final String name;
  final String slug;
  final String type;
  final int completedTemples;
  final int totalTemples;
  final double completionPercent;
  final String? coverImage;
  final DateTime? completedAt;

  int get percent => completionPercent.round();
  bool get isComplete => completedAt != null || (totalTemples > 0 && completedTemples >= totalTemples);
  bool get inProgress => !isComplete && completedTemples > 0;

  /// Saved / previewed but not yet started — the "Planned" bucket.
  bool get planned => !isComplete && completedTemples == 0;

  static int _i(Object? v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
  static double _d(Object? v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
  static DateTime? _dt(Object? v) => v is String ? DateTime.tryParse(v) : null;

  factory MyRouteProgress.fromJson(Map<String, dynamic> json) {
    final route = (json['route'] as Map?)?.cast<String, dynamic>() ?? const {};
    return MyRouteProgress(
      routeId: (json['routeId'] as String?) ?? (route['id'] as String?) ?? '',
      name: (route['name'] as String?) ?? '',
      slug: (route['slug'] as String?) ?? '',
      type: (route['type'] as String?) ?? 'CUSTOM',
      coverImage: route['coverImage'] as String?,
      completedTemples: _i(json['completedTemples']),
      totalTemples: _i(json['totalTemples']),
      completionPercent: _d(json['completionPercent']),
      completedAt: _dt(json['completedAt']),
    );
  }
}
