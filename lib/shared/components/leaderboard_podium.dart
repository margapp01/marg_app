import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';
import '../../core/extensions/context_extensions.dart';
import '../badges/app_badge.dart';
import '../images/app_avatar.dart';

/// One ranked devotee as the podium/row widgets need it. Feature code maps
/// its leaderboard rows onto this — the design system owns the look.
class RankedEntry {
  const RankedEntry({
    required this.position,
    required this.name,
    required this.pointsLabel,
    this.avatarUrl,
    this.caption,
  });

  final int position;
  final String name;
  final String pointsLabel;
  final String? avatarUrl;

  /// A second line under the name in rows (e.g. the devotee's level).
  final String? caption;
}

/// The top-3 podium (2nd · 1st · 3rd) with medal rings and rank badges.
///
/// [showcase] is the full-board version for a night-sky panel: larger
/// avatars in glowing medal rings, a trophy over the leader, light text and
/// stepped medal pedestals carrying the positions.
class LeaderboardPodium extends StatelessWidget {
  const LeaderboardPodium({required this.entries, this.showcase = false, super.key});

  /// Up to three entries, best first.
  final List<RankedEntry> entries;
  final bool showcase;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();
    final order = [if (entries.length > 1) entries[1], entries[0], if (entries.length > 2) entries[2]];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final e in order)
          Expanded(child: showcase ? _ShowcaseSpot(entry: e) : _PodiumSpot(entry: e)),
      ],
    );
  }
}

/// Medal colour for a podium position.
Color medalColor(BuildContext context, int position) => switch (position) {
      1 => context.colors.gold,
      2 => context.colors.silver,
      _ => context.colors.bronze,
    };

class _PodiumSpot extends StatelessWidget {
  const _PodiumSpot({required this.entry});

  final RankedEntry entry;

  @override
  Widget build(BuildContext context) {
    final first = entry.position == 1;
    final ring = medalColor(context, entry.position);
    return Semantics(
      label: '#${entry.position} ${entry.name}, ${entry.pointsLabel}',
      child: ExcludeSemantics(
        child: Column(
          children: [
            if (first) Icon(AppIcons.achievement, color: ring, fill: 1, size: 22),
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xxs + 1),
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ring, width: 2.5)),
                  child: AppAvatar(imageUrl: entry.avatarUrl, name: entry.name, radius: first ? 36 : 28),
                ),
                Positioned(
                  bottom: -AppSpacing.sm,
                  child: Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ring,
                      shape: BoxShape.circle,
                      border: Border.all(color: context.colors.card, width: 2),
                    ),
                    child: Text(
                      '${entry.position}',
                      style: context.textTheme.labelSmall?.bold.withColor(context.scheme.onPrimary),
                    ),
                  ),
                ),
              ],
            ),
            const Gap(AppSpacing.md),
            Text(
              entry.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: (first ? context.textTheme.labelLarge : context.textTheme.labelMedium)?.semiBold,
            ),
            Text(entry.pointsLabel, style: context.caption.copyWith(color: context.scheme.primary)),
          ],
        ),
      ),
    );
  }
}

class _ShowcaseSpot extends StatelessWidget {
  const _ShowcaseSpot({required this.entry});

  final RankedEntry entry;

  static const double _leaderRadius = 38;
  static const double _radius = 30;
  static const double _ring = 3;

  /// Pedestal heights for 1st · 2nd · 3rd.
  static const List<double> _pedestal = [76, 56, 42];

