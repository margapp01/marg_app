import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/services/connectivity_service.dart';
import '../../data/repository/home_repository_impl.dart';
import '../../domain/entities/home_dashboard.dart';

/// A resolved GPS fix, or null when unavailable/not granted.
typedef LocationFix = (double latitude, double longitude)?;

/// Reads the device's **last-known** location, but only if permission is
/// already granted — the Home screen never prompts (permission is requested
/// during onboarding). Injected behind a provider so tests don't touch the
/// platform channel.
Future<LocationFix> lastKnownIfGranted() async {
  try {
    final permission = await Geolocator.checkPermission();
    final granted = permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
    if (!granted) return null;
    final pos = await Geolocator.getLastKnownPosition();
    return pos == null ? null : (pos.latitude, pos.longitude);
  } catch (_) {
    return null; // location is best-effort; the dashboard loads without it
  }
}

final homeLocationProvider = Provider<Future<LocationFix> Function()>(
  (ref) => lastKnownIfGranted,
);

/// Drives the Home screen from the single `/home/dashboard` call.
class HomeController extends AsyncNotifier<HomeDashboard> {
  @override
  Future<HomeDashboard> build() {
    // Auto-refresh when connectivity is restored (offline → online), so a
    // cached dashboard is quietly replaced with live data once reachable.
    ref.listen(connectivityStatusProvider, (prev, next) {
      final wasOnline = prev?.valueOrNull ?? true;
      final isOnline = next.valueOrNull ?? true;
      if (!wasOnline && isOnline) refresh();
    });
    return _load();
  }

  Future<HomeDashboard> _load() async {
    final fix = await ref.read(homeLocationProvider)();
    return ref.read(homeRepositoryProvider).loadDashboard(
          latitude: fix?.$1,
          longitude: fix?.$2,
        );
  }

  /// Reload, keeping the previous data visible while the request is in flight
  /// (drives pull-to-refresh without flashing a skeleton).
  Future<void> refresh() async {
    state = const AsyncLoading<HomeDashboard>().copyWithPrevious(state);
    state = await AsyncValue.guard(_load);
  }
}

final homeControllerProvider =
    AsyncNotifierProvider<HomeController, HomeDashboard>(HomeController.new);
