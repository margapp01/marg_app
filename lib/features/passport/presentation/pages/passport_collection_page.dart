import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../shared/design_system.dart';
import '../../../cards/domain/entities/collection_group.dart';
import '../../../cards/domain/entities/sacred_card.dart';
import '../../../cards/presentation/controllers/cards_controllers.dart';
import '../../../cards/presentation/pages/card_gallery_page.dart';
import '../../../cards/presentation/widgets/card_widgets.dart';
import '../../domain/entities/passport_lists.dart';
import '../controllers/passport_controllers.dart';

/// Collection Summary — cards (by rarity + recent unlocks), series, seasons —
/// drawn with the Sacred Card components (gilt cards, rarity strip, series
/// tiles) so the passport matches the collection hub.
class PassportCollectionPage extends ConsumerWidget {
  const PassportCollectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: context.scheme.surface,
        appBar: AppBar(
          title: Text(l10n.ppCollection),
          bottom: TabBar(tabs: [Tab(text: l10n.ppCards), Tab(text: l10n.ppSeries), Tab(text: l10n.ppSeasons)]),
        ),
        body: TabBarView(
          children: [
            const _CardsTab(),
            _GroupTab(provider: passportSeriesProvider, isSeries: true),
            _GroupTab(provider: passportSeasonsProvider, isSeries: false),
          ],
        ),
      ),
    );
  }
}

class _CardsTab extends ConsumerWidget {
  const _CardsTab();

  static const double _tileWidth = 112;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(passportCardsProvider);
    return async.when(
      loading: () => const LoadingView(),
      error: (e, _) => ErrorView(title: l10n.ppErrorTitle, message: l10n.ppErrorBody, onRetry: () => ref.invalidate(passportCardsProvider)),
      data: (cards) => ListView(
        padding: AppSpacing.screenAll,
        children: [
          ParchmentCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.ppCardsCollected, style: context.textTheme.labelLarge?.withColor(context.colors.textSecondary)),
                      const Gap(AppSpacing.xs),
                      AnimatedCount(value: cards.totalOwned, style: context.displayText.headlineLarge.withColor(context.scheme.secondary)),
                    ],
                  ),
                ),
                const CardEmblem(size: 56),
              ],
            ),
          ).fadeIn(),
          const Gap(AppSpacing.md),
          RarityCountStrip(countOf: cards.countOf).fadeIn(delay: 60.ms),
          if (cards.recent.isNotEmpty) ...[
            const Gap(AppSpacing.xl),
            SectionHeader(title: l10n.ppRecentUnlocks, onViewAll: () => context.pushNamed(RouteNames.cardsRecent)),
            const Gap(AppSpacing.sm),
            SizedBox(
              height: _tileWidth / SacredCardTile.gridAspect + AppSpacing.md,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: cards.recent.length.clamp(0, 12),
                separatorBuilder: (_, _) => const Gap(AppSpacing.md),
                itemBuilder: (context, i) {
                  final card = _asCard(cards.recent[i]);
                  return SizedBox(
                    width: _tileWidth,
                    child: SacredCardTile(
                      card: card,
                      onTap: card.id.isEmpty
                          ? null
                          : () => context.pushNamed(RouteNames.cardDetail, pathParameters: {RoutePaths.cardIdParam: card.id}),
                    ),
                  ).slideIn(delay: (i * 50).ms, from: const Offset(24, 0));
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// A passport card row as a [SacredCard] the shared card widgets can draw.
  static SacredCard _asCard(RecentCard r) => SacredCard(
        id: r.cardId ?? '',
        title: r.title,
        imageUrl: r.imageUrl ?? '',
        rarity: r.rarity,
        owned: true,
        ownership: CardOwnership(userCardId: r.userCardId, mintNumber: r.mintNumber, unlockedAt: r.unlockedAt),
      );
}

class _GroupTab extends ConsumerWidget {
  const _GroupTab({required this.provider, required this.isSeries});

  final ProviderListenable<AsyncValue<List<PassportGroup>>> provider;
  final bool isSeries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(provider);
    return async.when(
      loading: () => const LoadingView(),
      error: (e, _) => ErrorView(title: l10n.ppErrorTitle, message: l10n.ppErrorBody),
      data: (groups) {
        if (groups.isEmpty) {
          return EmptyView(art: StateArt.empty, icon: AppIcons.card, title: l10n.ppNoGroups, message: l10n.ppNoGroupsBody);
        }
        return ListView.separated(
          padding: AppSpacing.screenAll,
          itemCount: groups.length,
          separatorBuilder: (_, _) => const Gap(AppSpacing.md),
          itemBuilder: (context, i) {
            final g = groups[i];
            return GroupProgressTile(
              group: CollectionGroup(
                id: g.id,
                name: g.name,
                slug: '',
                totalCards: g.totalCards,
                ownedCards: g.ownedCards,
                completionPercent: g.completionPercent,
                completed: g.completed,
              ),
              accent: groupAccent(context, i),
              onTap: g.id.isEmpty
                  ? null
                  : () => context.pushNamed(
                        RouteNames.cardGallery,
                        extra: GalleryArgs(
                          query: isSeries ? GalleryQuery(seriesId: g.id) : GalleryQuery(seasonId: g.id),
                          title: g.name,
                        ),
                      ),
            );
          },
        );
      },
    );
  }
}
