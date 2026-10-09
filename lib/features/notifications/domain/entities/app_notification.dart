// Domain models for the Notification Center & Activity Hub. Hand-written,
// defensive parsing (matches AuthUser / HomeDashboard). Every field degrades to
// null/false instead of throwing on a reshaped payload.

String? _s(Object? v) => v is String && v.isNotEmpty ? v : null;
bool _b(Object? v) => v == true;
DateTime? _dt(Object? v) => v is String ? DateTime.tryParse(v) : null;
Map<String, dynamic>? _m(Object? v) => v is Map<dynamic, dynamic> ? v.cast<String, dynamic>() : null;

/// The backend `NotificationType` union. `unknown` keeps forward-compat.
enum NotificationKind {
  visit('VISIT'),
  card('CARD'),
  achievement('ACHIEVEMENT'),
  route('ROUTE'),
  passport('PASSPORT'),
  trust('TRUST'),
  system('SYSTEM'),
  marketing('MARKETING'),
  unknown('');

  const NotificationKind(this.wire);
  final String wire;

  static NotificationKind fromWire(String? v) {
    for (final k in NotificationKind.values) {
      if (k.wire == v) return k;
    }
    return NotificationKind.unknown;
  }
}

/// One notification / activity record (`GET /my/notifications`).
class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.imageUrl,
    this.actionUrl,
    this.metadata,
    this.readAt,
  });

  final String id;
  final NotificationKind kind;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final String? imageUrl;
  final String? actionUrl;
  final Map<String, dynamic>? metadata;
  final DateTime? readAt;

  /// The deep-link "screen" hint from the notification metadata, if present.
  String? get screen => _s(metadata?['screen']);
  String? get entityId => _s(metadata?['entityId']);

  bool get hasDestination => (actionUrl != null && actionUrl!.isNotEmpty) || screen != null;

  AppNotification copyWith({bool? isRead, DateTime? readAt}) => AppNotification(
        id: id,
        kind: kind,
        title: title,
        message: message,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
        imageUrl: imageUrl,
        actionUrl: actionUrl,
        metadata: metadata,
        readAt: readAt ?? this.readAt,
      );

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: _s(j['id']) ?? '',
        kind: NotificationKind.fromWire(_s(j['type'])),
        title: _s(j['title']) ?? '',
        message: _s(j['message']) ?? '',
        isRead: _b(j['isRead']),
        createdAt: _dt(j['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
        imageUrl: _s(j['imageUrl']),
        actionUrl: _s(j['actionUrl']),
        metadata: _m(j['metadata']),
        readAt: _dt(j['readAt']),
      );
}

/// A page of notifications plus pagination cursor state.
class NotificationPage {
  const NotificationPage({required this.items, required this.page, required this.totalPages, required this.total});
  final List<AppNotification> items;
  final int page;
  final int totalPages;
  final int total;

  bool get hasMore => page < totalPages;

  factory NotificationPage.fromEnvelope(Map<String, dynamic> env) {
    final data = (env['data'] as List?) ?? const [];
    final p = _m(env['pagination']) ?? const {};
    return NotificationPage(
      items: data
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => AppNotification.fromJson(e.cast<String, dynamic>()))
          .toList(growable: false),
      page: (p['page'] as num?)?.toInt() ?? 1,
      totalPages: (p['totalPages'] as num?)?.toInt() ?? 1,
      total: (p['total'] as num?)?.toInt() ?? data.length,
    );
  }
}

/// A logical group of the eight real notification types (+ "all"). Used by both
/// the Center's tabs and the Activity Feed's filter — every value maps to a real
/// `NotificationType`, so nothing is fabricated.
enum NotificationFilter {
  all(null, 'ntAll'),
  visits(NotificationKind.visit, 'ntVisits'),
  achievements(NotificationKind.achievement, 'ntAchievements'),
  cards(NotificationKind.card, 'ntCards'),
  routes(NotificationKind.route, 'ntRoutes'),
  trust(NotificationKind.trust, 'ntTrust'),
  passport(NotificationKind.passport, 'ntPassport'),
  system(NotificationKind.system, 'ntSystem'),
  marketing(NotificationKind.marketing, 'ntUpdates');

  const NotificationFilter(this.kind, this.labelKey);
  final NotificationKind? kind;
  final String labelKey;

  bool matches(AppNotification n) => kind == null || n.kind == kind;
}
