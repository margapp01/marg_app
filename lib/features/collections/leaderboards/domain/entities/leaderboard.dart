// Domain models for the public leaderboards (`/leaderboards/:category`) and
// the devotee's own rank (`/my/rank`). Defensive parsing: a reshaped payload
// degrades, never throws.

String? _s(Object? v) => v is String && v.isNotEmpty ? v : null;
int _i(Object? v) => v is int ? v : (v is num ? v.toInt() : int.tryParse('$v') ?? 0);
int? _iOrNull(Object? v) => v == null ? null : _i(v);

/// The public boards the backend exposes (`marg_backend` leaderboards routes).
enum LeaderboardBoard {
  global('global'),
  visits('visits'),
  cards('cards'),
  routes('routes'),
  achievements('achievements'),
  trust('trust'),
  referrals('referrals');

  const LeaderboardBoard(this.path);

  /// Path segment under `/leaderboards/`.
  final String path;
}

/// Backend `LeaderboardPeriod` values accepted by public boards. WEEKLY and
/// MONTHLY read the latest frozen snapshot (falling back to the live board).
enum LeaderboardWindow {
  weekly('WEEKLY'),
  monthly('MONTHLY'),
  allTime('ALL_TIME');

  const LeaderboardWindow(this.wire);
  final String wire;
}

class BoardEntry {
  const BoardEntry({
    required this.position,
    required this.userId,
    this.displayName,
    this.avatarUrl,
    this.points = 0,
    this.tier,
  });

  final int position;
  final String userId;
  final String? displayName;
  final String? avatarUrl;
  final int points;
  final String? tier;

  factory BoardEntry.fromJson(Map<String, dynamic> j) => BoardEntry(
        position: _i(j['position']),
        userId: _s(j['userId']) ?? '',
        displayName: _s(j['displayName']),
        avatarUrl: _s(j['avatarUrl']),
        points: _i(j['points']),
        tier: _s(j['tier']),
      );
}

/// A loaded slice of a board plus the total ranked count.
class BoardPage {
  const BoardPage({required this.entries, required this.total, this.loadingMore = false});

  final List<BoardEntry> entries;
  final int total;
  final bool loadingMore;

  bool get hasMore => entries.length < total;

  BoardPage copyWith({List<BoardEntry>? entries, int? total, bool? loadingMore}) => BoardPage(
        entries: entries ?? this.entries,
        total: total ?? this.total,
        loadingMore: loadingMore ?? this.loadingMore,
      );
}

/// `GET /my/rank` — global rank, tier, points and movement.
class MyRank {
  const MyRank({
    this.rank,
    this.tier = 'SEEKER',
    this.points = 0,
    this.nextTier,
    this.pointsToNextTier,
    this.stateRank,
    this.cityRank,
    this.movement,
    this.direction = 'SAME',
    this.bestRank,
  });

  final int? rank;
  final String tier;
  final int points;
  final String? nextTier;
  final int? pointsToNextTier;
  final int? stateRank;
  final int? cityRank;
  final int? movement;

  /// UP / DOWN / SAME / NEW.
  final String direction;
  final int? bestRank;

  factory MyRank.fromJson(Map<String, dynamic> j) => MyRank(
        rank: _iOrNull(j['rank']),
        tier: _s(j['tier']) ?? 'SEEKER',
        points: _i(j['points']),
        nextTier: _s(j['nextTier']),
        pointsToNextTier: _iOrNull(j['pointsToNextTier']),
        stateRank: _iOrNull(j['stateRank']),
        cityRank: _iOrNull(j['cityRank']),
        movement: _iOrNull(j['movement']),
        direction: _s(j['direction']) ?? 'SAME',
        bestRank: _iOrNull(j['bestRank']),
      );
}
