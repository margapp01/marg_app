import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/app_shell.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../shared/design_system.dart';
import '../../../notifications/presentation/controllers/notification_controllers.dart';
import '../../domain/entities/explore_models.dart';
import '../controllers/explore_controllers.dart';
import '../widgets/explore_widgets.dart';
import 'browse_temples_page.dart';

/// Screen 1 — the Explore Bharat hub: location + search, discovery tools, and
/// live rails (nearby, popular, categories, states, recently visited).
class ExploreDashboardPage extends ConsumerWidget {
  const ExploreDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locAsync = ref.watch(exploreLocationProvider);

    return Scaffold(
      backgroundColor: context.scheme.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(explorePopularProvider);
          ref.invalidate(exploreNewestProvider);
          ref.invalidate(exploreCategoriesProvider);
          ref.invalidate(exploreStatesProvider);
          ref.invalidate(exploreRecentVisitsProvider);
          await ref.read(exploreLocationProvider.notifier).locate();
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            TabHeader(
              title: l10n.exTitle,
              subtitle: l10n.exGreeting,
              onMenu: AppShell.openMenu,
              onNotifications: () => context.pushNamed(RouteNames.notifications),
              notificationCount: ref.watch(unreadBadgeProvider),
            ),
            Padding(
              padding: AppSpacing.screenH,
              child: _SearchRow(
                hint: l10n.exSearchHint,
                onSearch: () => context.pushNamed(RouteNames.search, extra: _SearchRow.heroTag),
                onLocate: () => ref.read(exploreLocationProvider.notifier).locate(),
              ),
            ),
            const Gap(AppSpacing.md),
            Padding(
              padding: AppSpacing.screenH,
              child: _LocationCard(
                precise: locAsync.valueOrNull?.precise ?? false,
                onChange: () => ref.read(exploreLocationProvider.notifier).locate(),
              ),
            ),
            const Gap(AppSpacing.xl),
            _Tools(),
            const Gap(AppSpacing.xl),
            _NearbyRail(location: locAsync.valueOrNull),
            _PopularRail(),
            _CategoriesRail(),
            _StatesRail(),
            _RecentRail(),
            const Gap(AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

/// Tap-to-search pill with a saffron "locate me" button beside it.
class _SearchRow extends StatelessWidget {
  const _SearchRow({required this.hint, required this.onSearch, required this.onLocate});

  static final String heroTag = AppSearchBar.heroTagFor('explore');

  final String hint;
  final VoidCallback onSearch;
  final VoidCallback onLocate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(child: AppSearchBar(hint: hint, onTap: onSearch, heroTag: heroTag)),
        const Gap.h(AppSpacing.sm),
        Tooltip(
          message: l10n.exLocate,
          child: Material(
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: Ink(
              decoration: const BoxDecoration(gradient: AppGradients.primary, shape: BoxShape.circle),
              child: InkWell(
                onTap: onLocate,
                child: SizedBox.square(
                  dimension: AppSearchBar.height,
                  child: Icon(AppIcons.nearby, color: context.scheme.onPrimary, fill: 1),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.precise, required this.onChange});

  final bool precise;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.xs, AppSpacing.sm),
      child: Row(
        children: [
          IllustratedIcon(
            fallbackIcon: precise ? AppIcons.myLocation : AppIcons.location,
            color: context.palette.accentSaffron,
            size: 40,
          ),
          const Gap.h(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.exCurrentLocation, style: context.caption.copyWith(color: context.colors.textSecondary)),
                Text(precise ? l10n.exNearYou : l10n.exApproxArea, style: context.textTheme.titleSmall?.semiBold),
              ],
            ),
          ),
          TextButton(onPressed: onChange, child: Text(l10n.exChange)),
        ],
      ),
    );
  }
}

