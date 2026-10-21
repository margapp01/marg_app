import '../../app/localization/app_localizations.dart';

/// The words MARG shares with, in the user's language. Every message names
/// what was shared, then nudges the reader toward collecting Sacred Cards;
/// `ShareService` appends the link.
abstract final class ShareCopy {
  /// An unlocked card: a rarity-led headline, the card and its temple, the
  /// sharer's collection progress when known, and the invitation to collect.
  static String card(
    AppLocalizations l10n, {
    required String rarity,
    required String title,
    String? temple,
    int? owned,
    int? total,
  }) =>
      _lines([
        _cardHeadline(l10n, rarity),
        temple == null || temple.isEmpty ? '“$title”' : '“$title” · $temple',
        if (owned != null && total != null && total > 0) l10n.shCardProgress(owned, total),
        l10n.shCardCta,
      ]);

  /// The whole Sacred Card collection ("show off"): owned / total and the
  /// rarest card held, then the invitation to start collecting.
  static String collection(AppLocalizations l10n, {required int owned, required int total, String? rarest}) =>
      _lines([
        l10n.shCollection(owned, total),
        if (rarest != null) _cardHeadline(l10n, rarest),
        l10n.shCardCta,
      ]);

  static String passport(AppLocalizations l10n, {required int temples, required int cards, required int percent}) =>
      _lines([l10n.shPassport(temples, cards, percent), l10n.shPassportCta]);

  static String achievement(AppLocalizations l10n, {required String name}) =>
      _lines([l10n.shAchievement(name), l10n.shAchievementCta]);

  static String temple(AppLocalizations l10n, {required String name, String? place}) =>
      _lines(['🛕 $name${place == null || place.isEmpty ? '' : ' · $place'}', l10n.shTempleCta]);

  static String route(AppLocalizations l10n, {required String name}) => _lines([l10n.shRoute(name), l10n.shRouteCta]);

  static String routeCompleted(AppLocalizations l10n, {required String name}) =>
      _lines([l10n.shRouteCompleted(name), l10n.shRouteCompletedCta]);

  static String invite(AppLocalizations l10n) => l10n.shInvite;

  static String profile(AppLocalizations l10n, {required String name}) => l10n.shProfile(name);

  static String blog(AppLocalizations l10n, {required String title, String? excerpt}) =>
      _lines(['📖 $title', ?excerpt, l10n.shBlogCta]);

  static String festival(AppLocalizations l10n, {required String name, String? date}) =>
      _lines(['🪔 $name${date == null ? '' : ' · $date'}', l10n.shFestivalCta]);

  static String quote(AppLocalizations l10n, {required String text, String? attribution}) =>
      _lines(['“$text”${attribution == null || attribution.isEmpty ? '' : '\n— $attribution'}', l10n.shQuoteCta]);

  /// Announcements and notification activity: their own words + a nudge.
  static String activity(AppLocalizations l10n, {required String title, String? body}) =>
      _lines([title, ?body, l10n.shActivityCta]);

  static String _cardHeadline(AppLocalizations l10n, String rarity) => switch (rarity.toUpperCase()) {
        'MYTHIC' => l10n.shCardMythic,
        'LEGENDARY' => l10n.shCardLegendary,
        'EPIC' => l10n.shCardEpic,
        'RARE' => l10n.shCardRare,
        _ => l10n.shCardCommon,
      };

  static String _lines(List<String> lines) => lines.where((l) => l.trim().isNotEmpty).join('\n\n');
}
