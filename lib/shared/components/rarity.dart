import 'package:flutter/widgets.dart';

import '../../app/localization/app_localizations.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';

/// The backend `CardRarity` scale, in ascending order.
const List<String> kRarityOrder = ['COMMON', 'RARE', 'EPIC', 'LEGENDARY', 'MYTHIC'];

/// Highlight colour for a card rarity — shared across cards, visits and routes
/// so a "Legendary" always looks the same everywhere.
Color rarityColor(BuildContext context, String rarity) {
  switch (rarity.toUpperCase()) {
    case 'MYTHIC':
      return context.palette.accentRose;
    case 'LEGENDARY':
      return context.colors.gold;
    case 'EPIC':
      return context.palette.accentViolet;
    case 'RARE':
      return context.colors.info;
    default:
      return context.colors.textSecondary;
  }
}

/// Localized rarity label.
String rarityLabel(AppLocalizations l10n, String rarity) {
  switch (rarity.toUpperCase()) {
    case 'MYTHIC':
      return l10n.scRarityMythic;
    case 'LEGENDARY':
      return l10n.scRarityLegendary;
    case 'EPIC':
      return l10n.scRarityEpic;
    case 'RARE':
      return l10n.scRarityRare;
    default:
      return l10n.scRarityCommon;
  }
}

/// A small rarity badge (tinted pill).
class RarityChip extends StatelessWidget {
  const RarityChip({required this.rarity, this.compact = false, super.key});

  final String rarity;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = rarityColor(context, rarity);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.xs : AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.15), borderRadius: AppRadius.fullAll),
      child: Text(rarityLabel(AppLocalizations.of(context), rarity), style: context.overline.copyWith(color: c)),
    );
  }
}

/// The rarity banner across the foot of a showcase (card face, medal hero):
/// rarity-coloured, gold-rimmed, letter-spaced caps.
class RarityRibbon extends StatelessWidget {
  const RarityRibbon({required this.rarity, super.key});

  final String rarity;

  @override
  Widget build(BuildContext context) {
    final c = rarityColor(context, rarity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xxs + 1),
      decoration: BoxDecoration(
        color: c,
        borderRadius: AppRadius.fullAll,
        border: Border.all(color: context.colors.gold, width: 1.4),
        boxShadow: [BoxShadow(color: c.withValues(alpha: 0.5), blurRadius: 10)],
      ),
      child: Text(
        rarityLabel(AppLocalizations.of(context), rarity).toUpperCase(),
        style: context.overline.copyWith(color: context.scheme.onPrimary, letterSpacing: 1.6),
      ),
    );
  }
}
