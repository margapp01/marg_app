import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/app_notification.dart';
import '../../domain/entities/hub_content.dart';
import '../../domain/entities/notification_prefs.dart';
import '../datasource/hub_remote_datasource.dart';
import '../datasource/notification_remote_datasource.dart';

/// Thin orchestration over the notification + hub datasources.
class NotificationRepository {
  NotificationRepository(this._remote, this._hub);
  final NotificationRemoteDataSource _remote;
  final HubRemoteDataSource _hub;

  Future<NotificationPage> list({int page = 1, int limit = 20, bool unreadOnly = false}) =>
      _remote.list(page: page, limit: limit, unreadOnly: unreadOnly);
  Future<int> unreadCount() => _remote.unreadCount();
  Future<AppNotification> detail(String id) => _remote.detail(id);
  Future<void> markRead(String id) => _remote.markRead(id);
  Future<void> markAllRead() => _remote.markAllRead();
  Future<NotificationPreferences> preferences() => _remote.preferences();
  Future<NotificationPreferences> updatePreferences(Map<String, bool> patch) => _remote.updatePreferences(patch);
  Future<void> registerDevice({required String fcmToken, required String platform, String? appVersion, String? deviceModel}) =>
      _remote.registerDevice(fcmToken: fcmToken, platform: platform, appVersion: appVersion, deviceModel: deviceModel);

  Future<List<Festival>> upcomingFestivals() => _hub.upcomingFestivals();
  Future<Festival> festival(String slug) => _hub.festival(slug);
  Future<Quote?> dailyQuote() => _hub.dailyQuote();
  Future<List<Quote>> quotes({int page = 1, int limit = 20}) => _hub.quotes(page: page, limit: limit);
}

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(
    ref.watch(notificationRemoteDataSourceProvider),
    ref.watch(hubRemoteDataSourceProvider),
  ),
);
