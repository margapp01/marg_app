import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/collection_group.dart';
import '../../domain/entities/sacred_card.dart';

/// Accent for the [index]-th series / season, so neighbouring groups differ.
Color groupAccent(BuildContext context, int index) {
  final p = context.palette;
  final accents = [p.accentSaffron, p.accentViolet, p.accentBlue, p.accentTeal, p.accentRose, p.accentAmber, p.accentGreen];
  return accents[index % accents.length];
}

/// How large a Sacred Card is drawn: a grid [tile] or the Card Detail [hero].
enum SacredCardSize { tile, hero }

/// The front of a Sacred Card: temple art in a [GiltFrame] with a lotus emblem,
/// the owner's mint number (top right), a "NEW" tag for fresh unlocks (top
/// left) and — at hero size — the temple name and a rarity ribbon. Locked
/// cards fade to stone under a lock seal.
class SacredCardFace extends StatelessWidget {
  const SacredCardFace({required this.card, this.size = SacredCardSize.tile, this.heroTag, super.key});

  final SacredCard card;
  final SacredCardSize size;

  /// Shared-element tag for the art (tile → Card Detail).
  final Object? heroTag;

  /// Width ÷ height of every Sacred Card.
  static const double aspect = 3 / 4;

  @override
  Widget build(BuildContext context) {
    final locked = !card.owned;
    final hero = size == SacredCardSize.hero;
    final accent = rarityColor(context, card.rarity);
    final art = _Art(card: card, locked: locked);
    final edge = hero ? AppSpacing.md : AppSpacing.xs;
    // Corner tags sit just inside the filigree brackets so the gems never cover them.
    final tagInset = hero ? AppSpacing.xl + AppSpacing.xs : AppSpacing.md + AppSpacing.xxs;

    final mint = locked ? null : card.ownership?.mintNumber;

    return GiltFrame(
      accent: accent,
      locked: locked,
      large: hero,
      aspectRatio: SacredCardFace.aspect,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (heroTag == null) art else Hero(tag: heroTag!, child: art),
          if (hero && !locked) const DecoratedBox(decoration: BoxDecoration(gradient: AppGradients.photoScrim)),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: edge + AppSpacing.xxs),
              child: CardEmblem(size: hero ? 32 : 18, locked: locked),
            ),
          ),
          if (locked) Center(child: _LockSeal(size: hero ? 64 : 34)),
          if (!locked && card.isFresh)
            Positioned(top: tagInset, left: tagInset, child: _NewTag(large: hero)),
          if (mint != null) Positioned(top: tagInset, right: tagInset, child: _MintTag(number: mint, large: hero)),
          if (hero)
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.lg,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!locked)
                    Text(
                      card.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.brandText.headlineSmall.copyWith(
                        color: Color.lerp(context.colors.gold, context.colors.card, 0.3),
                        shadows: AppShadows.text,
                      ),
                    ),
                  const Gap(AppSpacing.sm),
                  RarityRibbon(rarity: card.rarity),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Art extends StatelessWidget {
  const _Art({required this.card, required this.locked});

  final SacredCard card;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final image = card.imageUrl.isEmpty
        ? ColoredBox(color: context.colors.templeSand)
        : AppNetworkImage(url: card.imageUrl, fit: BoxFit.cover);
    if (!locked) return image;
    // Desaturated and washed out: the temple is there, waiting to be visited.
    return Stack(
      fit: StackFit.expand,
      children: [
        ColorFiltered(
          colorFilter: const ColorFilter.matrix(<double>[
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0, 0, 0, 1, 0,
          ]),
          child: image,
        ),
        DecoratedBox(decoration: BoxDecoration(color: context.palette.heroCream.withValues(alpha: 0.62))),
      ],
    );
  }
}

/// The lotus seal at the top of every card (night-blue disc, gold rim).
class CardEmblem extends StatelessWidget {
  const CardEmblem({required this.size, this.locked = false, super.key});

  final double size;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final rim = locked ? context.colors.templeStone : context.colors.gold;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: locked ? context.colors.card : context.palette.night,
        border: Border.all(color: rim, width: size / 14),
      ),
      child: Icon(AppIcons.lotus, size: size * 0.6, fill: 1, color: rim),
    );
  }
}

class _LockSeal extends StatelessWidget {
  const _LockSeal({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.card.withValues(alpha: 0.92),
        border: Border.all(color: context.colors.templeStone, width: 1.5),
        boxShadow: AppShadows.sm,
      ),
      child: Icon(AppIcons.lock, size: size * 0.45, color: context.colors.textSecondary),
    );
  }
}

class _NewTag extends StatelessWidget {
  const _NewTag({required this.large});

