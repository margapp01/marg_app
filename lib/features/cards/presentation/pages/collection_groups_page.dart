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

/// Series Collection / Season Collection — a night-sky summary (sets
/// completed, cards held across them) over every series (or season) drawn as
/// a collector's album. Tapping one opens the gallery filtered to it.
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
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.huge),
              children: [
                GroupsSummary(groups: groups, series: isSeries).fadeIn(),
                const Gap(AppSpacing.lg),
                for (final (i, g) in groups.indexed) ...[
                  RepaintBoundary(
                    child: GroupProgressTile(
                      group: g,
                      accent: groupAccent(context, i),
                      onTap: () => _openGroup(context, g, isSeries),
                    ),
                  ).fadeIn(delay: AppDurations.stagger * i.clamp(0, 8)),
                  const Gap(AppSpacing.md),
                ],
              ],
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
