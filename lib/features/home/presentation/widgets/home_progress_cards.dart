import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/home_dashboard.dart';

/// My Yatra Progress — verified coverage per sacred family (Jyotirlingas,
/// Shakti Peeths, Char Dham, other temples) + a link to the full map.
class YatraProgressCard extends StatelessWidget {
  const YatraProgressCard({
    required this.groups,
    required this.onViewAll,
    required this.onOpenMap,
    super.key,
  });

  final List<YatraGroupProgress> groups;
  final VoidCallback onViewAll;
  final VoidCallback onOpenMap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      padding: AppSpacing.allLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: l10n.homeSectionYatraProgress, onViewAll: onViewAll, viewAllLabel: l10n.commonViewAll),
          for (var i = 0; i < groups.length; i++) ...[
            if (i > 0) const Gap(AppSpacing.lg),
            _GroupRow(progress: groups[i]),
          ],
          const Gap(AppSpacing.lg),
          Material(
            color: context.palette.heroCream,
            borderRadius: AppRadius.mdAll,
            child: InkWell(
              onTap: onOpenMap,
              borderRadius: AppRadius.mdAll,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
                child: Row(
                  children: [
                    Icon(AppIcons.map, color: context.scheme.secondary),
                    const Gap.h(AppSpacing.md),
                    Expanded(child: Text(l10n.homeViewYatraMap, style: context.textTheme.labelLarge?.semiBold)),
                    Icon(AppIcons.chevronRight, color: context.colors.textSecondary),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

typedef _GroupMeta = ({String label, String asset, IconData icon, Color color});

_GroupMeta _groupMeta(BuildContext context, AppLocalizations l10n, String group) {
  final p = context.palette;
  switch (group) {
    case 'JYOTIRLINGA':
      return (label: l10n.homeGroupJyotirlinga, asset: BrandAssets.categoryJyotirlinga, icon: AppIcons.temple, color: p.accentBlue);
    case 'SHAKTI_PEETH':
      return (label: l10n.homeGroupShaktiPeeth, asset: BrandAssets.categoryShaktiPeeth, icon: AppIcons.aarti, color: p.accentRose);
    case 'CHAR_DHAM':
      return (label: l10n.homeGroupCharDham, asset: BrandAssets.categoryCharDham, icon: AppIcons.route, color: p.accentTeal);
    default:
      return (label: l10n.homeGroupOther, asset: BrandAssets.iconRoutes, icon: AppIcons.temple, color: p.accentSaffron);
  }
}

class _GroupRow extends StatelessWidget {
  const _GroupRow({required this.progress});

  final YatraGroupProgress progress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final meta = _groupMeta(context, l10n, progress.group);
    final percent = (progress.fraction * 100).round();
    return Semantics(
      label: '${meta.label} ${progress.completed} / ${progress.total}, $percent%',
      child: ExcludeSemantics(
        child: Row(
          children: [
            IllustratedIcon(asset: meta.asset, fallbackIcon: meta.icon, color: meta.color, size: 48),
            const Gap.h(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(meta.label, style: context.textTheme.titleSmall?.semiBold)),
                      Text('$percent%', style: context.textTheme.labelLarge?.bold.withColor(meta.color)),
                    ],
                  ),
                  Text(
                    l10n.homeProgressCompleted(progress.completed, progress.total),
                    style: context.caption.copyWith(color: context.colors.textSecondary),
                  ),
                  const Gap(AppSpacing.sm),
                  AppLinearProgress(
                    value: progress.fraction,
                    height: 6,
                    color: meta.color,
                    backgroundColor: meta.color.withValues(alpha: 0.14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Top Achievements — up to four medals on parchment, recently earned first:
/// earned ones glow in their gilt sunburst, the rest (in stone) show how
/// close they are.
class AchievementsCard extends StatelessWidget {
  const AchievementsCard({required this.achievements, required this.onViewAll, required this.onOpen, super.key});

  final List<HomeAchievement> achievements;
  final VoidCallback onViewAll;
  final ValueChanged<HomeAchievement> onOpen;

  static const int _shown = 4;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.homeSectionAchievements, onViewAll: onViewAll, viewAllLabel: l10n.commonViewAll),
        ParchmentCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.lg),
          // Lets the tiles' ink show over the parchment.
          child: Material(
            type: MaterialType.transparency,
            // Equal-height tiles keep every status on one baseline.
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                for (final (i, a) in achievements.take(_shown).indexed)
                  Expanded(
                    child: _MedalTile(
                      achievement: a,
                      onTap: () => onOpen(a),
                    ).scaleIn(delay: AppDurations.stagger * i),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MedalTile extends StatelessWidget {
  const _MedalTile({required this.achievement, required this.onTap});

  final HomeAchievement achievement;
  final VoidCallback onTap;

  static const double _medal = 68;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final a = achievement;
    final gold = context.colors.gold;
    final green = context.palette.accentGreen;
    final medalArt = Padding(
      padding: const EdgeInsets.all(_medal * SunburstFrame.windowFactor * 0.08),
      child: Image.asset(
        BrandAssets.illustrationMedal,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Icon(AppIcons.achievement, color: gold),
      ),
    );
    final url = a.imageUrl;
    final status = a.earned ? l10n.acEarned : l10n.homeProgressFraction(a.current, a.target);
    return Semantics(
      button: true,
      label: '${a.name}, $status',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs, vertical: AppSpacing.xs),
          child: Column(
            children: [
              SunburstFrame(
                size: _medal,
                rim: gold,
                locked: !a.earned,
                child: url == null ? medalArt : AppNetworkImage(url: url, fit: BoxFit.cover, fallback: medalArt),
              ),
              const Gap(AppSpacing.sm),
              Text(
                a.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.labelMedium?.semiBold.withColor(context.scheme.secondary),
              ),
              const Gap(AppSpacing.xxs),
              const Spacer(),
              if (a.earned)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(AppIcons.success, size: 14, color: green, fill: 1),
                    const Gap.h(AppSpacing.xxs),
                    Flexible(child: Text(status, style: context.caption.semiBold.copyWith(color: green))),
                  ],
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: AppLinearProgress(
                    value: a.target == 0 ? 0 : (a.current / a.target).clamp(0, 1),
                    height: 4,
                    color: gold,
                  ),
                ),
                const Gap(AppSpacing.xxs),
                Text(status, style: context.caption.copyWith(color: context.colors.textSecondary)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Leaderboard — the global top three on a night sky in the gilt frame
/// (This Month / All Time), the next two on their own cards, the devotee's
/// own row when they're further down, and a link to the full board.
class LeaderboardPodiumCard extends StatefulWidget {
  const LeaderboardPodiumCard({
    required this.top,
    required this.myRank,
    required this.onViewAll,
    this.myName,
    this.myAvatarUrl,
    super.key,
  });

  final LeaderboardTop top;
  final LeaderboardRank? myRank;
  final VoidCallback onViewAll;
  final String? myName;
  final String? myAvatarUrl;

  @override
  State<LeaderboardPodiumCard> createState() => _LeaderboardPodiumCardState();
}

class _LeaderboardPodiumCardState extends State<LeaderboardPodiumCard> {
  int _tab = 0;

  static const double _skyline = 64;
  static const int _podium = 3;
  static const int _listed = 5;

  RankedEntry _ranked(AppLocalizations l10n, LeaderboardEntry e) => RankedEntry(
        position: e.position,
        name: e.displayName ?? l10n.homeDevotee,
        avatarUrl: e.avatarUrl,
        pointsLabel: l10n.homePoints(compactCount(e.points)),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gold = context.colors.gold;
    final entries = _tab == 0 ? widget.top.monthly : widget.top.allTime;
    final podium = entries.take(_podium).toList();
    final rest = entries.skip(_podium).take(_listed - _podium).toList();
    final rank = widget.myRank;
    final myPosition = rank?.rank;
    final tier = rank?.tier;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.homeSectionLeaderboard, onViewAll: widget.onViewAll, viewAllLabel: l10n.commonViewAll),
        GiltFrame(
          accent: gold,
          child: DecoratedBox(
            decoration: const BoxDecoration(gradient: AppGradients.night),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ExcludeSemantics(
                    child: Image.asset(
                      BrandAssets.skylineLineArt,
                      height: _skyline,
                      fit: BoxFit.cover,
                      alignment: Alignment.bottomCenter,
                      opacity: const AlwaysStoppedAnimation(0.12),
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
                  child: Column(
                    children: [
                      PillTabs(
                        labels: [l10n.homeThisMonth, l10n.homeAllTime],
                        selected: _tab,
                        onChanged: (i) => setState(() => _tab = i),
                      ),
                      const Gap(AppSpacing.lg),
                      AnimatedSwitcher(
                        duration: AppDurations.normal,
                        child: podium.isEmpty
                            ? Padding(
                                key: const ValueKey('empty'),
                                padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                                child: Text(
                                  l10n.homeLeaderboardEmpty,
                                  textAlign: TextAlign.center,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: context.colors.card.withValues(alpha: 0.75),
                                  ),
                                ),
                              )
                            : LeaderboardPodium(
                                key: ValueKey(_tab),
                                entries: [for (final e in podium) _ranked(l10n, e)],
                                showcase: true,
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        for (final e in rest) ...[
          const Gap(AppSpacing.sm),
          LeaderboardRow(entry: _ranked(l10n, e), framed: true),
        ],
        if (myPosition != null && myPosition > _listed) ...[
          const Gap(AppSpacing.sm),
          LeaderboardRow(
            entry: RankedEntry(
              position: myPosition,
              name: widget.myName ?? l10n.homeRankLabel,
              avatarUrl: widget.myAvatarUrl,
              pointsLabel: l10n.homePoints(compactCount(rank!.points)),
              caption: tier == null ? null : tierLabel(l10n, tier),
            ),
            framed: true,
            highlighted: true,
            youLabel: l10n.lbYou,
          ),
        ],
        const Gap(AppSpacing.md),
        AppButton.outlined(label: l10n.homeViewFullLeaderboard, size: AppButtonSize.small, onPressed: widget.onViewAll),
      ],
    );
  }
}
