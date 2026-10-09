import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/referral_models.dart';
import '../controllers/referral_controllers.dart';
import '../widgets/referral_widgets.dart';

/// Screen 1 — the Referral Dashboard: the invite card (code, copy, invite),
/// the referral ledger with progress to the next milestone, the referral
/// tools, and recent rewards.
class ReferralDashboardPage extends ConsumerWidget {
  const ReferralDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(referralSummaryProvider);

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.rfTitle)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(title: l10n.rfErrorTitle, message: l10n.rfErrorBody, onRetry: () => ref.invalidate(referralSummaryProvider)),
        data: (summary) => RefreshIndicator(
          onRefresh: () async {
            ref
              ..invalidate(referralSummaryProvider)
              ..invalidate(referralRewardsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.huge),
            children: [
              _InviteCard(summary: summary).fadeIn(),
              const Gap(AppSpacing.lg),
              _Ledger(summary: summary).fadeIn(delay: 60.ms),
              const Gap(AppSpacing.lg),
              GoldRuleHeader(label: l10n.rfTools),
              const Gap(AppSpacing.md),
              const _Tools(),
              const Gap(AppSpacing.lg),
              Row(
                children: [
                  Expanded(child: GoldRuleHeader(label: l10n.rfRecentActivity)),
                  TextButton(
                    onPressed: () => context.pushNamed(RouteNames.referralRewards),
                    child: Text(l10n.rfViewAll),
                  ),
                ],
              ),
              const Gap(AppSpacing.xs),
              const _RecentActivity(),
            ],
          ),
        ),
      ),
    );
  }
}

/// The night-sky invite card in the gilt frame: the code on a parchment
/// ticket with copy, one line on how it works, and Invite Friends.
class _InviteCard extends StatelessWidget {
  const _InviteCard({required this.summary});
  final ReferralSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gold = context.colors.gold;
    final light = context.colors.card;
    return GiltFrame(
      accent: gold,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.night),
        child: Padding(
          padding: AppSpacing.allLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.rfYourCode.toUpperCase(), style: context.overline.copyWith(color: gold, letterSpacing: 1.4)),
                        const Gap(AppSpacing.xs),
                        Text(l10n.rfInviteHeading, style: context.displayText.titleLarge.withColor(light)),
                      ],
                    ),
                  ),
                  IllustratedIcon(asset: BrandAssets.illustrationInviteGift, fallbackIcon: AppIcons.referral, color: gold, size: 60),
                ],
              ),
              const Gap(AppSpacing.md),
              _CodeTicket(code: summary.code),
              const Gap(AppSpacing.sm),
              Text(l10n.rfCodeHint, style: context.caption.copyWith(color: light.withValues(alpha: 0.75))),
              const Gap(AppSpacing.md),
              AppButton.primary(
                label: l10n.rfInviteFriends,
                icon: AppIcons.share,
                onPressed: () => context.pushNamed(RouteNames.referralInvite),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The code on a parchment ticket, tap or the copy button to copy.
class _CodeTicket extends StatelessWidget {
  const _CodeTicket({required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    void copy() {
      Clipboard.setData(ClipboardData(text: code));
      AppSnackbar.success(context, l10n.rfCopied);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: copy,
        borderRadius: AppRadius.mdAll,
        child: Ink(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xs, AppSpacing.xs, AppSpacing.xs),
          decoration: BoxDecoration(
            gradient: AppGradients.parchment,
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: context.colors.gold.withValues(alpha: 0.7)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  code,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.displayText.headlineSmall.copyWith(color: context.scheme.primary, letterSpacing: 3),
                ),
              ),
              IconButton(
                onPressed: copy,
                tooltip: l10n.rfCopy,
                icon: Icon(AppIcons.copy, color: context.scheme.secondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Invited · Joined · Points, then the road to the next milestone.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.summary});
  final ReferralSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    return StatLedger(
      stats: [
        LedgerStat(icon: AppIcons.mail, color: p.accentBlue, value: summary.totalInvites, label: l10n.rfInvited),
        LedgerStat(icon: AppIcons.verified, color: context.colors.success, value: summary.successfulInvites, label: l10n.rfJoined),
        LedgerStat(icon: AppIcons.points, color: p.accentAmber, value: summary.pointsEarned, label: l10n.rfPoints),
      ],
      footer: MilestoneProgress(summary: summary),
    );
  }
}

class _Tools extends StatelessWidget {
  const _Tools();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final tools = <(IconData, String, String, String, Color)>[
      (AppIcons.history, l10n.rfTileTimeline, l10n.rfTileTimelineHint, RouteNames.referralTimeline, p.accentViolet),
      (AppIcons.points, l10n.rfTileRewards, l10n.rfTileRewardsHint, RouteNames.referralRewards, p.accentAmber),
      (AppIcons.trending, l10n.rfTileAnalytics, l10n.rfTileAnalyticsHint, RouteNames.referralAnalytics, p.accentBlue),
      (AppIcons.leaderboard, l10n.rfTileRanking, l10n.rfTileRankingHint, RouteNames.referralRanking, p.accentSaffron),
      (AppIcons.share, l10n.rfTileShare, l10n.rfTileShareHint, RouteNames.referralShare, p.accentRose),
      (AppIcons.help, l10n.rfTileFaq, l10n.rfTileFaqHint, RouteNames.referralFaq, p.accentGreen),
    ];
    return GridView.count(
      crossAxisCount: context.responsive(compact: 2, medium: 3),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.45,
      children: [
        for (final (i, (icon, title, hint, route, accent)) in tools.indexed)
          AccentTile(
            icon: icon,
            title: title,
            subtitle: hint,
            accent: accent,
            onTap: () => context.pushNamed(route),
          ).fadeIn(delay: AppDurations.stagger * i),
      ],
    );
  }
}

class _RecentActivity extends ConsumerWidget {
  const _RecentActivity();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(referralRewardsProvider);
    return async.when(
      loading: () => const SkeletonList(count: 3, padding: EdgeInsets.zero),
      error: (_, _) => Text(l10n.rfErrorBody, style: context.caption.copyWith(color: context.colors.textSecondary)),
      data: (page) {
        if (page.items.isEmpty) {
          return EmptyCard(icon: AppIcons.referral, label: l10n.rfNoActivity);
        }
        return AppCard(
          child: Column(children: [for (final r in page.items.take(5)) RewardActivityTile(reward: r)]),
        );
      },
    );
  }
}
