import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/localization/locale_provider.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../core/geo/detailed_boundaries.dart';
import '../../../../features/auth/data/datasource/sign_out_guard.dart';
import '../../../../features/auth/presentation/controllers/auth_controller.dart';
import '../../../../shared/design_system.dart';
import '../../data/repository/profile_repository.dart';
import '../../domain/entities/app_preferences.dart';
import '../../domain/entities/cms_content.dart';
import '../controllers/profile_controllers.dart';

/// Settings — every account and app setting on one screen, kept off the
/// Profile tab: account, language & region, notifications & location,
/// appearance, performance & data, help & legal, delete account and logout.
class SettingsHubPage extends ConsumerWidget {
  const SettingsHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final prefs = ref.watch(appPreferencesProvider).valueOrNull ?? const AppPreferences();
    final email = ref.watch(profileProvider.select((a) => a.valueOrNull?.email));
    final language = ref.watch(profileProvider.select((a) => a.valueOrNull?.preferredLanguage)) ?? 'EN';
    final version = ref.watch(appVersionProvider).valueOrNull ?? '';
    final notifier = ref.read(appPreferencesProvider.notifier);

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.titleSettings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.huge),
        children: [
          SettingsGroup(
            title: l10n.pfGroupAccount,
            children: [
              // Google-only sign-in: the account is shown, not editable.
              AppListTile(leadingIcon: AppIcons.mail, iconColor: p.accentBlue, title: l10n.pfGoogleAccount, subtitle: email ?? '—'),
              SettingsTile.navigation(
                icon: AppIcons.temple,
                iconColor: p.accentSaffron,
                title: l10n.pfSpiritualPreferences,
                onTap: () => context.pushNamed(RouteNames.profilePreferences),
              ),
              SettingsTile.navigation(
                icon: AppIcons.trending,
                iconColor: p.accentViolet,
                title: l10n.pfMyStatistics,
                onTap: () => context.pushNamed(RouteNames.profileStatistics),
              ),
              SettingsTile.navigation(
                icon: AppIcons.smartphone,
                iconColor: p.accentTeal,
                title: l10n.pfMyDevices,
                subtitle: l10n.pfManageDevices,
                onTap: () => context.pushNamed(RouteNames.profileDevices),
              ),
            ],
          ).fadeIn(),
          const Gap(AppSpacing.xl),
          SettingsGroup(
            title: l10n.pfGroupRegion,
            children: [
              SettingsTile.value(
                icon: AppIcons.language,
                iconColor: p.accentSaffron,
                title: l10n.pfLanguage,
                value: language == 'HI' ? l10n.pfLanguageHindi : l10n.pfLanguageEnglish,
                onTap: () => _pickLanguage(context, ref, language),
              ),
              SettingsTile.value(
                icon: AppIcons.units,
                iconColor: p.accentGreen,
                title: l10n.pfUnits,
                value: prefs.units == DistanceUnit.miles ? l10n.pfMiles : l10n.pfKilometers,
                onTap: () => _pickUnits(context, ref, prefs.units),
              ),
            ],
          ).fadeIn(delay: 40.ms),
          const Gap(AppSpacing.xl),
          SettingsGroup(
            title: l10n.pfGroupPermissions,
            children: [
              SettingsTile.navigation(
                icon: AppIcons.notifications,
                iconColor: p.accentAmber,
                title: l10n.pfNotificationSettings,
                subtitle: l10n.pfNotificationSettingsHint,
                onTap: () => context.pushNamed(RouteNames.notificationSettings),
              ),
              SettingsTile.navigation(
                icon: AppIcons.location,
                iconColor: p.accentGreen,
                title: l10n.pfLocationPermission,
                subtitle: l10n.pfLocationPermissionHint,
                onTap: Geolocator.openAppSettings,
              ),
            ],
          ).fadeIn(delay: 80.ms),
          const Gap(AppSpacing.xl),
          // Theme is fixed for this release (read-only value); the map row
          // manages the optional detailed outline download.
          SettingsGroup(
            title: l10n.pfGroupAppearance,
            children: [
              SettingsTile.value(icon: AppIcons.palette, iconColor: p.accentViolet, title: l10n.pfTheme, value: l10n.pfThemeLight),
              const _DetailedMapTile(),
            ],
          ).fadeIn(delay: 120.ms),
          const Gap(AppSpacing.xl),
          SettingsGroup(
            title: l10n.pfGroupDisplay,
            children: [
              SettingsTile.toggle(
                icon: AppIcons.motion,
                iconColor: p.accentRose,
                title: l10n.pfReduceAnimations,
                subtitle: l10n.pfReduceAnimationsHint,
                switchValue: prefs.reduceAnimations,
                onToggle: notifier.setReduceAnimations,
              ),
              SettingsTile.toggle(
                icon: AppIcons.dataSaver,
                iconColor: p.accentTeal,
                title: l10n.pfDataSaver,
                subtitle: l10n.pfDataSaverHint,
                switchValue: prefs.dataSaver,
                onToggle: notifier.setDataSaver,
              ),
              SettingsTile.toggle(
                icon: AppIcons.imageQuality,
                iconColor: p.accentAmber,
                title: l10n.pfHighQualityImages,
                subtitle: l10n.pfHighQualityImagesHint,
                switchValue: prefs.highQualityImages,
                onToggle: notifier.setHighQualityImages,
              ),
            ],
          ).fadeIn(delay: 160.ms),
          const Gap(AppSpacing.xl),
          SettingsGroup(
            title: l10n.pfGroupSupport,
            children: [
              SettingsTile.navigation(
                icon: AppIcons.help,
                iconColor: p.accentRose,
                title: l10n.pfHelpSupport,
                subtitle: l10n.pfHelpSupportHint,
                onTap: () => context.pushNamed(RouteNames.profileHelp),
              ),
              SettingsTile.navigation(
                icon: AppIcons.shield,
                iconColor: p.accentViolet,
                title: l10n.pfPrivacyPolicy,
                onTap: () => _openPage(context, PageKind.privacy),
              ),
              SettingsTile.navigation(
                icon: AppIcons.description,
                iconColor: p.accentBlue,
                title: l10n.pfTerms,
                onTap: () => _openPage(context, PageKind.terms),
              ),
              SettingsTile.navigation(
                icon: AppIcons.info,
                iconColor: p.accentAmber,
                title: l10n.pfAbout,
                subtitle: version.isEmpty ? null : '${l10n.pfVersion} $version',
                onTap: () => _openPage(context, PageKind.about),
              ),
            ],
          ).fadeIn(delay: 200.ms),
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
          ),
          const Gap(AppSpacing.xl),
          const _LogoutButton(),
          const Gap(AppSpacing.md),
          Text(
            l10n.pfPrefsFootnote,
            textAlign: TextAlign.center,
            style: context.caption.copyWith(color: context.colors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _openPage(BuildContext context, PageKind kind) =>
      context.pushNamed(RouteNames.profileStaticPage, pathParameters: {RoutePaths.staticPageKindParam: kind.name});

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref, String current) async {
    final l10n = AppLocalizations.of(context);
    final choice = await AppSheets.select<String>(
      context,
      title: l10n.pfLanguage,
      selected: current,
      options: [
        SheetOption(value: 'EN', label: l10n.pfLanguageEnglish, icon: AppIcons.language),
        SheetOption(value: 'HI', label: l10n.pfLanguageHindi, icon: AppIcons.language),
      ],
    );
    if (choice == null || choice == current) return;
    try {
      await ref.read(profileRepositoryProvider).updateProfile(preferredLanguage: choice);
      ref.invalidate(profileProvider);
      ref.read(localeControllerProvider.notifier).locale = Locale(choice.toLowerCase());
      if (context.mounted) AppSnackbar.success(context, l10n.pfSaved);
    } catch (_) {
      if (context.mounted) AppSnackbar.error(context, l10n.pfSaveFailed);
    }
  }

  Future<void> _pickUnits(BuildContext context, WidgetRef ref, DistanceUnit current) async {
    final l10n = AppLocalizations.of(context);
    final choice = await AppSheets.select<DistanceUnit>(
      context,
      title: l10n.pfUnits,
      selected: current,
      options: [
        SheetOption(value: DistanceUnit.kilometers, label: l10n.pfKilometers, icon: AppIcons.units),
        SheetOption(value: DistanceUnit.miles, label: l10n.pfMiles, icon: AppIcons.units),
      ],
    );
    if (choice != null && choice != current) {
      await ref.read(appPreferencesProvider.notifier).setUnits(choice);
    }
  }
}

