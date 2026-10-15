import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/localization/app_localizations.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/services/app_update_service.dart';
import '../animations/app_entrance.dart';
import '../buttons/app_button.dart';
import '../dialogs/app_dialog.dart';
import '../images/brand_logo.dart';

/// Shows the update prompt this install calls for, over every screen
/// (mounted above the navigator in `MaterialApp.builder`, so sign-in too):
///  - a required update (a major behind, or below the minimum) covers the app
///    until it updates;
///  - a minor update asks, with "Later";
///  - a patch update is a small dismissible hint.
/// It checks on launch and whenever the app returns to the foreground, so a
/// declined required update reappears straight after Play's screen closes.
class AppUpdateGate extends ConsumerStatefulWidget {
  const AppUpdateGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppUpdateGate> createState() => _AppUpdateGateState();
}

class _AppUpdateGateState extends ConsumerState<AppUpdateGate> {
  late final AppLifecycleListener _lifecycle;
  AppUpdateCheck? _update;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _check);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    if (_busy) return;
    final update = await ref.read(appUpdateServiceProvider).check();
    if (mounted) setState(() => _update = update);
  }

  Future<void> _start() async {
    final update = _update;
    if (update == null || _busy) return;
    final service = ref.read(appUpdateServiceProvider);
    setState(() => _busy = true);
    await service.update(immediate: update.level != UpdateLevel.patch);
    // An optional update the pilgrim backed out of in Play waits like "Later";
    // a required one stays until the app is updated.
    if (update.level != UpdateLevel.major) await service.snooze(update);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (update.level != UpdateLevel.major) _update = null;
    });
  }

  Future<void> _later() async {
    final update = _update;
    if (update == null) return;
    await ref.read(appUpdateServiceProvider).snooze(update);
    if (mounted) setState(() => _update = null);
  }

  @override
  Widget build(BuildContext context) {
    final update = _update;
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (update != null)
          switch (update.level) {
            UpdateLevel.major => _RequiredUpdate(update: update, busy: _busy, onUpdate: _start),
            UpdateLevel.minor => _UpdateDialog(update: update, busy: _busy, onUpdate: _start, onLater: _later),
            UpdateLevel.patch => _UpdateHint(update: update, onUpdate: _start, onDismiss: _later),
            UpdateLevel.none => const SizedBox.shrink(),
          },
      ],
    );
  }
}

/// Full-screen, no way past it but the update.
class _RequiredUpdate extends StatelessWidget {
  const _RequiredUpdate({required this.update, required this.busy, required this.onUpdate});

  final AppUpdateCheck update;
  final bool busy;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: context.scheme.surface,
      child: SafeArea(
        child: FadeIn(
          child: Center(
            child: SingleChildScrollView(
              padding: AppSpacing.screenAll,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BrandLogo(size: 64),
                  const Gap(AppSpacing.xl),
                  Text(
                    l10n.upMajorTitle,
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineSmall?.bold.withColor(context.scheme.secondary),
                  ),
                  const Gap(AppSpacing.sm),
                  Text(
                    l10n.upMajorBody,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary, height: 1.5),
                  ),
                  if (update.notes != null) ...[
                    const Gap(AppSpacing.lg),
                    _WhatsNew(notes: update.notes!),
                  ],
                  const Gap(AppSpacing.xl),
                  AppButton.primary(label: l10n.upUpdateNow, icon: AppIcons.update, busy: busy, onPressed: onUpdate),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A minor update: the app dims behind a dialog with Update / Later.
class _UpdateDialog extends StatelessWidget {
  const _UpdateDialog({required this.update, required this.busy, required this.onUpdate, required this.onLater});

  final AppUpdateCheck update;
  final bool busy;
  final VoidCallback onUpdate;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ColoredBox(
      color: context.scheme.scrim.withValues(alpha: 0.5),
      child: Center(
        child: ScaleIn(
          child: AppDialog(
            icon: AppIcons.update,
            title: l10n.upMinorTitle,
            message: l10n.upMinorBody(update.version),
            content: update.notes == null ? null : _WhatsNew(notes: update.notes!),
            actions: [
              AppButton.primary(label: l10n.upUpdate, icon: AppIcons.update, busy: busy, onPressed: onUpdate),
              AppButton.ghost(label: l10n.upLater, onPressed: busy ? null : onLater),
            ],
          ),
        ),
      ),
    );
  }
}

/// A patch update: a slim card above the tab bar, once per version.
class _UpdateHint extends StatelessWidget {
  const _UpdateHint({required this.update, required this.onUpdate, required this.onDismiss});

  final AppUpdateCheck update;
  final VoidCallback onUpdate;
  final VoidCallback onDismiss;

  /// Clears the bottom navigation bar.
  static const double _navClearance = 88;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onNavy = context.scheme.onSecondary;
    return Positioned(
      left: AppSpacing.md,
      right: AppSpacing.md,
      bottom: context.viewPadding.bottom + _navClearance,
      child: FadeIn(
        child: Material(
          color: context.scheme.secondary,
          borderRadius: AppRadius.lgAll,
          elevation: 0,
          child: DecoratedBox(
            decoration: BoxDecoration(borderRadius: AppRadius.lgAll, boxShadow: AppShadows.md),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.xs, AppSpacing.xs, AppSpacing.xs),
              child: Row(
                children: [
                  Icon(AppIcons.update, color: context.colors.gold),
                  const Gap.h(AppSpacing.sm),
                  Expanded(
                    child: Text(l10n.upPatchBody(update.version), style: context.textTheme.bodySmall?.copyWith(color: onNavy)),
                  ),
                  TextButton(
                    onPressed: onUpdate,
                    style: TextButton.styleFrom(foregroundColor: context.colors.gold, minimumSize: const Size(48, 48)),
                    child: Text(l10n.upUpdate),
                  ),
                  Semantics(
                    button: true,
                    label: l10n.upDismiss,
                    child: InkResponse(
                      onTap: onDismiss,
                      radius: 24,
                      child: SizedBox.square(
                        dimension: 48,
                        child: Icon(AppIcons.close, size: 20, color: onNavy.withValues(alpha: 0.8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WhatsNew extends StatelessWidget {
  const _WhatsNew({required this.notes});

  final String notes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: AppSpacing.allMd,
      decoration: BoxDecoration(color: context.scheme.primary.withValues(alpha: 0.08), borderRadius: AppRadius.lgAll),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.upWhatsNew, style: context.textTheme.labelLarge?.semiBold),
          const Gap(AppSpacing.xxs),
          Text(notes, style: context.textTheme.bodySmall?.copyWith(height: 1.5)),
        ],
      ),
    );
  }
}
