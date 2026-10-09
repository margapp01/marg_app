import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/explore_models.dart';
import '../controllers/explore_controllers.dart';

/// Saved Places — the devotee's temple wishlist (`/my/saved-temples`).
/// A responsive grid of photo cards; the heart removes a temple instantly.
class SavedTemplesPage extends ConsumerWidget {
  const SavedTemplesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(savedTemplesProvider);
    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.homeActionSaved)),
      body: async.when(
        skipLoadingOnRefresh: true,
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(
          title: l10n.exErrorTitle,
          message: l10n.exErrorBody,
          onRetry: () => ref.invalidate(savedTemplesProvider),
        ),
        data: (saved) => saved.isEmpty
            ? EmptyView(art: StateArt.savedPlaces, 
                icon: AppIcons.favorite,
                title: l10n.savedEmptyTitle,
                message: l10n.savedEmptyBody,
                action: AppButton.primary(
                  label: l10n.savedExplore,
                  icon: AppIcons.explore,
                  expand: false,
                  onPressed: () => context.goNamed(RouteNames.explore),
                ),
              )
            : RefreshIndicator(
                onRefresh: () => ref.read(savedTemplesProvider.notifier).refresh(),
                child: _SavedGrid(saved: saved),
              ),
      ),
    );
  }
}

class _SavedGrid extends ConsumerWidget {
  const _SavedGrid({required this.saved});

  final List<SavedTemple> saved;

  Future<void> _remove(BuildContext context, WidgetRef ref, SavedTemple s) async {
    final l10n = AppLocalizations.of(context);
    final ok = await ref.read(savedTemplesProvider.notifier).remove(s.temple.id);
    if (!context.mounted) return;
    ok ? AppSnackbar.info(context, l10n.savedRemoved) : AppSnackbar.error(context, l10n.savedRemoveFailed);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final columns = context.responsive(compact: 2, medium: 3, expanded: 4);
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: AppSpacing.screenAll.copyWith(bottom: 0),
          sliver: SliverToBoxAdapter(
            child: Text(
              l10n.savedCount(saved.length),
              style: context.caption.copyWith(color: context.colors.textSecondary),
            ),
          ),
        ),
        SliverPadding(
          padding: AppSpacing.screenAll,
          sliver: SliverGrid.builder(
            itemCount: saved.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              mainAxisExtent: 236,
            ),
            itemBuilder: (context, i) {
              final s = saved[i];
              final t = s.temple;
              return TempleCardBase(
                dense: true,
                imageHeight: 120,
                name: t.name,
                location: t.place,
                imageUrl: t.imageUrl,
                chip: s.visited ? PhotoPill(label: l10n.savedVisited, icon: AppIcons.verified) : null,
                badge: _HeartButton(tooltip: l10n.savedRemove, onPressed: () => _remove(context, ref, s)),
                footer: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xxs,
                  children: [
                    RatingBadge(rating: t.ratingAverage, count: t.ratingCount),
                    OpenStatusLabel(
                      isOpen: t.openStatus.isOpen,
                      opensAt: t.openStatus.opensAt,
                      closesAt: t.openStatus.closesAt,
                    ),
                  ],
                ),
                onTap: () =>
                    context.pushNamed(RouteNames.templeDetail, pathParameters: {RoutePaths.templeIdParam: t.slug}),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Filled heart on a frosted disc, top-right of a photo.
class _HeartButton extends StatelessWidget {
  const _HeartButton({required this.tooltip, required this.onPressed});

  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.card.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(AppIcons.favorite, color: context.palette.accentRose, fill: 1, size: 20),
      ),
    );
  }
}
