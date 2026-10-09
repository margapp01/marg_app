import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../shared/design_system.dart';
import '../controllers/cards_controllers.dart';
import '../widgets/card_widgets.dart';

/// Arguments for the gallery: the base query (series/season/missing context)
/// and an optional title override.
class GalleryArgs {
  const GalleryArgs({this.query = const GalleryQuery(), this.title});
  final GalleryQuery query;
  final String? title;
}

/// Card Gallery — an adaptive grid of cards (owned + locked), with search,
/// rarity filters, and infinite scroll. Reused for "all cards", a series, a
/// season, and the "missing cards" view.
class CardGalleryPage extends ConsumerStatefulWidget {
  const CardGalleryPage({required this.args, super.key});

  final GalleryArgs args;

  @override
  ConsumerState<CardGalleryPage> createState() => _CardGalleryPageState();
}

class _CardGalleryPageState extends ConsumerState<CardGalleryPage> {
  final _scroll = ScrollController();
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  late GalleryQuery _query = widget.args.query;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 400) {
      ref.read(galleryControllerProvider(_query).notifier).loadMore();
    }
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(AppDurations.slow, () {
      setState(() => _query = _query.copyWith(query: value.trim()));
    });
  }

  void _setRarity(String? rarity) => setState(() {
        _query = rarity == null ? _query.copyWith(clearRarity: true) : _query.copyWith(rarity: rarity);
      });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(galleryControllerProvider(_query));

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(widget.args.title ?? l10n.scGallery)),
      body: Column(
        children: [
          Padding(
            padding: AppSpacing.screenH,
            child: AppSearchBar(
              controller: _searchCtrl,
              hint: l10n.scSearchHint,
              onChanged: _onSearch,
            ),
          ),
          const Gap(AppSpacing.sm),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: AppSpacing.screenH,
              children: [
                _rarityChip(l10n.scAll, null),
                for (final r in kRarityOrder) ...[const Gap(AppSpacing.sm), _rarityChip(rarityLabel(l10n, r), r)],
              ],
            ),
          ),
          const Gap(AppSpacing.sm),
          Expanded(
            child: async.when(
              loading: () => const LoadingView(),
              error: (e, _) => ErrorView(
                title: l10n.scErrorTitle,
                message: l10n.scErrorBody,
                onRetry: () => ref.invalidate(galleryControllerProvider(_query)),
              ),
              data: (state) => state.cards.isEmpty
                  ? EmptyView(art: StateArt.noResults, icon: AppIcons.card, title: l10n.scNoCards, message: l10n.scNoCardsBody)
                  : RefreshIndicator(
                      onRefresh: () async => ref.invalidate(galleryControllerProvider(_query)),
                      child: GridView.builder(
                        controller: _scroll,
                        padding: AppSpacing.screenAll,
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 180,
                          mainAxisSpacing: AppSpacing.lg,
                          crossAxisSpacing: AppSpacing.md,
                          childAspectRatio: SacredCardTile.gridAspect,
                        ),
                        itemCount: state.cards.length + (state.hasMore ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (i >= state.cards.length) {
                            return const Center(child: Padding(padding: EdgeInsets.all(AppSpacing.md), child: CircularProgressIndicator()));
                          }
                          final card = state.cards[i];
                          return SacredCardTile(
                            card: card,
                            onTap: () => context.pushNamed(
                              RouteNames.cardDetail,
                              pathParameters: {RoutePaths.cardIdParam: card.id},
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rarityChip(String label, String? rarity) => AppFilterChip(
        label: label,
        selected: _query.rarity == rarity,
        onSelected: (_) => _setRarity(rarity),
      );
}
