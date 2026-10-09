import 'package:flutter/widgets.dart';

import '../../../../../app/localization/app_localizations.dart';
import '../../../../../shared/design_system.dart';

/// An area of interest a devotee can opt into during onboarding.
///
/// [wire] mirrors the backend `UserInterestType` enum exactly — never change
/// these values without matching `prisma/schema.prisma`.
enum SetupInterest {
  templeVisits('Temple Visits', AppIcons.temple, 'TEMPLE_VISITS'),
  routeCompletion('Route Completion', AppIcons.route, 'ROUTE_COMPLETION'),
  pujaPandit('Puja & Pandit', AppIcons.pandit, 'PUJA_PANDIT'),
  collectCards('Collect Cards', AppIcons.card, 'COLLECT_CARDS'),
  achievements('Achievements', AppIcons.achievement, 'ACHIEVEMENTS'),
  eventsFestivals('Events & Festivals', AppIcons.calendar, 'EVENTS_FESTIVALS'),
  nearbyTemples('Nearby Temples', AppIcons.nearby, 'NEARBY_TEMPLES'),
  others('Others', AppIcons.explore, 'OTHERS');

  const SetupInterest(this.label, this.icon, this.wire);

  final String label;
  final IconData icon;

  /// Backend `UserInterestType` value.
  final String wire;

  /// Interests offered during onboarding. [pujaPandit] is excluded because
  /// MARG v1 ships no puja/pandit experience — the value stays in the enum so
  /// a previously-saved `PUJA_PANDIT` still parses.
  static List<SetupInterest> get selectable =>
      values.where((i) => i != SetupInterest.pujaPandit).toList(growable: false);

  static SetupInterest? fromWire(String wire) {
    for (final i in SetupInterest.values) {
      if (i.wire == wire) return i;
    }
    return null;
  }
}

/// The app language chosen in preferences. [wire] mirrors backend `Language`.
enum SetupLanguage {
  english('English', 'EN'),
  hindi('Hindi', 'HI');

  const SetupLanguage(this.label, this.wire);

  final String label;

  /// Backend `Language` value.
  final String wire;

  static SetupLanguage fromWire(String? wire) => SetupLanguage.values
      .firstWhere((l) => l.wire == wire, orElse: () => SetupLanguage.english);
}

/// Self-reported gender. [wire] mirrors the backend `Gender` enum.
enum SetupGender {
  male('Male', 'MALE'),
  female('Female', 'FEMALE'),
  other('Other', 'OTHER'),
  preferNotToSay('Prefer not to say', 'PREFER_NOT_TO_SAY');

  const SetupGender(this.label, this.wire);

  final String label;

  /// Backend `Gender` value.
  final String wire;

  static SetupGender? fromWire(String? wire) {
    if (wire == null) return null;
    for (final g in SetupGender.values) {
      if (g.wire == wire) return g;
    }
    return null;
  }
}

/// A notification category; onboarding submits the defaults, the devotee
/// tunes them later in settings.
enum SetupNotification {
  templeRoute(
    'Temple & Route Updates',
    'Get updates about temples, routes and new features',
    AppIcons.notifications,
  ),
  achievements(
    'Achievements & Cards',
    'Get notified when you unlock cards and achievements',
    AppIcons.shield,
  ),
  events(
    'Events & Festivals',
    'Stay updated on important events and festivals',
    AppIcons.calendar,
  ),
  marketing(
    'Marketing (Optional)',
    'Receive occasional updates and offers',
    AppIcons.mail,
  );

  const SetupNotification(this.title, this.subtitle, this.icon);

  final String title;
  final String subtitle;
  final IconData icon;

  /// Everything except marketing is on by default.
  static Set<SetupNotification> get defaults =>
      {templeRoute, achievements, events};

  /// Maps the four UI toggles onto the backend `NotificationPreference`
  /// boolean flags (`PATCH /my/notification-preferences`). Categories the UI
  /// doesn't surface (channels, nearby alerts) keep their server defaults.
  static Map<String, bool> toPreferencesBody(Set<SetupNotification> selected) {
    final temple = selected.contains(templeRoute);
    final achieve = selected.contains(achievements);
    return {
      'routeNotifications': temple,
      'templeUpdateNotifications': temple,
      'achievementNotifications': achieve,
      'cardNotifications': achieve,
      'festivalNotifications': selected.contains(events),
      'marketingNotifications': selected.contains(marketing),
    };
  }
}

// ── Localized display labels ────────────────────────────────────────────────
// The `label`/`title` fields above stay as the English source of truth (and are
// what the wire values were authored against); the UI renders these instead so
// onboarding is fully bilingual.

extension SetupInterestL10n on SetupInterest {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        SetupInterest.templeVisits => l10n.suInterestTempleVisits,
        SetupInterest.routeCompletion => l10n.suInterestRouteCompletion,
        SetupInterest.pujaPandit => l10n.suInterestPujaPandit,
        SetupInterest.collectCards => l10n.suInterestCollectCards,
        SetupInterest.achievements => l10n.suInterestAchievements,
        SetupInterest.eventsFestivals => l10n.suInterestEventsFestivals,
        SetupInterest.nearbyTemples => l10n.suInterestNearbyTemples,
        SetupInterest.others => l10n.suInterestOthers,
      };
}

extension SetupInterestDetails on SetupInterest {
  String localizedSubtitle(AppLocalizations l10n) => switch (this) {
        SetupInterest.templeVisits => l10n.suInterestTempleVisitsSub,
        SetupInterest.routeCompletion => l10n.suInterestRouteCompletionSub,
        SetupInterest.pujaPandit => l10n.suInterestPujaPanditSub,
        SetupInterest.collectCards => l10n.suInterestCollectCardsSub,
        SetupInterest.achievements => l10n.suInterestAchievementsSub,
        SetupInterest.eventsFestivals => l10n.suInterestEventsFestivalsSub,
        SetupInterest.nearbyTemples => l10n.suInterestNearbyTemplesSub,
        SetupInterest.others => l10n.suInterestOthersSub,
      };
}

extension SetupGenderIcon on SetupGender {
  IconData get icon => switch (this) {
        SetupGender.male => AppIcons.male,
        SetupGender.female => AppIcons.female,
        SetupGender.other => AppIcons.genderOther,
        SetupGender.preferNotToSay => AppIcons.preferNotToSay,
      };
}

extension SetupLanguageL10n on SetupLanguage {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        SetupLanguage.english => l10n.suLangEnglish,
        SetupLanguage.hindi => l10n.suLangHindi,
      };
}

extension SetupGenderL10n on SetupGender {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        SetupGender.male => l10n.suGenderMale,
        SetupGender.female => l10n.suGenderFemale,
        SetupGender.other => l10n.suGenderOther,
        SetupGender.preferNotToSay => l10n.suGenderPreferNot,
      };
}

extension SetupNotificationL10n on SetupNotification {
  String localizedTitle(AppLocalizations l10n) => switch (this) {
        SetupNotification.templeRoute => l10n.suNotifTempleTitle,
        SetupNotification.achievements => l10n.suNotifAchievementsTitle,
        SetupNotification.events => l10n.suNotifEventsTitle,
        SetupNotification.marketing => l10n.suNotifMarketingTitle,
      };

  String localizedSubtitle(AppLocalizations l10n) => switch (this) {
        SetupNotification.templeRoute => l10n.suNotifTempleSubtitle,
        SetupNotification.achievements => l10n.suNotifAchievementsSubtitle,
        SetupNotification.events => l10n.suNotifEventsSubtitle,
        SetupNotification.marketing => l10n.suNotifMarketingSubtitle,
      };
}
