import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/localization/app_localizations.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../shared/design_system.dart';
import '../../domain/entities/leaderboard.dart';
import '../controllers/leaderboard_controller.dart';

/// Leaderboards — the devotee's own rank, then any public board (overall,
/// visits, cards, routes, achievements, trust, referrals) for this week, this
/// month or all time: a podium for the top three and a paged list below.
class LeaderboardsPage extends ConsumerStatefulWidget {
  const LeaderboardsPage({super.key});

  @override
  ConsumerState<LeaderboardsPage> createState() => _LeaderboardsPageState();
}

class _LeaderboardsPageState extends ConsumerState<LeaderboardsPage> {
  LeaderboardWindow _window = LeaderboardWindow.monthly;
  LeaderboardBoard _board = LeaderboardBoard.global;

  BoardKey get _key => (board: _board, window: _window);

  (String, IconData) _boardMeta(AppLocalizations l10n, LeaderboardBoard b) => switch (b) {
        LeaderboardBoard.global => (l10n.lbOverall, AppIcons.leaderboard),
        LeaderboardBoard.visits => (l10n.lbVisits, AppIcons.temple),
        LeaderboardBoard.cards => (l10n.lbCards, AppIcons.card),
        LeaderboardBoard.routes => (l10n.lbRoutes, AppIcons.route),
        LeaderboardBoard.achievements => (l10n.lbAchievements, AppIcons.achievement),
        LeaderboardBoard.trust => (l10n.lbTrust, AppIcons.trustScore),
        LeaderboardBoard.referrals => (l10n.lbReferrals, AppIcons.referral),
      };

  Future<void> _refresh() async {
    ref.invalidate(myRankProvider);
    ref.invalidate(boardProvider(_key));
    await ref.read(boardProvider(_key).future);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final windows = LeaderboardWindow.values;
    final rank = ref.watch(myRankProvider).valueOrNull;

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.titleLeaderboards)),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: AppSpacing.screenAll,
              sliver: SliverList.list(
                children: [
                  _MyRankCard(rank: rank).fadeIn(),
                  const Gap(AppSpacing.xl),
                  PillTabs(
                    labels: [l10n.lbThisWeek, l10n.homeThisMonth, l10n.homeAllTime],
                    selected: windows.indexOf(_window),
                    onChanged: (i) => setState(() => _window = windows[i]),
                  ),
                  const Gap(AppSpacing.md),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final b in LeaderboardBoard.values) ...[
                          AppFilterChip(
                            label: _boardMeta(l10n, b).$1,
                            icon: _boardMeta(l10n, b).$2,
                            selected: b == _board,
                            onSelected: (_) => setState(() => _board = b),
                          ),
                          const Gap.h(AppSpacing.sm),
                        ],
                      ],
                    ),
                  ),
                  const Gap(AppSpacing.lg),
                ],
              ),
            ),
            _BoardSliver(boardKey: _key, myRank: _board == LeaderboardBoard.global ? rank?.rank : null),
          ],
        ),
      ),
    );
  }
}

/// The devotee's standing on a night sky in the gilt frame: a gold rank
/// medallion, level and points, progress to the next level, weekly movement
/// and regional ranks.
class _MyRankCard extends StatelessWidget {
  const _MyRankCard({required this.rank});

  final MyRank? rank;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final r = rank;
    final gold = context.colors.gold;
    final light = context.colors.card;
    final dim = light.withValues(alpha: 0.7);
    final chips = <String>[
      if (r?.stateRank != null) l10n.lbStateRank(r!.stateRank!),
      if (r?.cityRank != null) l10n.lbCityRank(r!.cityRank!),
      if (r?.bestRank != null) l10n.lbBestRank(r!.bestRank!),
    ];
    final toNext = r?.pointsToNextTier;
    final progress = r == null || toNext == null || r.points + toNext == 0 ? null : r.points / (r.points + toNext);

    return GiltFrame(
      accent: gold,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.night),
        child: Padding(
          padding: AppSpacing.allLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _RankMedallion(rank: r?.rank),
                  const Gap.h(AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.homeRankLabel, style: context.textTheme.labelMedium?.withColor(dim)),
                        Text(
                          tierLabel(l10n, r?.tier ?? 'SEEKER'),
                          style: context.displayText.titleLarge.copyWith(color: gold),
                        ),
                        const Gap(AppSpacing.xxs),
                        Row(
                          children: [
                            Icon(AppIcons.points, size: 16, color: gold, fill: 1),
                            const Gap.h(AppSpacing.xs),
                            Text(
                              l10n.homePoints(compactCount(r?.points ?? 0)),
                              style: context.textTheme.titleSmall?.bold.withColor(light),
                            ),
                          ],
                        ),
                        if (r?.movement != null && r!.movement != 0) ...[
                          const Gap(AppSpacing.xs),
                          _MovementPill(rank: r),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (progress != null && r?.nextTier != null) ...[
                const Gap(AppSpacing.lg),
                AppLinearProgress(value: progress.clamp(0, 1), height: 6, color: gold, backgroundColor: light.withValues(alpha: 0.12)),
                const Gap(AppSpacing.xs),
                Text(
                  '$toNext ${l10n.ppPointsToNext} ${tierLabel(l10n, r!.nextTier!)}',
                  style: context.caption.copyWith(color: dim),
                ),
              ],
              if (chips.isNotEmpty) ...[
                const Gap(AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final c in chips)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs + 1),
                        decoration: BoxDecoration(
                          color: gold.withValues(alpha: 0.12),
                          borderRadius: AppRadius.fullAll,
                          border: Border.all(color: gold.withValues(alpha: 0.45)),
                        ),
                        child: Text(c, style: context.textTheme.labelSmall?.semiBold.withColor(light)),
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

/// The global rank in a glowing gold ring ("—" until ranked).
class _RankMedallion extends StatelessWidget {
  const _RankMedallion({required this.rank});
  final int? rank;

  static const double _size = 88;
  static const double _ring = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gold = context.colors.gold;
    final light = context.colors.card;
    return Semantics(
      label: rank == null ? l10n.homeRankUnranked : '${l10n.homeRankLabel} #$rank',
      excludeSemantics: true,
      child: Container(
        width: _size,
        height: _size,
        padding: const EdgeInsets.all(_ring),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(colors: [gold, Color.lerp(gold, light, 0.55)!, gold]),
          boxShadow: [BoxShadow(color: gold.withValues(alpha: 0.4), blurRadius: 20)],
        ),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(shape: BoxShape.circle, color: context.palette.night),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: AppSpacing.allSm,
              child: rank == null
                  ? Icon(AppIcons.leaderboard, color: gold, size: 32, fill: 1)
                  : Text('#$rank', style: context.displayText.displaySmall.copyWith(color: gold)),
            ),
          ),
        ),
      ),
    ).scaleIn();
  }
}

