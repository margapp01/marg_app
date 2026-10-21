import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/app_shell.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../shared/design_system.dart';
import '../../../notifications/presentation/controllers/notification_controllers.dart';
import '../../data/repository/routes_repository_impl.dart';
import '../../domain/entities/my_route.dart';
import '../controllers/routes_controllers.dart';
import '../widgets/route_widgets.dart';

enum _YatraTab { discover, inProgress, planned, completed }

/// The Yatra tab: pilgrimage routes first. "Discover" (the default) lists every
/// published route by type — with progress on the ones the devotee has joined
/// and a nudge to continue the furthest one — and the other tabs hold their
/// own yatras: in progress, planned and completed, each with its count.
class MyYatrasPage extends ConsumerStatefulWidget {
  const MyYatrasPage({super.key});

  @override
  ConsumerState<MyYatrasPage> createState() => _MyYatrasPageState();
}

class _MyYatrasPageState extends ConsumerState<MyYatrasPage> {
  _YatraTab _tab = _YatraTab.discover;
  String? _type; // Discover filter; null = all

  static const _types = [null, 'JYOTIRLINGA', 'SHAKTI_PEETH', 'CHAR_DHAM', 'CUSTOM'];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mine = ref.watch(myRoutesProvider).valueOrNull ?? const <MyRouteProgress>[];
    final inProgress = mine.where((r) => r.inProgress).toList()..sort((a, b) => b.percent.compareTo(a.percent));
    final planned = mine.where((r) => r.planned).toList();
    final completed = mine.where((r) => r.isComplete).toList();
    String counted(String label, int n) => n == 0 ? label : '$label · $n';

