import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Build-time environment. Selected via --dart-define=APP_ENV=…
enum AppEnvironment { dev, staging, prod }

/// Immutable runtime configuration. Values come from --dart-define so a
/// single binary definition covers all environments without code changes.
class AppConfig {
  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.mapboxToken,
  });

  final AppEnvironment environment;
  final String apiBaseUrl;

  /// Public Mapbox token (URL-restricted, geocoding-scoped). Supplied via
  /// --dart-define=MAPBOX_TOKEN so it is never committed to source.
  final String mapboxToken;

  bool get isProd => environment == AppEnvironment.prod;
  bool get hasMapbox => mapboxToken.isNotEmpty;

  /// Release builds default to production, so a store build never ships
  /// pointing at a dev machine even if no --dart-define is passed.
  static AppConfig fromEnvironment() {
    const envName = String.fromEnvironment(
      'APP_ENV',
      defaultValue: kReleaseMode ? 'prod' : 'dev',
    );
    const baseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: kReleaseMode
          ? 'https://api.margapp.in/api/v1'
          : 'http://192.168.0.100:8000/api/v1',
    );
    const mapboxToken = String.fromEnvironment('MAPBOX_TOKEN');
    final environment = AppEnvironment.values.firstWhere(
      (e) => e.name == envName,
      orElse: () => AppEnvironment.dev,
    );
    return AppConfig(
      environment: environment,
      apiBaseUrl: baseUrl,
      mapboxToken: mapboxToken,
    );
  }
}

final appConfigProvider = Provider<AppConfig>(
  (ref) => AppConfig.fromEnvironment(),
);
