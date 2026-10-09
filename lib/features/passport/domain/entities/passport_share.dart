/// The shareable passport summary (`GET /my/passport/share`).
class PassportShare {
  const PassportShare({
    required this.name,
    required this.trustScore,
    required this.passportCompletion,
    required this.visitedTemples,
    required this.cardsCollected,
    required this.routesCompleted,
    required this.shareText,
    this.profilePhoto,
    this.memberSince,
  });

  final String name;
  final int trustScore;
  final int passportCompletion;
  final int visitedTemples;
  final int cardsCollected;
  final int routesCompleted;
  final String shareText;
  final String? profilePhoto;
  final DateTime? memberSince;

  static int _i(Object? v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

  factory PassportShare.fromJson(Map<String, dynamic> json) {
    final stats = (json['stats'] as Map?)?.cast<String, dynamic>() ?? const {};
    final profile = (json['profileSummary'] as Map?)?.cast<String, dynamic>() ?? const {};
    return PassportShare(
      name: (profile['name'] as String?) ?? 'Pilgrim',
      profilePhoto: profile['profilePhoto'] as String?,
      memberSince: profile['memberSince'] is String ? DateTime.tryParse(profile['memberSince'] as String) : null,
      trustScore: _i(stats['trustScore']),
      passportCompletion: _i(stats['passportCompletion']),
      visitedTemples: _i(stats['visitedTemples']),
      cardsCollected: _i(stats['cardsCollected']),
      routesCompleted: _i(stats['routesCompleted']),
      shareText: (json['shareText'] as String?) ?? '',
    );
  }
}
