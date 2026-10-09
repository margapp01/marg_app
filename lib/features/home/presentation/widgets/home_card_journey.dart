import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/home_dashboard.dart';

/// Collection milestones the card quest counts towards.
const List<int> kCardMilestones = [1, 5, 10, 25, 50, 100];

/// The next collection milestone above [collected], or null past the last.
int? nextCardMilestone(int collected) {
  for (final m in kCardMilestones) {
    if (m > collected) return m;
  }
  return null;
}

/// The card quest at the top of Home — keeps every devotee moving.
///
/// A fresh devotee (no cards yet) is invited to collect their first Sacred
/// Card: three locked cards, how it works in three steps, and one action —
/// find a temple nearby. Everyone else continues their journey: their latest
/// cards fanned out, progress to the next collection milestone, and the
/// nearest temple whose card is waiting.
class CardJourneyCard extends StatelessWidget {
  const CardJourneyCard({
    required this.collected,
    required this.recent,
    required this.onFindTemple,
    required this.onOpenCollection,
    required this.onOpenTemple,
    this.nextTemple,
    super.key,
  });

  final int collected;
  final List<HomeCard> recent;

  /// The nearest temple to visit next, when known.
  final NearbyTemple? nextTemple;
  final VoidCallback onFindTemple;
  final VoidCallback onOpenCollection;
  final ValueChanged<NearbyTemple> onOpenTemple;

  @override
  Widget build(BuildContext context) {
    final gold = context.colors.gold;
    final first = collected == 0;
    return GiltFrame(
      accent: gold,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.night),
        child: Padding(
          padding: AppSpacing.allLg,
          child: first
              ? _FirstCard(nextTemple: nextTemple, onFindTemple: onFindTemple, onOpenTemple: onOpenTemple)
              : _Continue(
                  collected: collected,
                  recent: recent,
                  nextTemple: nextTemple,
                  onFindTemple: onFindTemple,
                  onOpenCollection: onOpenCollection,
                  onOpenTemple: onOpenTemple,
                ),
        ),
      ),
    );
  }
}

class _FirstCard extends StatelessWidget {
  const _FirstCard({required this.nextTemple, required this.onFindTemple, required this.onOpenTemple});

  final NearbyTemple? nextTemple;
  final VoidCallback onFindTemple;
  final ValueChanged<NearbyTemple> onOpenTemple;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final light = context.colors.card;
    final gold = context.colors.gold;
    final next = nextTemple;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const _CardFan(cards: []),
            const Gap.h(AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.homeQuestFirstOverline.toUpperCase(), style: context.overline.copyWith(color: gold, letterSpacing: 1.4)),
                  const Gap(AppSpacing.xxs),
                  Text(l10n.homeQuestFirstTitle, style: context.displayText.titleLarge.withColor(light)),
                  const Gap(AppSpacing.xs),
                  Text(l10n.homeQuestFirstBody, style: context.caption.copyWith(color: light.withValues(alpha: 0.8))),
                ],
              ),
            ),
          ],
        ),
        const Gap(AppSpacing.lg),
        Row(
          children: [
            Expanded(child: _Step(icon: AppIcons.temple, label: l10n.homeQuestStepVisit)),
            _StepArrow(color: gold),
            Expanded(child: _Step(icon: AppIcons.verified, label: l10n.homeQuestStepCheckIn)),
            _StepArrow(color: gold),
            Expanded(child: _Step(icon: AppIcons.card, label: l10n.homeQuestStepCard)),
          ],
        ),
        if (next != null) ...[
          const Gap(AppSpacing.md),
          _NextTempleRow(temple: next, onTap: () => onOpenTemple(next)),
        ],
        const Gap(AppSpacing.md),
        AppButton.primary(label: l10n.homeQuestFindTemple, icon: AppIcons.nearby, onPressed: onFindTemple),
      ],
    );
  }
}

class _Continue extends StatelessWidget {
  const _Continue({
    required this.collected,
    required this.recent,
    required this.nextTemple,
    required this.onFindTemple,
    required this.onOpenCollection,
    required this.onOpenTemple,
  });

