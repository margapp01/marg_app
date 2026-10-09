import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/referral_models.dart';

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String referralDate(DateTime? d) => d == null ? '' : '${d.day} ${_months[d.month - 1]} ${d.year}';

/// (icon, colour) for a reward type.
(IconData, Color) rewardVisual(BuildContext context, ReferralRewardType type) {
  switch (type) {
    case ReferralRewardType.points:
      return (AppIcons.points, context.colors.gold);
    case ReferralRewardType.card:
      return (AppIcons.card, context.colors.info);
    case ReferralRewardType.achievement:
      return (AppIcons.achievement, context.colors.gold);
    case ReferralRewardType.specialBadge:
      return (AppIcons.trustScore, context.scheme.primary);
    case ReferralRewardType.unknown:
      return (AppIcons.referral, context.colors.textSecondary);
  }
}

/// Localized label + colour for a referral status.
(String, Color) statusChip(BuildContext context, AppLocalizations l10n, ReferralStatus s) {
  switch (s) {
    case ReferralStatus.pending:
      return (l10n.rfStatusPending, context.colors.warning);
    case ReferralStatus.completed:
      return (l10n.rfStatusJoined, context.colors.info);
    case ReferralStatus.rewarded:
      return (l10n.rfStatusRewarded, context.colors.success);
    case ReferralStatus.unknown:
      return (l10n.rfStatusPending, context.colors.textSecondary);
  }
}

/// The extra a milestone brings beyond points (a bonus card or badge).
String? milestoneBonus(AppLocalizations l10n, MilestoneRule rule) => switch (rule.bonusKey) {
      'rfBonusRareCard' => l10n.rfBonusRareCard,
      'rfBonusEpicCard' => l10n.rfBonusEpicCard,
      'rfBonusLegendaryCard' => l10n.rfBonusLegendaryCard,
      'rfBonusBadge' => l10n.rfBonusBadge,
      _ => null,
    };

/// "3 more to reach 5 friends · +150" over a gold progress bar — or a thank
/// you once every milestone is reached.
class MilestoneProgress extends StatelessWidget {
  const MilestoneProgress({required this.summary, super.key});
  final ReferralSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final next = summary.nextMilestone;
    final gold = context.colors.gold;
    if (next == null) {
      return Row(
        children: [
          Icon(AppIcons.achievement, size: 18, color: gold, fill: 1),
          const Gap.h(AppSpacing.xs),
          Expanded(child: Text(l10n.rfAllMilestonesDone, style: context.textTheme.bodySmall?.semiBold)),
        ],
      );
    }
    final rule = kMilestoneRules.where((r) => r.milestone == next).firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.rfToMilestone(summary.referralsToNextMilestone ?? next, next),
                style: context.textTheme.bodySmall?.semiBold.withColor(context.scheme.secondary),
              ),
            ),
            if (rule != null) AppBadge(label: '+${rule.points}', icon: AppIcons.points, tone: AppBadgeTone.gold),
          ],
        ),
        const Gap(AppSpacing.sm),
        AppLinearProgress(value: summary.milestoneProgress, height: 6, color: gold),
      ],
    );
  }
}

/// A recent-activity row from the reward feed (has the friend's name + points).
class RewardActivityTile extends StatelessWidget {
  const RewardActivityTile({required this.reward, super.key});
  final ReferralReward reward;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (icon, color) = rewardVisual(context, reward.type);
    return Semantics(
      label: '${reward.friendName ?? l10n.rfAFriend}. ${reward.points != null ? '+${reward.points} ${l10n.rfPoints}' : ''}',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            AppAvatar(imageUrl: reward.friendPhoto, name: reward.friendName, radius: 20),
            const Gap(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reward.friendName ?? l10n.rfAFriend, style: context.textTheme.bodyMedium?.semiBold, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(referralDate(reward.awardedAt), style: context.caption.copyWith(color: context.colors.textSecondary)),
                ],
              ),
            ),
            if (reward.points != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: AppRadius.fullAll),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(icon, size: 13, color: color),
                  const Gap(AppSpacing.xxs),
                  Text('+${reward.points}', style: context.caption.copyWith(color: color, fontWeight: FontWeight.w600)),
                ]),
              ),
          ],
        ),
      ),
    );
  }
}

/// One leaderboard list row.
class LeaderTile extends StatelessWidget {
  const LeaderTile({required this.row, required this.isCurrentUser, super.key});
  final LeaderRow row;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isCurrentUser ? context.scheme.primary.withValues(alpha: 0.08) : context.colors.card,
        borderRadius: AppRadius.lgAll,
        border: isCurrentUser ? Border.all(color: context.scheme.primary.withValues(alpha: 0.4)) : null,
      ),
      child: Row(
        children: [
          SizedBox(width: 28, child: Text('${row.position}', style: context.textTheme.bodyMedium?.bold, textAlign: TextAlign.center)),
          const Gap(AppSpacing.sm),
          AppAvatar(imageUrl: row.avatarUrl, name: row.displayName, radius: 18),
          const Gap(AppSpacing.md),
          Expanded(child: Text(isCurrentUser ? l10n.rfYou : (row.displayName ?? l10n.rfAFriend), style: context.textTheme.bodyMedium?.semiBold, maxLines: 1, overflow: TextOverflow.ellipsis)),
          Text('${row.points} ${l10n.rfPts}', style: context.textTheme.bodySmall?.semiBold.copyWith(color: context.scheme.primary)),
        ],
      ),
    );
  }
}
