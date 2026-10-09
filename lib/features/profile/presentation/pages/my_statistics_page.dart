import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../../achievements/presentation/controllers/achievements_controllers.dart' show achievementCollectionProvider;
import '../../../explore/presentation/controllers/explore_controllers.dart' show exploreStatisticsProvider;
import '../../../passport/presentation/controllers/passport_controllers.dart';
import '../../../passport/presentation/widgets/passport_widgets.dart' show PassportCompletionCard;

/// Screen 6 — My Statistics. Reuses the passport/achievements data plus a real
/// monthly-visits chart. Only backend-backed numbers are shown (no fabricated
/// trend lines for trust or referrals — those have no time-series endpoint).
class MyStatisticsPage extends ConsumerWidget {
  const MyStatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(passportDashboardProvider);

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.pfMyStatistics)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(title: l10n.pfErrorTitle, message: l10n.pfErrorBody, onRetry: () => ref.invalidate(passportDashboardProvider)),
        data: (bundle) {
          final s = bundle.overview.statistics;
          final achievements = ref.watch(achievementCollectionProvider.select((a) => a.valueOrNull?.earnedCount ?? 0));
          final p = context.palette;
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(passportDashboardProvider);
              ref.invalidate(exploreStatisticsProvider);
            },
            child: ListView(
              padding: AppSpacing.screenAll,
              children: [
                IntroBanner(icon: AppIcons.trending, title: l10n.pfStatsHeroTitle, message: l10n.pfStatsHeroBody).fadeIn(),
                const Gap(AppSpacing.lg),
                _StatPair(
                  first: StatCard(icon: AppIcons.temple, accent: p.accentSaffron, value: s.totalVisitedTemples, label: l10n.pfTotalVisits),
                  second: StatCard(icon: AppIcons.card, accent: p.accentBlue, value: s.cardsCollected, label: l10n.pfCardsCollected),
                ).fadeIn(delay: 40.ms),
                const Gap(AppSpacing.md),
                _StatPair(
                  first: StatCard(icon: AppIcons.achievement, accent: p.accentViolet, value: achievements, label: l10n.pfAchievements),
                  second: StatCard(icon: AppIcons.trustScore, accent: p.accentGreen, value: bundle.overview.trustScore, label: l10n.pfTrustScore),
                ).fadeIn(delay: 60.ms),
                const Gap(AppSpacing.lg),
                AppCard(
                  padding: AppSpacing.allLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.pfVisitsOverTime, style: context.textTheme.titleSmall?.semiBold.withColor(context.scheme.secondary)),
                      const Gap(AppSpacing.md),
                      const _VisitsChart(),
                    ],
                  ),
                ).fadeIn(delay: 80.ms),
                const Gap(AppSpacing.lg),
                PassportCompletionCard(overview: bundle.overview).fadeIn(delay: 120.ms),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Two stat cards side by side, sized to their content (no fixed aspect, so
/// large text never clips).
class _StatPair extends StatelessWidget {
  const _StatPair({required this.first, required this.second});
  final Widget first;
  final Widget second;
  @override
  Widget build(BuildContext context) => IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [Expanded(child: first), const Gap.h(AppSpacing.md), Expanded(child: second)],
        ),
      );
}

class _VisitsChart extends ConsumerWidget {
  const _VisitsChart();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ref.watch(exploreStatisticsProvider).when(
          loading: () => const SkeletonBox(height: TrendChart.defaultHeight, radius: AppRadius.smAll),
          error: (_, _) => SizedBox(
            height: TrendChart.defaultHeight,
            child: Center(child: Text(l10n.pfErrorBody, style: context.caption)),
          ),
          data: (stats) => TrendChart(points: stats.monthly, emptyMessage: l10n.pfNoVisitsYet),
        );
  }
}
