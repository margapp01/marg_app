import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/collection_group.dart';
import '../../domain/entities/collection_stats.dart';
import '../../domain/entities/sacred_card.dart';
import '../controllers/cards_controllers.dart';
import '../widgets/card_widgets.dart';
import 'card_gallery_page.dart';

/// Collection Statistics — a night-sky hero (completion ring, owned / missing),
/// the rarest card held, the by-rarity breakdown as glowing gem bars, and every
/// series and season as a collector's album. The backend exposes rarity and
/// group completion only; by-deity/state/route groupings are not shown.
class CollectionStatsPage extends ConsumerWidget {
  const CollectionStatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final statsAsync = ref.watch(collectionStatsProvider);

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.scStatistics)),
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
            ref.invalidate(seasonProgressProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.huge),
            children: [
              _Hero(stats: stats).fadeIn(),
              const _RarestCard(),
              const Gap(AppSpacing.xl),
              GoldRuleHeader(label: l10n.scByRarity),
              const Gap(AppSpacing.sm),
              _RarityBreakdown(stats: stats).fadeIn(delay: 80.ms),
              const Gap(AppSpacing.xl),
              GoldRuleHeader(label: l10n.scSeriesCompletion),
              const Gap(AppSpacing.sm),
              _Albums(provider: seriesProgressProvider, series: true),
              const Gap(AppSpacing.lg),
              GoldRuleHeader(label: l10n.scSeasonCompletion),
              const Gap(AppSpacing.sm),
              _Albums(provider: seasonProgressProvider, series: false),
            ],
          ),
        ),
      ),
    );
  }
}