class _Tools extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final tools = <(IconData, String, String, Color, Color)>[
      (AppIcons.nearby, l10n.exNearby, RouteNames.exploreNearby, p.tileSky, p.accentBlue),
      (AppIcons.map, l10n.exMap, RouteNames.exploreMap, p.tileMint, p.accentGreen),
      (AppIcons.category, l10n.exCategories, RouteNames.exploreCategories, p.tilePeach, p.accentSaffron),
      (AppIcons.publicMap, l10n.exStates, RouteNames.exploreStates, p.tileButter, p.accentAmber),
      (AppIcons.layers, l10n.exCollections, RouteNames.exploreCollections, p.tileLavender, p.accentViolet),
      (AppIcons.favorite, l10n.homeActionSaved, RouteNames.exploreSaved, p.tileRose, p.accentRose),
      (AppIcons.trending, l10n.exStatistics, RouteNames.exploreStatistics, p.tileMint, p.accentGreen),
    ];
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.screenH,
        itemCount: tools.length,
        separatorBuilder: (_, _) => const Gap.h(AppSpacing.sm),
        itemBuilder: (context, i) {
          final (icon, label, route, tint, accent) = tools[i];
          return _ToolTile(icon: icon, label: label, tint: tint, accent: accent, onTap: () => context.pushNamed(route));
        },
      ),
    );
  }
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({
    required this.icon,
    required this.label,
    required this.tint,
    required this.accent,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color tint;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      child: Semantics(
        button: true,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.lgAll,
          child: Column(
            children: [
              IllustratedIcon(fallbackIcon: icon, color: accent, background: tint, size: 56),
              const Gap(AppSpacing.xs),
              Text(
                label,
                style: context.textTheme.labelSmall?.semiBold,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A horizontal rail of temple cards backed by an async provider.
class _Rail extends StatelessWidget {
  const _Rail({required this.title, required this.onViewAll, required this.child});
  final String title;
  final VoidCallback? onViewAll;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSpacing.screenH,
          child: SectionHeader(title: title, onViewAll: onViewAll, viewAllLabel: l10n.exViewAll),
        ),
        const Gap(AppSpacing.sm),
        child,
        const Gap(AppSpacing.lg),
      ],
    );
  }
}

class _NearbyRail extends ConsumerWidget {
  const _NearbyRail({required this.location});
  final ExploreLocation? location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (location == null) return const SizedBox.shrink();
    final async = ref.watch(
      exploreNearbyProvider((lat: location!.latitude, lng: location!.longitude, radiusKm: 25, deity: null)),
    );
    return _Rail(
      title: l10n.exNearbyTemples,
      onViewAll: () => context.pushNamed(RouteNames.exploreNearby),
      child: async.when(
        loading: () => const _RailLoader(height: ExploreTempleCard.railHeight),
        error: (_, _) => _RailMessage(text: l10n.exErrorBody),
        data: (temples) => temples.isEmpty
            ? _RailMessage(text: l10n.exNoNearby, icon: AppIcons.nearby)
            : SizedBox(
                height: ExploreTempleCard.railHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: AppSpacing.screenH,
                  itemCount: temples.length.clamp(0, 10),
                  separatorBuilder: (_, _) => const Gap(AppSpacing.sm),
                  itemBuilder: (context, i) => ExploreTempleCard(
                    temple: temples[i],
                    compact: true,
                    onTap: () => context.pushNamed(
                      RouteNames.templeDetail,
                      pathParameters: {RoutePaths.templeIdParam: temples[i].slug},
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _PopularRail extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(explorePopularProvider);
    return _Rail(
      title: l10n.exPopularToday,
      onViewAll: () => context.pushNamed(
        RouteNames.exploreBrowse,
        extra: BrowseArgs(title: l10n.exPopular, query: (deity: null, stateId: null, cityId: null, sort: ExploreSort.popular)),
      ),
      child: async.when(
        loading: () => const _RailLoader(height: ExploreTempleCard.railHeight),
        error: (_, _) => _RailMessage(text: l10n.exErrorBody),
        data: (temples) => temples.isEmpty
            ? _RailMessage(text: l10n.exNoTemples, icon: AppIcons.temple)
            : SizedBox(
                height: ExploreTempleCard.railHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: AppSpacing.screenH,
                  itemCount: temples.length,
                  separatorBuilder: (_, _) => const Gap(AppSpacing.sm),
                  itemBuilder: (context, i) => ExploreTempleCard(
                    temple: temples[i],
                    compact: true,
                    onTap: () => context.pushNamed(
                      RouteNames.templeDetail,
                      pathParameters: {RoutePaths.templeIdParam: temples[i].slug},
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

/// The deity categories as photo cards — each led by its most-visited
/// temple — biggest first, as on the Categories page.
class _CategoriesRail extends ConsumerWidget {
  static const double _width = 156;
  static const double _height = 188;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(exploreCategoriesProvider);
    return _Rail(
      title: l10n.exCategories,
      onViewAll: () => context.pushNamed(RouteNames.exploreCategories),
      child: async.when(
        loading: () => const _RailLoader(height: _height),
        error: (_, _) => _RailMessage(text: l10n.exErrorBody),
        data: (all) {
          final cats = all.where((c) => c.count > 0).toList()..sort((a, b) => b.count.compareTo(a.count));
          if (cats.isEmpty) return _RailMessage(text: l10n.exNoTemples, icon: AppIcons.category);
          return SizedBox(
            height: _height,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: AppSpacing.screenH,
              itemCount: cats.length,
              separatorBuilder: (_, _) => const Gap.h(AppSpacing.sm),
              itemBuilder: (context, i) => SizedBox(
                width: _width,
                child: CategoryCard(
                  category: cats[i],
                  onTap: () => context.pushNamed(
                    RouteNames.exploreBrowse,
                    extra: BrowseArgs(
                      title: deityLabel(l10n, cats[i].deity.wire),
                      query: (deity: cats[i].deity, stateId: null, cityId: null, sort: ExploreSort.popular),
                    ),
                  ),
                ),
              ).slideIn(delay: AppDurations.stagger * i, from: const Offset(24, 0)),
            ),
          );
        },
      ),
    );
  }
}

class _StatesRail extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(exploreStatesProvider);
    return _Rail(
      title: l10n.exExploreByState,
      onViewAll: () => context.pushNamed(RouteNames.exploreStates),
      child: async.when(
        loading: () => const _RailLoader(height: _stateTileHeight),
        error: (_, _) => _RailMessage(text: l10n.exErrorBody),
        data: (states) => SizedBox(
          height: _stateTileHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: AppSpacing.screenH,
            itemCount: states.length.clamp(0, 12),
            separatorBuilder: (_, _) => const Gap.h(AppSpacing.sm),
            itemBuilder: (context, i) => SizedBox(
              width: _stateTileWidth,
              child: AccentTile(
                icon: AppIcons.publicMap,
                watermark: AppIcons.temple,
                title: states[i].name,
                subtitle: l10n.exStateTemples(states[i].templeCount ?? 0),
                accent: stateAccent(context, i),
                onTap: () => context.pushNamed(
                  RouteNames.exploreBrowse,
                  extra: BrowseArgs(
                    title: states[i].name,
                    query: (deity: null, stateId: states[i].id, cityId: null, sort: ExploreSort.popular),
                  ),
                ),
              ),
            ).slideIn(delay: AppDurations.stagger * i, from: const Offset(24, 0)),
          ),
        ),
      ),
    );
  }
}

const double _stateTileWidth = 152;
const double _stateTileHeight = 116;

class _RecentRail extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(exploreRecentVisitsProvider);
    final visits = async.valueOrNull ?? const [];
    if (visits.isEmpty) return const SizedBox.shrink();
    return _Rail(
      title: l10n.exRecentlyVisited,
      onViewAll: null,
      child: SizedBox(
        height: _VisitedTile.height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: AppSpacing.screenH,
          itemCount: visits.length.clamp(0, 10),
          separatorBuilder: (_, _) => const Gap.h(AppSpacing.sm),
          itemBuilder: (context, i) {
            final v = visits[i];
            return _VisitedTile(
              visit: v,
              onTap: v.templeSlug == null
                  ? null
                  : () => context.pushNamed(
                        RouteNames.templeDetail,
                        pathParameters: {RoutePaths.templeIdParam: v.templeSlug!},
                      ),
            ).slideIn(delay: AppDurations.stagger * i, from: const Offset(24, 0));
          },
        ),
      ),
    );
  }
}

/// A visited temple as an immersive photo card: the photo under a navy fade,
/// a "Visited" pill, the name in the display face and where/when.
class _VisitedTile extends StatelessWidget {
  const _VisitedTile({required this.visit, required this.onTap});
  final VisitRecord visit;
  final VoidCallback? onTap;

  static const double width = 224;
  static const double height = 156;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final light = context.colors.card;
    final when = visit.visitedAt == null
        ? null
        : DateFormat('d MMM', Localizations.localeOf(context).toLanguageTag()).format(visit.visitedAt!.toLocal());
    final subtitle = [visit.place, when].whereType<String>().join(' · ');
    final sand = ColoredBox(
      color: context.colors.templeSand,
      child: Center(child: Icon(AppIcons.temple, size: 56, color: context.colors.templeStone)),
    );
    return SizedBox(
      width: width,
      child: ClipRRect(
        borderRadius: AppRadius.card,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (visit.imageUrl == null) sand else AppNetworkImage(url: visit.imageUrl!, fit: BoxFit.cover, fallback: sand),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [context.scheme.secondary.withValues(alpha: 0), context.scheme.secondary.withValues(alpha: 0.85)],
                  stops: const [0.35, 1],
                ),
              ),
            ),
            Positioned(top: AppSpacing.sm, left: AppSpacing.sm, child: PhotoPill(label: l10n.exVisited, icon: AppIcons.verified)),
            Positioned(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    visit.templeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.displayText.titleLarge.withColor(light),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.caption.copyWith(color: light.withValues(alpha: 0.85)),
                    ),
                ],
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(onTap: onTap, borderRadius: AppRadius.card),
            ),
          ],
        ),
      ),
    );
  }
}

/// Holds the rail's full height while loading, so content doesn't jump in.
class _RailLoader extends StatelessWidget {
  const _RailLoader({required this.height});
  final double height;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: const Center(child: SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2.5))),
  );
}

/// Compact empty/error state for a rail — never reserves the cards' height.
class _RailMessage extends StatelessWidget {
  const _RailMessage({required this.text, this.icon});
  final String text;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Padding(
    padding: AppSpacing.screenH,
    child: EmptyCard(label: text, icon: icon, height: 88),
  );
}
