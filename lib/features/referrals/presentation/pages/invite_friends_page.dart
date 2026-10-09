import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../controllers/referral_controllers.dart';
import '../widgets/referral_share.dart';

/// Screen 2 — Invite Friends: the real referral link (code + app base), per-app
/// share buttons, copy, and a QR of the invite link.
class InviteFriendsPage extends ConsumerWidget {
  const InviteFriendsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(referralSummaryProvider);

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.rfInviteFriends)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(title: l10n.rfErrorTitle, message: l10n.rfErrorBody, onRetry: () => ref.invalidate(referralSummaryProvider)),
        data: (summary) {
          final text = '${l10n.rfShareMessage} ${summary.inviteLink}';
          return ListView(
            padding: AppSpacing.screenAll,
            children: [
              const Gap(AppSpacing.sm),
              Center(child: Icon(AppIcons.referral, size: 56, color: context.colors.gold)),
              const Gap(AppSpacing.md),
              Text(l10n.rfInviteHeading, style: context.textTheme.titleMedium?.bold, textAlign: TextAlign.center),
              const Gap(AppSpacing.xs),
              Text(l10n.rfInviteSubtitle, style: context.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary), textAlign: TextAlign.center),
              const Gap(AppSpacing.xl),
              SectionHeader(title: l10n.rfShareVia),
              const Gap(AppSpacing.sm),
              _ShareGrid(text: text, link: summary.inviteLink),
              const Gap(AppSpacing.lg),
              SectionHeader(title: l10n.rfYourLink),
              const Gap(AppSpacing.sm),
              _LinkRow(link: summary.inviteLink),
              const Gap(AppSpacing.lg),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.lgAll, boxShadow: AppShadows.sm),
                  child: QrImageView(data: summary.inviteLink, size: 160, padding: EdgeInsets.zero),
                ),
              ),
              const Gap(AppSpacing.sm),
              Center(child: Text(l10n.rfScanToJoin, style: context.caption.copyWith(color: context.colors.textSecondary))),
            ],
          );
        },
      ),
    );
  }
}

class _ShareGrid extends StatelessWidget {
  const _ShareGrid({required this.text, required this.link});
  final String text;
  final String link;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final targets = <(IconData, String, ShareTarget)>[
      (AppIcons.share, 'WhatsApp', ShareTarget.whatsapp),
      (AppIcons.share, 'Telegram', ShareTarget.telegram),
      (AppIcons.share, 'X', ShareTarget.twitter),
      (AppIcons.mail, l10n.rfEmail, ShareTarget.email),
      (AppIcons.more, l10n.rfMore, ShareTarget.system),
    ];
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (final (icon, label, target) in targets)
          _ShareButton(icon: icon, label: label, onTap: () => shareReferral(target, text: text, link: link)),
      ],
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgAll,
        child: Column(children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: context.scheme.primary.withValues(alpha: 0.1), borderRadius: AppRadius.lgAll),
            child: Icon(icon, color: context.scheme.primary),
          ),
          const Gap(AppSpacing.xxs),
          Text(label, style: context.overline, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.link});
  final String link;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.xs, AppSpacing.xs, AppSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(link, style: context.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
          IconButton(
            icon: const Icon(AppIcons.copy, size: 20),
            tooltip: l10n.rfCopy,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: link));
              AppSnackbar.success(context, l10n.rfCopied);
            },
          ),
        ],
      ),
    );
  }
}
