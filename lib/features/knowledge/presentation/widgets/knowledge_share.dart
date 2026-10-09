import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';

/// What to render on a branded MARG share card. `heroImageUrl` shows an artwork
/// band; `verse` renders a scripture card instead of a title/subtitle body.
class ShareContent {
  const ShareContent({
    required this.title,
    this.subtitle,
    this.heroImageUrl,
    this.verse,
    this.attribution,
    required this.shareText,
  });

  final String title;
  final String? subtitle;
  final String? heroImageUrl;
  final String? verse;
  final String? attribution;
  final String shareText;
}

/// Opens the branded share sheet for any piece of Knowledge Hub content.
Future<void> showKnowledgeShare(BuildContext context, ShareContent content) {
  return AppSheets.show<void>(
    context,
    padded: false,
    builder: (_) => _ShareSheet(content: content),
  );
}

class _ShareSheet extends StatefulWidget {
  const _ShareSheet({required this.content});
  final ShareContent content;

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  final _cardKey = GlobalKey();
  bool _busy = false;

  Future<void> _share() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await shareBoundaryImage(_cardKey, text: widget.content.shareText, fileName: 'marg-share.png');
    } catch (_) {
      if (mounted) AppSnackbar.error(context, l10n.kbShareFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppSheetLayout(
      title: l10n.kbShareContent,
      actions: [
        AppButton.primary(label: l10n.kbShareNow, icon: AppIcons.share, busy: _busy, onPressed: _share),
      ],
      child: RepaintBoundary(key: _cardKey, child: _ShareCard(content: widget.content)),
    );
  }
}

class _ShareCard extends StatelessWidget {
  const _ShareCard({required this.content});
  final ShareContent content;

  @override
  Widget build(BuildContext context) {
    final gold = context.colors.gold;
    final c = content;
    return Container(
      decoration: BoxDecoration(
        color: context.colors.splashCanvas,
        borderRadius: AppRadius.xlAll,
        border: Border.all(color: gold, width: 2),
        boxShadow: [BoxShadow(color: gold.withValues(alpha: 0.22), blurRadius: 20, spreadRadius: 1)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (c.heroImageUrl != null)
            AppNetworkImage(url: c.heroImageUrl!, height: 150, width: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: AppSpacing.allLg,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _Logo(),
                const Gap(AppSpacing.md),
                if (c.verse != null) ...[
                  Icon(AppIcons.quote, color: gold),
                  const Gap(AppSpacing.sm),
                  Text(c.verse!, textAlign: TextAlign.center, style: context.textTheme.titleMedium?.copyWith(height: 1.7)),
                ] else
                  Text(c.title, textAlign: TextAlign.center, style: context.brandText.headlineSmall, maxLines: 3, overflow: TextOverflow.ellipsis),
                if (c.subtitle != null) ...[
                  const Gap(AppSpacing.sm),
                  Text(
                    c.subtitle!,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (c.attribution != null) ...[
                  const Gap(AppSpacing.md),
                  Text('— ${c.attribution!}', style: context.textTheme.labelLarge?.semiBold.copyWith(color: context.scheme.primary)),
                ],
                const Gap(AppSpacing.md),
                Text(AppLocalizations.of(context).kbShareTagline, style: context.caption.copyWith(color: context.colors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The official MARG logo, degrading to the brand wordmark if the asset can't
/// be decoded — keeps the off-screen RepaintBoundary capture safe.
class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: rootBundle.load(BrandAssets.logo).then((_) => true).catchError((_) => false),
      builder: (context, snap) {
        if (snap.data == true) {
          return Image.asset(BrandAssets.logo, height: 48, filterQuality: FilterQuality.medium);
        }
        return Text('MARG', style: context.brandText.headlineSmall.copyWith(color: context.colors.gold, letterSpacing: 2));
      },
    );
  }
}
