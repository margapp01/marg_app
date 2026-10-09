import 'geo_place.dart';

/// A GPS fix captured during onboarding, plus its reverse-geocoded place.
/// Maps directly onto the backend `PUT /my/location` contract.
class CapturedLocation {
  const CapturedLocation({
    required this.latitude,
    required this.longitude,
    required this.capturedAt,
    this.accuracyMeters,
    this.altitudeMeters,
    this.timezone,
    this.permissionStatus,
    this.isMocked = false,
    this.source = 'FUSED',
    this.place,
  });

  final double latitude;
  final double longitude;
  final DateTime capturedAt;
  final double? accuracyMeters;
  final double? altitudeMeters;
  final String? timezone;
  final String? permissionStatus;

  /// Whether the platform flagged this fix as a mock/simulated location
  /// (Android). Always false on iOS. A signal for the check-in anti-fraud
  /// pipeline — the backend, not the client, decides the verdict.
  final bool isMocked;

  /// Backend `LocationSource`: GPS / NETWORK / FUSED / UNKNOWN.
  final String source;
  final GeoPlace? place;

  CapturedLocation withPlace(GeoPlace place) => CapturedLocation(
        latitude: latitude,
        longitude: longitude,
        capturedAt: capturedAt,
        accuracyMeters: accuracyMeters,
        altitudeMeters: altitudeMeters,
        timezone: timezone,
        permissionStatus: permissionStatus,
        isMocked: isMocked,
        source: source,
        place: place,
      );

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'capturedAt': capturedAt.toUtc().toIso8601String(),
        if (accuracyMeters != null) 'accuracyMeters': accuracyMeters,
        if (altitudeMeters != null) 'altitudeMeters': altitudeMeters,
        if (timezone != null) 'timezone': timezone,
        if (permissionStatus != null) 'permissionStatus': permissionStatus,
        'source': source,
        if (place?.city != null) 'city': place!.city,
        if (place?.state != null) 'state': place!.state,
        if (place?.country != null) 'country': place!.country,
      };
}