/// Map outline: the bundled one, or a downloaded detailed / full-resolution
/// one (live progress while downloading). Switching tiers downloads the new
/// one first; going back to built-in asks for confirmation.
class _DetailedMapTile extends ConsumerWidget {
  const _DetailedMapTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(detailedMapProvider).valueOrNull ?? const DetailedMapAbsent();
    final value = switch (status) {
      DetailedMapAbsent() => l10n.pfMapOutlineBuiltIn,
      DetailedMapDownloading(:final progress) => l10n.pfDetailedMapProgress((progress * 100).round()),
      DetailedMapReady(detail: MapDetail.detailed) => l10n.pfMapOutlineDetailed,
      DetailedMapReady(detail: MapDetail.full) => l10n.pfMapOutlineFull,
    };
    return SettingsTile.value(
      icon: AppIcons.map,
      iconColor: context.palette.accentBlue,
      title: l10n.pfDetailedMap,
      subtitle: l10n.pfDetailedMapHint,
      value: value,
      onTap: status is DetailedMapDownloading ? null : () => _choose(context, ref, status),
    );
  }

  Future<void> _choose(BuildContext context, WidgetRef ref, DetailedMapStatus status) async {
    final l10n = AppLocalizations.of(context);
    final current = status is DetailedMapReady ? status.detail : null;
    final choice = await AppSheets.select<_Outline>(
      context,
      title: l10n.pfDetailedMap,
      selected: _Outline.of(current),
      options: [
        SheetOption(value: _Outline.builtIn, label: l10n.pfMapOutlineBuiltInOption, icon: AppIcons.map),
        SheetOption(value: _Outline.detailed, label: l10n.pfMapOutlineDetailedOption, icon: AppIcons.download),
        SheetOption(value: _Outline.full, label: l10n.pfMapOutlineFullOption, icon: AppIcons.download),
      ],
    );
    if (choice == null || choice == _Outline.of(current) || !context.mounted) return;
    final detail = choice.detail;
    if (detail == null) {
      final confirmed = await AppSheets.confirm(
        context,
        title: l10n.pfDetailedMapRemoveTitle,
        message: l10n.pfDetailedMapRemoveBody,
        confirmLabel: l10n.pfDetailedMapRemove,
        cancelLabel: l10n.pfCancel,
        destructive: true,
      );
      if (confirmed) await ref.read(detailedMapProvider.notifier).remove();
      return;
    }
    final ok = await ref.read(detailedMapProvider.notifier).download(detail);
    if (!context.mounted) return;
    ok ? AppSnackbar.success(context, l10n.pfDetailedMapSaved) : AppSnackbar.error(context, l10n.pfDetailedMapFailed);
  }
}

/// The picker's choices: the bundled outline or one of the [MapDetail]s.
enum _Outline {
  builtIn(null),
  detailed(MapDetail.detailed),
  full(MapDetail.full);

  const _Outline(this.detail);
  final MapDetail? detail;

  static _Outline of(MapDetail? detail) => values.firstWhere((o) => o.detail == detail);
}

/// Logout — refused inside a temple's check-in area (anti-fraud), confirmed
/// otherwise.
class _LogoutButton extends ConsumerWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppButton.outlined(
      label: l10n.pfLogout,
      icon: AppIcons.logout,
      onPressed: () async {
        final navigator = Navigator.of(context, rootNavigator: true);
        unawaited(AppDialogs.loading(context, message: l10n.pfLogoutChecking));
        final temple = await ref.read(signOutGuardProvider).templeHere();
        navigator.pop();
        if (!context.mounted) return;
        if (temple != null) {
          await AppDialogs.info(context, title: l10n.pfLogoutBlockedTitle, message: l10n.pfLogoutBlockedBody(temple));
          return;
        }
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
    );
  }
}
