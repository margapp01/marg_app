import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/localization/app_localizations.dart';
import '../../app/theme/theme.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/location/location_access.dart';
import '../buttons/app_button.dart';
import '../empty/state_art.dart';
import '../images/illustrated_icon.dart';
import 'app_sheets.dart';

/// The location ask, ride-hailing style: the location scene, what access
/// unlocks (temples near you, daily darshan reminders, verified check-ins)
/// and one primary action that fits the state — Allow, Turn on location, or
/// Open settings — with "Not now" beside it. Closes itself the moment access
/// is granted (including on return from the system settings).
class LocationPermissionSheet extends ConsumerWidget {
  const LocationPermissionSheet({super.key});

  /// Shows the sheet; resolves true when access ended up granted.
  static Future<bool> show(BuildContext context) async {
    final granted = await AppSheets.show<bool>(
      context,
      padded: false,
      builder: (_) => const LocationPermissionSheet(),
    );
    return granted ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    ref.listen(locationAccessProvider, (_, next) {
      if (next.valueOrNull == LocationAccess.granted) Navigator.of(context).pop(true);
    });
    final access = ref.watch(locationAccessProvider).valueOrNull ?? LocationAccess.denied;
    final (label, icon) = switch (access) {
      LocationAccess.serviceOff => (l10n.locTurnOn, AppIcons.location),
      LocationAccess.deniedForever => (l10n.locOpenSettings, AppIcons.settings),
      _ => (l10n.locAllow, AppIcons.myLocation),
    };
    final p = context.palette;
    final benefits = [
      (AppIcons.temple, p.accentSaffron, l10n.locBenefitNearby),
      (AppIcons.notifications, p.accentViolet, l10n.locBenefitReminders),
      (AppIcons.verified, p.accentGreen, l10n.locBenefitCheckIn),
    ];
    return AppSheetLayout(
      actions: [
        AppButton.primary(
          label: label,
          icon: icon,
          onPressed: () => ref.read(locationAccessProvider.notifier).resolve(),
        ),
        AppButton.ghost(label: l10n.locNotNow, expand: true, onPressed: () => Navigator.of(context).pop(false)),
      ],
      child: Column(
        children: [
          const StateArtImage(StateArt.location),
          const Gap(AppSpacing.md),
          Semantics(
            header: true,
            child: Text(
              access == LocationAccess.serviceOff ? l10n.locServiceOffTitle : l10n.locTitle,
              textAlign: TextAlign.center,
              style: context.displayText.titleLarge.withColor(context.scheme.secondary),
            ),
          ),
          const Gap(AppSpacing.xs),
          Text(
            switch (access) {
              LocationAccess.serviceOff => l10n.locServiceOffBody,
              LocationAccess.deniedForever => l10n.locBlockedBody,
              _ => l10n.locBody,
            },
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.withColor(context.colors.textSecondary),
          ),
          const Gap(AppSpacing.lg),
          for (final (icon, color, text) in benefits)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  IllustratedIcon(fallbackIcon: icon, color: color, size: 36),
                  const Gap.h(AppSpacing.md),
                  Expanded(child: Text(text, style: context.textTheme.bodyMedium?.medium)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
