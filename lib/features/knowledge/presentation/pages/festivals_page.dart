import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/knowledge_models.dart';
import '../controllers/knowledge_controllers.dart';
import '../widgets/knowledge_widgets.dart';

/// Screen 5 — Festival Explorer. Upcoming festivals grouped by month (a
/// lightweight calendar view), each opening a detail screen.
class FestivalsPage extends ConsumerWidget {
  const FestivalsPage({super.key});

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(upcomingFestivalsProvider);

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.kbFestivals)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(title: l10n.kbErrorTitle, message: l10n.kbErrorBody, onRetry: () => ref.invalidate(upcomingFestivalsProvider)),
        data: (festivals) {
          if (festivals.isEmpty) {
            return EmptyView(art: StateArt.festivals, icon: AppIcons.festival, title: l10n.kbNoFestivals, message: l10n.kbNoFestivalsBody);
          }
          final groups = _groupByMonth(festivals);
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(upcomingFestivalsProvider),
            child: ListView(
              padding: AppSpacing.screenAll,
              children: [
                for (final entry in groups.entries) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.sm),
                    child: Text(entry.key, style: context.textTheme.titleSmall?.semiBold.copyWith(color: context.scheme.primary)),
                  ),
                  for (final f in entry.value) ...[
                    FestivalTile(festival: f, onTap: () => context.pushNamed(RouteNames.knowledgeFestivalDetail, pathParameters: {'slug': f.slug})),
                    const Gap(AppSpacing.sm),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  /// Groups festivals under a "Month Year" header, preserving start-date order.
  Map<String, List<Festival>> _groupByMonth(List<Festival> festivals) {
    final map = <String, List<Festival>>{};
    for (final f in festivals) {
      final d = f.startDate;
      final key = d == null ? '' : '${_months[d.month - 1]} ${d.year}';
      map.putIfAbsent(key, () => []).add(f);
    }
    return map;
  }
}
