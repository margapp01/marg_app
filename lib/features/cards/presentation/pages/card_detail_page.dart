import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../shared/design_system.dart';
import '../../data/repository/cards_repository_impl.dart';
import '../../domain/entities/sacred_card.dart';
import '../controllers/cards_controllers.dart';
import '../widgets/card_widgets.dart';

/// Card Detail — the card at hero size in its gilt frame (tap to flip to its
/// night-sky back), then its story, unlock details and actions.
class CardDetailPage extends ConsumerWidget {
  const CardDetailPage({required this.cardId, super.key});

  final String cardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(cardDetailProvider(cardId));
    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.scCardTitle)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          title: l10n.scErrorTitle,
          message: l10n.scErrorBody,
          onRetry: () => ref.invalidate(cardDetailProvider(cardId)),
        ),
        data: (card) => _Content(card: card),
      ),
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.card});

  final SacredCard card;

  static const double _cardMaxWidth = 280;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final accent = rarityColor(context, card.rarity);
    final place = card.subtitle?.isNotEmpty == true ? card.subtitle : card.temple?.name;
    return ListView(
      padding: AppSpacing.screenAll,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [accent.withValues(alpha: card.owned ? 0.2 : 0.06), accent.withValues(alpha: 0)],
              radius: 0.7,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _cardMaxWidth),
                child: CardFlip(
                  front: SacredCardFace(card: card, size: SacredCardSize.hero, heroTag: 'card-${card.id}'),
                  back: _CardBack(card: card),
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AppIcons.refresh, size: 14, color: context.colors.textSecondary),
            const Gap.h(AppSpacing.xs),
            Text(l10n.scTapToFlip, style: context.caption.copyWith(color: context.colors.textSecondary)),
          ],
        ),
        const Gap(AppSpacing.xl),
        Text(card.title, style: context.textTheme.titleLarge?.bold.withColor(context.scheme.secondary)),
        if (place != null) ...[
          const Gap(AppSpacing.xxs),
          Text(place, style: context.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary)),
        ],
        const Gap(AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            RarityChip(rarity: card.rarity),
            if (card.series != null) AppBadge(label: card.series!.name, icon: AppIcons.route),
            if (card.season != null) AppBadge(label: card.season!.name, icon: AppIcons.calendar),
            if (card.isLimited) AppBadge(label: l10n.scLimited, icon: AppIcons.star, tone: AppBadgeTone.gold),
          ],
        ),
        if (card.description != null && card.description!.isNotEmpty) ...[
          const Gap(AppSpacing.lg),
          Text(card.description!, style: context.textTheme.bodyMedium?.copyWith(height: 1.55)),
        ],
        const Gap(AppSpacing.lg),
        _Details(card: card),
        if (card.temple?.history != null && card.temple!.history!.isNotEmpty) ...[
          const Gap(AppSpacing.lg),
          SectionHeader(title: l10n.scHistory),
          const Gap(AppSpacing.sm),
          Text(card.temple!.history!, style: context.textTheme.bodyMedium?.copyWith(height: 1.55)),
        ],
        const Gap(AppSpacing.xl),
        if (card.temple != null)
          AppButton.primary(
            label: l10n.scViewTemple,
            icon: AppIcons.temple,
            onPressed: () => context.pushNamed(
              RouteNames.templeDetail,
              pathParameters: {RoutePaths.templeIdParam: card.temple!.slug},
            ),
          ),
        if (card.owned && card.ownership?.userCardId != null) ...[
          const Gap(AppSpacing.sm),
          AppButton.outlined(
            label: l10n.scShareCard,
            icon: AppIcons.share,
            onPressed: () => _share(context, ref, card),
          ),
        ],
      ],
    );
  }

  Future<void> _share(BuildContext context, WidgetRef ref, SacredCard card) =>
      AppSheets.show<void>(context, padded: false, builder: (_) => _CardShareSheet(card: card));
}

/// Previews the branded share poster of an owned card and shares it as an
/// image (with the backend's share text, when available).
class _CardShareSheet extends ConsumerStatefulWidget {
  const _CardShareSheet({required this.card});

  final SacredCard card;

  @override
  ConsumerState<_CardShareSheet> createState() => _CardShareSheetState();
}

class _CardShareSheetState extends ConsumerState<_CardShareSheet> {
  final _posterKey = GlobalKey();
  bool _busy = false;

