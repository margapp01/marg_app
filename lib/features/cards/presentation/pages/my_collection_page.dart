import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/collection_group.dart';
import '../../domain/entities/collection_stats.dart';
import '../controllers/cards_controllers.dart';
import '../widgets/card_widgets.dart';
import 'card_gallery_page.dart';

/// My Sacred Collection — the cards hub: completion hero, rarity breakdown,
/// recent unlocks, series progress, and entries into the gallery, seasons,
/// stats and missing cards.
class MyCollectionPage extends ConsumerWidget {
  const MyCollectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final statsAsync = ref.watch(collectionStatsProvider);

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(
        title: Text(l10n.scTitle),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.search),
            tooltip: l10n.scSearch,
            onPressed: () => _openGallery(context, const GalleryArgs()),
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          title: l10n.scErrorTitle,
          message: l10n.scErrorBody,
          onRetry: () => ref.invalidate(collectionStatsProvider),
        ),
        data: (stats) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(collectionStatsProvider);
            ref.invalidate(recentCardsProvider);
            ref.invalidate(seriesProgressProvider);
          },
          child: ListView(
            padding: AppSpacing.screenAll,
            children: [
              _ProgressHero(stats: stats).fadeIn(),
              const Gap(AppSpacing.md),
              RarityCountStrip(countOf: stats.ownedOf).fadeIn(delay: 60.ms),
              _RecentStrip(onOpenCard: (id) => _openCard(context, id)),
              const _SeriesStrip(),
              const Gap(AppSpacing.xl),
              SectionHeader(title: l10n.scExplore),
              const Gap(AppSpacing.sm),
              const _NavTiles(),
            ],
          ),
        ),
      ),
    );
  }

  void _openGallery(BuildContext context, GalleryArgs args) =>
      context.pushNamed(RouteNames.cardGallery, extra: args);

  void _openCard(BuildContext context, String id) => context.pushNamed(
        RouteNames.cardDetail,
        pathParameters: {RoutePaths.cardIdParam: id},
      );
}

/// Parchment hero: owned / total, missing count and the completion ring.
class _ProgressHero extends StatelessWidget {
  const _ProgressHero({required this.stats});

  final CollectionStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final navy = context.scheme.secondary;
    return ParchmentCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.scCollectionProgress, style: context.textTheme.labelLarge?.withColor(context.colors.textSecondary)),
                const Gap(AppSpacing.xs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    AnimatedCount(value: stats.ownedCards, style: context.displayText.headlineLarge.withColor(navy)),
                    Text(' / ${stats.totalCards}', style: context.textTheme.titleMedium?.withColor(context.colors.textSecondary)),
                  ],
                ),
                const Gap(AppSpacing.xs),
                Text(
                  '${stats.missingCards} ${l10n.scMissing}',
                  style: context.textTheme.bodySmall?.semiBold.withColor(context.scheme.primary),
                ),
              ],
            ),
          ),
          AppCircularProgress(
            value: (stats.percent / 100).clamp(0, 1),
            size: 92,
            strokeWidth: 8,
            color: context.scheme.primary,
            backgroundColor: context.colors.gold.withValues(alpha: 0.2),
            center: Text('${stats.percent}%', style: context.textTheme.titleMedium?.bold.withColor(navy)),
          ),
        ],
      ),
    );
  }
}

class _RecentStrip extends ConsumerWidget {
  const _RecentStrip({required this.onOpenCard});

  final void Function(String id) onOpenCard;