  final bool large;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: large ? AppSpacing.sm : AppSpacing.xs, vertical: AppSpacing.xxs / 2),
      decoration: BoxDecoration(gradient: AppGradients.primary, borderRadius: AppRadius.fullAll, boxShadow: AppShadows.sm),
      child: Text(AppLocalizations.of(context).scNew, style: context.overline.copyWith(color: context.scheme.onPrimary)),
    );
  }
}

/// The owner's mint number ("#7") — gold on night blue.
class _MintTag extends StatelessWidget {
  const _MintTag({required this.number, required this.large});

  final int number;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final gold = context.colors.gold;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: large ? AppSpacing.sm : AppSpacing.xs, vertical: AppSpacing.xxs / 2),
      decoration: BoxDecoration(
        color: context.palette.night.withValues(alpha: 0.85),
        borderRadius: AppRadius.fullAll,
        border: Border.all(color: gold, width: 0.8),
      ),
      child: Text('#$number', style: context.overline.copyWith(color: gold)),
    );
  }
}

/// A grid tile for a sacred card: the framed [SacredCardFace], its title and
/// rarity (plus an optional [detail], e.g. the unlock date).
class SacredCardTile extends StatelessWidget {
  const SacredCardTile({required this.card, this.onTap, this.detail, super.key});

  final SacredCard card;
  final VoidCallback? onTap;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locked = !card.owned;
    final rarity = rarityLabel(l10n, card.rarity);

    return Semantics(
      label: '${card.title}, $rarity, ${locked ? l10n.scLocked : l10n.scUnlocked}',
      button: true,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RepaintBoundary(child: SacredCardFace(card: card, heroTag: 'card-${card.id}')),
            const Gap(AppSpacing.sm),
            Text(
              card.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.semiBold.copyWith(
                color: locked ? context.colors.textSecondary : context.scheme.secondary,
              ),
            ),
            Text(
              [rarity, ?detail].join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.caption.copyWith(
                color: locked ? context.colors.textDisabled : rarityColor(context, card.rarity),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Width ÷ height of a tile in a grid (3:4 card + two lines of text).
  static const double gridAspect = 0.58;
}

/// Owned cards per rarity, rarest first (Mythic only once one is owned), as
/// gem + label + count columns.
class RarityCountStrip extends StatelessWidget {
  const RarityCountStrip({required this.countOf, super.key});

  final int Function(String rarity) countOf;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rarities = [
      for (final r in kRarityOrder.reversed)
        if (r != 'MYTHIC' || countOf(r) > 0) r,
    ];
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < rarities.length; i++) ...[
              if (i > 0) VerticalDivider(width: 1, color: context.colors.divider),
              Expanded(
                child: Column(
                  children: [
                    _Gem(color: rarityColor(context, rarities[i])),
                    const Gap(AppSpacing.xs),
                    Text(rarityLabel(l10n, rarities[i]), style: context.caption.copyWith(color: context.colors.textSecondary)),
                    const Gap(AppSpacing.xxs),
                    AnimatedCount(
                      value: countOf(rarities[i]),
                      style: context.textTheme.titleLarge?.semiBold.withColor(context.scheme.secondary),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A small faceted diamond in a rarity colour.
class _Gem extends StatelessWidget {
  const _Gem({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 4,
      child: Container(
        width: AppSpacing.sm + 2,
        height: AppSpacing.sm + 2,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppSpacing.xxs / 2),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: 6)],
        ),
      ),
    );
  }
}

/// A series / season as a collector's album: a gilt frame in the group's
/// accent (gold once complete) around a completion ring, the name, a row of
/// card slots — gilt for owned, stone and locked for missing — and the next
/// card still to collect with its rarity. Completed albums carry a gold seal.
class GroupProgressTile extends StatelessWidget {
  const GroupProgressTile({required this.group, this.accent, this.onTap, super.key});

  final CollectionGroup group;
  final Color? accent;
  final VoidCallback? onTap;

  static const int _maxSlots = 12;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final done = group.completed;
    final gold = context.colors.gold;
    final tint = done ? gold : accent ?? context.scheme.primary;
    final next = group.missingCards.firstOrNull;
    final slots = group.totalCards.clamp(0, _maxSlots);
    final ownedSlots = group.ownedCards.clamp(0, slots);
    return Semantics(
      button: onTap != null,
      label: '${group.name}, ${group.ownedCards} / ${group.totalCards} ${l10n.scCardsOwned}, ${group.percent}%',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: GiltFrame(
          accent: tint,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [context.colors.card, Color.lerp(context.colors.card, tint, 0.1)!],
              ),
            ),
            child: Padding(
              padding: AppSpacing.allMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      done
                          ? const GoldSeal(size: 56, glow: true)
                          : AppCircularProgress(
                              value: (group.percent / 100).clamp(0, 1),
                              size: 56,
                              strokeWidth: 5,
                              color: tint,
                              backgroundColor: tint.withValues(alpha: 0.15),
                              center: Text('${group.percent}%', style: context.textTheme.labelMedium?.bold.withColor(tint)),
                            ),
                      const Gap.h(AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.displayText.titleLarge.withColor(context.scheme.secondary),
                            ),
                            const Gap(AppSpacing.xxs),
                            Text(
                              done ? l10n.scAlbumComplete : '${group.ownedCards} / ${group.totalCards} ${l10n.scCardsOwned}',
                              style: (done ? context.caption.semiBold : context.caption)
                                  .copyWith(color: done ? gold : context.colors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      if (onTap != null) Icon(AppIcons.chevronRight, color: context.colors.textSecondary),
                    ],
                  ),
                  if (slots > 0) ...[
                    const Gap(AppSpacing.md),
                    Row(
                      children: [
                        for (var i = 0; i < slots; i++) ...[
                          if (i > 0) const Gap.h(AppSpacing.xxs + 1),
                          Expanded(child: _Slot(owned: i < ownedSlots, accent: tint)),
                        ],
                        if (group.totalCards > _maxSlots) ...[
                          const Gap.h(AppSpacing.xs),
                          Text('+${group.totalCards - _maxSlots}', style: context.caption.copyWith(color: context.colors.textSecondary)),
                        ],
                      ],
                    ),
                  ],
                  if (!done && next != null) ...[
                    const Gap(AppSpacing.md),
                    Row(
                      children: [
                        Icon(AppIcons.lock, size: 14, color: context.colors.textSecondary),
                        const Gap.h(AppSpacing.xs),
                        Expanded(
                          child: Text(
                            l10n.scAlbumNext(next.templeName ?? next.title),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.caption.copyWith(color: context.scheme.secondary),
                          ),
                        ),
                        const Gap.h(AppSpacing.xs),
                        RarityChip(rarity: next.rarity, compact: true),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One card slot in an album row: gilt for owned, stone with a lock if not.
class _Slot extends StatelessWidget {
  const _Slot({required this.owned, required this.accent});

  final bool owned;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: SacredCardFace.aspect,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: owned ? AppGradients.gilt : AppGradients.stone,
          borderRadius: AppRadius.xsAll,
          boxShadow: owned ? [BoxShadow(color: accent.withValues(alpha: 0.35), blurRadius: 4)] : null,
        ),
        child: owned
            ? null
            : FittedBox(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxs),
                  child: Icon(AppIcons.lock, color: context.colors.templeStone),
                ),
              ),
      ),
    );
  }
}

/// A flip animation between a card's front (art) and back (details).
class CardFlip extends StatefulWidget {
  const CardFlip({required this.front, required this.back, super.key});

  final Widget front;
  final Widget back;

  @override
  State<CardFlip> createState() => _CardFlipState();
}

class _CardFlipState extends State<CardFlip> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: AppDurations.slow);
  bool _showBack = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    setState(() => _showBack = !_showBack);
    _showBack ? _controller.forward() : _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final angle = _controller.value * 3.1415926;
          final isBack = angle > 3.1415926 / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(3.1415926),
                    child: widget.back,
                  )
                : widget.front,
          );
        },
      ),
    );
  }
}

