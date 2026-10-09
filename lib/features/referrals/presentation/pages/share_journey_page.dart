import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../features/auth/presentation/controllers/auth_controller.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/referral_models.dart';
import '../controllers/referral_controllers.dart';

/// Screen 6 — Share Your Journey: a branded MARG referral card (logo + name +
/// code + QR of the invite link + milestone highlight), shared as an image.
class ShareJourneyPage extends ConsumerStatefulWidget {
  const ShareJourneyPage({super.key});

  @override
  ConsumerState<ShareJourneyPage> createState() => _ShareJourneyPageState();
}

class _ShareJourneyPageState extends ConsumerState<ShareJourneyPage> {
  final _cardKey = GlobalKey();
  bool _busy = false;

  Future<void> _share(ReferralSummary summary) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final boundary = _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return;
      final file = XFile.fromData(bytes.buffer.asUint8List(), name: 'marg-invite.png', mimeType: 'image/png');
      await SharePlus.instance.share(ShareParams(files: [file], text: '${l10n.rfShareMessage} ${summary.inviteLink}'));
    } catch (_) {
      if (mounted) AppSnackbar.error(context, l10n.rfShareFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(referralSummaryProvider);
    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.rfShareJourney)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(title: l10n.rfErrorTitle, message: l10n.rfErrorBody, onRetry: () => ref.invalidate(referralSummaryProvider)),
        data: (summary) => ListView(
          padding: AppSpacing.screenAll,
          children: [
            Text(l10n.rfShareCardHint, style: context.caption.copyWith(color: context.colors.textSecondary), textAlign: TextAlign.center),
            const Gap(AppSpacing.lg),
            RepaintBoundary(key: _cardKey, child: _ShareCard(summary: summary)),
            const Gap(AppSpacing.xl),
            AppButton.primary(label: l10n.rfShareNow, icon: AppIcons.share, busy: _busy, onPressed: () => _share(summary)),
          ],
        ),
      ),
    );
  }
}

class _ShareCard extends ConsumerWidget {
  const _ShareCard({required this.summary});
  final ReferralSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final gold = context.colors.gold;
    final name = ref.watch(authControllerProvider).user?.name;
    return Container(
      padding: AppSpacing.allLg,
      decoration: BoxDecoration(
        color: context.colors.splashCanvas,
        borderRadius: AppRadius.xlAll,
        border: Border.all(color: gold, width: 2),
        boxShadow: [BoxShadow(color: gold.withValues(alpha: 0.22), blurRadius: 20, spreadRadius: 1)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Logo(),
          const Gap(AppSpacing.md),
          Text(name ?? l10n.rfAFriend, style: context.brandText.headlineSmall, textAlign: TextAlign.center),
          const Gap(AppSpacing.xxs),
          Text(l10n.rfShareTagline, style: context.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary), textAlign: TextAlign.center),
          const Gap(AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            decoration: BoxDecoration(color: context.scheme.primary.withValues(alpha: 0.1), borderRadius: AppRadius.fullAll),
            child: Text(summary.code, style: context.textTheme.titleLarge?.bold.copyWith(color: context.scheme.primary, letterSpacing: 3)),
          ),
          const Gap(AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.mdAll),
            child: QrImageView(data: summary.inviteLink, size: 108, padding: EdgeInsets.zero),
          ),
          const Gap(AppSpacing.sm),
          Text(l10n.rfScanToJoin, style: context.caption.copyWith(color: context.colors.textSecondary)),
        ],
      ),
    );
  }
}

/// Renders the official MARG logo, gracefully degrading to a brand wordmark if
/// the asset can't be decoded (keeps the RepaintBoundary capture safe).
class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: rootBundle.load(BrandAssets.logo).then((_) => true).catchError((_) => false),
      builder: (context, snap) {
        if (snap.data == true) {
          return Image.asset(BrandAssets.logo, height: 56, filterQuality: FilterQuality.medium);
        }
        return Text('MARG', style: context.brandText.headlineSmall.copyWith(color: context.colors.gold, letterSpacing: 2));
      },
    );
  }
}
