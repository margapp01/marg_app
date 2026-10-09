import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';

/// Shimmer shown while a query is in flight.
class SearchSkeleton extends StatelessWidget {
  const SearchSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        padding: AppSpacing.screenAll,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const SkeletonLine(widthFactor: 0.35, height: 14),
          const Gap(AppSpacing.lg),
          for (var i = 0; i < 6; i++) ...[
            Row(
              children: [
                const SkeletonBox(width: 52, height: 52, radius: AppRadius.mdAll),
                const Gap.h(AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonLine(widthFactor: 0.6, height: 12),
                      Gap(AppSpacing.sm),
                      SkeletonLine(widthFactor: 0.4, height: 10),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}

/// Beautiful empty state — "No results for X" + a way forward.
class SearchEmptyState extends StatelessWidget {
  const SearchEmptyState({
    required this.query,
    required this.onViewNearby,
    this.suggestions = const [],
    this.onSuggestion,
    super.key,
  });

  final String query;
  final VoidCallback onViewNearby;
  final List<String> suggestions;
  final ValueChanged<String>? onSuggestion;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: AppSpacing.screenAll,
      children: [
        const Gap(AppSpacing.lg),
        const Center(child: FadeIn(child: StateArtImage(StateArt.noResults))),
        const Gap(AppSpacing.lg),
        Text(
          l10n.searchEmptyTitle,
          textAlign: TextAlign.center,
          style: context.displayText.headlineSmall,
        ),
        const Gap(AppSpacing.sm),
        const Center(child: LotusRule()),
        const Gap(AppSpacing.sm),
        Text(
          '${l10n.searchNoResultsFor} "$query"',
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary),
        ),
        const Gap(AppSpacing.xs),
        Text(
          l10n.searchEmptySubtitle,
          textAlign: TextAlign.center,
          style: context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary),
        ),
        if (suggestions.isNotEmpty) ...[
          const Gap(AppSpacing.xl),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final s in suggestions)
                ActionChip(
                  label: Text(s),
                  onPressed: onSuggestion == null ? null : () => onSuggestion!(s),
                ),
            ],
          ),
        ],
        const Gap(AppSpacing.xl),
        AppButton.primary(
          label: l10n.searchViewNearby,
          icon: AppIcons.nearby,
          onPressed: onViewNearby,
        ),
      ],
    );
  }
}

/// Offline / error inline state with retry.
class SearchInlineError extends StatelessWidget {
  const SearchInlineError({required this.offline, required this.onRetry, super.key});

  final bool offline;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ErrorView(
      art: offline ? StateArt.offline : StateArt.error,
      title: offline ? l10n.searchOfflineTitle : l10n.searchErrorTitle,
      message: offline ? l10n.searchOfflineSubtitle : l10n.homeErrorMessage,
      retryLabel: l10n.commonRetry,
      onRetry: onRetry,
    );
  }
}
