import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/passport_share.dart';
import '../controllers/passport_controllers.dart';
import '../widgets/passport_widgets.dart';

/// Share Passport — a premium share card the pilgrim can send as an image, plus
/// the public link + QR (minted via `POST /my/passport/share-link`).
class PassportSharePage extends ConsumerStatefulWidget {
  const PassportSharePage({super.key});

  @override
  ConsumerState<PassportSharePage> createState() => _PassportSharePageState();
}

class _PassportSharePageState extends ConsumerState<PassportSharePage> {
  final _cardKey = GlobalKey();
  bool _sharingImage = false;

  Future<void> _shareImage(PassportShare share) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _sharingImage = true);
    try {
      final boundary = _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return;
      final file = XFile.fromData(bytes.buffer.asUint8List(), name: 'marg-passport.png', mimeType: 'image/png');
      await SharePlus.instance.share(ShareParams(files: [file], text: share.shareText.isEmpty ? null : share.shareText));
    } catch (_) {
      if (mounted) AppSnackbar.error(context, l10n.ppShareFailed);
    } finally {
      if (mounted) setState(() => _sharingImage = false);
    }
  }

  Future<void> _shareLink(String link) async {
    await SharePlus.instance.share(ShareParams(text: link));
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
              child: PassportShareCard(share: share, qrData: link.valueOrNull),
            ),
            const Gap(AppSpacing.xl),
            AppButton.primary(
              label: l10n.ppShareAsImage,
              icon: AppIcons.share,
              busy: _sharingImage,
              onPressed: () => _shareImage(share),
            ),
            const Gap(AppSpacing.sm),
            AppButton.outlined(
              label: l10n.ppShareLink,
              icon: AppIcons.copy,
              busy: link.isLoading,
              onPressed: link.valueOrNull == null ? null : () => _shareLink(link.value!),
            ),
            if (link.hasError) ...[
              const Gap(AppSpacing.sm),
              Text(l10n.ppLinkUnavailable, textAlign: TextAlign.center, style: context.caption.copyWith(color: context.colors.textSecondary)),
            ],
          ],
        ),
      ),
    );
  }
}
