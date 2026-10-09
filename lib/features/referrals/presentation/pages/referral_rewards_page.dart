import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/referral_models.dart';
import '../controllers/referral_controllers.dart';
import '../widgets/referral_widgets.dart';

/// Screen 4 — Referral Rewards: the points earned, the milestone ladder (the
/// real backend reward table — reached, next, still ahead) and the reward
/// history. (There is no redemption / ledger-debit system, so no
/// available/redeemed split and no redeem action are shown.)
class ReferralRewardsPage extends ConsumerWidget {
  const ReferralRewardsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final summary = ref.watch(referralSummaryProvider).valueOrNull;
    final rewardsAsync = ref.watch(referralRewardsProvider);

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.rfRewards)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref
            ..invalidate(referralSummaryProvider)
            ..invalidate(referralRewardsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.huge),
          children: [
            _PointsCard(points: summary?.pointsEarned ?? 0, joined: summary?.successfulInvites ?? 0).fadeIn(),
            if (summary != null) ...[
              const Gap(AppSpacing.md),
              ParchmentCard(child: MilestoneProgress(summary: summary)),
            ],
            const Gap(AppSpacing.lg),
            GoldRuleHeader(label: l10n.rfMilestones, count: kMilestoneRules.length),
            const Gap(AppSpacing.md),
            _MilestoneLadder(joined: summary?.successfulInvites ?? 0),
            const Gap(AppSpacing.md),
            GoldRuleHeader(label: l10n.rfRewardHistory, count: rewardsAsync.valueOrNull?.items.length),
            const Gap(AppSpacing.md),
            rewardsAsync.when(
              loading: () => const SkeletonList(count: 3, padding: EdgeInsets.zero),
              error: (_, _) => ErrorView(title: l10n.rfErrorTitle, message: l10n.rfErrorBody, onRetry: () => ref.invalidate(referralRewardsProvider)),
              data: (page) => page.items.isEmpty
                  ? EmptyView(art: StateArt.referrals, icon: AppIcons.referral, title: l10n.rfNoRewards, message: l10n.rfNoRewardsBody)
                  : AppCard(child: Column(children: [for (final r in page.items) RewardActivityTile(reward: r)])),
            ),
          ],
        ),
      ),
    );
  }
}

/// The points earned from referrals on the night sky in the gilt frame.
class _PointsCard extends StatelessWidget {
  const _PointsCard({required this.points, required this.joined});
  final int points;
  final int joined;

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
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.rfPointsEarned.toUpperCase(), style: context.overline.copyWith(color: gold, letterSpacing: 1.4)),
                    const Gap(AppSpacing.xxs),
                    AnimatedCount(value: points, style: context.displayText.displaySmall.copyWith(color: gold)),
                    Text(l10n.rfPointsFromReferrals, style: context.caption.copyWith(color: light.withValues(alpha: 0.75))),
                    const Gap(AppSpacing.sm),
                    Row(
                      children: [
                        Icon(AppIcons.verified, size: 14, color: gold),
                        const Gap.h(AppSpacing.xxs),
                        Text('$joined ${l10n.rfJoined}', style: context.caption.copyWith(color: light.withValues(alpha: 0.85))),
                      ],
                    ),
                  ],
                ),
              ),
              IllustratedIcon(asset: BrandAssets.illustrationPoints, fallbackIcon: AppIcons.points, color: gold, size: 72),
            ],
          ),
        ),
      ),
    );
  }
}

/// The backend's referral milestones as a rail: reached ones checked, the
/// next one outlined, the rest still ahead — each with its points and bonus.
class _MilestoneLadder extends StatelessWidget {
  const _MilestoneLadder({required this.joined});
  final int joined;

  @override
  Widget build(BuildContext context) {
    final nextIndex = kMilestoneRules.indexWhere((r) => r.milestone > joined);
    return Column(
      children: [
        for (final (i, rule) in kMilestoneRules.indexed)
          _step(context, rule, next: i == nextIndex, isLast: i == kMilestoneRules.length - 1),
      ],
    );
  }

  Widget _step(BuildContext context, MilestoneRule rule, {required bool next, required bool isLast}) {
    final l10n = AppLocalizations.of(context);
    final reached = joined >= rule.milestone;
    final gold = context.colors.gold;
    final success = context.colors.success;
    return JourneyRailTile(
      icon: AppIcons.check,
      nodeLabel: reached ? null : '${rule.milestone}',
      color: reached ? success : next ? gold : context.colors.textSecondary,
      title: l10n.rfMilestoneTitle(rule.milestone),
      subtitle: milestoneBonus(l10n, rule),
      caption: reached ? l10n.rfReached : next ? l10n.rfNextUp : null,
      captionIcon: reached ? AppIcons.verified : next ? AppIcons.flag : null,
      captionColor: reached ? success : next ? gold : null,
      trailing: AppBadge(
        label: '+${rule.points}',
        icon: AppIcons.points,
        tone: reached || next ? AppBadgeTone.gold : AppBadgeTone.neutral,
      ),
      highlighted: next,
      muted: !reached && !next,
      isLast: isLast,
    );
  }
}
