import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/app_notification.dart';
import '../controllers/notification_controllers.dart';
import '../widgets/notification_widgets.dart';

/// Screen 10 — Share Activity: renders a premium share card for a notification
/// (visit verified, achievement, route completed, card, milestone) and shares
/// it as an image via share_plus.
class ShareActivityPage extends ConsumerStatefulWidget {
  const ShareActivityPage({required this.id, super.key});
  final String id;

  @override
  ConsumerState<ShareActivityPage> createState() => _ShareActivityPageState();
}

class _ShareActivityPageState extends ConsumerState<ShareActivityPage> {
  final _cardKey = GlobalKey();
  bool _busy = false;

  Future<void> _share(AppNotification n) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final boundary = _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return;
      final file = XFile.fromData(bytes.buffer.asUint8List(), name: 'marg-activity.png', mimeType: 'image/png');
      await SharePlus.instance.share(ShareParams(files: [file], text: '${n.title} — via MARG'));
    } catch (_) {
      if (mounted) AppSnackbar.error(context, l10n.ntShareFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(notificationDetailProvider(widget.id));
    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.ntShareActivity)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(title: l10n.ntErrorTitle, message: l10n.ntErrorBody, onRetry: () => ref.invalidate(notificationDetailProvider(widget.id))),
        data: (n) => ListView(
          padding: AppSpacing.screenAll,
          children: [
            RepaintBoundary(key: _cardKey, child: _ShareCard(notification: n)),
            const Gap(AppSpacing.xl),
            AppButton.primary(label: l10n.ntShareAsImage, icon: AppIcons.share, busy: _busy, onPressed: () => _share(n)),
          ],
        ),
      ),
    );
  }
}

class _ShareCard extends StatelessWidget {
  const _ShareCard({required this.notification});
  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (icon, color) = notificationVisual(context, notification.kind);
    final gold = context.colors.gold;
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
          Text('MARG', style: context.brandText.headlineSmall.copyWith(color: gold, letterSpacing: 2)),
          const Gap(AppSpacing.lg),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.16)),
                clipBehavior: Clip.antiAlias,
                child: notification.imageUrl != null
                    ? AppNetworkImage(url: notification.imageUrl!, width: 110, height: 110)
                    : Icon(icon, size: 52, color: color),
              ),
              if (notification.kind == NotificationKind.visit)
                Icon(AppIcons.success, color: context.colors.success, size: 30),
            ],
          ),
          const Gap(AppSpacing.md),
          Text(notification.title, style: context.textTheme.titleLarge?.bold, textAlign: TextAlign.center),
          const Gap(AppSpacing.xs),
          Text(notification.message, style: context.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary, height: 1.4), textAlign: TextAlign.center),
          const Gap(AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            decoration: BoxDecoration(color: gold.withValues(alpha: 0.14), borderRadius: AppRadius.fullAll),
            child: Text(l10n.ntSpiritualJourney, style: context.caption.copyWith(color: gold, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
