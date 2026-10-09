import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Device location (Geolocator). The visits phase adds position streams,
/// accuracy policy, and geofence checks here.
///
/// Foundation seam: dependency-injected via Riverpod now, implemented in its
/// feature phase. No behaviour yet by design.
class LocationService {
  const LocationService();
}

final locationServiceProvider = Provider<LocationService>((ref) => const LocationService());
