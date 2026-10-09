import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/collection_group.dart';
import '../../domain/entities/collection_stats.dart';
import '../controllers/cards_controllers.dart';
import '../widgets/card_widgets.dart';

/// Collection Statistics — by-rarity distribution + series/season completion.
/// The backend exposes rarity + group completion only; by-deity/state/route
/// groupings are not available and are intentionally not shown.
class CollectionStatsPage extends ConsumerWidget {
  const CollectionStatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final statsAsync = ref.watch(collectionStatsProvider);

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.scStatistics)),
      body: statsAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          title: l10n.scErrorTitle,
          message: l10n.scErrorBody,
          onRetry: () => ref.invalidate(collectionStatsProvider),
        ),
        data: (stats) => ListView(
          padding: AppSpacing.screenAll,
          children: [
            _Overview(stats: stats),
            const Gap(AppSpacing.lg),
            SectionHeader(title: l10n.scByRarity),
            const Gap(AppSpacing.sm),
            _RarityChart(stats: stats),
            const Gap(AppSpacing.lg),
            SectionHeader(title: l10n.scSeriesCompletion),
            const Gap(AppSpacing.sm),
            _GroupCompletion(provider: seriesProgressProvider),
            const Gap(AppSpacing.lg),
            SectionHeader(title: l10n.scSeasonCompletion),
            const Gap(AppSpacing.sm),
            _GroupCompletion(provider: seasonProgressProvider),
          ],
        ),
      ),
    );
  }
}

class _Overview extends StatelessWidget {
  const _Overview({required this.stats});
  final CollectionStats stats;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      child: Row(
        children: [
          _stat(context, '${stats.ownedCards}', l10n.scOwned),
          _divider(context),
          _stat(context, '${stats.missingCards}', l10n.scMissing),
          _divider(context),
          _stat(context, '${stats.percent}%', l10n.scComplete),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String value, String label) => Expanded(
        child: Column(
          children: [
            Text(value, style: context.textTheme.titleLarge?.bold),
            Text(label, style: context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary)),
          ],
        ),
      );

  Widget _divider(BuildContext context) => Container(width: 1, height: 36, color: context.colors.divider);
}

class _RarityChart extends StatelessWidget {
  const _RarityChart({required this.stats});
  final CollectionStats stats;
  @override
  Widget build(BuildContext context) {
    final max = stats.byRarity.values.fold<int>(1, (m, v) => v > m ? v : m);
    return AppCard(
      child: Column(
        children: [
          for (final r in stats.rarityOrder)
            RarityBar(rarity: r, owned: stats.ownedOf(r), max: max),
        ],
      ),
    );
  }
}

class _GroupCompletion extends ConsumerWidget {
  const _GroupCompletion({required this.provider});
  final ProviderListenable<AsyncValue<List<CollectionGroup>>> provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(provider);
    return async.maybeWhen(
      orElse: () => const SizedBox(height: 40, child: Center(child: CircularProgressIndicator())),
      data: (groups) {
        if (groups.isEmpty) {
          return Text(l10n.scNoGroupsBody,
              style: context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary));
        }
        return AppCard(
          child: Column(
            children: [
              for (var i = 0; i < groups.length; i++) ...[
                if (i > 0) AppDivider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Row(
                    children: [
                      Expanded(child: Text(groups[i].name, style: context.textTheme.bodyMedium?.medium, maxLines: 1, overflow: TextOverflow.ellipsis)),
                      Text('${groups[i].ownedCards}/${groups[i].totalCards}',
                          style: context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary)),
                      const Gap(AppSpacing.sm),
                      Text('${groups[i].percent}%',
                          style: context.textTheme.bodyMedium?.bold.copyWith(color: context.scheme.primary)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
