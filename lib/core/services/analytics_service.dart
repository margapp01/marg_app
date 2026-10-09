import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Product analytics (Firebase Analytics). Typed event methods land here so
/// event names stay consistent app-wide.
///
/// Foundation seam: dependency-injected via Riverpod now, implemented in its
/// feature phase. No behaviour yet by design.
class AnalyticsService {
  const AnalyticsService();
}

final analyticsServiceProvider = Provider<AnalyticsService>((ref) => const AnalyticsService());
