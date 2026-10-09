import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/achievement_summary.dart';

/// (label, icon) for an AchievementCategory.
({String label, IconData icon}) categoryMeta(AppLocalizations l10n, String category) {
  switch (category.toUpperCase()) {
    case 'TEMPLE':
      return (label: l10n.acCatTemple, icon: AppIcons.temple);
    case 'ROUTE':
      return (label: l10n.acCatRoute, icon: AppIcons.route);
    case 'CARD':
      return (label: l10n.acCatCard, icon: AppIcons.card);
    case 'SERIES':
      return (label: l10n.acCatSeries, icon: AppIcons.star);
    case 'SEASON':
      return (label: l10n.acCatSeason, icon: AppIcons.calendar);
    case 'TRUST':
      return (label: l10n.acCatTrust, icon: AppIcons.trustScore);
    default:
      return (label: l10n.acCatSpecial, icon: AppIcons.achievement);
  }
}

/// Accent colour for an AchievementCategory.
Color categoryAccent(BuildContext context, String category) {
  final p = context.palette;
  switch (category.toUpperCase()) {
    case 'TEMPLE':
      return p.accentSaffron;
    case 'ROUTE':
      return p.accentBlue;
    case 'CARD':
      return p.accentViolet;
    case 'SERIES':
      return p.accentAmber;
    case 'SEASON':
      return p.accentTeal;
    case 'TRUST':
      return p.accentGreen;
    default:
      return p.accentRose;
  }
}

/// A sunburst medallion: gilt rays (stone when locked) around a night-blue
/// disc rimmed in the rarity colour, holding the achievement's artwork (or the
/// trishul medal). Earned medals glow; locked ones are greyed under a lock.
/// [size] is the outer diameter.
class AchievementMedal extends StatelessWidget {
  const AchievementMedal({required this.achievement, this.size = 64, this.hero = false, super.key});

  final Achievement achievement;
  final double size;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final accent = rarityColor(context, achievement.rarity);
    final locked = achievement.locked;
    final disc = size * SunburstFrame.windowFactor;
    final ownArt = achievement.artwork != null;

    Widget art = ownArt
        ? AppNetworkImage(url: achievement.artwork!, width: disc, height: disc, fit: BoxFit.cover)
        : Padding(
            padding: EdgeInsets.all(disc * 0.08),
            child: Image.asset(
              BrandAssets.illustrationMedal,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Icon(AppIcons.achievement, size: disc * 0.5, color: context.colors.gold),
            ),
          );
    if (locked) {
      art = Opacity(
        opacity: 0.55,
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix(<double>[
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0.2126, 0.7152, 0.0722, 0, 0,
            0, 0, 0, 1, 0,
          ]),
          child: art,
        ),
      );
    }

    final medal = Stack(
      children: [
        SunburstFrame(size: size, rim: accent, locked: locked, child: art),
        if (locked)
          Positioned(
            right: size * 0.06,
            bottom: size * 0.06,
            child: Container(
              padding: EdgeInsets.all(size * 0.05),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.card,
                border: Border.all(color: context.colors.templeStone),
              ),
              child: Icon(AppIcons.lock, size: size * 0.16, color: context.colors.textSecondary),
            ),
          ),
      ],
    );
    return hero ? Hero(tag: 'achievement-${achievement.id}', child: medal) : medal;
  }
}

/// A grid tile: medal, name and progress (or rarity once earned).
class AchievementTile extends StatelessWidget {
  const AchievementTile({required this.achievement, this.onTap, super.key});

