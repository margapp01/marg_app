import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/collection_group.dart';
import '../controllers/cards_controllers.dart';
import '../widgets/card_widgets.dart';
import 'card_gallery_page.dart';

enum CollectionGroupMode { series, season }

/// Series Collection / Season Collection — a list of every series (or season)
/// with the user's completion. Tapping opens the gallery filtered to that group.
class CollectionGroupsPage extends ConsumerWidget {
  const CollectionGroupsPage({required this.mode, super.key});

  final CollectionGroupMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isSeries = mode == CollectionGroupMode.series;
    final provider = isSeries ? seriesProgressProvider : seasonProgressProvider;
    final async = ref.watch(provider);

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(isSeries ? l10n.scSeries : l10n.scSeasons)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          title: l10n.scErrorTitle,
          message: l10n.scErrorBody,
          onRetry: () => ref.invalidate(provider),
        ),
        data: (groups) {
          if (groups.isEmpty) {
            return EmptyView(
              art: StateArt.cards,
              icon: isSeries ? AppIcons.route : AppIcons.calendar,
              title: isSeries ? l10n.scNoSeries : l10n.scNoSeasons,
              message: l10n.scNoGroupsBody,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(provider),
            child: ListView.separated(
              padding: AppSpacing.screenAll,
              itemCount: groups.length,
              separatorBuilder: (_, _) => const Gap(AppSpacing.md),
              itemBuilder: (context, i) {
                final g = groups[i];
                return RepaintBoundary(
                  child: GroupProgressTile(
                    group: g,
                    accent: groupAccent(context, i),
                    onTap: () => _openGroup(context, g, isSeries),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _openGroup(BuildContext context, CollectionGroup g, bool isSeries) {
    context.pushNamed(
      RouteNames.cardGallery,
      extra: GalleryArgs(
        query: isSeries ? GalleryQuery(seriesId: g.id) : GalleryQuery(seasonId: g.id),
        title: g.name,
      ),
    );
  }
}