  static const double _tileWidth = 112;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(recentCardsProvider);
    return async.maybeWhen(
      orElse: () => const SizedBox.shrink(),
      data: (cards) {
        if (cards.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: l10n.scRecentlyUnlocked,
                onViewAll: () => context.pushNamed(RouteNames.cardsRecent),
              ),
              const Gap(AppSpacing.sm),
              SizedBox(
                height: _tileWidth / SacredCardTile.gridAspect + AppSpacing.md,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: cards.length.clamp(0, 10),
                  separatorBuilder: (_, _) => const Gap(AppSpacing.md),
                  itemBuilder: (context, i) {
                    final card = cards[i];
                    return SizedBox(
                      width: _tileWidth,
                      child: SacredCardTile(card: card, onTap: () => onOpenCard(card.id)),
                    ).slideIn(delay: (i * 50).ms, from: const Offset(24, 0));
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Series progress as a horizontal row of tiles ("12 Jyotirlinga · 8 / 12").
class _SeriesStrip extends ConsumerWidget {
  const _SeriesStrip();

  static const double _height = 140;
  static const double _width = 156;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(seriesProgressProvider);
    return async.maybeWhen(
      orElse: () => const SizedBox.shrink(),
      data: (groups) {
        if (groups.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: l10n.scSeries, onViewAll: () => context.pushNamed(RouteNames.cardSeries)),
              const Gap(AppSpacing.sm),
              SizedBox(
                height: _height,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: groups.length,
                  separatorBuilder: (_, _) => const Gap(AppSpacing.md),
                  itemBuilder: (context, i) => SizedBox(
                    width: _width,
                    child: _SeriesCard(
                      group: groups[i],
                      accent: groupAccent(context, i),
                      onTap: () => context.pushNamed(
                        RouteNames.cardGallery,
                        extra: GalleryArgs(query: GalleryQuery(seriesId: groups[i].id), title: groups[i].name),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SeriesCard extends StatelessWidget {
  const _SeriesCard({required this.group, required this.accent, required this.onTap});

  final CollectionGroup group;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final done = group.completed;
    return AppCard(
      onTap: onTap,
      padding: AppSpacing.allMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IllustratedIcon(fallbackIcon: AppIcons.temple, color: accent, size: 40),
              const Spacer(),
              if (done) Icon(AppIcons.verified, color: context.colors.success, size: 20, fill: 1),
            ],
          ),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Text(
              group.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelLarge?.semiBold.withColor(context.scheme.secondary),
            ),
          ),
          Row(
            children: [
              Text('${group.ownedCards} / ${group.totalCards}', style: context.caption.copyWith(color: context.colors.textSecondary)),
              const Spacer(),
              Text('${group.percent}%', style: context.caption.copyWith(color: done ? context.colors.success : accent)),
            ],
          ),
          const Gap(AppSpacing.xs),
          AppLinearProgress(value: (group.percent / 100).clamp(0, 1), color: done ? context.colors.success : accent),
        ],
      ),
    );
  }
}

class _NavTiles extends StatelessWidget {
  const _NavTiles();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final tiles = <(IconData, Color, String, VoidCallback)>[
      (AppIcons.card, p.accentSaffron, l10n.scGallery, () => context.pushNamed(RouteNames.cardGallery, extra: const GalleryArgs())),
      (AppIcons.route, p.accentViolet, l10n.scSeries, () => context.pushNamed(RouteNames.cardSeries)),
      (AppIcons.calendar, p.accentBlue, l10n.scSeasons, () => context.pushNamed(RouteNames.cardSeasons)),
      (AppIcons.trending, p.accentTeal, l10n.scStatistics, () => context.pushNamed(RouteNames.cardStats)),
      (AppIcons.lock, p.accentRose, l10n.scMissingCards, () => context.pushNamed(RouteNames.cardGallery,
          extra: GalleryArgs(query: const GalleryQuery(missingOnly: true), title: l10n.scMissingCards))),
      (AppIcons.history, p.accentAmber, l10n.scRecentlyUnlocked, () => context.pushNamed(RouteNames.cardsRecent)),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 2.6,
      children: [
        for (final t in tiles)
          AppCard(
            onTap: t.$4,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                IllustratedIcon(fallbackIcon: t.$1, color: t.$2, size: 36),
                const Gap.h(AppSpacing.sm),
                Expanded(
                  child: Text(t.$3, style: context.textTheme.bodyMedium?.semiBold, maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