    return Scaffold(
      backgroundColor: context.scheme.surface,
      body: Column(
        children: [
          TabHeader(
            title: l10n.ryTitle,
            onMenu: AppShell.openMenu,
            onNotifications: () => context.pushNamed(RouteNames.notifications),
            notificationCount: ref.watch(unreadBadgeProvider),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
            child: PillTabs(
              labels: [
                l10n.ryDiscoverTab,
                counted(l10n.ryInProgress, inProgress.length),
                counted(l10n.ryPlanned, planned.length),
                counted(l10n.ryCompleted, completed.length),
              ],
              selected: _tab.index,
              onChanged: (i) => setState(() => _tab = _YatraTab.values[i]),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: AppDurations.normal,
              child: KeyedSubtree(
                key: ValueKey(_tab),
                child: switch (_tab) {
                  _YatraTab.discover => _discover(context, l10n, mine, inProgress.firstOrNull),
                  _YatraTab.inProgress => _mine(context, l10n, inProgress),
                  _YatraTab.planned => _mine(context, l10n, planned),
                  _YatraTab.completed => _mine(context, l10n, completed),
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _discover(BuildContext context, AppLocalizations l10n, List<MyRouteProgress> mine, MyRouteProgress? current) {
    final async = ref.watch(discoverRoutesProvider(_type));
    final joined = {for (final r in mine) r.slug: r};
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(discoverRoutesProvider(_type));
        ref.invalidate(myRoutesProvider);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.huge),
        children: [
          if (current != null) ...[
            _ContinueStrip(route: current, onTap: () => _openRoute(current.slug)),
            const Gap(AppSpacing.md),
          ],
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _types.length,
              separatorBuilder: (_, _) => const Gap.h(AppSpacing.sm),
              itemBuilder: (context, i) {
                final t = _types[i];
                return Center(
                  child: AppFilterChip(
                    label: t == null ? l10n.ryTypeAll : routeTypeMeta(l10n, t).label,
                    selected: _type == t,
                    onSelected: (_) => setState(() => _type = t),
                  ),
                );
              },
            ),
          ),
          const Gap(AppSpacing.sm),
          ...async.when(
            loading: () => [const SkeletonBox(height: 220, radius: AppRadius.card)],
            error: (e, _) => [
              ErrorView(
                title: l10n.ryErrorTitle,
                message: l10n.ryErrorBody,
                onRetry: () => ref.invalidate(discoverRoutesProvider(_type)),
              ),
            ],
            data: (routes) => routes.isEmpty
                ? [EmptyView(art: StateArt.journey, icon: AppIcons.route, title: l10n.ryNoRoutes, message: l10n.ryNoRoutesBody)]
                : [
                    for (final (i, r) in routes.indexed) ...[
                      RepaintBoundary(
                        child: RouteCard(
                          name: r.name,
                          type: r.type,
                          templeCount: r.templeCount,
                          coverImage: r.coverImage,
                          description: r.description,
                          percent: joined[r.slug]?.planned == false ? joined[r.slug]!.percent : null,
                          completedTemples: joined[r.slug]?.planned == false ? joined[r.slug]!.completedTemples : null,
                          onTap: () => _openRoute(r.slug),
                        ),
                      ).fadeIn(delay: AppDurations.stagger * i.clamp(0, 6)),
                      const Gap(AppSpacing.md),
                    ],
                  ],
          ),
        ],
      ),
    );
  }

  Widget _mine(BuildContext context, AppLocalizations l10n, List<MyRouteProgress> routes) {
    final async = ref.watch(myRoutesProvider);
    if (async.isLoading && !async.hasValue) return const LoadingView();
    if (async.hasError && !async.hasValue) {
      return ErrorView(
        title: l10n.ryErrorTitle,
        message: l10n.ryErrorBody,
        onRetry: () => ref.invalidate(myRoutesProvider),
      );
    }
    if (routes.isEmpty) {
      return EmptyView(
        art: StateArt.journey,
        icon: AppIcons.route,
        title: l10n.ryNoYatras,
        message: l10n.ryNoYatrasBody,
        action: AppButton.primary(
          label: l10n.ryDiscover,
          icon: AppIcons.explore,
          expand: false,
          onPressed: () => setState(() => _tab = _YatraTab.discover),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(myRoutesProvider),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.huge),
        children: [
          for (final r in routes) ...[_routeItem(context, l10n, r), const Gap(AppSpacing.md)],
        ],
      ),
    );
  }

  Widget _routeItem(BuildContext context, AppLocalizations l10n, MyRouteProgress r) {
    final card = RepaintBoundary(
      child: r.planned
          ? PlannedRouteTile(
              name: r.name,
              templeCount: r.totalTemples,
              coverImage: r.coverImage,
              onTap: () => _openRoute(r.slug),
            )
          : RouteCard(
              name: r.name,
              type: r.type,
              templeCount: r.totalTemples,
              coverImage: r.coverImage,
              percent: r.percent,
              completedTemples: r.completedTemples,
              onTap: () => _openRoute(r.slug),
            ),
    );
    // Planned (not started) routes can be swiped away to un-enroll.
    if (!r.planned) return card;
    return Dismissible(
      key: ValueKey('planned-${r.routeId}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(color: context.scheme.error.withValues(alpha: 0.12), borderRadius: AppRadius.lgAll),
        child: Icon(AppIcons.delete, color: context.scheme.error),
      ),
      onDismissed: (_) => _unenroll(context, l10n, r),
      child: card,
    );
  }

  Future<void> _unenroll(BuildContext context, AppLocalizations l10n, MyRouteProgress r) async {
    try {
      await ref.read(routesRepositoryProvider).unenroll(r.routeId);
      if (context.mounted) AppSnackbar.info(context, l10n.ryRemovedFromPlanned);
    } catch (_) {
      if (context.mounted) AppSnackbar.error(context, l10n.ryErrorBody);
    }
    ref.invalidate(myRoutesProvider);
  }

  void _openRoute(String slug) => context.pushNamed(
        RouteNames.routeDetail,
        pathParameters: {RoutePaths.routeSlugParam: slug},
      );
}

/// "Continue your yatra" — the in-progress route closest to done, on top of
/// Discover so the next temple is one tap away.
class _ContinueStrip extends StatelessWidget {
  const _ContinueStrip({required this.route, required this.onTap});

  final MyRouteProgress route;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final light = context.colors.card;
    final gold = context.colors.gold;
    return AppCard(
      gradient: AppGradients.navy,
      onTap: onTap,
      padding: AppSpacing.allMd,
      child: Row(
        children: [
          AppCircularProgress(
            value: (route.percent / 100).clamp(0, 1),
            size: 52,
            strokeWidth: 5,
            color: gold,
            backgroundColor: light.withValues(alpha: 0.15),
            center: Text('${route.percent}%', style: context.caption.copyWith(color: light)),
          ),
          const Gap.h(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.ryContinueYatra.toUpperCase(), style: context.overline.copyWith(color: gold, letterSpacing: 1.2)),
                Text(
                  route.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleSmall?.semiBold.withColor(light),
                ),
                Text(
                  l10n.ryTemplesDone(route.completedTemples, route.totalTemples),
                  style: context.caption.copyWith(color: light.withValues(alpha: 0.75)),
                ),
              ],
            ),
          ),
          Icon(AppIcons.chevronRight, color: light.withValues(alpha: 0.7)),
        ],
      ),
    );
  }
}
