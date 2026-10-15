import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../data/repository/passport_repository_impl.dart';
import '../../domain/entities/passport_share.dart';
import '../controllers/passport_controllers.dart';
import '../widgets/passport_widgets.dart';

/// Share Passport — a premium share card the pilgrim can send as an image, plus
/// the public passport link + QR (`GET /my/passport/share-link`, stable until
/// the pilgrim resets it).
class PassportSharePage extends ConsumerStatefulWidget {
  const PassportSharePage({super.key});

  @override
  ConsumerState<PassportSharePage> createState() => _PassportSharePageState();
}

class _PassportSharePageState extends ConsumerState<PassportSharePage> {
  final _cardKey = GlobalKey();
  bool _sharingImage = false;

  /// The passport's public page; until its link loads, the sharer's invite.
  ShareMessage _message(AppLocalizations l10n, PassportShare share, String? path) => ShareMessage(
        kind: ShareKind.passport,
        path: path,
        text: ShareCopy.passport(
          l10n,
          temples: share.visitedTemples,
          cards: share.cardsCollected,
          percent: share.passportCompletion,
        ),
      );

  Future<void> _shareImage(PassportShare share, String? path) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _sharingImage = true);
    try {
      await ref.read(shareServiceProvider).share(_message(l10n, share, path), capture: _cardKey, fileName: 'marg-passport.png');
    } catch (_) {
      if (mounted) AppSnackbar.error(context, l10n.ppShareFailed);
    } finally {
      if (mounted) setState(() => _sharingImage = false);
    }
  }

  Future<void> _shareLink(PassportShare share, String path) async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(shareServiceProvider).share(_message(l10n, share, path));
    } catch (_) {
      if (mounted) AppSnackbar.error(context, l10n.ppShareFailed);
    }
  }

  Future<void> _resetLink() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await AppDialogs.confirm(
      context,
      title: l10n.shResetLinkTitle,
      message: l10n.shResetLinkBody,
      confirmLabel: l10n.shResetLink,
      cancelLabel: l10n.pfCancel,
      icon: AppIcons.refresh,
    );
    if (!confirmed || !mounted) return;
    try {
      await ref.read(passportRepositoryProvider).resetShareLink();
      ref.invalidate(passportShareLinkProvider);
      if (mounted) AppSnackbar.success(context, l10n.shResetLinkDone);
    } catch (_) {
      if (mounted) AppSnackbar.error(context, l10n.ppLinkUnavailable);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(passportShareProvider);
    final link = ref.watch(passportShareLinkProvider);
    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.ppSharePassport)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(title: l10n.ppErrorTitle, message: l10n.ppErrorBody, onRetry: () => ref.invalidate(passportShareProvider)),
        data: (share) => ListView(
          padding: AppSpacing.screenAll,
          children: [
            RepaintBoundary(
              key: _cardKey,
              child: PassportShareCard(share: share, qrData: _publicUrl(link.valueOrNull)),
            ),
            const Gap(AppSpacing.xl),
            AppButton.primary(
              label: l10n.ppShareAsImage,
              icon: AppIcons.share,
              busy: _sharingImage,
              onPressed: () => _shareImage(share, link.valueOrNull),
            ),
            const Gap(AppSpacing.sm),
            AppButton.outlined(
              label: l10n.ppShareLink,
              icon: AppIcons.link,
              busy: link.isLoading,
              onPressed: link.valueOrNull == null ? null : () => _shareLink(share, link.value!),
            ),
            if (link.hasError) ...[
              const Gap(AppSpacing.sm),
              Text(l10n.ppLinkUnavailable, textAlign: TextAlign.center, style: context.caption.copyWith(color: context.colors.textSecondary)),
            ],
            if (link.hasValue) ...[
              const Gap(AppSpacing.xs),
              AppButton.ghost(label: l10n.shResetLink, icon: AppIcons.refresh, onPressed: _resetLink),
            ],
          ],
        ),
      ),
    );
  }

  static String? _publicUrl(String? path) =>
      path == null || path.isEmpty ? null : ShareLinks.web(path, kind: ShareKind.passport);
}
