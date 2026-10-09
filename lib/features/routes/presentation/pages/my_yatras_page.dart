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

enum _YatraFilter { all, inProgress, planned, completed }

/// My Yatras — the user's active + completed pilgrimage routes, with a
/// "Continue Journey" banner and an entry to Discover.
class MyYatrasPage extends ConsumerStatefulWidget {
  const MyYatrasPage({super.key});

  @override
  ConsumerState<MyYatrasPage> createState() => _MyYatrasPageState();
}

class _MyYatrasPageState extends ConsumerState<MyYatrasPage> {
  _YatraFilter _filter = _YatraFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(myRoutesProvider);

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
          Expanded(
            child: async.when(
              loading: () => const LoadingView(),
              error: (e, _) => ErrorView(
                title: l10n.ryErrorTitle,
                message: l10n.ryErrorBody,
                onRetry: () => ref.invalidate(myRoutesProvider),
              ),
              data: (routes) => _content(context, l10n, routes),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(BuildContext context, AppLocalizations l10n, List<MyRouteProgress> routes) {
    if (routes.isEmpty) {
      return EmptyView(art: StateArt.journey, 
        icon: AppIcons.route,
        title: l10n.ryNoYatras,
        message: l10n.ryNoYatrasBody,
        action: AppButton.primary(
          label: l10n.ryDiscover,
          icon: AppIcons.explore,
          expand: false,
          onPressed: () => context.pushNamed(RouteNames.routesDiscover),
        ),
      );
    }

    final inProgress = routes.where((r) => r.inProgress).toList()
      ..sort((a, b) => b.percent.compareTo(a.percent));
    final completed = routes.where((r) => r.isComplete).toList();
    final planned = routes.where((r) => r.planned).toList();
    final filters = _YatraFilter.values;
    bool show(_YatraFilter f) => _filter == _YatraFilter.all || _filter == f;

    List<Widget> section(String title, List<MyRouteProgress> items) => [
          const Gap(AppSpacing.lg),
          SectionHeader(title: title),
          for (final r in items) ...[_routeItem(context, l10n, r), const Gap(AppSpacing.md)],
        ];

    final sections = <Widget>[
      if (show(_YatraFilter.inProgress) && inProgress.isNotEmpty) ...section(l10n.ryInProgress, inProgress),
      if (show(_YatraFilter.planned) && planned.isNotEmpty) ...section(l10n.ryPlannedYatras, planned),
      if (show(_YatraFilter.completed) && completed.isNotEmpty) ...section(l10n.ryCompletedYatras, completed),
    ];

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(myRoutesProvider),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.huge),
        children: [
          PillTabs(
            labels: [l10n.ryAll, l10n.ryInProgress, l10n.ryPlanned, l10n.ryCompleted],
            selected: filters.indexOf(_filter),
            onChanged: (i) => setState(() => _filter = filters[i]),
          ),
          if (sections.isEmpty)
            Padding(
              padding: AppSpacing.screenAll,
              child: Center(
                child: Text(l10n.ryNoInFilter,
                    style: context.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary)),
              ),
            )
          else
            ...sections,
          const Gap(AppSpacing.md),
          _DiscoverBanner(onTap: () => context.pushNamed(RouteNames.routesDiscover)),
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

/// "Embark on a Divine Journey" — the entry to Discover Routes.
class _DiscoverBanner extends StatelessWidget {
  const _DiscoverBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      gradient: AppGradients.navy,
      onTap: onTap,
      padding: AppSpacing.allXl,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.ryEmbarkTitle, style: context.displayText.titleLarge.copyWith(color: Colors.white)),
                const Gap(AppSpacing.xs),
                Text(l10n.ryEmbarkBody, style: context.textTheme.bodySmall?.copyWith(color: Colors.white70)),
                const Gap(AppSpacing.md),
                Text(l10n.ryDiscover, style: context.textTheme.labelLarge?.bold.withColor(context.colors.gold)),
              ],
            ),
          ),
          const Gap.h(AppSpacing.md),
          IllustratedIcon(
            asset: BrandAssets.iconRoutes,
            fallbackIcon: AppIcons.route,
            color: context.colors.gold,
            background: Colors.white12,
            size: 64,
          ),
        ],
      ),
    );
  }
}
