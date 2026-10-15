import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Product analytics (Firebase Analytics). Typed event methods land here so
/// event names stay consistent app-wide. Collection stays off until the user
/// consents (see `bootstrap.dart`), so every event is a no-op until then.
class AnalyticsService {
  const AnalyticsService();

  /// A completed trip through the system share sheet.
  Future<void> logShare({required String contentType, required String itemId}) async {
    try {
      await FirebaseAnalytics.instance.logShare(contentType: contentType, itemId: itemId, method: 'system_sheet');
    } catch (_) {/* analytics never breaks a share */}
  }
}

final analyticsServiceProvider = Provider<AnalyticsService>((ref) => const AnalyticsService());