  final Achievement achievement;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locked = achievement.locked;
    return Semantics(
      button: true,
      label: '${achievement.name}, ${achievement.earned ? l10n.acStatusCompleted : '${achievement.percent}%'}',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            AchievementMedal(achievement: achievement, size: 80, hero: true),
            const Gap(AppSpacing.sm),
            Text(
              achievement.name,
              style: context.textTheme.bodySmall?.semiBold.copyWith(
                color: locked ? context.colors.textSecondary : context.scheme.secondary,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            const Gap(AppSpacing.xs),
            if (achievement.earned)
              RarityChip(rarity: achievement.rarity, compact: true)
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: AppLinearProgress(
                  value: (achievement.percent / 100).clamp(0, 1),
                  height: 5,
                  color: rarityColor(context, achievement.rarity),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A list row: medal, name, requirement, rarity, progress and status.
class AchievementRow extends StatelessWidget {
  const AchievementRow({required this.achievement, this.trailingDate, this.onTap, super.key});

  final Achievement achievement;
  final String? trailingDate;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = rarityColor(context, achievement.rarity);
    final earned = achievement.earned;
    final count = achievement.threshold == null
        ? null
        : '${earned ? achievement.threshold : achievement.currentCount} / ${achievement.threshold}';
    return AppCard(
      onTap: onTap,
      padding: AppSpacing.allMd,
      child: Row(
        children: [
          AchievementMedal(achievement: achievement, size: 60),
          const Gap.h(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.name,
                  style: context.textTheme.bodyMedium?.semiBold.withColor(context.scheme.secondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (achievement.description != null)
                  Text(
                    achievement.description!,
                    style: context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const Gap(AppSpacing.xs),
                Row(
                  children: [
                    RarityChip(rarity: achievement.rarity, compact: true),
                    const Gap.h(AppSpacing.sm),
                    if (earned)
                      Expanded(
                        child: Text(
                          trailingDate ?? count ?? '',
                          style: context.caption.copyWith(color: context.colors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    else ...[
                      Expanded(child: AppLinearProgress(value: (achievement.percent / 100).clamp(0, 1), height: 5, color: accent)),
                      if (count != null) ...[
                        const Gap.h(AppSpacing.sm),
                        Text(count, style: context.caption.copyWith(color: context.colors.textSecondary)),
                      ],
                    ],
                  ],
                ),
              ],
            ),
          ),
          const Gap.h(AppSpacing.sm),
          if (earned)
            Icon(AppIcons.success, color: context.colors.success, size: 24, fill: 1)
          else
            Text('${achievement.percent}%', style: context.textTheme.bodySmall?.semiBold.withColor(accent)),
        ],
      ),
    );
  }
}

/// A category tile: illustrated icon, name, X/Y and progress.
class CategoryCard extends StatelessWidget {
  const CategoryCard({required this.category, required this.earned, required this.total, this.onTap, super.key});

  final String category;
  final int earned;
  final int total;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final meta = categoryMeta(l10n, category);
    final accent = categoryAccent(context, category);
    final pct = total == 0 ? 0.0 : earned / total;
    return AppCard(
      onTap: onTap,
      padding: AppSpacing.allMd,
      child: Column(
        children: [
          IllustratedIcon(fallbackIcon: meta.icon, color: accent, size: 52),
          const Gap(AppSpacing.sm),
          Text(
            meta.label,
            textAlign: TextAlign.center,
            style: context.textTheme.labelLarge?.semiBold.withColor(context.scheme.secondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Gap(AppSpacing.xxs),
          Text('$earned / $total', style: context.textTheme.bodySmall?.semiBold.withColor(context.colors.textSecondary)),
          const Spacer(),
          AppLinearProgress(value: pct.clamp(0, 1), height: 5, color: accent),
        ],
      ),
    );
  }
}

/// A milestone in the timeline: dot/check + label + progress.
class MilestoneTile extends StatelessWidget {
  const MilestoneTile({required this.milestone, required this.isLast, super.key});

  final Milestone milestone;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final accent = milestone.achieved ? context.colors.success : context.scheme.primary;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: milestone.achieved ? accent : context.colors.border,
                ),
                child: milestone.achieved ? Icon(AppIcons.check, size: 16, color: context.scheme.onPrimary) : null,
              ),
              if (!isLast) Expanded(child: Container(width: 2, color: milestone.achieved ? accent : context.colors.border)),
            ],
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(milestone.label, style: context.textTheme.bodyMedium?.semiBold),
                  const Gap(AppSpacing.xxs),
                  if (milestone.achieved)
                    Text('${milestone.current} / ${milestone.target}',
                        style: context.caption.copyWith(color: context.colors.success))
                  else ...[
                    AppLinearProgress(value: (milestone.percent / 100).clamp(0, 1), height: 6),
                    const Gap(AppSpacing.xxs),
                    Text('${milestone.current} / ${milestone.target}',
                        style: context.caption.copyWith(color: context.colors.textSecondary)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A donut chart of segments (value + colour), with a centre label.
class StatDonut extends StatelessWidget {
  const StatDonut({required this.segments, this.centerLabel, this.centerSub, this.size = 150, super.key});

  final List<({double value, Color color})> segments;
  final String? centerLabel;
  final String? centerSub;
  final double size;

  @override
  Widget build(BuildContext context) {
    final total = segments.fold<double>(0, (s, e) => s + e.value);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: AppDurations.slow,
            curve: AppCurves.emphasize,
            builder: (context, t, _) => CustomPaint(
              size: Size(size, size),
              painter: _DonutPainter(segments, total, context.colors.border, t),
            ),
          ),
          if (centerLabel != null)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(centerLabel!, style: context.textTheme.titleLarge?.bold),
                if (centerSub != null)
                  Text(centerSub!, style: context.caption.copyWith(color: context.colors.textSecondary)),
              ],
            ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.segments, this.total, this.track, this.t);

  final List<({double value, Color color})> segments;
  final double total;
  final Color track;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.14;
    final rect = Offset(stroke / 2, stroke / 2) & Size(size.width - stroke, size.height - stroke);
    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track;
    canvas.drawArc(rect, 0, math.pi * 2, false, bg);
    if (total <= 0) return;
    var start = -math.pi / 2;
    for (final seg in segments) {
      final sweep = (seg.value / total) * math.pi * 2 * t;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt
        ..color = seg.color;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.t != t || old.segments != segments;
}
