// Immutable domain models for `GET /home/dashboard` (Phase 21.4 frozen
// contract). Hand-written `fromJson` matches the app's established model
// convention (see AuthUser) — no codegen. Every parser is defensive so a
// missing or reshaped section degrades to null/[] instead of throwing.

import '../../../../core/models/temple_summary.dart';

export '../../../../core/models/temple_summary.dart' show OpenStatus;

String? _str(Object? v) => v is String && v.isNotEmpty ? v : null;
int _int(Object? v) => v is int ? v : (v is num ? v.toInt() : int.tryParse('$v') ?? 0);
double _dbl(Object? v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
DateTime? _date(Object? v) => v is String ? DateTime.tryParse(v) : null;

Map<String, dynamic>? _map(Object? v) =>
    v is Map<dynamic, dynamic> ? v.cast<String, dynamic>() : null;

List<T> _list<T>(Object? v, T Function(Map<String, dynamic>) fromMap) =>
    v is List
        ? v
            .whereType<Map<dynamic, dynamic>>()
            .map((e) => fromMap(e.cast<String, dynamic>()))
            .toList(growable: false)
        : const [];

/// Top-level Home payload. Sections are nullable/empty-safe so partial backend
/// failures never break the screen.
class HomeDashboard {
  const HomeDashboard({
    required this.profile,
    required this.greeting,
    required this.banners,
    required this.dailyQuote,
    required this.passport,
    required this.leaderboard,
    required this.referral,
    required this.unreadNotifications,
    required this.recentActivity,
    required this.upcomingFestivals,
    required this.nearbyTemples,
    required this.promotions,
    required this.blogs,
    this.yatraProgress = const [],
    this.popularTemples = const [],
    this.recentCards = const [],
    this.achievements = const [],
    this.leaderboardTop = const LeaderboardTop(),
    this.templeIntelligence = const [],
    this.quotes = const [],
  });

  final HomeProfile? profile;
  final HomeGreeting greeting;
  final List<HomeBanner> banners;
  final DailyQuote? dailyQuote;
  final PassportSummary? passport;
  final LeaderboardRank? leaderboard;
  final ReferralSummary? referral;
  final int unreadNotifications;
  final List<HomeActivity> recentActivity;
  final List<HomeFestival> upcomingFestivals;
  final List<NearbyTemple> nearbyTemples;
  final List<HomePromotion> promotions;
  final List<HomeBlog> blogs;
  final List<YatraGroupProgress> yatraProgress;

  /// Most-viewed temples — the fallback when GPS is unavailable.
  final List<NearbyTemple> popularTemples;
  final List<HomeCard> recentCards;
  final List<HomeAchievement> achievements;
  final LeaderboardTop leaderboardTop;
  final List<TempleIntelligence> templeIntelligence;

  /// Recent published quotes for the Daily Inspiration carousel.
  final List<DailyQuote> quotes;

  HomeBanner? get featuredBanner => banners.isEmpty ? null : banners.first;

  /// Today's quote first, then the rest of the carousel (no duplicates).
  List<DailyQuote> get inspiration => [
        ?dailyQuote,
        ...quotes.where((q) => q.id != dailyQuote?.id),
      ];

  factory HomeDashboard.fromJson(Map<String, dynamic> json) {
    final explore = _map(json['explore']) ?? const {};
    return HomeDashboard(
      profile: _map(json['profile']) == null
          ? null
          : HomeProfile.fromJson(_map(json['profile'])!),
      greeting: HomeGreeting.fromJson(_map(json['greeting']) ?? const {}),
      banners: _list(json['banners'], HomeBanner.fromJson),
      dailyQuote: _map(json['dailyQuote']) == null
          ? null
          : DailyQuote.fromJson(_map(json['dailyQuote'])!),
      passport: _map(json['passport']) == null
          ? null
          : PassportSummary.fromJson(_map(json['passport'])!),
      leaderboard: _map(json['leaderboardRank']) == null
          ? null
          : LeaderboardRank.fromJson(_map(json['leaderboardRank'])!),
      referral: _map(json['referral']) == null
          ? null
          : ReferralSummary.fromJson(_map(json['referral'])!),
      unreadNotifications: _int(json['unreadNotifications']),
      recentActivity: _list(json['recentActivity'], HomeActivity.fromJson),
      upcomingFestivals: _list(json['upcomingFestivals'], HomeFestival.fromJson),
      nearbyTemples: _list(json['nearbyTemples'], NearbyTemple.fromJson),
      promotions: _list(explore['promotions'], HomePromotion.fromJson),
      blogs: _list(explore['blogs'], HomeBlog.fromJson),
      yatraProgress: _list(json['yatraProgress'], YatraGroupProgress.fromJson),
      popularTemples: _list(json['popularTemples'], NearbyTemple.fromJson),
      recentCards: _list(json['recentCards'], HomeCard.fromJson),
      achievements: _list(json['achievements'], HomeAchievement.fromJson),
      leaderboardTop: LeaderboardTop.fromJson(_map(json['leaderboardTop']) ?? const {}),
      templeIntelligence: _list(json['templeIntelligence'], TempleIntelligence.fromJson),
      quotes: _list(json['quotes'], DailyQuote.fromJson),
    );
  }
}

class HomeProfile {
  const HomeProfile({
    required this.id,
    this.name,
    this.profilePhoto,
    this.city,
    this.preferredLanguage = 'EN',
  });

  final String id;
  final String? name;
  final String? profilePhoto;
  final String? city;
  final String preferredLanguage;

  factory HomeProfile.fromJson(Map<String, dynamic> j) => HomeProfile(
        id: _str(j['id']) ?? '',
        name: _str(j['name']),
        profilePhoto: _str(j['profilePhoto']),
        city: _str(j['city']),
        preferredLanguage: _str(j['preferredLanguage']) ?? 'EN',
      );
}

/// `timeOfDay` is a backend enum key (MORNING/AFTERNOON/EVENING); the UI maps
/// it to a localized greeting.
class HomeGreeting {
  const HomeGreeting({this.salutation = 'Namaste', this.timeOfDay = 'MORNING'});

  final String salutation;
  final String timeOfDay;

  factory HomeGreeting.fromJson(Map<String, dynamic> j) => HomeGreeting(
        salutation: _str(j['salutation']) ?? 'Namaste',
        timeOfDay: _str(j['timeOfDay']) ?? 'MORNING',
      );
}

class HomeBanner {
  const HomeBanner({
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.ctaLabel,
    this.ctaUrl,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String? ctaLabel;
  final String? ctaUrl;

  factory HomeBanner.fromJson(Map<String, dynamic> j) => HomeBanner(
        id: _str(j['id']) ?? '',
        title: _str(j['title']) ?? '',
        subtitle: _str(j['subtitle']),
        imageUrl: _str(j['imageUrl']),
        ctaLabel: _str(j['ctaLabel']),
        ctaUrl: _str(j['ctaUrl']),
      );
}

class DailyQuote {
  const DailyQuote({
    required this.id,
    required this.text,
    this.textHi,
    this.reference,
    this.author,
    this.source,
  });

  final String id;
  final String text;
  final String? textHi;
  final String? reference;
  final String? author;
  final String? source;

  factory DailyQuote.fromJson(Map<String, dynamic> j) => DailyQuote(
        id: _str(j['id']) ?? '',
        text: _str(j['text']) ?? '',
        textHi: _str(j['textHi']),
        reference: _str(j['reference']),
        author: _str(j['author']),
        source: _str(j['source']),
      );
}

/// Weighted passport completion + the three real pillars the backend returns
/// (temples / cards / routes).
class PassportSummary {
  const PassportSummary({
    required this.completion,
    required this.templesPercent,
    required this.cardsPercent,
    required this.routesPercent,
    required this.visitedTemples,
    required this.cardsCollected,
    required this.routesCompleted,
    required this.trustScore,
  });

  final double completion;
  final double templesPercent;
  final double cardsPercent;
  final double routesPercent;
  final int visitedTemples;
  final int cardsCollected;
  final int routesCompleted;
  final int trustScore;

  factory PassportSummary.fromJson(Map<String, dynamic> j) {
    final stats = _map(j['statistics']) ?? const {};
    final completion = _map(j['completion']) ?? const {};
    final breakdown = _map(completion['breakdown']) ?? const {};
    return PassportSummary(
      completion: _dbl(completion['passportCompletion']),
      templesPercent: _dbl(breakdown['templesPercent']),
      cardsPercent: _dbl(breakdown['cardsPercent']),
      routesPercent: _dbl(breakdown['routesPercent']),
      visitedTemples: _int(stats['totalVisitedTemples']),
      cardsCollected: _int(stats['cardsCollected']),
      routesCompleted: _int(stats['routesCompleted']),
      trustScore: _int(j['trustScore'] ?? stats['trustScore']),
    );
  }
}

class LeaderboardRank {
  const LeaderboardRank({
    this.rank,
    this.tier,
    required this.points,
    this.movement,
    this.direction = 'SAME',
  });

  final int? rank;
  final String? tier;
  final int points;
  final int? movement;
  final String direction;

  factory LeaderboardRank.fromJson(Map<String, dynamic> j) => LeaderboardRank(
        rank: j['rank'] == null ? null : _int(j['rank']),
        tier: _str(j['tier']),
        points: _int(j['points']),
        movement: j['movement'] == null ? null : _int(j['movement']),
        direction: _str(j['direction']) ?? 'SAME',
      );
}

class ReferralSummary {
  const ReferralSummary({this.code, required this.successfulReferrals});

  final String? code;
  final int successfulReferrals;

  factory ReferralSummary.fromJson(Map<String, dynamic> j) => ReferralSummary(
        code: _str(j['code']),
        successfulReferrals: _int(j['successfulReferrals']),
      );
}

class HomeActivity {
  const HomeActivity({
    required this.id,
    required this.type,
    required this.title,
    this.createdAt,
    this.href,
    this.imageUrl,
    this.points,
  });

  final String id;
  final String type;
  final String title;
  final DateTime? createdAt;
  final String? href;
  final String? imageUrl;

  /// Leaderboard points the action earned (null when none / not fixed).
  final int? points;

  factory HomeActivity.fromJson(Map<String, dynamic> j) => HomeActivity(
        id: _str(j['id']) ?? '',
        type: _str(j['type']) ?? 'VISIT',
        title: _str(j['title']) ?? '',
        createdAt: _date(j['createdAt']),
        href: _str(j['href']),
        imageUrl: _str(j['imageUrl']),
        points: j['points'] == null ? null : _int(j['points']),
      );
}

class HomeFestival {
  const HomeFestival({
    required this.id,
    required this.name,
    required this.slug,
    this.deity,
    this.imageUrl,
    this.scope,
    this.startDate,
  });

  final String id;
  final String name;
  final String slug;
  final String? deity;
  final String? imageUrl;
  final String? scope;
  final DateTime? startDate;

  factory HomeFestival.fromJson(Map<String, dynamic> j) => HomeFestival(
        id: _str(j['id']) ?? '',
        name: _str(j['name']) ?? '',
        slug: _str(j['slug']) ?? '',
        deity: _str(j['deity']),
        imageUrl: _str(j['imageUrl']),
        scope: _str(j['scope']),
        startDate: _date(j['startDate']),
      );
}

/// A temple card on Home — nearby (with distance) or popular (no distance).
class NearbyTemple {
  const NearbyTemple({
    required this.id,
    required this.name,
    required this.slug,
    this.deity,
    this.city,
    this.state,
    this.imageUrl,
    this.ratingAverage = 0,
    this.ratingCount = 0,
    this.openStatus = const OpenStatus(),
    this.distanceMeters = 0,
    this.distanceKm = 0,
    this.formattedDistance = '',
    this.travelTimeMinutes,
  });

  final String id;
  final String name;
  final String slug;
  final String? deity;
  final String? city;
  final String? state;
  final String? imageUrl;
  final double ratingAverage;
  final int ratingCount;
  final OpenStatus openStatus;
  final int distanceMeters;
  final double distanceKm;

  /// Display distance ("850 m"); empty for popular temples.
  final String formattedDistance;
  final int? travelTimeMinutes;

  /// "Varanasi, Uttar Pradesh" (whichever parts are known).
  String get place => [?city, ?state].join(', ');

  factory NearbyTemple.fromJson(Map<String, dynamic> j) => NearbyTemple(
        id: _str(j['id']) ?? '',
        name: _str(j['name']) ?? '',
        slug: _str(j['slug']) ?? '',
        deity: _str(j['deity']),
        city: _str(j['city']),
        state: _str(j['state']),
        imageUrl: _str(j['imageUrl']),
        ratingAverage: _dbl(j['ratingAverage']),
        ratingCount: _int(j['ratingCount']),
        openStatus: OpenStatus.fromJson(_map(j['openStatus'])),
        distanceMeters: _int(j['distanceMeters']),
        distanceKm: _dbl(j['distanceKm']),
        formattedDistance: _str(j['formattedDistance']) ?? '',
        travelTimeMinutes:
            j['travelTimeMinutes'] == null ? null : _int(j['travelTimeMinutes']),
      );
}

/// Verified coverage of one sacred-site family ("Jyotirlingas 6 / 12").
/// [group] is a backend `RouteType` key or `OTHER`.
class YatraGroupProgress {
  const YatraGroupProgress({required this.group, required this.completed, required this.total});

  final String group;
  final int completed;
  final int total;

  double get fraction => total <= 0 ? 0 : (completed / total).clamp(0, 1).toDouble();

  factory YatraGroupProgress.fromJson(Map<String, dynamic> j) => YatraGroupProgress(
        group: _str(j['group']) ?? 'OTHER',
        completed: _int(j['completed']),
        total: _int(j['total']),
      );
}

/// A recently unlocked sacred card.
class HomeCard {
  const HomeCard({required this.id, required this.title, this.imageUrl, this.rarity = 'COMMON'});

  final String id;
  final String title;
  final String? imageUrl;
  final String rarity;

  factory HomeCard.fromJson(Map<String, dynamic> j) => HomeCard(
        id: _str(j['id']) ?? '',
        title: _str(j['title']) ?? '',
        imageUrl: _str(j['imageUrl']),
        rarity: _str(j['rarity']) ?? 'COMMON',
      );
}

/// An earned or in-progress achievement highlight.
class HomeAchievement {
  const HomeAchievement({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.earned = false,
    this.current = 0,
    this.target = 1,
  });

  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final bool earned;
  final int current;
  final int target;

  factory HomeAchievement.fromJson(Map<String, dynamic> j) => HomeAchievement(
        id: _str(j['id']) ?? '',
        name: _str(j['name']) ?? '',
        description: _str(j['description']),
        imageUrl: _str(j['imageUrl']),
        earned: j['earned'] == true,
        current: _int(j['current']),
        target: j['target'] == null ? 1 : _int(j['target']),
      );
}

/// Top of the global board for the "This Month" / "All Time" podium.
class LeaderboardTop {
  const LeaderboardTop({this.monthly = const [], this.allTime = const []});

  final List<LeaderboardEntry> monthly;
  final List<LeaderboardEntry> allTime;

  factory LeaderboardTop.fromJson(Map<String, dynamic> j) => LeaderboardTop(
        monthly: _list(j['monthly'], LeaderboardEntry.fromJson),
        allTime: _list(j['allTime'], LeaderboardEntry.fromJson),
      );
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.position,
    required this.userId,
    this.displayName,
    this.avatarUrl,
    this.points = 0,
  });

  final int position;
  final String userId;
  final String? displayName;
  final String? avatarUrl;
  final int points;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> j) => LeaderboardEntry(
        position: _int(j['position']),
        userId: _str(j['userId']) ?? '',
        displayName: _str(j['displayName']),
        avatarUrl: _str(j['avatarUrl']),
        points: _int(j['points']),
      );
}

