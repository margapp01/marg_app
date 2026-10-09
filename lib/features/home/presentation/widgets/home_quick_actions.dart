import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';

/// The Home quick actions (pastel tiles under the hero). Destination is
/// decided by the page.
enum HomeQuickAction { myRoutes, nearby, cards, achievements, passport, saved }

/// The secondary round shortcuts further down Home.
enum HomeShortcut { knowledge, festivals, quotes, leaderboards }

typedef _Tile = ({String? asset, IconData icon, String title, String hint, Color tint, Color accent});

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({required this.onAction, super.key});

  final ValueChanged<HomeQuickAction> onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final tiles = <HomeQuickAction, _Tile>{
      HomeQuickAction.myRoutes: (asset: BrandAssets.iconRoutes, icon: AppIcons.route, title: l10n.homeActionMyRoutes, hint: l10n.homeActionMyRoutesHint, tint: p.tileMint, accent: p.accentGreen),
      HomeQuickAction.nearby: (asset: BrandAssets.iconNearby, icon: AppIcons.nearby, title: l10n.homeActionNearby, hint: l10n.homeActionNearbyHint, tint: p.tileSky, accent: p.accentBlue),
      HomeQuickAction.cards: (asset: BrandAssets.iconCards, icon: AppIcons.card, title: l10n.homeActionCards, hint: l10n.homeActionCardsHint, tint: p.tileRose, accent: p.accentRose),
      HomeQuickAction.achievements: (asset: BrandAssets.iconAchievements, icon: AppIcons.achievement, title: l10n.homeActionAchievements, hint: l10n.homeActionAchievementsHint, tint: p.tileButter, accent: p.accentAmber),
      HomeQuickAction.passport: (asset: BrandAssets.iconPassport, icon: AppIcons.passport, title: l10n.homeActionPassport, hint: l10n.homeActionPassportHint, tint: p.tilePeach, accent: p.accentSaffron),
      HomeQuickAction.saved: (asset: BrandAssets.iconSaved, icon: AppIcons.favorite, title: l10n.homeActionSaved, hint: l10n.homeActionSavedHint, tint: p.tileLavender, accent: p.accentViolet),
    };
    final columns = context.responsive(compact: 3, medium: 6);
    final entries = tiles.entries.toList();

    // Rows of equal-height tiles (IntrinsicHeight keeps large text from clipping).
    return Column(
      children: [
        for (var r = 0; r < entries.length; r += columns) ...[
          if (r > 0) const Gap(AppSpacing.md),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var c = r; c < r + columns && c < entries.length; c++) ...[
                  if (c > r) const Gap.h(AppSpacing.md),
                  Expanded(
                    child: _ActionTile(tile: entries[c].value, onTap: () => onAction(entries[c].key))
                        .fadeIn(delay: AppDurations.stagger * c),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.tile, required this.onTap});

  final _Tile tile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tile.title,
      child: Material(
        color: tile.tint,
        borderRadius: AppRadius.lgAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.lgAll,
          child: Padding(
            padding: AppSpacing.allMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IllustratedIcon(
                  asset: tile.asset,
                  fallbackIcon: tile.icon,
                  color: tile.accent,
                  background: context.colors.card.withValues(alpha: 0.85),
                  size: 46,
                ),
                const Gap(AppSpacing.md),
                Text(
                  tile.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelMedium?.bold.withColor(context.scheme.secondary),
                ),
                const Gap(AppSpacing.xxs),
                Text(
                  tile.hint,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelSmall?.copyWith(color: context.colors.textSecondary, height: 1.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Four round shortcuts (Knowledge Hub, Festivals, Daily Quotes, Leaderboards).
class ShortcutsRow extends StatelessWidget {
  const ShortcutsRow({required this.onShortcut, super.key});

  final ValueChanged<HomeShortcut> onShortcut;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final items = <(HomeShortcut, String?, IconData, String, Color, Color)>[
      (HomeShortcut.knowledge, BrandAssets.iconKnowledge, AppIcons.blog, l10n.kbKnowledgeHub, p.tileLavender, p.accentViolet),
      (HomeShortcut.festivals, BrandAssets.iconFestivals, AppIcons.festival, l10n.kbFestivals, p.tilePeach, p.accentSaffron),
      (HomeShortcut.quotes, null, AppIcons.quote, l10n.kbDailyQuotes, p.tileButter, p.accentAmber),
      (HomeShortcut.leaderboards, null, AppIcons.leaderboard, l10n.titleLeaderboards, p.tileSky, p.accentBlue),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (id, asset, icon, label, tint, accent) in items)
          Expanded(
            child: Semantics(
              button: true,
              label: label,
              child: InkWell(
                onTap: () => onShortcut(id),
                borderRadius: AppRadius.mdAll,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Column(
                    children: [
                      IllustratedIcon(asset: asset, fallbackIcon: icon, color: accent, background: tint, size: 56),
                      const Gap(AppSpacing.sm),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.labelMedium?.semiBold,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
