// `GET/PATCH /my/notification-preferences` — the 11 real preference toggles.
// The UI exposes only these; there is no leaderboard/daily-quote toggle on the
// backend, so those mockup rows are intentionally not shown.

bool _b(Object? v, {bool or = false}) => v is bool ? v : or;

class NotificationPreferences {
  const NotificationPreferences({
    required this.pushEnabled,
    required this.emailEnabled,
    required this.smsEnabled,
    required this.whatsappEnabled,
    required this.achievementNotifications,
    required this.cardNotifications,
    required this.routeNotifications,
    required this.templeUpdateNotifications,
    required this.festivalNotifications,
    required this.nearbyAlerts,
    required this.marketingNotifications,
  });

  final bool pushEnabled;
  final bool emailEnabled;
  final bool smsEnabled;
  final bool whatsappEnabled;
  final bool achievementNotifications;
  final bool cardNotifications;
  final bool routeNotifications;
  final bool templeUpdateNotifications;
  final bool festivalNotifications;
  final bool nearbyAlerts;
  final bool marketingNotifications;

  /// The toggles the app offers (SMS / WhatsApp are not delivered yet).
  List<bool> get _offered => [
        pushEnabled,
        emailEnabled,
        achievementNotifications,
        cardNotifications,
        routeNotifications,
        templeUpdateNotifications,
        festivalNotifications,
        nearbyAlerts,
        marketingNotifications,
      ];

  /// How many of the [total] toggles are on (the settings header summary).
  int get enabledCount => _offered.where((on) => on).length;
  int get total => _offered.length;

  factory NotificationPreferences.fromJson(Map<String, dynamic> j) => NotificationPreferences(
        pushEnabled: _b(j['pushEnabled'], or: true),
        emailEnabled: _b(j['emailEnabled'], or: true),
        smsEnabled: _b(j['smsEnabled']),
        whatsappEnabled: _b(j['whatsappEnabled']),
        achievementNotifications: _b(j['achievementNotifications'], or: true),
        cardNotifications: _b(j['cardNotifications'], or: true),
        routeNotifications: _b(j['routeNotifications'], or: true),
        templeUpdateNotifications: _b(j['templeUpdateNotifications'], or: true),
        festivalNotifications: _b(j['festivalNotifications'], or: true),
        nearbyAlerts: _b(j['nearbyAlerts'], or: true),
        marketingNotifications: _b(j['marketingNotifications']),
      );
}
