import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../data/repository/profile_repository.dart';
import '../../domain/entities/user_device.dart';
import '../controllers/profile_controllers.dart';
import '../widgets/profile_widgets.dart';

/// This device's FCM token (fail-soft) — used to flag the current device.
final _currentFcmTokenProvider = FutureProvider.autoDispose<String?>((ref) async {
  try {
    return await FirebaseMessaging.instance.getToken();
  } catch (_) {
    return null;
  }
});

/// Screen 5 — My Devices. Lists registered devices (`GET /my/devices`), flags
/// the current one, and lets the user sign other devices out (confirmed).
class MyDevicesPage extends ConsumerWidget {
  const MyDevicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(devicesProvider);
    final currentToken = ref.watch(_currentFcmTokenProvider).valueOrNull;

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.pfMyDevices)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(title: l10n.pfErrorTitle, message: l10n.pfErrorBody, onRetry: () => ref.invalidate(devicesProvider)),
        data: (devices) {
          if (devices.isEmpty) {
            return EmptyView(art: StateArt.empty, icon: AppIcons.smartphone, title: l10n.pfNoDevices, message: l10n.pfNoDevicesBody);
          }
          final current = devices.where((d) => currentToken != null && d.fcmToken == currentToken).toList();
          final others = devices.where((d) => currentToken == null || d.fcmToken != currentToken).toList();
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(devicesProvider),
            child: ListView(
              padding: AppSpacing.screenAll,
              children: [
                IntroBanner(icon: AppIcons.smartphone, title: l10n.pfDevicesHeroTitle, message: l10n.pfDevicesHeroBody).fadeIn(),
                if (current.isNotEmpty) ...[
                  const Gap(AppSpacing.xl),
                  SettingsGroup(title: l10n.pfCurrentDevice, children: [_DeviceRow(device: current.first, isCurrent: true)]),
                ],
                if (others.isNotEmpty) ...[
                  const Gap(AppSpacing.xl),
                  SettingsGroup(
                    title: l10n.pfOtherDevices,
                    children: [for (final d in others) _DeviceRow(device: d, isCurrent: false)],
                  ),
                  const Gap(AppSpacing.xl),
                  _LogoutOthersButton(devices: others),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Confirms, then removes [devices] from the account.
Future<bool> _confirmAndRemove(BuildContext context, WidgetRef ref, List<UserDevice> devices) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await AppDialogs.confirm(
    context,
    title: l10n.pfLogoutOthersTitle,
    message: l10n.pfLogoutOthersBody,
    confirmLabel: l10n.pfLogout,
    cancelLabel: l10n.pfCancel,
  );
  if (confirmed != true) return false;
  for (final d in devices) {
    await ref.read(profileRepositoryProvider).removeDevice(d.id);
  }
  ref.invalidate(devicesProvider);
  return true;
}

class _DeviceRow extends ConsumerWidget {
  const _DeviceRow({required this.device, required this.isCurrent});
  final UserDevice device;
  final bool isCurrent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final color = isCurrent ? context.colors.success : context.palette.accentBlue;
    return AppListTile(
      leading: IllustratedIcon(fallbackIcon: AppIcons.smartphone, color: color, size: 36),
      title: device.deviceModel ?? _platformName(device.platform),
      subtitle: device.lastSeenAt == null ? _platformName(device.platform) : '${l10n.pfLastActive}: ${formatDate(device.lastSeenAt)}',
      trailing: isCurrent
          ? AppBadge(label: l10n.pfThisDevice, tone: AppBadgeTone.success)
          : TextButton(
              onPressed: () => _confirmAndRemove(context, ref, [device]),
              style: TextButton.styleFrom(foregroundColor: context.scheme.error),
              child: Text(l10n.pfLogout),
            ),
    );
  }
}

/// Backend `platform` (IOS / ANDROID) as a product name.
String _platformName(String platform) => platform.toUpperCase() == 'IOS' ? 'iPhone' : 'Android';

class _LogoutOthersButton extends ConsumerStatefulWidget {
  const _LogoutOthersButton({required this.devices});
  final List<UserDevice> devices;
  @override
  ConsumerState<_LogoutOthersButton> createState() => _LogoutOthersButtonState();
}

class _LogoutOthersButtonState extends ConsumerState<_LogoutOthersButton> {
  bool _busy = false;

  Future<void> _run() async {
    setState(() => _busy = true);
    try {
      await _confirmAndRemove(context, ref, widget.devices);
    } catch (_) {
      if (mounted) AppSnackbar.error(context, AppLocalizations.of(context).pfErrorBody);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        AppButton.danger(label: l10n.pfLogoutOthers, icon: AppIcons.logout, busy: _busy, onPressed: _busy ? null : _run),
        const Gap(AppSpacing.sm),
        Text(
          l10n.pfLogoutOthersHint,
          textAlign: TextAlign.center,
          style: context.caption.copyWith(color: context.colors.textSecondary),
        ),
      ],
    );
  }
}
