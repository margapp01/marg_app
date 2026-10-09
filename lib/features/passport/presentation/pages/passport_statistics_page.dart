import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/passport.dart';
import '../../domain/entities/timeline_event.dart';
import '../controllers/passport_controllers.dart';
import '../widgets/passport_widgets.dart';

/// Statistics — headline counts, a 6-month activity chart (derived from the
/// journey timeline), completion breakdown, and leaderboard rank.
class PassportStatisticsPage extends ConsumerWidget {
  const PassportStatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(passportDashboardProvider);
    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.ppStatistics)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(title: l10n.ppErrorTitle, message: l10n.ppErrorBody, onRetry: () => ref.invalidate(passportDashboardProvider)),
        data: (bundle) {
          final o = bundle.overview;
          final s = o.statistics;
          return ListView(
            padding: AppSpacing.screenAll,
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 2.4,
                children: [
                  PassportStatTile(icon: AppIcons.temple, value: '${s.totalVisitedTemples}', label: l10n.ppTemplesVisited),
                  PassportStatTile(icon: AppIcons.verified, value: '${s.verifiedVisits}', label: l10n.ppVerifiedVisits, color: context.colors.success),
                  PassportStatTile(icon: AppIcons.card, value: '${s.cardsCollected}', label: l10n.ppCardsCollected, color: context.colors.info),
                  PassportStatTile(icon: AppIcons.route, value: '${s.routesCompleted}', label: l10n.ppRoutesCompleted, color: context.scheme.primary),
                  PassportStatTile(icon: AppIcons.trustScore, value: '${o.trustScore}', label: l10n.ppTrustScore, color: context.colors.gold),
                  if (bundle.rank?.globalRank != null)
                    PassportStatTile(icon: AppIcons.leaderboard, value: '#${bundle.rank!.globalRank}', label: l10n.ppGlobalRank, color: context.scheme.primary),
                ],
              ),
              const Gap(AppSpacing.lg),
              const _MonthlyActivityCard(),
              const Gap(AppSpacing.lg),
              PassportCompletionCard(overview: o),
              if (bundle.rank != null) ...[
                const Gap(AppSpacing.lg),
                _RankCard(rank: bundle.rank!),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _MonthlyActivityCard extends ConsumerWidget {
  const _MonthlyActivityCard();

  static const _labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(passportTimelineProvider);
    return AppCard(
      padding: AppSpacing.allLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.ppMonthlyActivity, style: context.textTheme.titleSmall?.semiBold.withColor(context.scheme.secondary)),
          const Gap(AppSpacing.md),
          async.when(
            loading: () => const SkeletonBox(height: TrendChart.defaultHeight, radius: AppRadius.smAll),
            error: (_, _) => SizedBox(
              height: TrendChart.defaultHeight,
              child: Center(child: Text(l10n.ppErrorBody, style: context.caption)),
            ),
            data: (events) => TrendChart(points: _lastSixMonths(events), emptyMessage: l10n.ppNoActivity),
          ),
        ],
      ),
    );
  }

  /// (label, count) for the trailing six months, oldest → newest.
  List<(String, int)> _lastSixMonths(List<TimelineEvent> events) {
    final now = DateTime.now();
    final buckets = <String, int>{};
    final order = <(String, int, int)>[]; // label, year, month
    for (var i = 5; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i);
      final key = '${d.year}-${d.month}';
      buckets[key] = 0;
      order.add((_labels[d.month - 1], d.year, d.month));
    }
    for (final e in events) {
      final key = '${e.date.year}-${e.date.month}';
      if (buckets.containsKey(key)) buckets[key] = buckets[key]! + 1;
    }
    return [for (final (label, y, m) in order) (label, buckets['$y-$m'] ?? 0)];
  }
}

class _RankCard extends StatelessWidget {
  const _RankCard({required this.rank});
  final PassportRank rank;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      variant: AppCardVariant.filled,
      child: Row(
        children: [
          AppCircularProgress(
            value: rank.tierProgress,
            size: 64,
            strokeWidth: 6,
            center: Icon(AppIcons.leaderboard, color: context.colors.gold, size: 24),
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${l10n.ppLevel} · ${tierLabel(l10n, rank.tier)}', style: context.textTheme.titleSmall?.semiBold),
                if (rank.globalRank != null)
                  Text('${l10n.ppGlobalRank}: #${rank.globalRank}', style: context.caption.copyWith(color: context.colors.textSecondary)),
                if (rank.nextTier != null)
                  Text('${rank.pointsToNextTier} ${l10n.ppPointsToNext} ${tierLabel(l10n, rank.nextTier!)}',
                      style: context.caption.copyWith(color: context.colors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