  final int collected;
  final List<HomeCard> recent;
  final NearbyTemple? nextTemple;
  final VoidCallback onFindTemple;
  final VoidCallback onOpenCollection;
  final ValueChanged<NearbyTemple> onOpenTemple;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final light = context.colors.card;
    final gold = context.colors.gold;
    final milestone = nextCardMilestone(collected);
    final previous = kCardMilestones.lastWhere((m) => m <= collected, orElse: () => 0);
    final progress = milestone == null ? 1.0 : (collected - previous) / (milestone - previous);
    final next = nextTemple;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _CardFan(cards: recent),
            const Gap.h(AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.homeQuestContinueOverline.toUpperCase(), style: context.overline.copyWith(color: gold, letterSpacing: 1.4)),
                  const Gap(AppSpacing.xxs),
                  Text(l10n.homeQuestCollected(collected), style: context.displayText.titleLarge.withColor(light)),
                  const Gap(AppSpacing.sm),
                  AppLinearProgress(value: progress.clamp(0, 1), height: 6, color: gold, backgroundColor: light.withValues(alpha: 0.15)),
                  const Gap(AppSpacing.xs),
                  Text(
                    milestone == null ? l10n.homeQuestAllMilestones : l10n.homeQuestToMilestone(milestone - collected, milestone),
                    style: context.caption.copyWith(color: light.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (next != null) ...[
          const Gap(AppSpacing.md),
          _NextTempleRow(temple: next, onTap: () => onOpenTemple(next)),
        ],
        const Gap(AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppButton.outlined(
                label: l10n.homeQuestMyCollection,
                icon: AppIcons.card,
                size: AppButtonSize.small,
                onPressed: onOpenCollection,
              ),
            ),
            const Gap.h(AppSpacing.sm),
            Expanded(
              child: AppButton.primary(
                label: l10n.homeQuestCollectMore,
                icon: AppIcons.nearby,
                size: AppButtonSize.small,
                onPressed: onFindTemple,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Up to three cards fanned out — the latest collected art, or locked
/// stone-framed cards when there is nothing yet.
class _CardFan extends StatelessWidget {
  const _CardFan({required this.cards});

  final List<HomeCard> cards;

  static const double _cardWidth = 62;
  static const double _width = 118;
  static const double _height = 104;
  static const double _tilt = 0.16;

  @override
  Widget build(BuildContext context) {
    final shown = cards.take(3).toList();
    final slots = shown.isEmpty ? 3 : shown.length;
    return SizedBox(
      width: _width,
      height: _height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < slots; i++)
            Transform.translate(
              offset: Offset((i - (slots - 1) / 2) * (_cardWidth * 0.55), 0),
              child: Transform.rotate(
                angle: (i - (slots - 1) / 2) * _tilt,
                child: SizedBox(
                  width: _cardWidth,
                  child: shown.isEmpty ? const _LockedCard() : _CollectedCard(card: shown[i]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CollectedCard extends StatelessWidget {
  const _CollectedCard({required this.card});
  final HomeCard card;

  @override
  Widget build(BuildContext context) {
    final accent = rarityColor(context, card.rarity);
    final url = card.imageUrl;
    return GiltFrame(
      accent: accent,
      aspectRatio: 3 / 4,
      child: url == null || url.isEmpty
          ? ColoredBox(color: accent.withValues(alpha: 0.2), child: Icon(AppIcons.card, color: context.colors.card))
          : AppNetworkImage(url: url, fit: BoxFit.cover),
    );
  }
}

class _LockedCard extends StatelessWidget {
  const _LockedCard();

  @override
  Widget build(BuildContext context) {
    return GiltFrame(
      accent: context.colors.templeStone,
      locked: true,
      aspectRatio: 3 / 4,
      child: ColoredBox(
        color: context.colors.templeSand,
        child: Center(child: Icon(AppIcons.lotus, size: 22, color: context.colors.templeStone)),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final light = context.colors.card;
    return Column(
      children: [
        Container(
          padding: AppSpacing.allSm,
          decoration: BoxDecoration(shape: BoxShape.circle, color: context.colors.gold.withValues(alpha: 0.18)),
          child: Icon(icon, size: 18, color: context.colors.gold, fill: 1),
        ),
        const Gap(AppSpacing.xxs),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: context.caption.copyWith(color: light.withValues(alpha: 0.85)),
        ),
      ],
    );
  }
}

class _StepArrow extends StatelessWidget {
  const _StepArrow({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: Icon(AppIcons.arrowForward, size: 16, color: color.withValues(alpha: 0.7)),
      );
}

/// "Your next card awaits · Sankat Mochan · 3.4 km ›".
class _NextTempleRow extends StatelessWidget {
  const _NextTempleRow({required this.temple, required this.onTap});
  final NearbyTemple temple;
  final VoidCallback onTap;

  static const double _thumb = 44;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final light = context.colors.card;
    final url = temple.imageUrl;
    final meta = [if (temple.formattedDistance.isNotEmpty) temple.formattedDistance, if (temple.place.isNotEmpty) temple.place];
    return Material(
      color: light.withValues(alpha: 0.08),
      borderRadius: AppRadius.mdAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Padding(
          padding: AppSpacing.allSm,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: AppRadius.smAll,
                child: SizedBox.square(
                  dimension: _thumb,
                  child: url == null
                      ? const BrandedImageFallback(iconSize: 20)
                      : AppNetworkImage(url: url, fallback: const BrandedImageFallback(iconSize: 20)),
                ),
              ),
              const Gap.h(AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.homeQuestNextCard, style: context.caption.copyWith(color: context.colors.gold)),
                    Text(
                      temple.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleSmall?.semiBold.withColor(light),
                    ),
                    if (meta.isNotEmpty)
                      Text(
                        meta.join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.caption.copyWith(color: light.withValues(alpha: 0.7)),
                      ),
                  ],
                ),
              ),
              Icon(AppIcons.chevronRight, color: light.withValues(alpha: 0.7)),
            ],
          ),
        ),
      ),
    );
  }
}
