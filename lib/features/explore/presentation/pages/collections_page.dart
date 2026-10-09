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

/// Screen 6 — Temple Collections. There's no backend Collection model, so each
/// collection is a real temple query with a friendly identity (Most Popular,
/// Newly Added, and per-deity) — shown as a photo card led by its first
/// temple, with its live count. Nothing here is fabricated.
class CollectionsPage extends ConsumerWidget {
  const CollectionsPage({super.key});

  static const double _cardHeight = 148;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(exploreCollectionsProvider);
    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.exCollections,
          style: context.textTheme.titleMedium?.semiBold.withColor(context.scheme.secondary),
        ),
        centerTitle: true,
      ),
      body: async.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(
          title: l10n.exErrorTitle,
          message: l10n.exErrorBody,
          onRetry: () => ref.invalidate(exploreCollectionsProvider),
        ),
        data: (all) {
          final collections = all.where((c) => c.count > 0).toList();
          if (collections.isEmpty) {
            return EmptyView(icon: AppIcons.layers, title: l10n.exNoTemples, message: l10n.exNoTemplesBody);
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(exploreCollectionsProvider),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.huge),
              children: [
                IntroBanner(
                  icon: AppIcons.layers,
                  title: l10n.exCollections,
                  message: l10n.exCollectionsIntro,
                ).fadeIn(),
                for (final (i, c) in collections.indexed) ...[
                  const Gap(AppSpacing.md),
                  SizedBox(
                    height: i == 0 ? ExploreCoverCard.featuredHeight : _cardHeight,
                    child: _CollectionCard(summary: c, featured: i == 0),
                  ).fadeIn(delay: AppDurations.stagger * (i + 1)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({required this.summary, this.featured = false});

  final CollectionSummary summary;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = summary.collection;
    final (title, subtitle, icon, accent) = switch (c.id) {
      'popular' => (l10n.exCollPopular, l10n.exCollPopularSub, AppIcons.trending, context.scheme.primary),
      'newest' => (l10n.exCollNewest, l10n.exCollNewestSub, AppIcons.star, context.colors.gold),
      _ => (deityLabel(l10n, c.deity?.wire), l10n.exCollDeitySub, AppIcons.temple, deityColor(context, c.deity?.wire)),
    };
    return ExploreCoverCard(
      title: title,
      countLabel: l10n.exStateTemples(summary.count),
      caption: subtitle,
      coverImage: summary.coverImage,
      accent: accent,
      emblem: CoverEmblem(icon: icon, color: accent, featured: featured),
      featured: featured,
      onTap: () => context.pushNamed(
        RouteNames.exploreBrowse,
        extra: BrowseArgs(title: title, query: (deity: c.deity, stateId: null, cityId: null, sort: c.sort)),
      ),
    );
  }
}
