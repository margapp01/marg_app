import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Push + local notifications (Firebase Messaging). Token registration and
/// message handlers arrive with the notifications phase.
///
/// Foundation seam: dependency-injected via Riverpod now, implemented in its
/// feature phase. No behaviour yet by design.
class NotificationService {
  const NotificationService();
}

final notificationServiceProvider = Provider<NotificationService>((ref) => const NotificationService());
