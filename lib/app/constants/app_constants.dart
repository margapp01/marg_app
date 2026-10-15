/// Global, environment-independent constants.
abstract final class AppConstants {
  static const String appName = 'MARG';

  /// The public website — every shared link lands here (App Links open the
  /// app instead when it is installed).
  static const String webBaseUrl = 'https://margapp.in';

  /// The Play Store listing, for shares with no web page to land on.
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.techluminix.marg';

  /// Minimum account age. 18 until the guardian-consent flow for 13–17 ships
  /// (DPDP: under-18s need verifiable parental consent); the API enforces it too.
  static const int minAccountAge = 18;
  static const int defaultPageSize = 20;
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration snackBarDuration = Duration(seconds: 4);

  /// Minimum time the check-in "Verifying" choreography is shown, so the
  /// verification steps read as deliberate even when the server responds fast.
  static const Duration visitVerificationFloor = Duration(milliseconds: 2600);

  /// OpenStreetMap raster tiles (no API key) — only the fallback for builds
  /// without a Mapbox token (local development); production uses Mapbox, as
  /// OSM's tile policy does not allow apps to rely on its volunteer servers.
  static const String osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Mapbox raster tiles (retina) for every map; `{style}` and `{accessToken}`
  /// are filled per map from [mapboxLightStyle]/[mapboxStreetsStyle] and the
  /// configured token.
  /// Platform channel for MainActivity's "Turn on location" dialog.
  static const String locationChannel = 'com.techluminix.marg/location';

  /// Native channel for the stable device identifier (Android `ANDROID_ID`).
  static const String deviceChannel = 'com.techluminix.marg/device';

  /// Longest the sign-out temple check may take before sign-out proceeds.
  static const Duration signOutGuardTimeout = Duration(seconds: 12);

  static const String mapboxTileUrl =
      'https://api.mapbox.com/styles/v1/mapbox/{style}/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}';

  /// Mapbox styles behind [MapTiles]: a calm base for overviews (warmed in the
  /// app) and full street detail for directions.
  static const String mapboxLightStyle = 'light-v11';
  static const String mapboxStreetsStyle = 'streets-v12';

  /// User agent sent with tile requests, per the OSM tile usage policy.
  static const String mapUserAgent = 'com.techluminix.marg';
}
