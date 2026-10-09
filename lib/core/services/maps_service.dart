import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Google Maps helpers: camera math, marker building, style loading from
/// assets/map_styles. Populated in the maps phase.
///
/// Foundation seam: dependency-injected via Riverpod now, implemented in its
/// feature phase. No behaviour yet by design.
class MapsService {
  const MapsService();
}

final mapsServiceProvider = Provider<MapsService>((ref) => const MapsService());
