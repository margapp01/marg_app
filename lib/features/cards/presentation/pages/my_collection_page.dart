import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/app_shell.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../shared/design_system.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../notifications/presentation/controllers/notification_controllers.dart';
import '../../domain/entities/collection_group.dart';
import '../../domain/entities/collection_stats.dart';
import '../controllers/cards_controllers.dart';
import '../widgets/card_widgets.dart';
import '../widgets/collection_showcase.dart';
import 'card_gallery_page.dart';

/// My Sacred Collection — the Cards tab and the heart of MARG: the collection
/// as a shareable trophy ("Show off my collection" sends it as an image), then
/// recent unlocks, series progress, and entries into the gallery, seasons,
/// stats and missing cards.
class MyCollectionPage extends ConsumerStatefulWidget {
  const MyCollectionPage({super.key});

  @override
  ConsumerState<MyCollectionPage> createState() => _MyCollectionPageState();
}

class _MyCollectionPageState extends ConsumerState<MyCollectionPage> {
  final _showcaseKey = GlobalKey();
  bool _sharing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final statsAsync = ref.watch(collectionStatsProvider);

    return Scaffold(
      backgroundColor: context.scheme.surface,
      body: Column(
        children: [
          TabHeader(
            title: l10n.scTitle,
            onMenu: AppShell.openMenu,
            onNotifications: () => context.pushNamed(RouteNames.notifications),
            notificationCount: ref.watch(unreadBadgeProvider),
            trailing: IconButton(
              icon: Icon(AppIcons.search, color: context.scheme.secondary),
              tooltip: l10n.scSearch,
              onPressed: () => _openGallery(context, const GalleryArgs()),
            ),
          ),
          Expanded(
            child: statsAsync.when(
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
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.huge),
                  children: [
                    RepaintBoundary(
                      key: _showcaseKey,
                      child: CollectionShowcase(
                        stats: stats,
                        cards: ref.watch(recentCardsProvider).valueOrNull ?? const [],
                        ownerName: ref.watch(authControllerProvider.select((s) => s.user?.name)),
                      ),
                    ).fadeIn(),
                    const Gap(AppSpacing.md),
                    AppButton.primary(
                      label: l10n.scShowOff,
                      icon: AppIcons.share,
                      busy: _sharing,
                      onPressed: stats.ownedCards == 0 ? null : () => _showOff(stats),
                    ),
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
          ),
        ],
      ),
    );
  }

  /// Shares the collection showcase as an image with the collection count,
  /// linking to the public Sacred Cards page (tagged with the invite code).
  Future<void> _showOff(CollectionStats stats) async {
    final l10n = AppLocalizations.of(context);
    final rarest = kRarityOrder.reversed.where((r) => stats.ownedOf(r) > 0).firstOrNull;
    setState(() => _sharing = true);
    try {
      await ref.read(shareServiceProvider).share(
            ShareMessage(
              kind: ShareKind.collection,
              path: SharePaths.cards,
              text: ShareCopy.collection(l10n, owned: stats.ownedCards, total: stats.totalCards, rarest: rarest),
            ),
            capture: _showcaseKey,
            fileName: 'marg-collection.png',
          );
    } catch (_) {
      if (mounted) AppSnackbar.error(context, l10n.scShowOffError);
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  void _openGallery(BuildContext context, GalleryArgs args) =>
      context.pushNamed(RouteNames.cardGallery, extra: args);

  void _openCard(BuildContext context, String id) => context.pushNamed(
        RouteNames.cardDetail,
        pathParameters: {RoutePaths.cardIdParam: id},
      );
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

/// Gallery, Series, Seasons and Statistics as tinted accent tiles.
class _NavTiles extends StatelessWidget {
  const _NavTiles();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final tiles = <(IconData, Color, String, String, VoidCallback)>[
      (AppIcons.card, p.accentSaffron, l10n.scGallery, l10n.scGalleryHint,
          () => context.pushNamed(RouteNames.cardGallery, extra: const GalleryArgs())),
      (AppIcons.route, p.accentViolet, l10n.scSeries, l10n.scSeriesHint, () => context.pushNamed(RouteNames.cardSeries)),
      (AppIcons.calendar, p.accentBlue, l10n.scSeasons, l10n.scSeasonsHint, () => context.pushNamed(RouteNames.cardSeasons)),
      (AppIcons.trending, p.accentTeal, l10n.scStatistics, l10n.scStatisticsHint, () => context.pushNamed(RouteNames.cardStats)),
    ];
    return GridView.count(
      crossAxisCount: context.responsive(compact: 2, medium: 4),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.45,
      children: [
        for (final (i, (icon, accent, title, hint, onTap)) in tiles.indexed)
          AccentTile(icon: icon, title: title, subtitle: hint, accent: accent, onTap: onTap)
              .fadeIn(delay: AppDurations.stagger * i),
      ],
    );
  }
}