/// Live crowd + today's quietest hour for one temple.
class TempleIntelligence {
  const TempleIntelligence({
    required this.temple,
    required this.crowdLevel,
    this.occupancyPercent = 0,
    this.estimatedWaitMinutes,
    this.bestHour,
  });

  final NearbyTemple temple;

  /// Backend `CrowdLevel` key (LOW / MODERATE / HIGH / VERY_HIGH / FULL).
  final String crowdLevel;
  final int occupancyPercent;
  final int? estimatedWaitMinutes;

  /// Quietest hour today (0–23, IST), or null without history.
  final int? bestHour;

  factory TempleIntelligence.fromJson(Map<String, dynamic> j) => TempleIntelligence(
        temple: NearbyTemple.fromJson(_map(j['temple']) ?? const {}),
        crowdLevel: _str(j['crowdLevel']) ?? 'LOW',
        occupancyPercent: _int(j['occupancyPercent']),
        estimatedWaitMinutes:
            j['estimatedWaitMinutes'] == null ? null : _int(j['estimatedWaitMinutes']),
        bestHour: j['bestHour'] == null ? null : _int(j['bestHour']),
      );
}

class HomePromotion {
  const HomePromotion({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.ctaUrl,
  });

  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? ctaUrl;

  factory HomePromotion.fromJson(Map<String, dynamic> j) => HomePromotion(
        id: _str(j['id']) ?? '',
        title: _str(j['title']) ?? '',
        description: _str(j['description']),
        imageUrl: _str(j['imageUrl']),
        ctaUrl: _str(j['ctaUrl']),
      );
}

class HomeBlog {
  const HomeBlog({
    required this.id,
    required this.title,
    required this.slug,
    this.excerpt,
    this.coverImageUrl,
    this.category,
  });

  final String id;
  final String title;
  final String slug;
  final String? excerpt;
  final String? coverImageUrl;
  final String? category;

  factory HomeBlog.fromJson(Map<String, dynamic> j) => HomeBlog(
        id: _str(j['id']) ?? '',
        title: _str(j['title']) ?? '',
        slug: _str(j['slug']) ?? '',
        excerpt: _str(j['excerpt']),
        coverImageUrl: _str(j['coverImageUrl']),
        category: _str(j['category']),
      );
}
