/// Global, environment-independent constants.
abstract final class AppConstants {
  static const String appName = 'MARG';
  static const int defaultPageSize = 20;
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration snackBarDuration = Duration(seconds: 4);

  /// Minimum time the check-in "Verifying" choreography is shown, so the
  /// verification steps read as deliberate even when the server responds fast.
  static const Duration visitVerificationFloor = Duration(milliseconds: 2600);

  /// OpenStreetMap raster tiles (no API key) used by every map.
  static const String osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Mapbox Streets raster tiles (retina) for street-level maps such as
  /// directions; `{accessToken}` is filled from the configured token.
  /// Platform channel for MainActivity's "Turn on location" dialog.
  static const String locationChannel = 'in.margapp.marg_app/location';

  static const String mapboxStreetsTileUrl =
      'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/256/{z}/{x}/{y}@2x?access_token={accessToken}';

  /// User agent sent with tile requests, per the OSM tile usage policy.
  static const String mapUserAgent = 'in.margapp.marg';
}
