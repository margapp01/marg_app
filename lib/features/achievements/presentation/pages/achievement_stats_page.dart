import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/achievement_collection.dart';
import '../controllers/achievements_controllers.dart';
import '../widgets/achievement_widgets.dart';

/// Achievement Statistics — completion overview, a by-rarity donut, and a
/// by-category breakdown. All derived from the progress buckets.
class AchievementStatsPage extends ConsumerWidget {
  const AchievementStatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(achievementCollectionProvider);
    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.acStatistics)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          title: l10n.acErrorTitle,
          message: l10n.acErrorBody,
          onRetry: () => ref.invalidate(achievementCollectionProvider),
        ),
        data: (c) => ListView(
          padding: AppSpacing.screenAll,
          children: [
            _Overview(collection: c),
            const Gap(AppSpacing.xl),
            SectionHeader(title: l10n.acByRarity),
            const Gap(AppSpacing.md),
            _RarityDonut(collection: c),
            const Gap(AppSpacing.xl),
            SectionHeader(title: l10n.acByCategory),
            const Gap(AppSpacing.md),
            _CategoryBreakdown(collection: c),
          ],
        ),
      ),
    );
  }
}

class _Overview extends StatelessWidget {
  const _Overview({required this.collection});
  final AchievementCollection collection;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      child: Row(
        children: [
          _stat(context, '${collection.total}', l10n.acTotal),
          _divider(context),
          _stat(context, '${collection.earnedCount}', l10n.acCompleted),
          _divider(context),
          _stat(context, '${collection.completionPercent}%', l10n.acCompletionPct),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String value, String label) => Expanded(
        child: Column(
          children: [
            Text(value, style: context.textTheme.titleLarge?.bold),
            Text(label, style: context.caption.copyWith(color: context.colors.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      );

  Widget _divider(BuildContext context) => Container(width: 1, height: 36, color: context.colors.divider);
}

class _RarityDonut extends StatelessWidget {
  const _RarityDonut({required this.collection});
  final AchievementCollection collection;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final byRarity = collection.byRarity;
    final segments = [
      for (final entry in byRarity.entries)
        (value: entry.value.earned.toDouble(), color: rarityColor(context, entry.key)),
    ];
    final anyEarned = segments.any((s) => s.value > 0);
    return AppCard(
      child: Row(
        children: [
          StatDonut(
            segments: anyEarned ? segments : const [],
            centerLabel: '${collection.earnedCount}',
            centerSub: l10n.acEarned,
          ),
          const Gap(AppSpacing.lg),
          Expanded(
            child: Column(
              children: [
                for (final entry in byRarity.entries)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                    child: Row(
                      children: [
                        Container(width: 10, height: 10, decoration: BoxDecoration(color: rarityColor(context, entry.key), shape: BoxShape.circle)),
                        const Gap(AppSpacing.sm),
                        Expanded(child: Text(entry.key, style: context.textTheme.bodySmall)),
                        Text('${entry.value.earned}/${entry.value.total}',
                            style: context.textTheme.bodySmall?.semiBold),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({required this.collection});
  final AchievementCollection collection;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        children: [
          for (final cat in collection.categories) ...[
            Builder(builder: (context) {
              final p = collection.categoryProgress(cat);
              final meta = categoryMeta(l10n, cat);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  children: [
                    SizedBox(width: 120, child: Text(meta.label, style: context.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Expanded(child: AppLinearProgress(value: p.total == 0 ? 0 : (p.earned / p.total).clamp(0, 1), height: 8)),
                    const Gap(AppSpacing.sm),
                    SizedBox(width: 44, child: Text('${p.earned}/${p.total}', style: context.textTheme.bodySmall?.semiBold, textAlign: TextAlign.end)),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
