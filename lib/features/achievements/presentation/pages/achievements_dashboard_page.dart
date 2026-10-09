import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/achievement_collection.dart';
import '../../domain/entities/achievement_summary.dart';
import '../controllers/achievements_controllers.dart';
import '../widgets/achievement_widgets.dart';
import 'achievement_gallery_page.dart';

/// My Spiritual Achievements — the hub: overall progress, points, trust score,
/// quick stats, recent unlocks, and entries into gallery / categories /
/// milestones / statistics.
class AchievementsDashboardPage extends ConsumerWidget {
  const AchievementsDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(achievementCollectionProvider);
    final summary = ref.watch(achievementSummaryProvider).valueOrNull ?? AchievementSummary.empty;

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(
        title: Text(l10n.acTitle),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.search),
            tooltip: l10n.acSearch,
            onPressed: () => context.pushNamed(RouteNames.achievementGallery, extra: const AchievementGalleryArgs()),
          ),
        ],
      ),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          title: l10n.acErrorTitle,
          message: l10n.acErrorBody,
          onRetry: () => ref.invalidate(achievementCollectionProvider),
        ),
        data: (c) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(achievementCollectionProvider);
            ref.invalidate(achievementSummaryProvider);
          },
          child: ListView(
            padding: AppSpacing.screenAll,
            children: [
              const _QuoteBanner().fadeIn(),
              const Gap(AppSpacing.md),
              _Header(collection: c, summary: summary).fadeIn(delay: 60.ms),
              const Gap(AppSpacing.md),
              _QuickStats(collection: c),
              const Gap(AppSpacing.xl),
              _Recent(collection: c),
              const Gap(AppSpacing.lg),
              SectionHeader(title: l10n.acExplore),
              const Gap(AppSpacing.sm),
              const _NavTiles(),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuoteBanner extends StatelessWidget {
  const _QuoteBanner();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ParchmentCard(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxl),
      child: Column(
        children: [
          Icon(AppIcons.quote, color: context.colors.gold, size: 28),
          const Gap(AppSpacing.xs),
          Text(
            l10n.acQuote,
            style: context.brandText.headlineSmall.copyWith(color: context.scheme.secondary),
            textAlign: TextAlign.center,
          ),
          const Gap(AppSpacing.xs),
          Text('— MARG', style: context.textTheme.labelLarge?.semiBold.withColor(context.scheme.primary)),
        ],
      ),
    );
  }
}

/// Overall completion ring with points and trust score.
class _Header extends StatelessWidget {
  const _Header({required this.collection, required this.summary});

  final AchievementCollection collection;
  final AchievementSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final navy = context.scheme.secondary;
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              AppCircularProgress(
                value: (collection.completionPercent / 100).clamp(0, 1),
                size: 92,
                strokeWidth: 8,
                color: context.scheme.primary,
                backgroundColor: context.colors.gold.withValues(alpha: 0.2),
                center: Text('${collection.completionPercent}%', style: context.textTheme.titleMedium?.bold.withColor(navy)),
              ),
              const Gap.h(AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.acOverallProgress, style: context.textTheme.labelLarge?.withColor(context.colors.textSecondary)),
                    const Gap(AppSpacing.xxs),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        AnimatedCount(value: collection.earnedCount, style: context.displayText.headlineLarge.withColor(navy)),
                        Text(' / ${collection.total}', style: context.textTheme.titleMedium?.withColor(context.colors.textSecondary)),
                      ],
                    ),
                    Text(l10n.acCompleted, style: context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.md),
          const AppDivider(),
          const Gap(AppSpacing.md),
          IntrinsicHeight(
            child: Row(
              children: [
                _metric(context, AppIcons.points, collection.pointsEarned, l10n.acPointsEarned, context.colors.gold),
                VerticalDivider(width: AppSpacing.lg, color: context.colors.divider),
                _metric(context, AppIcons.trustScore, summary.trustScore, l10n.acTrustScore, context.palette.accentGreen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(BuildContext context, IconData icon, int value, String label, Color color) => Expanded(
        child: Row(
          children: [
            IllustratedIcon(fallbackIcon: icon, color: color, size: 40),
            const Gap.h(AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedCount(value: value, style: context.textTheme.titleMedium?.bold.withColor(context.scheme.secondary)),
                  Text(label, style: context.caption.copyWith(color: context.colors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      );
}

class _QuickStats extends StatelessWidget {
  const _QuickStats({required this.collection});

  final AchievementCollection collection;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final stats = <(IconData, int, String, Color)>[
      (AppIcons.success, collection.earnedCount, l10n.acCompleted, p.accentGreen),
      (AppIcons.timer, collection.inProgressCount, l10n.acInProgress, p.accentSaffron),
      (AppIcons.lock, collection.lockedCount, l10n.acLocked, p.accentRose),
      (AppIcons.leaderboard, collection.categories.length, l10n.acCategories, p.accentBlue),
    ];
    return Row(
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          if (i > 0) const Gap.h(AppSpacing.sm),
          Expanded(
            child: AppCard(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.xs),
              child: Column(
                children: [
                  IllustratedIcon(fallbackIcon: stats[i].$1, color: stats[i].$4, size: 36),
                  const Gap(AppSpacing.xs),
                  AnimatedCount(value: stats[i].$2, style: context.textTheme.titleMedium?.bold.withColor(context.scheme.secondary)),
                  Text(
                    stats[i].$3,
                    style: context.caption.copyWith(color: context.colors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Recent extends StatelessWidget {
  const _Recent({required this.collection});

  final AchievementCollection collection;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final recent = collection.recent.take(3).toList();
    if (recent.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.acRecent,
          onViewAll: () => context.pushNamed(RouteNames.achievementRecent),
        ),
        const Gap(AppSpacing.sm),
        for (var i = 0; i < recent.length; i++) ...[
          AchievementRow(
            achievement: recent[i],
            trailingDate: '+${recent[i].points} · ${DateFormat('d MMM').format(recent[i].earnedAt!.toLocal())}',
            onTap: () => context.pushNamed(
              RouteNames.achievementDetail,
              pathParameters: {RoutePaths.achievementIdParam: recent[i].id},
            ),
          ).slideIn(delay: (i * 60).ms),
          const Gap(AppSpacing.sm),
        ],
      ],
    );
  }
}

class _NavTiles extends StatelessWidget {
  const _NavTiles();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final tiles = <(IconData, Color, String, VoidCallback)>[
      (AppIcons.achievement, p.accentAmber, l10n.acGallery,
          () => context.pushNamed(RouteNames.achievementGallery, extra: const AchievementGalleryArgs())),
      (AppIcons.leaderboard, p.accentBlue, l10n.acCategories, () => context.pushNamed(RouteNames.achievementCategories)),
      (AppIcons.route, p.accentViolet, l10n.acMilestones, () => context.pushNamed(RouteNames.achievementMilestones)),
      (AppIcons.trending, p.accentTeal, l10n.acStatistics, () => context.pushNamed(RouteNames.achievementStats)),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 2.6,
      children: [
        for (final t in tiles)
          AppCard(
            onTap: t.$4,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                IllustratedIcon(fallbackIcon: t.$1, color: t.$2, size: 36),
                const Gap.h(AppSpacing.sm),
                Expanded(
                  child: Text(t.$3, style: context.textTheme.bodyMedium?.semiBold, maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
