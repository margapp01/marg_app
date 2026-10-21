import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/collection_stats.dart';
import '../../domain/entities/sacred_card.dart';
import 'card_widgets.dart';

/// The Sacred Card collection as a trophy: a night-sky gilt panel with the
/// latest cards fanned out, the owned / total count, completion and a gem per
/// rarity. Drawn to be shared — it carries the MARG mark and site — and used
/// as the Cards tab hero and on Profile ([compact] trims it to the essentials).
class CollectionShowcase extends StatelessWidget {
  const CollectionShowcase({
    required this.stats,
    required this.cards,
    this.ownerName,
    this.compact = false,
    super.key,
  });

  final CollectionStats stats;

  /// Owned cards, newest first; the first three are fanned out.
  final List<SacredCard> cards;

  /// Names the collection ("Vikram's Sacred Collection"), e.g. on the shared image.
  final String? ownerName;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gold = context.colors.gold;
    final light = context.colors.card;
    final owned = cards.where((c) => c.owned).take(3).toList();
    final name = ownerName;
    return GiltFrame(
      accent: gold,
      large: true,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.night),
        child: Padding(
          padding: AppSpacing.allLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _Fan(cards: owned, compact: compact),
                  const Gap.h(AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (name == null ? l10n.scShowcaseTitle : l10n.scShowcaseTitleOf(name)).toUpperCase(),
                          maxLines: 2,
                          style: context.overline.copyWith(color: gold, letterSpacing: 1.4),
                        ),
                        const Gap(AppSpacing.xs),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            AnimatedCount(value: stats.ownedCards, style: context.displayText.headlineLarge.withColor(light)),
                            Flexible(
                              child: Text(
                                ' / ${stats.totalCards}',
                                style: context.textTheme.titleMedium?.withColor(light.withValues(alpha: 0.7)),
                              ),
                            ),
                          ],
                        ),
                        Text(l10n.scShowcaseCards, style: context.caption.copyWith(color: light.withValues(alpha: 0.8))),
                        const Gap(AppSpacing.sm),
                        AppLinearProgress(
                          value: (stats.percent / 100).clamp(0, 1),
                          height: 6,
                          color: gold,
                          backgroundColor: light.withValues(alpha: 0.15),
                        ),
                        const Gap(AppSpacing.xxs),
                        Text(
                          l10n.scShowcaseComplete(stats.percent),
                          style: context.caption.copyWith(color: gold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!compact) ...[
                const Gap(AppSpacing.lg),
                _RarityGems(stats: stats),
                const Gap(AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(BrandAssets.logoMark, height: 18, excludeFromSemantics: true),
                    const Gap.h(AppSpacing.xs),
                    Text(
                      l10n.scShowcaseSignature,
                      style: context.caption.copyWith(color: light.withValues(alpha: 0.7), letterSpacing: 0.6),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Up to three owned cards fanned out (locked stone cards when none yet).
class _Fan extends StatelessWidget {
  const _Fan({required this.cards, required this.compact});

  final List<SacredCard> cards;
  final bool compact;

  static const double _tilt = 0.16;

  @override
  Widget build(BuildContext context) {
    final cardWidth = compact ? 56.0 : 74.0;
    final slots = cards.isEmpty ? 3 : cards.length;
    return SizedBox(
      width: cardWidth * 1.9,
      height: cardWidth / SacredCardFace.aspect + AppSpacing.md,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < slots; i++)
            Transform.translate(
              offset: Offset((i - (slots - 1) / 2) * (cardWidth * 0.5), 0),
              child: Transform.rotate(
                angle: (i - (slots - 1) / 2) * _tilt,
                child: SizedBox(
                  width: cardWidth,
                  child: cards.isEmpty
                      ? GiltFrame(
                          accent: context.colors.templeStone,
                          locked: true,
                          aspectRatio: SacredCardFace.aspect,
                          child: ColoredBox(
                            color: context.colors.templeSand,
                            child: Center(child: Icon(AppIcons.lotus, size: 20, color: context.colors.templeStone)),
                          ),
                        )
                      : SacredCardFace(card: cards[i]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One gem + count per rarity, light on the night sky.
class _RarityGems extends StatelessWidget {
  const _RarityGems({required this.stats});

  final CollectionStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final light = context.colors.card;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: light.withValues(alpha: 0.06),
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: context.colors.gold.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          for (final r in kRarityOrder.reversed)
            Expanded(
              child: Semantics(
                label: '${rarityLabel(l10n, r)} ${stats.ownedOf(r)}',
                excludeSemantics: true,
                child: Column(
                  children: [
                    Text(
                      '${stats.ownedOf(r)}',
                      style: context.textTheme.titleMedium?.bold.withColor(rarityColor(context, r)),
                    ),
                    Text(
                      rarityLabel(l10n, r),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.caption.copyWith(color: light.withValues(alpha: 0.75)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