/// The night-sky header of the Series / Seasons screens: how many sets are
/// complete, the cards held across them and overall completion.
class GroupsSummary extends StatelessWidget {
  const GroupsSummary({required this.groups, required this.series, super.key});

  final List<CollectionGroup> groups;
  final bool series;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gold = context.colors.gold;
    final light = context.colors.card;
    final done = groups.where((g) => g.completed).length;
    final owned = groups.fold<int>(0, (n, g) => n + g.ownedCards);
    final total = groups.fold<int>(0, (n, g) => n + g.totalCards);
    final fraction = total == 0 ? 0.0 : owned / total;
    Widget stat(String value, String label) => Expanded(
          child: Column(
            children: [
              Text(value, style: context.displayText.titleLarge.withColor(light)),
              Text(label, textAlign: TextAlign.center, style: context.caption.copyWith(color: light.withValues(alpha: 0.75))),
            ],
          ),
        );
    return GiltFrame(
      accent: gold,
      large: true,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.night),
        child: Padding(
          padding: AppSpacing.allLg,
          child: Row(
            children: [
              AppCircularProgress(
                value: fraction.clamp(0, 1),
                size: 84,
                strokeWidth: 7,
                color: gold,
                backgroundColor: light.withValues(alpha: 0.12),
                center: Text('${(fraction * 100).round()}%', style: context.textTheme.titleMedium?.bold.withColor(light)),
              ),
              const Gap.h(AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (series ? l10n.scSeriesSummary : l10n.scSeasonsSummary).toUpperCase(),
                      style: context.overline.copyWith(color: gold, letterSpacing: 1.4),
                    ),
                    const Gap(AppSpacing.sm),
                    Row(
                      children: [
                        stat('$done/${groups.length}', l10n.scSetsComplete),
                        stat('$owned/$total', l10n.scShowcaseCards),
                      ],
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
