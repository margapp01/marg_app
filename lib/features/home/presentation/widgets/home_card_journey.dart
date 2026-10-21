import 'dart:ui' show ImageFilter;

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

/// Home's card-first section: the card quest and the temples near you in one
/// night-sky frame — Sacred Cards are what MARG is about.
///
/// A fresh devotee (no cards yet) is invited to collect their first Sacred
/// Card (three locked cards, how it works in three steps); everyone else sees
/// their latest cards fanned out with progress to the next milestone. Below
/// sits a rail of nearby temples drawn as the cards waiting there — rarity,
/// blurred art and a lock until collected — so the next card is one tap away.
class CardJourneyCard extends StatelessWidget {
  const CardJourneyCard({
    required this.collected,
    required this.recent,
    required this.temples,
    required this.onFindTemple,
    required this.onOpenCollection,
    required this.onOpenTemple,
    this.nearby = true,
    super.key,
  });

  final int collected;
  final List<HomeCard> recent;

  /// Nearby temples (or popular ones when location is off) as waiting cards.
  final List<NearbyTemple> temples;

  /// False when [temples] are popular picks rather than ones near the devotee.
  final bool nearby;
  final VoidCallback onFindTemple;
  final VoidCallback onOpenCollection;
  final ValueChanged<NearbyTemple> onOpenTemple;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gold = context.colors.gold;
    final first = collected == 0;
    return GiltFrame(
      accent: gold,
      large: true,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.night),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: AppSpacing.screenH,
                child: first ? const _FirstCard() : _Continue(collected: collected, recent: recent),
              ),
              if (temples.isNotEmpty) ...[
                const Gap(AppSpacing.lg),
                _WaitingRail(temples: temples, nearby: nearby, onSeeAll: onFindTemple, onOpen: onOpenTemple),
              ],
              const Gap(AppSpacing.lg),
              Padding(
                padding: AppSpacing.screenH,
                child: first
                    ? AppButton.primary(label: l10n.homeQuestFindTemple, icon: AppIcons.nearby, onPressed: onFindTemple)
                    : Row(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FirstCard extends StatelessWidget {
  const _FirstCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final light = context.colors.card;
    final gold = context.colors.gold;
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
      ],
    );
  }
}

class _Continue extends StatelessWidget {
  const _Continue({required this.collected, required this.recent});

  final int collected;
  final List<HomeCard> recent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final light = context.colors.card;
    final gold = context.colors.gold;
    final milestone = nextCardMilestone(collected);
    final previous = kCardMilestones.lastWhere((m) => m <= collected, orElse: () => 0);
    final progress = milestone == null ? 1.0 : (collected - previous) / (milestone - previous);
    return Row(
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

/// "Cards waiting near you" — a horizontal rail of [CardWaitingTile]s.
class _WaitingRail extends StatelessWidget {
  const _WaitingRail({required this.temples, required this.nearby, required this.onSeeAll, required this.onOpen});

  final List<NearbyTemple> temples;
  final bool nearby;
  final VoidCallback onSeeAll;
  final ValueChanged<NearbyTemple> onOpen;

  static const double _tileWidth = 132;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gold = context.colors.gold;
    final waiting = temples.where((t) => t.card != null && !t.card!.collected).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.lg, right: AppSpacing.xs),
          child: Row(
            children: [
              Icon(nearby ? AppIcons.nearby : AppIcons.card, size: 16, color: gold),
              const Gap.h(AppSpacing.xs),
              Expanded(
                child: Text(
                  (nearby ? l10n.homeQuestWaitingNearby(waiting) : l10n.homeQuestWaitingPopular).toUpperCase(),
                  style: context.overline.copyWith(color: gold, letterSpacing: 1.2),
                ),
              ),
              TextButton(
                onPressed: onSeeAll,
                style: TextButton.styleFrom(foregroundColor: context.colors.card),
                child: Text(l10n.commonViewAll),
              ),
            ],
          ),
        ),
        SizedBox(
          height: _tileWidth * 4 / 3,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: AppSpacing.screenH,
            itemCount: temples.length,
            separatorBuilder: (_, _) => const Gap.h(AppSpacing.md),
            itemBuilder: (context, i) => SizedBox(
              width: _tileWidth,
              child: CardWaitingTile(temple: temples[i], onTap: () => onOpen(temples[i]))
                  .fadeIn(delay: AppDurations.stagger * i),
            ),
          ),
        ),
      ],
    );
  }
}

/// A temple as the Sacred Card waiting there: a 3:4 gilt card in its rarity
/// colour. Until collected the art is veiled (blurred, sealed with a lock);
/// once collected it shows clear with a "Collected" seal. Temples without a
/// published card show their photo in a stone frame.
class CardWaitingTile extends StatelessWidget {
  const CardWaitingTile({required this.temple, required this.onTap, super.key});

  final NearbyTemple temple;
  final VoidCallback onTap;

  static const double _veil = 5;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final card = temple.card;
    final light = context.colors.card;
    final collected = card?.collected ?? false;
    final accent = card == null ? context.colors.templeStone : rarityColor(context, card.rarity);
    final art = card?.imageUrl ?? temple.imageUrl;
    final image = art == null
        ? const BrandedImageFallback(iconSize: 28)
        : AppNetworkImage(url: art, fit: BoxFit.cover, fallback: const BrandedImageFallback(iconSize: 28));
    final status = card == null
        ? l10n.homeCardVisit
        : collected
            ? l10n.homeCardCollected
            : l10n.homeCardWaiting;
    return Semantics(
      button: true,
      label: [temple.name, if (card != null) rarityLabel(l10n, card.rarity), status, temple.formattedDistance].join(', '),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: GiltFrame(
          accent: accent,
          locked: card == null,
          aspectRatio: 3 / 4,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (card != null && !collected)
                ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: _veil, sigmaY: _veil), child: image)
              else
                image,
              const DecoratedBox(decoration: BoxDecoration(gradient: AppGradients.photoScrim)),
              if (card != null)
                Positioned(top: AppSpacing.xs, left: AppSpacing.xs, child: RarityChip(rarity: card.rarity, compact: true)),
              if (card != null)
                Center(
                  child: Container(
                    padding: AppSpacing.allSm,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (collected ? context.colors.success : context.palette.night).withValues(alpha: 0.75),
                      border: Border.all(color: context.colors.gold, width: 1.2),
                    ),
                    child: Icon(collected ? AppIcons.check : AppIcons.lock, size: 18, color: light),
                  ),
                ),
              Positioned(
                left: AppSpacing.sm,
                right: AppSpacing.sm,
                bottom: AppSpacing.sm,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      temple.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.labelLarge?.semiBold.withColor(light),
                    ),
                    Text(
                      [status, if (temple.formattedDistance.isNotEmpty) temple.formattedDistance].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.caption.copyWith(color: collected ? light.withValues(alpha: 0.8) : context.colors.gold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
