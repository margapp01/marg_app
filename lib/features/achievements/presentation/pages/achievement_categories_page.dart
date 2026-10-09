import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../shared/design_system.dart';
import '../controllers/achievements_controllers.dart';
import '../widgets/achievement_widgets.dart';
import 'achievement_gallery_page.dart';

/// Achievement Categories — a card per category with the user's completion.
class AchievementCategoriesPage extends ConsumerWidget {
  const AchievementCategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(achievementCollectionProvider);
    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.acCategories)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          title: l10n.acErrorTitle,
          message: l10n.acErrorBody,
          onRetry: () => ref.invalidate(achievementCollectionProvider),
        ),
        data: (c) => GridView.count(
          crossAxisCount: 2,
          padding: AppSpacing.screenAll,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.05,
          children: [
            for (final cat in c.categories)
              RepaintBoundary(
                child: Builder(builder: (context) {
                  final p = c.categoryProgress(cat);
                  return CategoryCard(
                    category: cat,
                    earned: p.earned,
                    total: p.total,
                    onTap: () => context.pushNamed(
                      RouteNames.achievementGallery,
                      extra: AchievementGalleryArgs(category: cat, title: categoryMeta(l10n, cat).label),
                    ),
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }
}
