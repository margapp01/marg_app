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

/// Screen 4 — Temple Categories. Backed by the real `DeityType` values only
/// (the mockup's Jyotirlinga / Jain / Buddhist / Sikh categories aren't modelled
/// on the backend and are deliberately not shown). The largest category leads
/// as a featured card; the rest follow in a photo grid.
class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  static const double _tileExtent = 188;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(exploreCategoriesProvider);
    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.exCategories)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(
          title: l10n.exErrorTitle,
          message: l10n.exErrorBody,
          onRetry: () => ref.invalidate(exploreCategoriesProvider),
        ),
        data: (all) {
          final cats = all.where((c) => c.count > 0).toList()..sort((a, b) => b.count.compareTo(a.count));
          if (cats.isEmpty) {
            return EmptyView(icon: AppIcons.category, title: l10n.exNoTemples, message: l10n.exNoTemplesBody);
          }
          final total = cats.fold<int>(0, (sum, c) => sum + c.count);
          void open(TempleCategory c) => context.pushNamed(
                RouteNames.exploreBrowse,
                extra: BrowseArgs(
                  title: deityLabel(l10n, c.deity.wire),
                  query: (deity: c.deity, stateId: null, cityId: null, sort: ExploreSort.popular),
                ),
              );
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(exploreCategoriesProvider),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
                  sliver: SliverList.list(
                    children: [
                      IntroBanner(
                        icon: AppIcons.category,
                        title: l10n.exCategories,
                        message: l10n.exCategoriesIntro,
                        status: l10n.exStateTemples(total),
                      ).fadeIn(),
                      const Gap(AppSpacing.lg),
                      SizedBox(
                        height: CategoryCard.featuredHeight,
                        child: CategoryCard(category: cats.first, featured: true, onTap: () => open(cats.first)),
                      ).fadeIn(delay: 60.ms),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.huge),
                  sliver: SliverGrid.builder(
                    itemCount: cats.length - 1,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: context.responsive(compact: 2, medium: 3, expanded: 4),
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisExtent: _tileExtent,
                    ),
                    itemBuilder: (context, i) {
                      final c = cats[i + 1];
                      return CategoryCard(category: c, onTap: () => open(c)).fadeIn(delay: (60 * (i + 2)).ms);
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
