import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../controllers/explore_controllers.dart';
import '../widgets/explore_widgets.dart';

/// Screen 9 — Explore Statistics, honestly derived from `/my/visits` (+ the
/// user's location for nearest/farthest): a parchment ledger of temples,
/// states and cities, the monthly trend, where the visits were and how far
/// the nearest and farthest temples are. Distance travelled isn't derivable
/// from the backend and is omitted.
class ExploreStatisticsPage extends ConsumerWidget {
  const ExploreStatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(exploreStatisticsProvider);
    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.exStatistics,
          style: context.textTheme.titleMedium?.semiBold.withColor(context.scheme.secondary),
        ),
        centerTitle: true,
      ),
      body: async.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(
          title: l10n.exErrorTitle,
          message: l10n.exErrorBody,
          onRetry: () => ref.invalidate(exploreStatisticsProvider),
        ),
        data: (s) {
          if (s.isEmpty) {
            return EmptyView(art: StateArt.empty, icon: AppIcons.trending, title: l10n.exNoStats, message: l10n.exNoStatsBody);
          }
          final first = s.firstVisit;
          final since = first == null
              ? null
              : DateFormat.yMMM(Localizations.localeOf(context).toLanguageTag()).format(first.toLocal());
          final p = context.palette;
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(exploreStatisticsProvider),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.huge),
              children: [
                IntroBanner(
                  icon: AppIcons.trending,
                  title: l10n.exStatsTitle,
                  message: l10n.exStatsIntro,
                  status: since == null ? null : l10n.exExploringSince(since),
                ).fadeIn(),
                const Gap(AppSpacing.lg),
                StatLedger(
                  stats: [
                    LedgerStat(icon: AppIcons.temple, color: p.accentSaffron, value: s.templesExplored, label: l10n.exTemplesExplored),
                    LedgerStat(icon: AppIcons.publicMap, color: p.accentBlue, value: s.statesVisited, label: l10n.exStatesVisited),
                    LedgerStat(icon: AppIcons.location, color: p.accentViolet, value: s.citiesVisited, label: l10n.exCitiesVisited),
                    LedgerStat(icon: AppIcons.calendar, color: p.accentGreen, value: s.thisMonth, label: l10n.exThisMonth),
                  ],
                ).fadeIn(delay: AppDurations.stagger),
                const Gap(AppSpacing.xl),
                GoldRuleHeader(label: l10n.exMonthlyExploration),
                const Gap(AppSpacing.sm),
                ParchmentCard(
                  child: TrendChart(points: s.monthly, emptyMessage: l10n.exNoActivity),
                ).fadeIn(delay: AppDurations.stagger * 2),
                if (s.topStates.isNotEmpty) ...[
                  const Gap(AppSpacing.xl),
                  GoldRuleHeader(label: l10n.exWhereYouveBeen, count: s.statesVisited),
                  const Gap(AppSpacing.sm),
                  _WhereYouveBeen(states: s.topStates).fadeIn(delay: AppDurations.stagger * 3),
                ],
                if (s.nearestName != null || s.farthestName != null) ...[
                  const Gap(AppSpacing.xl),
                  GoldRuleHeader(label: l10n.exFromHere),
                  const Gap(AppSpacing.sm),
                  ParchmentCard(
                    child: Column(
                      children: [
                        if (s.nearestName != null)
                          _DistanceRow(
                            icon: AppIcons.nearby,
                            color: p.accentGreen,
                            label: l10n.exNearestTemple,
                            temple: s.nearestName!,
                            km: s.nearestKm,
                          ),
                        if (s.nearestName != null && s.farthestName != null)
                          const Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.md), child: GoldRule()),
                        if (s.farthestName != null)
                          _DistanceRow(
                            icon: AppIcons.location,
                            color: p.accentAmber,
                            label: l10n.exFarthestTemple,
                            temple: s.farthestName!,
                            km: s.farthestKm,
                          ),
                      ],
                    ),
                  ).fadeIn(delay: AppDurations.stagger * 4),
                ],
                const Gap(AppSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(AppIcons.info, size: 14, color: context.colors.textDisabled),
                    const Gap.h(AppSpacing.xs),
                    Expanded(
                      child: Text(l10n.exStatsNote, style: context.caption.copyWith(color: context.colors.textDisabled)),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// The most-visited states on parchment — each with its visit count and a
/// bar against the busiest one.
class _WhereYouveBeen extends StatelessWidget {
  const _WhereYouveBeen({required this.states});

  final List<(String, int)> states;

  static const double _icon = 36;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final most = states.first.$2;
    return ParchmentCard(
      child: Column(
        children: [
          for (final (i, (name, visits)) in states.indexed) ...[
            if (i > 0) const Gap(AppSpacing.md),
            Builder(
              builder: (context) {
                final accent = stateAccent(context, i);
                return Semantics(
                  label: '$name, ${l10n.exVisitsCount(visits)}',
                  excludeSemantics: true,
                  child: Row(
                    children: [
                      IllustratedIcon(fallbackIcon: AppIcons.publicMap, color: accent, size: _icon),
                      const Gap.h(AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.textTheme.bodyMedium?.semiBold.withColor(context.scheme.secondary),
                                  ),
                                ),
                                Text(l10n.exVisitsCount(visits), style: context.caption.semiBold.copyWith(color: accent)),
                              ],
                            ),
                            const Gap(AppSpacing.xs),
                            AppLinearProgress(
                              value: most == 0 ? 0 : visits / most,
                              height: 6,
                              color: accent,
                              backgroundColor: accent.withValues(alpha: 0.14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// "Nearest Temple · Shree Siddhivinayak Temple · 51 km".
class _DistanceRow extends StatelessWidget {
  const _DistanceRow({required this.icon, required this.color, required this.label, required this.temple, this.km});

  final IconData icon;
  final Color color;
  final String label;
  final String temple;
  final double? km;

  static const double _icon = 40;

  static String _distance(double km) =>
      km < 1 ? '${(km * 1000).round()} m' : '${km.toStringAsFixed(km < 10 ? 1 : 0)} km';

  @override
  Widget build(BuildContext context) {
    final km = this.km;
    return Row(
      children: [
        IllustratedIcon(fallbackIcon: icon, color: color, size: _icon),
        const Gap.h(AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: context.caption.copyWith(color: context.colors.textSecondary)),
              Text(
                temple,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium?.semiBold.withColor(context.scheme.secondary),
              ),
            ],
          ),
        ),
        if (km != null) ...[
          const Gap.h(AppSpacing.sm),
          Text(_distance(km), style: context.displayText.titleLarge.withColor(context.scheme.secondary)),
        ],
      ],
    );
  }
}
