import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'captured_location.dart';

/// Outcome of a location request.
enum LocationStatus { success, denied, deniedForever, serviceDisabled, error }

class LocationResult {
  const LocationResult(this.status, [this.location]);

  final LocationStatus status;
  final CapturedLocation? location;

  bool get isSuccess => status == LocationStatus.success && location != null;
}

/// Requests location permission and captures a single high-accuracy GPS fix.
/// Reverse-geocoding is layered on top by the caller (Mapbox), keeping this
/// service provider-agnostic.
class LocationService {
  const LocationService();

  Future<LocationResult> capture() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return const LocationResult(LocationStatus.serviceDisabled);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return const LocationResult(LocationStatus.deniedForever);
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      return const LocationResult(LocationStatus.denied);
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      return LocationResult(
        LocationStatus.success,
        CapturedLocation(
          latitude: pos.latitude,
          longitude: pos.longitude,
          accuracyMeters: pos.accuracy,
          altitudeMeters: pos.altitude,
          capturedAt: pos.timestamp,
          timezone: DateTime.now().timeZoneName,
          permissionStatus: permission.name,
          isMocked: pos.isMocked,
          source: 'FUSED',
        ),
      );
    } catch (_) {
      return const LocationResult(LocationStatus.error);
    }
  }

  Future<void> openSettings() => Geolocator.openAppSettings();
}

final locationServiceProvider = Provider<LocationService>((ref) => const LocationService());