/// Completion ring with owned / missing / total on a night sky.
class _Hero extends StatelessWidget {
  const _Hero({required this.stats});
  final CollectionStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gold = context.colors.gold;
    final light = context.colors.card;
    Widget stat(int value, String label) => Expanded(
      child: Column(
        children: [
          AnimatedCount(value: value, style: context.displayText.titleLarge.withColor(light)),
          Text(label, style: context.caption.copyWith(color: light.withValues(alpha: 0.75))),
        ],
      ),
    );
    return GiltFrame(
      accent: gold,
      large: true,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.night),
        child: Padding(
          padding: AppSpacing.allLg,
          child: Column(
            children: [
              Text(
                l10n.scShowcaseTitle.toUpperCase(),
                style: context.overline.copyWith(color: gold, letterSpacing: 1.4),
              ),
              const Gap(AppSpacing.md),
              AppCircularProgress(
                value: (stats.percent / 100).clamp(0, 1),
                size: 132,
                strokeWidth: 10,
                color: gold,
                backgroundColor: light.withValues(alpha: 0.12),
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${stats.percent}%', style: context.displayText.headlineMedium.withColor(light)),
                    Text(l10n.scComplete, style: context.caption.copyWith(color: gold)),
                  ],
                ),
              ),
              const Gap(AppSpacing.lg),
              Row(
                children: [
                  stat(stats.ownedCards, l10n.scOwned),
                  stat(stats.missingCards, l10n.scMissing),
                  stat(stats.totalCards, l10n.scTotal),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Your rarest card" — the highest-rarity card owned, face up; hidden until
/// the first card is collected.
class _RarestCard extends ConsumerWidget {
  const _RarestCard();

  static const double _cardWidth = 104;

  static SacredCard? _rarest(List<SacredCard> cards) {
    SacredCard? best;
    for (final c in cards.where((c) => c.owned)) {
      if (best == null ||
          kRarityOrder.indexOf(c.rarity.toUpperCase()) > kRarityOrder.indexOf(best.rarity.toUpperCase())) {
        best = c;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final card = _rarest(ref.watch(recentCardsProvider).valueOrNull ?? const []);
    if (card == null) return const SizedBox.shrink();
    final accent = rarityColor(context, card.rarity);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: GestureDetector(
        onTap: () => context.pushNamed(RouteNames.cardDetail, pathParameters: {RoutePaths.cardIdParam: card.id}),
        child: ParchmentCard(
          child: Row(
            children: [
              SizedBox(
                width: _cardWidth,
                child: SacredCardFace(card: card),
              ),
              const Gap.h(AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.scRarestCard.toUpperCase(),
                      style: context.overline.copyWith(color: accent, letterSpacing: 1.2),
                    ),
                    const Gap(AppSpacing.xs),
                    Text(
                      card.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.displayText.titleLarge,
                    ),
                    const Gap(AppSpacing.sm),
                    RarityRibbon(rarity: card.rarity),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).fadeIn(delay: 40.ms);
  }
}

/// One glowing gem bar per rarity, rarest first, each with its share of the
/// cards held.
class _RarityBreakdown extends StatelessWidget {
  const _RarityBreakdown({required this.stats});
  final CollectionStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final max = math.max(1, stats.byRarity.values.fold<int>(0, math.max));
    final owned = math.max(1, stats.ownedCards);
    return AppCard(
      padding: AppSpacing.allLg,
      child: Column(
        children: [
          for (final (i, r) in kRarityOrder.reversed.indexed) ...[
            if (i > 0) const Gap(AppSpacing.md),
            _GemBar(
              label: rarityLabel(l10n, r),
              color: rarityColor(context, r),
              count: stats.ownedOf(r),
              fraction: stats.ownedOf(r) / max,
              share: (stats.ownedOf(r) * 100 / owned).round(),
            ),
          ],
        ],
      ),
    );
  }
}

class _GemBar extends StatelessWidget {
  const _GemBar({
    required this.label,
    required this.color,
    required this.count,
    required this.fraction,
    required this.share,
  });

  final String label;
  final Color color;
  final int count;
  final double fraction;
  final int share;

  static const double _bar = 12;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label $count',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Transform.rotate(
                angle: math.pi / 4,
                child: Container(
                  width: AppSpacing.md,
                  height: AppSpacing.md,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: AppRadius.xsAll,
                    boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8)],
                  ),
                ),
              ),
              const Gap.h(AppSpacing.sm),
              Expanded(child: Text(label, style: context.textTheme.labelLarge?.semiBold.withColor(color))),
              Text('$count', style: context.textTheme.titleMedium?.bold.withColor(context.scheme.secondary)),
              const Gap.h(AppSpacing.xs),
              SizedBox(
                width: 44,
                child: Text(
                  '$share%',
                  textAlign: TextAlign.end,
                  style: context.caption.copyWith(color: context.colors.textSecondary),
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.xs),
          LayoutBuilder(
            builder: (context, constraints) => TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: fraction.clamp(0, 1)),
              duration: AppDurations.slow,
              curve: AppCurves.emphasize,
              builder: (context, v, _) => Stack(
                children: [
                  Container(
                    height: _bar,
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: AppRadius.fullAll),
                  ),
                  Container(
                    height: _bar,
                    width: constraints.maxWidth * v,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [color.withValues(alpha: 0.7), color]),
                      borderRadius: AppRadius.fullAll,
                      boxShadow: [BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: 8)],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Every series (or season) as a collector's album; tapping opens its cards.
class _Albums extends ConsumerWidget {
  const _Albums({required this.provider, required this.series});
  final ProviderListenable<AsyncValue<List<CollectionGroup>>> provider;
  final bool series;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ref
        .watch(provider)
        .when(
          loading: () => const SkeletonBox(height: 120, radius: AppRadius.card),
          error: (_, _) => EmptyCard(icon: AppIcons.error, label: l10n.scErrorBody),
          data: (groups) {
            if (groups.isEmpty) return EmptyCard(icon: AppIcons.card, label: l10n.scNoGroupsBody);
            return Column(
              children: [
                for (final (i, g) in groups.indexed) ...[
                  if (i > 0) const Gap(AppSpacing.md),
                  GroupProgressTile(
                    group: g,
                    accent: groupAccent(context, i),
                    onTap: () => context.pushNamed(
                      RouteNames.cardGallery,
                      extra: GalleryArgs(
                        query: series ? GalleryQuery(seriesId: g.id) : GalleryQuery(seasonId: g.id),
                        title: g.name,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        );
  }
}
