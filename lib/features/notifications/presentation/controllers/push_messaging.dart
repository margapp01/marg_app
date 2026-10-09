import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/device_context_service.dart';
import '../../../../core/storage/shared_prefs_store.dart';
import '../../data/repository/notification_repository.dart';

/// Firebase Cloud Messaging for the signed-in devotee: asks for notification
/// permission once, registers this device's token with the backend (again
/// whenever FCM rotates it), and hands messages to the caller — [onOpen] for
/// a tapped system notification (including the one that launched the app),
/// [onForeground] for one that arrives while the app is open.
class PushMessaging {
  PushMessaging(this._ref);

  final Ref _ref;
  final List<StreamSubscription<Object?>> _subscriptions = [];

  static const String _askedKey = 'push.permissionAsked';

  Future<void> start({
    required void Function(RemoteMessage message) onOpen,
    required void Function(RemoteMessage message) onForeground,
  }) async {
    try {
      final messaging = FirebaseMessaging.instance;
      var settings = await messaging.getNotificationSettings();
      final store = _ref.read(keyValueStoreProvider);
      if (!_allowed(settings) && await store.getBool(_askedKey) != true) {
        await store.setBool(_askedKey, value: true);
        settings = await messaging.requestPermission();
      }
      if (_allowed(settings)) {
        final token = await messaging.getToken();
        if (token != null) await _register(token);
        _subscriptions.add(messaging.onTokenRefresh.listen(_register));
      }
      _subscriptions
        ..add(FirebaseMessaging.onMessage.listen(onForeground))
        ..add(FirebaseMessaging.onMessageOpenedApp.listen(onOpen));
      final initial = await messaging.getInitialMessage();
      if (initial != null) onOpen(initial);
    } catch (_) {/* push is best-effort; the in-app inbox still works */}
  }

  void stop() {
    for (final s in _subscriptions) {
      s.cancel();
    }
    _subscriptions.clear();
  }

  static bool _allowed(NotificationSettings s) =>
      s.authorizationStatus == AuthorizationStatus.authorized ||
      s.authorizationStatus == AuthorizationStatus.provisional;

  Future<void> _register(String token) async {
    try {
      final device = await _ref.read(deviceContextServiceProvider).load();
      await _ref.read(notificationRepositoryProvider).registerDevice(
            fcmToken: token,
            platform: device.platform,
            appVersion: device.appVersion,
            deviceModel: device.deviceModel,
          );
    } catch (_) {/* retried on the next launch / token refresh */}
  }
}

final pushMessagingProvider = Provider<PushMessaging>((ref) {
  final push = PushMessaging(ref);
  ref.onDispose(push.stop);
  return push;
});
