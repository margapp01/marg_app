import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../features/auth/presentation/controllers/auth_controller.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/cms_content.dart';
import '../controllers/profile_controllers.dart';

/// Screen 4 — Privacy & Security. Google-only auth, so there is no password
/// management and no self-session management (device management covers it).
class PrivacySecurityPage extends ConsumerWidget {
  const PrivacySecurityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final email = ref.watch(profileProvider).valueOrNull?.email;
    final p = context.palette;

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.pfPrivacySecurity)),
      body: ListView(
        padding: AppSpacing.screenAll,
        children: [
          SettingsGroup(
            title: l10n.pfGroupAccount,
            children: [
              // Google-only sign-in: the account is shown, not editable.
              AppListTile(leadingIcon: AppIcons.mail, iconColor: p.accentBlue, title: l10n.pfGoogleAccount, subtitle: email ?? '—'),
              SettingsTile.navigation(icon: AppIcons.smartphone, iconColor: p.accentTeal, title: l10n.pfMyDevices, subtitle: l10n.pfManageDevices, onTap: () => context.pushNamed(RouteNames.profileDevices)),
              SettingsTile.navigation(icon: AppIcons.notifications, iconColor: p.accentAmber, title: l10n.pfNotificationSettings, subtitle: l10n.pfNotificationSettingsHint, onTap: () => context.pushNamed(RouteNames.notificationSettings)),
              SettingsTile.navigation(icon: AppIcons.location, iconColor: p.accentGreen, title: l10n.pfLocationPermission, subtitle: l10n.pfLocationPermissionHint, onTap: Geolocator.openAppSettings),
            ],
          ).fadeIn(),
          const Gap(AppSpacing.xl),
          SettingsGroup(
            title: l10n.pfGroupLegal,
            children: [
              SettingsTile.navigation(icon: AppIcons.shield, iconColor: p.accentViolet, title: l10n.pfPrivacyPolicy, onTap: () => _openPage(context, PageKind.privacy)),
              SettingsTile.navigation(icon: AppIcons.description, iconColor: p.accentSaffron, title: l10n.pfTerms, onTap: () => _openPage(context, PageKind.terms)),
            ],
          ).fadeIn(delay: 60.ms),
          const Gap(AppSpacing.xl),
          SettingsGroup(
            children: [
              SettingsTile.navigation(
                icon: AppIcons.delete,
                destructive: true,
                title: l10n.pfDeleteAccount,
                subtitle: l10n.pfDeleteAccountHint,
                onTap: () => context.pushNamed(RouteNames.profileDelete),
              ),
            ],
          ).fadeIn(delay: 120.ms),
          const Gap(AppSpacing.xl),
          AppButton.outlined(
            label: l10n.pfLogout,
            icon: AppIcons.logout,
            onPressed: () async {
              final confirmed = await AppDialogs.confirm(
                context,
                title: l10n.pfLogout,
                message: l10n.pfLogoutConfirm,
                confirmLabel: l10n.pfLogout,
              );
              if (confirmed != true) return;
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) context.goNamed(RouteNames.auth);
            },
          ),
        ],
      ),
    );
  }

  void _openPage(BuildContext context, PageKind kind) =>
      context.pushNamed(RouteNames.profileStaticPage, pathParameters: {RoutePaths.staticPageKindParam: kind.name});
}
