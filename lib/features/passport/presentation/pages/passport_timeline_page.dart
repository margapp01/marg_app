import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/timeline_event.dart';
import '../controllers/passport_controllers.dart';
import '../widgets/passport_widgets.dart';

/// Spiritual Journey — visits, achievements and route completions, newest
/// first: the journey in numbers, type filters, then the story month by month.
class PassportTimelinePage extends ConsumerStatefulWidget {
  const PassportTimelinePage({super.key});

  @override
  ConsumerState<PassportTimelinePage> createState() => _PassportTimelinePageState();
}

class _PassportTimelinePageState extends ConsumerState<PassportTimelinePage> {
  TimelineEventType? _filter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(passportTimelineProvider);
    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.ppTimeline)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          title: l10n.ppErrorTitle,
          message: l10n.ppErrorBody,
          onRetry: () => ref.invalidate(passportTimelineProvider),
        ),
        data: (events) {
          if (events.isEmpty) {
            return EmptyView(art: StateArt.noVisits, icon: AppIcons.history, title: l10n.ppNoActivity, message: l10n.ppNoActivityBody);
          }
          int count(TimelineEventType t) => events.where((e) => e.type == t).length;
          final p = context.palette;
          final filtered = _filter == null ? events : events.where((e) => e.type == _filter).toList();
          final months = _byMonth(filtered);
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(passportTimelineProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.huge),
              children: [
                StatLedger(
                  stats: [
                    LedgerStat(icon: AppIcons.temple, color: p.accentSaffron, value: count(TimelineEventType.visit), label: l10n.ppVisitsPlotted),
                    LedgerStat(icon: AppIcons.route, color: p.accentBlue, value: count(TimelineEventType.route), label: l10n.ppRoutes),
                    LedgerStat(icon: AppIcons.achievement, color: p.accentAmber, value: count(TimelineEventType.achievement), label: l10n.ppAchievements),
                  ],
                ).fadeIn(),
                const Gap(AppSpacing.lg),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final (label, type) in [
                        (l10n.ppAll, null),
                        (l10n.ppTemples, TimelineEventType.visit),
                        (l10n.ppRoutes, TimelineEventType.route),
                        (l10n.ppAchievements, TimelineEventType.achievement),
                      ]) ...[
                        AppFilterChip(
                          label: label,
                          icon: type == null ? AppIcons.history : timelineStyle(context, type).$1,
                          selected: _filter == type,
                          onSelected: (_) => setState(() => _filter = type),
                        ),
                        const Gap.h(AppSpacing.sm),
                      ],
                    ],
                  ),
                ),
                const Gap(AppSpacing.md),
                for (final (month, items) in months) ...[
                  GoldRuleHeader(
                    label: DateFormat.yMMMM(Localizations.localeOf(context).toLanguageTag()).format(month),
                    count: items.length,
                  ),
                  const Gap(AppSpacing.sm),
                  for (final (i, e) in items.indexed)
                    TimelineEventTile(event: e, isLast: i == items.length - 1, onTap: _destination(context, e)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  VoidCallback? _destination(BuildContext context, TimelineEvent e) {
    final slug = e.slug;
    return switch (e.type) {
      TimelineEventType.visit when slug != null =>
        () => context.pushNamed(RouteNames.templeDetail, pathParameters: {RoutePaths.templeIdParam: slug}),
      TimelineEventType.route when slug != null =>
        () => context.pushNamed(RouteNames.routeDetail, pathParameters: {RoutePaths.routeSlugParam: slug}),
      TimelineEventType.achievement => () => context.pushNamed(RouteNames.achievements),
      _ => null,
    };
  }

  /// Events grouped by calendar month, keeping their newest-first order.
  static List<(DateTime, List<TimelineEvent>)> _byMonth(List<TimelineEvent> events) {
    final groups = <(DateTime, List<TimelineEvent>)>[];
    for (final e in events) {
      final month = DateTime(e.date.year, e.date.month);
      if (groups.isEmpty || groups.last.$1 != month) groups.add((month, []));
      groups.last.$2.add(e);
    }
    return groups;
  }
}