  @override
  Widget build(BuildContext context) {
    final first = entry.position == 1;
    final medal = medalColor(context, entry.position);
    final light = context.colors.card;
    final night = context.palette.night;
    final pedestal = _pedestal[(entry.position - 1).clamp(0, 2)];
    return Semantics(
      label: '#${entry.position} ${entry.name}, ${entry.pointsLabel}',
      child: ExcludeSemantics(
        child: Column(
          children: [
            if (first) Icon(AppIcons.achievement, color: medal, fill: 1, size: 28),
            const Gap(AppSpacing.xxs),
            Container(
              padding: const EdgeInsets.all(_ring),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(colors: [medal, Color.lerp(medal, light, 0.55)!, medal]),
                boxShadow: [BoxShadow(color: medal.withValues(alpha: 0.45), blurRadius: first ? 22 : 14)],
              ),
              child: AppAvatar(imageUrl: entry.avatarUrl, name: entry.name, radius: first ? _leaderRadius : _radius),
            ),
            const Gap(AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
              child: Text(
                entry.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: context.textTheme.labelLarge?.semiBold.withColor(light),
              ),
            ),
            Text(entry.pointsLabel, style: context.caption.semiBold.copyWith(color: medal)),
            const Gap(AppSpacing.sm),
            Container(
              height: pedestal,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
                border: Border(top: BorderSide(color: medal, width: 2)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color.lerp(medal, night, 0.2)!, Color.lerp(medal, night, 0.75)!],
                ),
              ),
              child: Text('${entry.position}', style: context.displayText.headlineSmall.withColor(light)),
            ),
          ],
        ),
      ),
    );
  }
}

/// A ranked row below the podium. [highlighted] marks the devotee's own row
/// (with [youLabel] as a pill when given); [framed] sets it on its own card
/// for full-page boards.
class LeaderboardRow extends StatelessWidget {
  const LeaderboardRow({
    required this.entry,
    this.highlighted = false,
    this.framed = false,
    this.youLabel,
    super.key,
  });

  final RankedEntry entry;
  final bool highlighted;
  final bool framed;
  final String? youLabel;

  static const double _positionSize = 32;

  @override
  Widget build(BuildContext context) {
    final saffron = context.scheme.primary;
    final navy = context.scheme.secondary;
    return Semantics(
      label: '#${entry.position} ${entry.name}, ${entry.pointsLabel}',
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: framed ? AppSpacing.md : AppSpacing.sm),
        decoration: BoxDecoration(
          color: highlighted
              ? context.palette.tilePeach
              : framed
                  ? context.colors.card
                  : null,
          borderRadius: framed ? AppRadius.card : AppRadius.mdAll,
          border: framed ? Border.all(color: highlighted ? saffron.withValues(alpha: 0.5) : context.colors.border) : null,
          boxShadow: framed && !highlighted ? AppShadows.xs : null,
        ),
        child: Row(
          children: [
            if (framed)
              Container(
                width: _positionSize,
                height: _positionSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (highlighted ? saffron : navy).withValues(alpha: 0.1),
                ),
                child: Text(
                  '${entry.position}',
                  style: context.textTheme.labelLarge?.bold.withColor(highlighted ? saffron : navy),
                ),
              )
            else
              SizedBox(
                width: AppSpacing.huge,
                child: Text(
                  '${entry.position}',
                  style: context.textTheme.labelLarge?.semiBold.withColor(highlighted ? saffron : context.scheme.onSurface),
                ),
              ),
            if (framed) const Gap.h(AppSpacing.md),
            AppAvatar(imageUrl: entry.avatarUrl, name: entry.name, radius: framed ? 20 : 18),
            const Gap.h(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          entry.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: (highlighted || framed ? context.textTheme.bodyMedium?.semiBold : context.textTheme.bodyMedium)
                              ?.copyWith(color: framed ? navy : null),
                        ),
                      ),
                      if (highlighted && youLabel != null) ...[
                        const Gap.h(AppSpacing.xs),
                        AppBadge(label: youLabel!, tone: AppBadgeTone.primary),
                      ],
                    ],
                  ),
                  if (framed && entry.caption != null)
                    Text(entry.caption!, style: context.caption.copyWith(color: context.colors.textSecondary)),
                ],
              ),
            ),
            const Gap.h(AppSpacing.sm),
            if (framed) ...[
              Icon(AppIcons.points, size: 16, color: context.colors.gold, fill: 1),
              const Gap.h(AppSpacing.xxs),
              Text(entry.pointsLabel, style: context.textTheme.labelLarge?.bold.withColor(navy)),
            ] else
              Text(entry.pointsLabel, style: context.textTheme.labelMedium?.semiBold),
          ],
        ),
      ),
    );
  }
}
