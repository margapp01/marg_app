import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/explore_models.dart';
import '../controllers/explore_controllers.dart';
import '../widgets/explore_widgets.dart';
import 'browse_temples_page.dart';

/// Screen 5 — State Explorer, in the Categories page's language: a parchment
/// intro with the totals, the richest state as a featured photo card, then
/// every state as a photo card led by its most-visited temple. (Per-state
/// personal completion isn't modelled on the backend, so it isn't shown.)
class StateExplorerPage extends ConsumerWidget {
  const StateExplorerPage({super.key});

  static const double _tileExtent = 188;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(exploreStatesProvider);
    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.exStateExplorer,
          style: context.textTheme.titleMedium?.semiBold.withColor(context.scheme.secondary),
        ),
        centerTitle: true,
      ),
      body: async.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(
          title: l10n.exErrorTitle,
          message: l10n.exErrorBody,
          onRetry: () => ref.invalidate(exploreStatesProvider),
        ),
        data: (states) {
          if (states.isEmpty) {
            return EmptyView(
              art: StateArt.noResults,
              icon: AppIcons.publicMap,
              title: l10n.exNoStates,
              message: l10n.exNoStatesBody,
            );
          }
          final totalTemples = states.fold<int>(0, (n, s) => n + (s.templeCount ?? 0));
          void open(ExploreStateItem s) => context.pushNamed(
            RouteNames.exploreBrowse,
            extra: BrowseArgs(
              title: s.name,
              query: (deity: null, stateId: s.id, cityId: null, sort: ExploreSort.popular),
            ),
          );
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(exploreStatesProvider),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
                  sliver: SliverList.list(
                    children: [
                      IntroBanner(
                        icon: AppIcons.publicMap,
                        title: l10n.exDiscoverBharat,
                        message: l10n.exStatesIntro,
                        status: l10n.exStatesStatus(states.length, totalTemples),
                      ).fadeIn(),
                      const Gap(AppSpacing.lg),
                      SizedBox(
                        height: ExploreCoverCard.featuredHeight,
                        child: _StateCard(state: states.first, index: 0, featured: true, onTap: () => open(states.first)),
                      ).fadeIn(delay: AppDurations.stagger),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.huge),
                  sliver: SliverGrid.builder(
                    itemCount: states.length - 1,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: context.responsive(compact: 2, medium: 3, expanded: 4),
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisExtent: _tileExtent,
                    ),
                    itemBuilder: (context, i) {
                      final s = states[i + 1];
                      return _StateCard(
                        state: s,
                        index: i + 1,
                        onTap: () => open(s),
                      ).fadeIn(delay: AppDurations.stagger * (i + 2));
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.state, required this.index, required this.onTap, this.featured = false});

  final ExploreStateItem state;
  final int index;
  final VoidCallback onTap;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accent = stateAccent(context, index);
    final top = state.topTemple;
    return ExploreCoverCard(
      title: state.name,
      countLabel: l10n.exStateTemples(state.templeCount ?? 0),
      caption: featured && top != null ? l10n.exMostVisited(top) : null,
      coverImage: state.coverImage,
      accent: accent,
      emblem: CoverEmblem(icon: AppIcons.publicMap, color: accent, featured: featured),
      featured: featured,
      onTap: onTap,
    );
  }
}