  Future<void> _share() async {
    final l10n = AppLocalizations.of(context);
    final card = widget.card;
    setState(() => _busy = true);
    try {
      final text = await ref.read(cardsRepositoryProvider).shareText(card.ownership!.userCardId!);
      await shareBoundaryImage(
        _posterKey,
        text: text ?? '${l10n.scShareFallback} ${card.title} · MARG',
        fileName: 'marg-card.png',
      );
    } catch (_) {
      if (mounted) AppSnackbar.error(context, l10n.scErrorBody);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppSheetLayout(
      title: l10n.scShareCard,
      actions: [
        AppButton.primary(label: l10n.kbShareNow, icon: AppIcons.share, busy: _busy, onPressed: _share),
      ],
      child: Center(
        child: RepaintBoundary(key: _posterKey, child: _CardPoster(card: widget.card)),
      ),
    );
  }
}

/// The shareable poster: MARG mark, headline, the card at showcase size and
/// the brand line, on a night-sky panel with a gold rim.
class _CardPoster extends StatelessWidget {
  const _CardPoster({required this.card});

  final SacredCard card;

  static const double _width = 300;
  static const double _cardWidth = 224;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gold = context.colors.gold;
    final light = context.colors.card;
    return Container(
      width: _width,
      padding: AppSpacing.allLg,
      decoration: BoxDecoration(
        gradient: AppGradients.night,
        borderRadius: AppRadius.xlAll,
        border: Border.all(color: gold, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: AppRadius.smAll,
                child: Image.asset(BrandAssets.logo, height: 28, errorBuilder: (_, _, _) => const SizedBox.shrink()),
              ),
              const Gap.h(AppSpacing.sm),
              Text('MARG', style: context.brandText.headlineSmall.copyWith(color: gold, letterSpacing: 2)),
            ],
          ),
          const Gap(AppSpacing.sm),
          Text(l10n.scShareHeadline, textAlign: TextAlign.center, style: context.textTheme.bodySmall?.withColor(light.withValues(alpha: 0.8))),
          const Gap(AppSpacing.lg),
          SizedBox(width: _cardWidth, child: SacredCardFace(card: card, size: SacredCardSize.hero)),
          const Gap(AppSpacing.lg),
          Text(l10n.acBrandTagline, textAlign: TextAlign.center, style: context.caption.copyWith(color: gold.withValues(alpha: 0.85))),
        ],
      ),
    );
  }
}

/// The reverse of the card: night sky inside the same gilt frame, with the
/// emblem, name, rarity and the temple it belongs to.
class _CardBack extends StatelessWidget {
  const _CardBack({required this.card});

  final SacredCard card;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final light = context.colors.card;
    return GiltFrame(
      accent: rarityColor(context, card.rarity),
      locked: !card.owned,
      large: true,
      aspectRatio: SacredCardFace.aspect,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.night),
        child: Padding(
          padding: AppSpacing.allXl,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CardEmblem(size: 48, locked: !card.owned),
              const Gap(AppSpacing.lg),
              Text(
                card.title,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: context.brandText.headlineSmall.copyWith(color: context.colors.gold),
              ),
              const Gap(AppSpacing.md),
              RarityRibbon(rarity: card.rarity),
              if (card.temple != null) ...[
                const Gap(AppSpacing.lg),
                Text(card.temple!.name, textAlign: TextAlign.center, style: context.textTheme.bodyMedium?.semiBold.withColor(light)),
                if (card.temple!.deity != null)
                  Text(card.temple!.deity!, style: context.caption.copyWith(color: light.withValues(alpha: 0.7))),
              ],
              const Gap(AppSpacing.lg),
              Text(
                card.owned ? l10n.scUnlocked : l10n.scLocked,
                style: context.overline.copyWith(color: card.owned ? context.colors.gold : light.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Unlock date, mint number and catalogue facts as icon rows.
class _Details extends StatelessWidget {
  const _Details({required this.card});

  final SacredCard card;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final o = card.ownership;
    final rows = <(IconData, String, String)>[
      if (o?.unlockedAt != null) (AppIcons.calendar, l10n.scUnlockedOn, DateFormat('d MMM yyyy').format(o!.unlockedAt!.toLocal())),
      if (o?.mintNumber != null) (AppIcons.verified, l10n.scMintNumber, '#${o!.mintNumber}'),
      if (card.series != null) (AppIcons.route, l10n.scSeries, card.series!.name),
      if (card.season != null) (AppIcons.calendar, l10n.scSeasons, card.season!.name),
      if (card.editionName != null && card.editionName!.isNotEmpty) (AppIcons.star, l10n.scEdition, card.editionName!),
      if (!card.owned) (AppIcons.lock, l10n.scLocked, rarityLabel(l10n, card.rarity)),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const AppDivider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Row(
                children: [
                  Icon(rows[i].$1, size: 18, color: context.scheme.primary),
                  const Gap.h(AppSpacing.md),
                  Expanded(
                    child: Text(rows[i].$2, style: context.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary)),
                  ),
                  Flexible(
                    child: Text(
                      rows[i].$3,
                      textAlign: TextAlign.end,
                      style: context.textTheme.bodyMedium?.semiBold.withColor(context.scheme.secondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
