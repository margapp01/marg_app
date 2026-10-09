import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/hub_content.dart';
import '../controllers/notification_controllers.dart';
import '../widgets/notification_widgets.dart';

enum _FestTab { upcoming, today, thisWeek }

/// Screen 3 — Festival Updates: upcoming + today's festivals with countdowns,
/// backed by `GET /festivals/upcoming`.
class FestivalUpdatesPage extends ConsumerStatefulWidget {
  const FestivalUpdatesPage({super.key});

  @override
  ConsumerState<FestivalUpdatesPage> createState() => _FestivalUpdatesPageState();
}

class _FestivalUpdatesPageState extends ConsumerState<FestivalUpdatesPage> {
  _FestTab _tab = _FestTab.upcoming;

  bool _matches(Festival f) => switch (_tab) {
        _FestTab.upcoming => true,
        _FestTab.today => f.isToday,
        _FestTab.thisWeek => (f.daysUntil ?? 999) <= 7,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(upcomingFestivalsProvider);

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.ntFestivals)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(title: l10n.ntErrorTitle, message: l10n.ntErrorBody, onRetry: () => ref.invalidate(upcomingFestivalsProvider)),
        data: (all) {
          final list = all.where(_matches).toList();
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(upcomingFestivalsProvider),
            child: ListView(
              padding: AppSpacing.screenAll,
              children: [
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _chip(l10n.ntUpcoming, _FestTab.upcoming),
                      const Gap(AppSpacing.sm),
                      _chip(l10n.ntToday, _FestTab.today),
                      const Gap(AppSpacing.sm),
                      _chip(l10n.ntThisWeek, _FestTab.thisWeek),
                    ],
                  ),
                ),
                const Gap(AppSpacing.md),
                if (list.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xxl),
                    child: EmptyView(art: StateArt.festivals, icon: AppIcons.aarti, title: l10n.ntNoFestivals, message: l10n.ntNoFestivalsBody),
                  )
                else ...[
                  FestivalBanner(festival: list.first, onTap: () => _openFestival(context, list.first)),
                  if (list.length > 1) ...[
                    const Gap(AppSpacing.lg),
                    SectionHeader(title: l10n.ntUpcomingFestivals),
                    const Gap(AppSpacing.sm),
                    for (final f in list.skip(1))
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: FestivalRow(festival: f, onTap: () => _openFestival(context, f)),
                      ),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _chip(String label, _FestTab tab) => Center(child: AppFilterChip(label: label, selected: _tab == tab, onSelected: (_) => setState(() => _tab = tab)));

  void _openFestival(BuildContext context, Festival f) {
    AppSheets.show<void>(
      context,
      padded: false,
      builder: (_) => _FestivalDetailSheet(slug: f.slug, fallback: f),
    );
  }
}

class _FestivalDetailSheet extends ConsumerWidget {
  const _FestivalDetailSheet({required this.slug, required this.fallback});
  final String slug;
  final Festival fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(festivalProvider(slug));
    final f = async.valueOrNull ?? fallback;
    final hasDescription = f.description != null && f.description!.isNotEmpty;
    return AppSheetLayout(
      title: f.name,
      subtitle: f.startDate == null ? null : fullDate(f.startDate!),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (f.imageUrl != null) ...[
            ClipRRect(borderRadius: AppRadius.card, child: AppNetworkImage(url: f.imageUrl!, height: 180, width: double.infinity)),
            const Gap(AppSpacing.md),
          ],
          if (!f.isToday && f.daysUntil != null) ...[
            AppBadge(label: '${f.daysUntil} ${l10n.ntDaysToGo}', icon: AppIcons.calendar, tone: AppBadgeTone.primary),
            const Gap(AppSpacing.md),
          ],
          if (hasDescription)
            Text(f.description!, style: context.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary, height: 1.5)),
        ],
      ),
    );
  }
}
