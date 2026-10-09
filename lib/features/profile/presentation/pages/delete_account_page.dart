import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../features/auth/presentation/controllers/auth_controller.dart';
import '../../../../shared/design_system.dart';
import '../../data/repository/profile_repository.dart';

/// Screen 10 — Delete Account. A clear, irreversible confirmation flow backed by
/// the real `DELETE /my/account` (soft-delete + session/device revocation).
class DeleteAccountPage extends ConsumerStatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  ConsumerState<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends ConsumerState<DeleteAccountPage> {
  bool _deleting = false;

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await AppDialogs.confirm(
      context,
      title: l10n.pfDeleteConfirmTitle,
      message: l10n.pfDeleteConfirmBody,
      confirmLabel: l10n.pfDeleteConfirmCta,
      cancelLabel: l10n.pfCancel,
    );
    if (confirmed != true) return;
    setState(() => _deleting = true);
    try {
      await ref.read(profileRepositoryProvider).deleteAccount();
      await ref.read(authControllerProvider.notifier).signOut();
      if (mounted) context.goNamed(RouteNames.auth);
    } catch (_) {
      if (mounted) {
        AppSnackbar.error(context, l10n.pfDeleteFailed);
        setState(() => _deleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final losses = <String>[l10n.pfLossProgress, l10n.pfLossData, l10n.pfLossSignedOut];
    final error = context.scheme.error;
    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.pfDeleteAccount)),
      body: ListView(
        padding: AppSpacing.screenAll,
        children: [
          const _WarningHero(),
          const Gap(AppSpacing.lg),
          AppCard(
            padding: AppSpacing.allLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.pfDeleteHeading, style: context.displayText.titleLarge.withColor(context.scheme.secondary)),
                const Gap(AppSpacing.sm),
                Text(
                  l10n.pfDeleteExplain,
                  style: context.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary, height: 1.5),
                ),
                const Gap(AppSpacing.md),
                const AppDivider(),
                const Gap(AppSpacing.sm),
                for (final item in losses)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: Row(
                      children: [
                        IllustratedIcon(fallbackIcon: AppIcons.close, color: error, size: 28),
                        const Gap.h(AppSpacing.md),
                        Expanded(child: Text(item, style: context.textTheme.bodyMedium)),
                      ],
                    ),
                  ),
              ],
            ),
          ).fadeIn(delay: 60.ms),
          const Gap(AppSpacing.xl),
          AppButton.danger(label: l10n.pfDeleteMyAccount, icon: AppIcons.delete, busy: _deleting, onPressed: _deleting ? null : _delete),
          const Gap(AppSpacing.sm),
          AppButton.outlined(label: l10n.pfCancel, onPressed: _deleting ? null : () => context.pop()),
        ],
      ),
    );
  }
}

/// A red warning medallion standing over the faint temple skyline.
class _WarningHero extends StatelessWidget {
  const _WarningHero();

  static const double _medallion = 104;
  static const double _skylineHeight = 96;

  @override
  Widget build(BuildContext context) {
    final error = context.scheme.error;
    return SizedBox(
      height: _medallion + AppSpacing.lg,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: _skylineHeight,
            child: Image.asset(
              BrandAssets.skylineLineArt,
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
              opacity: const AlwaysStoppedAnimation(0.22),
              excludeFromSemantics: true,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
          Container(
            width: _medallion,
            height: _medallion,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color.alphaBlend(error.withValues(alpha: 0.1), context.colors.card),
              border: Border.all(color: error.withValues(alpha: 0.35), width: 2),
              boxShadow: [BoxShadow(color: error.withValues(alpha: 0.18), blurRadius: 24, spreadRadius: 2)],
            ),
            child: Icon(AppIcons.warning, size: _medallion * 0.45, color: error, fill: 1),
          ).scaleIn(),
        ],
      ),
    );
  }
}
