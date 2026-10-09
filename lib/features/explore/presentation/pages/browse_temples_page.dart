import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../shared/design_system.dart';
import '../controllers/explore_controllers.dart';
import '../widgets/explore_widgets.dart';

/// Navigation payload for the browse list (a titled temple query). Passed via
/// GoRouter `extra` from categories / states / collections.
class BrowseArgs {
  const BrowseArgs({required this.title, required this.query});
  final String title;
  final BrowseQuery query;
}

/// A titled, scrollable temple list for a category / state / collection query.
class BrowseTemplesPage extends ConsumerWidget {
  const BrowseTemplesPage({required this.args, super.key});
  final BrowseArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(exploreBrowseProvider(args.query));
    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(args.title)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(
          title: l10n.exErrorTitle,
          message: l10n.exErrorBody,
          onRetry: () => ref.invalidate(exploreBrowseProvider(args.query)),
        ),
        data: (page) {
          if (page.temples.isEmpty) {
            return EmptyView(art: StateArt.noResults, icon: AppIcons.temple, title: l10n.exNoTemples, message: l10n.exNoTemplesBody);
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(exploreBrowseProvider(args.query)),
            child: ListView.separated(
              padding: AppSpacing.screenAll,
              itemCount: page.temples.length + 1,
              separatorBuilder: (_, _) => const Gap(AppSpacing.md),
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Text(
                      l10n.exTemplesFoundCount(page.total),
                      style: context.caption.copyWith(color: context.colors.textSecondary),
                    ),
                  );
                }
                final t = page.temples[i - 1];
                return ExploreTempleCard(
                  temple: t,
                  onTap: () =>
                      context.pushNamed(RouteNames.templeDetail, pathParameters: {RoutePaths.templeIdParam: t.slug}),
                  onNavigate: () => context.pushNamed(RouteNames.directions, extra: t.directionsArgs),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
