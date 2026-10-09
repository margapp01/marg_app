import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Crash reporting (Firebase Crashlytics). bootstrap() wires Flutter error
/// hooks through this seam once Firebase is configured.
///
/// Foundation seam: dependency-injected via Riverpod now, implemented in its
/// feature phase. No behaviour yet by design.
class CrashlyticsService {
  const CrashlyticsService();
}

final crashlyticsServiceProvider = Provider<CrashlyticsService>((ref) => const CrashlyticsService());
