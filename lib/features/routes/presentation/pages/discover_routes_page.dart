import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/yatra_route.dart';
import '../controllers/routes_controllers.dart';

/// Discover Routes — browse published pilgrimage routes by category.
/// Categories are the backend RouteType values (Jyotirlinga, Shakti Peeth,
/// Char Dham, Custom); there is no separate Panch Kedar / 108-temple type.
class DiscoverRoutesPage extends ConsumerStatefulWidget {
  const DiscoverRoutesPage({super.key});

  @override
  ConsumerState<DiscoverRoutesPage> createState() => _DiscoverRoutesPageState();
}

class _DiscoverRoutesPageState extends ConsumerState<DiscoverRoutesPage> {
  String? _type; // null = all

  static const _types = [null, 'JYOTIRLINGA', 'SHAKTI_PEETH', 'CHAR_DHAM', 'CUSTOM'];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(discoverRoutesProvider(_type));

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.ryDiscover)),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: AppSpacing.screenH,
              itemCount: _types.length,
              separatorBuilder: (_, _) => const Gap(AppSpacing.sm),
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
          Expanded(
            child: async.when(
              loading: () => const LoadingView(),
              error: (e, _) => ErrorView(
                title: l10n.ryErrorTitle,
                message: l10n.ryErrorBody,
                onRetry: () => ref.invalidate(discoverRoutesProvider(_type)),
              ),
              data: (routes) => _list(context, l10n, routes),
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(BuildContext context, AppLocalizations l10n, List<YatraRoute> routes) {
    if (routes.isEmpty) {
      return EmptyView(art: StateArt.journey, icon: AppIcons.route, title: l10n.ryNoRoutes, message: l10n.ryNoRoutesBody);
    }
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(discoverRoutesProvider(_type)),
      child: ListView.separated(
        padding: AppSpacing.screenAll,
        itemCount: routes.length,
        separatorBuilder: (_, _) => const Gap(AppSpacing.md),
        itemBuilder: (context, i) {
          final r = routes[i];
          return RepaintBoundary(
            child: RouteCard(
              name: r.name,
              type: r.type,
              templeCount: r.templeCount,
              coverImage: r.coverImage,
              description: r.description,
              onTap: () => context.pushNamed(
                RouteNames.routeDetail,
                pathParameters: {RoutePaths.routeSlugParam: r.slug},
              ),
            ),
          );
        },
      ),
    );
  }
}
