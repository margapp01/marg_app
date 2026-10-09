import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/referral_models.dart';
import '../controllers/referral_controllers.dart';
import '../widgets/referral_widgets.dart';

/// Screen 3 (+ 8, Invite Status) — the Referral Timeline. The backend exposes
/// PENDING → COMPLETED → REWARDED with sent/completed timestamps (no friend
/// profile), so entries are status-based, not named.
class ReferralTimelinePage extends ConsumerStatefulWidget {
  const ReferralTimelinePage({super.key});

  @override
  ConsumerState<ReferralTimelinePage> createState() => _ReferralTimelinePageState();
}

class _ReferralTimelinePageState extends ConsumerState<ReferralTimelinePage> {
  ReferralStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(referralInvitesProvider);

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.rfTimeline)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(title: l10n.rfErrorTitle, message: l10n.rfErrorBody, onRetry: () => ref.invalidate(referralInvitesProvider)),
        data: (page) {
          final all = page.items;
          final filtered = _filter == null ? all : all.where((i) => i.status == _filter).toList();
          return Column(
            children: [
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: AppSpacing.screenH,
                  children: [
                    _chip(l10n.rfAll, null),
                    const Gap(AppSpacing.sm),
                    _chip(l10n.rfStatusPending, ReferralStatus.pending),
                    const Gap(AppSpacing.sm),
                    _chip(l10n.rfStatusJoined, ReferralStatus.completed),
                    const Gap(AppSpacing.sm),
                    _chip(l10n.rfStatusRewarded, ReferralStatus.rewarded),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? EmptyView(art: StateArt.referrals, icon: AppIcons.referral, title: l10n.rfNoInvites, message: l10n.rfNoInvitesBody)
                    : RefreshIndicator(
                        onRefresh: () async => ref.invalidate(referralInvitesProvider),
                        child: ListView.builder(
                          padding: AppSpacing.screenAll,
                          itemCount: filtered.length,
                          itemBuilder: (context, i) => _InviteTile(invite: filtered[i], isLast: i == filtered.length - 1),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _chip(String label, ReferralStatus? status) =>
      Center(child: AppFilterChip(label: label, selected: _filter == status, onSelected: (_) => setState(() => _filter = status)));
}

class _InviteTile extends StatelessWidget {
  const _InviteTile({required this.invite, required this.isLast});
  final ReferralInvite invite;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (label, color) = statusChip(context, l10n, invite.status);
    final when = invite.completedAt ?? invite.createdAt;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(width: 14, height: 14, margin: const EdgeInsets.only(top: 4), decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: color.withValues(alpha: 0.3), width: 3))),
              if (!isLast) Expanded(child: Container(width: 2, color: context.colors.border)),
            ],
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_title(l10n, invite.status), style: context.textTheme.bodyMedium?.semiBold),
                          if (when != null) Text(referralDate(when), style: context.caption.copyWith(color: context.colors.textSecondary)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: AppRadius.fullAll),
                      child: Text(label, style: context.overline.copyWith(color: color)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _title(AppLocalizations l10n, ReferralStatus s) {
    switch (s) {
      case ReferralStatus.pending:
        return l10n.rfInvitationSent;
      case ReferralStatus.completed:
        return l10n.rfFriendJoined;
      case ReferralStatus.rewarded:
        return l10n.rfRewardCredited;
      case ReferralStatus.unknown:
        return l10n.rfInvitationSent;
    }
  }
}
