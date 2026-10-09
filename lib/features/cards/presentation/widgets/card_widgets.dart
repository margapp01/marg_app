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

/// A rarity distribution bar for the Statistics screen.
class RarityBar extends StatelessWidget {
  const RarityBar({required this.rarity, required this.owned, required this.max, super.key});

  final String rarity;
  final int owned;
  final int max;

  @override
  Widget build(BuildContext context) {
    final c = rarityColor(context, rarity);
    final fraction = max == 0 ? 0.0 : (owned / max).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            child: Text(rarityLabel(AppLocalizations.of(context), rarity),
                style: context.textTheme.bodySmall?.copyWith(color: c)),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: fraction),
                duration: AppDurations.slow,
                curve: AppCurves.emphasize,
                builder: (context, v, _) => Stack(
                  children: [
                    Container(height: 10, decoration: BoxDecoration(color: context.colors.border, borderRadius: AppRadius.fullAll)),
                    Container(height: 10, width: constraints.maxWidth * v, decoration: BoxDecoration(color: c, borderRadius: AppRadius.fullAll)),
                  ],
                ),
              ),
            ),
          ),
          const Gap(AppSpacing.sm),
          SizedBox(width: 28, child: Text('$owned', style: context.textTheme.bodySmall?.semiBold, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

/// A series/season progress row: emblem, name, completion bar and count.
class GroupProgressTile extends StatelessWidget {
  const GroupProgressTile({required this.group, this.accent, this.onTap, super.key});

  final CollectionGroup group;
  final Color? accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tint = accent ?? context.scheme.primary;
    final done = group.completed;
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          IllustratedIcon(fallbackIcon: AppIcons.temple, color: tint, size: 48),
          const Gap.h(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(group.name, style: context.textTheme.titleSmall?.semiBold, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    const Gap.h(AppSpacing.sm),
                    if (done)
                      Icon(AppIcons.verified, color: context.colors.success, size: 20, fill: 1)
                    else
                      Text('${group.percent}%', style: context.textTheme.bodyMedium?.bold.withColor(tint)),
                  ],
                ),
                const Gap(AppSpacing.sm),
                AppLinearProgress(value: (group.percent / 100).clamp(0, 1), color: done ? context.colors.success : tint),
                const Gap(AppSpacing.xs),
                Text(
                  '${group.ownedCards} / ${group.totalCards} ${l10n.scCardsOwned}',
                  style: context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
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
