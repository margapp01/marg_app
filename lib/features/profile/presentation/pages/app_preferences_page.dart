import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/localization/locale_provider.dart';
import '../../../../core/geo/detailed_boundaries.dart';
import '../../../../shared/design_system.dart';
import '../../data/repository/profile_repository.dart';
import '../../domain/entities/app_preferences.dart';
import '../controllers/profile_controllers.dart';

/// Screen 8 — App Preferences. Language syncs to the backend + app locale; the
/// rest are device-local. Theme is Light-only for this release (no switch);
/// the map row downloads (or removes) the detailed Bharat outline.
class AppPreferencesPage extends ConsumerWidget {
  const AppPreferencesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final prefsAsync = ref.watch(appPreferencesProvider);
    final language = ref.watch(profileProvider).valueOrNull?.preferredLanguage ?? 'EN';

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.pfAppPreferences)),
      body: prefsAsync.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(title: l10n.pfErrorTitle, message: l10n.pfErrorBody, onRetry: () => ref.invalidate(appPreferencesProvider)),
        data: (prefs) {
          final p = context.palette;
          return ListView(
            padding: AppSpacing.screenAll,
            children: [
              IntroBanner(icon: AppIcons.tune, title: l10n.pfPrefsHeroTitle, message: l10n.pfPrefsHeroBody).fadeIn(),
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
              // Theme is fixed for this release (read-only value); the map row
              // manages the optional detailed outline download.
              SettingsGroup(
                title: l10n.pfGroupAppearance,
                children: [
                  SettingsTile.value(icon: AppIcons.palette, iconColor: p.accentViolet, title: l10n.pfTheme, value: l10n.pfThemeLight),
                  const _DetailedMapTile(),
                ],
              ).fadeIn(delay: 80.ms),
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
                    onToggle: (v) => ref.read(appPreferencesProvider.notifier).setReduceAnimations(v),
                  ),
                  SettingsTile.toggle(
                    icon: AppIcons.dataSaver,
                    iconColor: p.accentTeal,
                    title: l10n.pfDataSaver,
                    subtitle: l10n.pfDataSaverHint,
                    switchValue: prefs.dataSaver,
                    onToggle: (v) => ref.read(appPreferencesProvider.notifier).setDataSaver(v),
                  ),
                  SettingsTile.toggle(
                    icon: AppIcons.imageQuality,
                    iconColor: p.accentAmber,
                    title: l10n.pfHighQualityImages,
                    subtitle: l10n.pfHighQualityImagesHint,
                    switchValue: prefs.highQualityImages,
                    onToggle: (v) => ref.read(appPreferencesProvider.notifier).setHighQualityImages(v),
                  ),
                ],
              ).fadeIn(delay: 120.ms),
              const Gap(AppSpacing.lg),
              _Footnote(text: l10n.pfPrefsFootnote),
            ],
          );
        },
      ),
    );
  }

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

/// Detailed map outline: download with live progress, or remove (back to the
/// bundled outline) after a confirmation.
class _DetailedMapTile extends ConsumerWidget {
  const _DetailedMapTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(detailedMapProvider).valueOrNull ?? const DetailedMapAbsent();
    final value = switch (status) {
      DetailedMapAbsent() => l10n.pfDetailedMapDownload,
      DetailedMapDownloading(:final progress) => l10n.pfDetailedMapProgress((progress * 100).round()),
      DetailedMapReady() => l10n.pfDetailedMapReady,
    };
    return SettingsTile.value(
      icon: AppIcons.map,
      iconColor: context.palette.accentBlue,
      title: l10n.pfDetailedMap,
      subtitle: l10n.pfDetailedMapHint,
      value: value,
      onTap: switch (status) {
        DetailedMapAbsent() => () => _download(context, ref),
        DetailedMapDownloading() => null,
        DetailedMapReady() => () => _remove(context, ref),
      },
    );
  }

  Future<void> _download(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await ref.read(detailedMapProvider.notifier).download();
    if (!context.mounted) return;
    ok ? AppSnackbar.success(context, l10n.pfDetailedMapSaved) : AppSnackbar.error(context, l10n.pfDetailedMapFailed);
  }

  Future<void> _remove(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await AppSheets.confirm(
      context,
      title: l10n.pfDetailedMapRemoveTitle,
      message: l10n.pfDetailedMapRemoveBody,
      confirmLabel: l10n.pfDetailedMapRemove,
      cancelLabel: l10n.pfCancel,
      destructive: true,
    );
    if (confirmed) await ref.read(detailedMapProvider.notifier).remove();
  }
}

/// A quiet info line under the last group.
class _Footnote extends StatelessWidget {
  const _Footnote({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final muted = context.colors.textSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(AppIcons.info, size: 16, color: muted),
          const Gap.h(AppSpacing.xs),
          Expanded(child: Text(text, style: context.caption.copyWith(color: muted))),
        ],
      ),
    );
  }
}
