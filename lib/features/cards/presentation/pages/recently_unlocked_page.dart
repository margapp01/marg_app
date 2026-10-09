import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../shared/design_system.dart';
import '../controllers/cards_controllers.dart';
import '../widgets/card_widgets.dart';

/// Recently Unlocked — the user's newest cards first, as framed cards with
/// their unlock date.
class RecentlyUnlockedPage extends ConsumerWidget {
  const RecentlyUnlockedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(recentCardsProvider);
    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.scRecentlyUnlocked)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          title: l10n.scErrorTitle,
          message: l10n.scErrorBody,
          onRetry: () => ref.invalidate(recentCardsProvider),
        ),
        data: (cards) {
          if (cards.isEmpty) {
            return EmptyView(art: StateArt.cards, icon: AppIcons.card, title: l10n.scNoRecent, message: l10n.scNoRecentBody);
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(recentCardsProvider),
            child: GridView.builder(
              padding: AppSpacing.screenAll,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 180,
                mainAxisSpacing: AppSpacing.lg,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: SacredCardTile.gridAspect,
              ),
              itemCount: cards.length,
              itemBuilder: (context, i) {
                final card = cards[i];
                final date = card.ownership?.unlockedAt;
                return SacredCardTile(
                  card: card,
                  detail: date == null ? null : DateFormat('d MMM').format(date.toLocal()),
                  onTap: () => context.pushNamed(
                    RouteNames.cardDetail,
                    pathParameters: {RoutePaths.cardIdParam: card.id},
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
