import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../app/constants/app_constants.dart';
import '../storage/shared_prefs_store.dart';
import 'location_api.dart';
import 'location_service.dart';
import 'mapbox_geocoder.dart';

/// Where location access stands right now.
enum LocationAccess { granted, denied, deniedForever, serviceOff }

Future<LocationAccess> _readAccess() async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) return LocationAccess.serviceOff;
    return switch (await Geolocator.checkPermission()) {
      LocationPermission.always || LocationPermission.whileInUse => LocationAccess.granted,
      LocationPermission.deniedForever => LocationAccess.deniedForever,
      _ => LocationAccess.denied,
    };
  } catch (_) {
    return LocationAccess.denied;
  }
}

/// Turns device location on: Google Play services' in-app "Turn on location"
/// dialog on Android, the location settings page where that dialog isn't
/// available (iOS, devices without Play services).
Future<void> _turnOnLocation() async {
  try {
    final shown = await const MethodChannel(AppConstants.locationChannel).invokeMethod<bool>('requestLocationService');
    if (shown != null) return;
  } on Exception {
    // No in-app dialog on this device; the settings page below is the way.
  }
  await Geolocator.openLocationSettings();
}

/// Reads the platform's location access; overridable in tests.
final locationAccessReaderProvider = Provider<Future<LocationAccess> Function()>((ref) => _readAccess);

/// Location access, re-read on demand — e.g. when the app returns from the
/// system settings the devotee was sent to.
class LocationAccessController extends AsyncNotifier<LocationAccess> {
  @override
  Future<LocationAccess> build() => ref.read(locationAccessReaderProvider)();

  Future<LocationAccess> refresh() async {
    final next = await ref.read(locationAccessReaderProvider)();
    state = AsyncData(next);
    return next;
  }

  /// The one step that moves access forward from where it is: the system
  /// permission dialog, or the device's location / app settings. Resolves to
  /// the access afterwards (settings changes land on the next [refresh]).
  Future<LocationAccess> resolve() async {
    try {
      switch (state.valueOrNull ?? await future) {
        case LocationAccess.granted:
          return LocationAccess.granted;
        case LocationAccess.serviceOff:
          await _turnOnLocation();
        case LocationAccess.deniedForever:
          await Geolocator.openAppSettings();
        case LocationAccess.denied:
          await Geolocator.requestPermission();
      }
    } catch (_) {
      // The platform couldn't ask (e.g. no permission declared); the app's
      // settings page is the remaining way to grant it.
      await Geolocator.openAppSettings();
    }
    return refresh();
  }

  /// Asks straight away, the way ride apps do: the "Turn on location" dialog
  /// if device location is off, then the system permission dialog. Never
  /// sends the devotee to a settings page; stops as soon as they decline.
  Future<LocationAccess> askDirectly() async {
    var access = state.valueOrNull ?? await future;
    while (access == LocationAccess.serviceOff || access == LocationAccess.denied) {
      final next = await resolve();
      if (next == access) break;
      access = next;
    }
    return access;
  }
}

final locationAccessProvider =
    AsyncNotifierProvider<LocationAccessController, LocationAccess>(LocationAccessController.new);

/// Keeps the backend's copy of the devotee's location fresh — it powers
/// Nearby Temples and the morning / afternoon / evening "temple near you"
/// nudges. Saves at most every few hours, or sooner after moving more than a
/// kilometre. Best-effort: never throws. Call only once access is granted.
class LocationSync {
  LocationSync(this._ref);

  final Ref _ref;

  static const String _syncedAtKey = 'location.syncedAt';
  static const String _latKey = 'location.syncedLat';
  static const String _lngKey = 'location.syncedLng';
  static const Duration _interval = Duration(hours: 3);
  static const double _movedMeters = 1000;

  Future<bool>? _inFlight;

  /// Whether a new location was saved. Overlapping calls (e.g. the location
  /// ask and the app resuming from the system dialog) share one save.
  Future<bool> syncIfStale() => _inFlight ??= _sync().whenComplete(() => _inFlight = null);

  Future<bool> _sync() async {
    try {
      final result = await _ref.read(locationServiceProvider).capture();
      if (!result.isSuccess) return false;
      var location = result.location!;

      final store = _ref.read(keyValueStoreProvider);
      final syncedAt = DateTime.tryParse(await store.getString(_syncedAtKey) ?? '');
      final lat = double.tryParse(await store.getString(_latKey) ?? '');
      final lng = double.tryParse(await store.getString(_lngKey) ?? '');
      final recent = syncedAt != null && DateTime.now().difference(syncedAt) < _interval;
      final moved = lat == null ||
          lng == null ||
          Geolocator.distanceBetween(lat, lng, location.latitude, location.longitude) > _movedMeters;
      if (recent && !moved) return false;

      final geocoder = _ref.read(mapboxGeocoderProvider);
      if (geocoder.token.isNotEmpty) {
        try {
          location = location.withPlace(
            await geocoder.reverse(latitude: location.latitude, longitude: location.longitude),
          );
        } catch (_) {/* the place is optional; coordinates are what matter */}
      }
      await _ref.read(locationApiProvider).updateMyLocation(location);
      await store.setString(_syncedAtKey, DateTime.now().toIso8601String());
      await store.setString(_latKey, '${location.latitude}');
      await store.setString(_lngKey, '${location.longitude}');
      return true;
    } catch (_) {
      return false;
    }
  }
}

final locationSyncProvider = Provider<LocationSync>(LocationSync.new);