/// "Up 3 since last week" in green, or down in red.
class _MovementPill extends StatelessWidget {
  const _MovementPill({required this.rank});
  final MyRank rank;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final down = rank.direction == 'DOWN';
    final n = rank.movement!.abs();
    final color = down ? context.palette.crowdHigh : context.palette.accentGreen;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.18), borderRadius: AppRadius.fullAll),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(down ? AppIcons.trendingDown : AppIcons.trending, size: 14, color: color),
          const Gap.h(AppSpacing.xxs),
          Text(
            down ? l10n.lbMovedDown(n) : l10n.lbMovedUp(n),
            style: context.textTheme.labelSmall?.semiBold.withColor(context.colors.card),
          ),
        ],
      ),
    );
  }
}

class _BoardSliver extends ConsumerWidget {
  const _BoardSliver({required this.boardKey, required this.myRank});

  final BoardKey boardKey;

  /// The devotee's global position, highlighted in the overall board.
  final int? myRank;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(boardProvider(boardKey));

    RankedEntry ranked(BoardEntry e) => RankedEntry(
          position: e.position,
          name: e.displayName ?? l10n.homeDevotee,
          avatarUrl: e.avatarUrl,
          pointsLabel: l10n.homePoints(compactCount(e.points)),
          caption: e.tier == null ? null : tierLabel(l10n, e.tier!),
        );

    return async.when(
      skipLoadingOnRefresh: true,
      loading: () => const SliverPadding(
        padding: AppSpacing.screenH,
        sliver: SliverToBoxAdapter(child: AppShimmer(child: SkeletonBox(height: 320, radius: AppRadius.lgAll))),
      ),
      error: (_, _) => SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorView(
          title: l10n.homeErrorTitle,
          message: l10n.homeErrorMessage,
          retryLabel: l10n.commonRetry,
          onRetry: () => ref.invalidate(boardProvider(boardKey)),
        ),
      ),
      data: (page) {
        if (page.entries.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyView(art: StateArt.leaderboard, icon: AppIcons.leaderboard, title: l10n.lbEmptyTitle, message: l10n.lbEmptyBody),
          );
        }
        final podium = page.entries.take(3).map(ranked).toList();
        final rest = page.entries.skip(3).toList();
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.huge),
          sliver: SliverList.builder(
            itemCount: rest.length + 2,
            itemBuilder: (context, i) {
              if (i == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: _PodiumPanel(total: page.total, podium: podium),
                );
              }
              if (i == rest.length + 1) {
                if (!page.hasMore) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: AppButton.outlined(
                    label: l10n.lbLoadMore,
                    size: AppButtonSize.small,
                    busy: page.loadingMore,
                    onPressed: () => ref.read(boardProvider(boardKey).notifier).loadMore(),
                  ),
                );
              }
              final e = rest[i - 1];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: LeaderboardRow(
                  entry: ranked(e),
                  framed: true,
                  highlighted: e.position == myRank,
                  youLabel: l10n.lbYou,
                ).fadeIn(delay: AppDurations.stagger * ((i - 1) % 10)),
              );
            },
          ),
        );
      },
    );
  }
}

/// The top three on a night sky in the gilt frame, over the faint temple
/// skyline: "N devotees ranked" and the showcase podium.
class _PodiumPanel extends StatelessWidget {
  const _PodiumPanel({required this.total, required this.podium});
  final int total;
  final List<RankedEntry> podium;

  static const double _skylineHeight = 64;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gold = context.colors.gold;
    return GiltFrame(
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
                  height: _skylineHeight,
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                  opacity: const AlwaysStoppedAnimation(0.12),
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, 0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(AppIcons.leaderboard, size: 16, color: gold, fill: 1),
                      const Gap.h(AppSpacing.xs),
                      Text(
                        l10n.lbRankedCount(compactCount(total)).toUpperCase(),
                        style: context.overline.copyWith(color: gold, letterSpacing: 1.2),
                      ),
                    ],
                  ),
                  const Gap(AppSpacing.lg),
                  LeaderboardPodium(entries: podium, showcase: true).fadeIn(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
