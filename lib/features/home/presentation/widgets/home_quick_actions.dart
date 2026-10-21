import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';

/// The round shortcuts on Home (Knowledge Hub, festivals, quotes, leaderboards).
enum HomeShortcut { knowledge, festivals, quotes, leaderboards }

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
