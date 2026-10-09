import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/notification_prefs.dart';

/// Talks to `/my/notifications*`, `/my/notification-preferences`, `/my/devices`.
class NotificationRemoteDataSource {
  NotificationRemoteDataSource(this._dio);
  final Dio _dio;

  Map<String, dynamic> _env(Response<dynamic> res) => (res.data as Map).cast<String, dynamic>();
  Map<String, dynamic> _data(Response<dynamic> res) => (_env(res)['data'] as Map).cast<String, dynamic>();

  Future<NotificationPage> list({int page = 1, int limit = 20, bool unreadOnly = false}) async {
    final res = await _dio.get<dynamic>('/my/notifications', queryParameters: {
      'page': page,
      'limit': limit,
      if (unreadOnly) 'unreadOnly': true,
    });
    return NotificationPage.fromEnvelope(_env(res));
  }

  Future<int> unreadCount() async {
    final res = await _dio.get<dynamic>('/my/notifications/unread-count');
    return (_data(res)['unreadCount'] as num?)?.toInt() ?? 0;
  }

  Future<AppNotification> detail(String id) async {
    final res = await _dio.get<dynamic>('/my/notifications/$id');
    return AppNotification.fromJson(_data(res));
  }

  Future<void> markRead(String id) => _dio.patch<dynamic>('/my/notifications/$id/read');

  Future<void> markAllRead() => _dio.patch<dynamic>('/my/notifications/read-all');

  Future<NotificationPreferences> preferences() async {
    final res = await _dio.get<dynamic>('/my/notification-preferences');
    return NotificationPreferences.fromJson(_data(res));
  }

  Future<NotificationPreferences> updatePreferences(Map<String, bool> patch) async {
    final res = await _dio.patch<dynamic>('/my/notification-preferences', data: patch);
    return NotificationPreferences.fromJson(_data(res));
  }

  /// Registers an FCM device token (`POST /my/devices`). Best-effort push opt-in.
  Future<void> registerDevice({required String fcmToken, required String platform, String? appVersion, String? deviceModel}) =>
      _dio.post<dynamic>('/my/devices', data: {
        'fcmToken': fcmToken,
        'platform': platform,
        'appVersion': ?appVersion,
        'deviceModel': ?deviceModel,
      });
}

final notificationRemoteDataSourceProvider = Provider<NotificationRemoteDataSource>(
  (ref) => NotificationRemoteDataSource(ref.watch(dioProvider)),
);
