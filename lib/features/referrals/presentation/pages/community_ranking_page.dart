import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../features/auth/presentation/controllers/auth_controller.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/referral_models.dart';
import '../controllers/referral_controllers.dart';
import '../widgets/referral_widgets.dart';

/// Screen 5 — Community Ranking. Reuses the referral leaderboard
/// (`GET /referrals/leaderboard`). Only the National board is exposed by the
/// backend, so State / City / Friends tabs are not shown.
class CommunityRankingPage extends ConsumerWidget {
  const CommunityRankingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(referralLeaderboardProvider);
    final currentUserId = ref.watch(authControllerProvider).user?.id;

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.rfCommunityRanking)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(title: l10n.rfErrorTitle, message: l10n.rfErrorBody, onRetry: () => ref.invalidate(referralLeaderboardProvider)),
        data: (rows) {
          if (rows.isEmpty) {
            return EmptyView(art: StateArt.leaderboard, icon: AppIcons.leaderboard, title: l10n.rfNoRanking, message: l10n.rfNoRankingBody);
          }
          final top3 = rows.take(3).toList();
          final rest = rows.skip(3).toList();
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(referralLeaderboardProvider),
            child: ListView(
              padding: AppSpacing.screenAll,
              children: [
                Center(child: Text(l10n.rfNational, style: context.textTheme.labelMedium?.semiBold.copyWith(color: context.scheme.primary))),
                const Gap(AppSpacing.md),
                _Podium(top3: top3, currentUserId: currentUserId),
                const Gap(AppSpacing.lg),
                for (final row in rest) LeaderTile(row: row, isCurrentUser: row.userId == currentUserId),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  const _Podium({required this.top3, required this.currentUserId});
  final List<LeaderRow> top3;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    // Arrange as 2nd — 1st — 3rd.
    final ordered = <(LeaderRow, double)>[
      if (top3.length > 1) (top3[1], 66),
      if (top3.isNotEmpty) (top3[0], 84),
      if (top3.length > 2) (top3[2], 58),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final (row, size) in ordered)
          Expanded(child: _PodiumEntry(row: row, size: size, isCurrentUser: row.userId == currentUserId)),
      ],
    );
  }
}

class _PodiumEntry extends StatelessWidget {
  const _PodiumEntry({required this.row, required this.size, required this.isCurrentUser});
  final LeaderRow row;
  final double size;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isFirst = row.position == 1;
    return Column(
      children: [
        if (isFirst) Icon(AppIcons.achievement, color: context.colors.gold, size: 22),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isFirst ? SweepGradient(colors: [context.colors.gold, context.scheme.primary, context.colors.gold]) : null,
            color: isFirst ? null : context.colors.border,
          ),
          child: AppAvatar(imageUrl: row.avatarUrl, name: row.displayName, radius: size / 2),
        ),
        const Gap(AppSpacing.xs),
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(color: _rankColor(context, row.position), shape: BoxShape.circle),
          child: Center(child: Text('${row.position}', style: context.overline.copyWith(color: Colors.white, fontWeight: FontWeight.w700))),
        ),
        const Gap(AppSpacing.xxs),
        Text(isCurrentUser ? l10n.rfYou : (row.displayName ?? l10n.rfAFriend), style: context.textTheme.bodySmall?.semiBold, maxLines: 1, overflow: TextOverflow.ellipsis),
        Text('${row.points} ${l10n.rfPts}', style: context.caption.copyWith(color: context.colors.textSecondary)),
      ],
    );
  }

  Color _rankColor(BuildContext context, int pos) => switch (pos) {
        1 => context.colors.gold,
        2 => context.colors.silver,
        _ => context.colors.bronze,
      };
}
