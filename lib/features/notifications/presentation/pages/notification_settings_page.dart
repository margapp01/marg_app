import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../data/repository/notification_repository.dart';
import '../controllers/notification_controllers.dart';

/// Screen 6 — Notification Settings. Exposes the real preference toggles
/// (`/my/notification-preferences`) except SMS / WhatsApp, which MARG does not
/// deliver through yet. Turning Push on requests permission and
/// registers this device's FCM token (`POST /my/devices`).
class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(preferencesProvider);

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.ntSettingsTitle)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(title: l10n.ntErrorTitle, message: l10n.ntErrorBody, onRetry: () => ref.invalidate(preferencesProvider)),
        data: (p) {
          final c = context.palette;
          return ListView(
            padding: AppSpacing.screenAll,
            children: [
              IntroBanner(
                icon: AppIcons.pushNotification,
                title: l10n.ntHeroTitle,
                message: l10n.ntSettingsSubtitle,
                status: l10n.ntEnabledCount(p.enabledCount, p.total),
              ).fadeIn(),
              const Gap(AppSpacing.xl),
              SettingsGroup(
                title: l10n.ntChannels,
                children: [
                  _toggle(AppIcons.pushNotification, c.accentSaffron, l10n.ntPush, l10n.ntPushHint, p.pushEnabled, (v) => _onPush(ref, v)),
                  _toggle(AppIcons.mail, c.accentBlue, l10n.ntEmail, l10n.ntEmailHint, p.emailEnabled, (v) => _set(ref, 'emailEnabled', v)),
                ],
              ).fadeIn(delay: 40.ms),
              const Gap(AppSpacing.xl),
              SettingsGroup(
                title: l10n.ntCategoriesHeader,
                children: [
                  _toggle(AppIcons.temple, c.accentSaffron, l10n.ntTempleAlerts, l10n.ntTempleAlertsHint, p.templeUpdateNotifications, (v) => _set(ref, 'templeUpdateNotifications', v)),
                  _toggle(AppIcons.nearby, c.accentGreen, l10n.ntNearbyAlerts, l10n.ntNearbyAlertsHint, p.nearbyAlerts, (v) => _set(ref, 'nearbyAlerts', v)),
                  _toggle(AppIcons.route, c.accentBlue, l10n.ntRouteUpdates, l10n.ntRouteUpdatesHint, p.routeNotifications, (v) => _set(ref, 'routeNotifications', v)),
                  _toggle(AppIcons.achievement, c.accentViolet, l10n.ntAchievementUpdates, l10n.ntAchievementUpdatesHint, p.achievementNotifications, (v) => _set(ref, 'achievementNotifications', v)),
                  _toggle(AppIcons.card, c.accentRose, l10n.ntCardUpdates, l10n.ntCardUpdatesHint, p.cardNotifications, (v) => _set(ref, 'cardNotifications', v)),
                  _toggle(AppIcons.festival, c.accentAmber, l10n.ntFestivalReminders, l10n.ntFestivalRemindersHint, p.festivalNotifications, (v) => _set(ref, 'festivalNotifications', v)),
                  _toggle(AppIcons.announcement, c.accentTeal, l10n.ntMarketing, l10n.ntMarketingHint, p.marketingNotifications, (v) => _set(ref, 'marketingNotifications', v)),
                ],
              ).fadeIn(delay: 80.ms),
            ],
          );
        },
      ),
    );
  }

  Widget _toggle(IconData icon, Color color, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return SettingsTile.toggle(icon: icon, iconColor: color, title: title, subtitle: subtitle, switchValue: value, onToggle: onChanged);
  }

  Future<void> _set(WidgetRef ref, String key, bool value) => ref.read(preferencesProvider.notifier).toggle(key, value);

  /// Push toggle: on enable, request permission + register this device's FCM
  /// token (best-effort), then persist the preference.
  Future<void> _onPush(WidgetRef ref, bool value) async {
    if (value) {
      try {
        final messaging = FirebaseMessaging.instance;
        final settings = await messaging.requestPermission();
        if (settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional) {
          final token = await messaging.getToken();
          if (token != null) {
            await ref.read(notificationRepositoryProvider).registerDevice(
                  fcmToken: token,
                  platform: defaultTargetPlatform == TargetPlatform.iOS ? 'IOS' : 'ANDROID',
                );
          }
        }
      } catch (_) {/* best-effort; still persist the preference below */}
    }
    await _set(ref, 'pushEnabled', value);
  }
}
