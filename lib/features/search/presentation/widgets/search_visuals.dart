import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/search_models.dart';

/// The hit's subtitle as a devotee should read it. `/search` sends a few
/// backend enums verbatim — a route's `RouteType`, a card's `CardRarity`
/// fallback, a page's `PageKind` — so those are localized (or, for pages,
/// dropped: the kind only repeats the title). Free text passes through.
String? searchSubtitle(AppLocalizations l10n, SearchHit hit) {
  final s = hit.subtitle;
  if (s == null || s.isEmpty) return null;
  return switch (hit.type) {
    SearchType.route => routeTypeMeta(l10n, s).label,
    SearchType.card when kRarityOrder.contains(s.toUpperCase()) => rarityLabel(l10n, s),
    SearchType.page => null,
    _ => s,
  };
}

/// Icon + accent colour per result type — shared by result tiles and chips so
/// the visual language stays consistent across the screen.
IconData searchTypeIcon(SearchType type) => switch (type) {
      SearchType.temple => AppIcons.temple,
      SearchType.route => AppIcons.route,
      SearchType.festival => AppIcons.calendar,
      SearchType.blog => AppIcons.article,
      SearchType.faq => AppIcons.help,
      SearchType.page => AppIcons.description,
      SearchType.city => AppIcons.location,
      SearchType.card => AppIcons.card,
      SearchType.achievement => AppIcons.achievement,
      SearchType.unknown => AppIcons.explore,
    };

Color searchTypeColor(BuildContext context, SearchType type) => switch (type) {
      SearchType.temple => context.scheme.primary,
      SearchType.route => context.colors.info,
      SearchType.festival => context.scheme.error,
      SearchType.blog => context.colors.gold,
      SearchType.faq => context.scheme.secondary,
      SearchType.page => context.colors.textSecondary,
      _ => context.scheme.primary,
    };
