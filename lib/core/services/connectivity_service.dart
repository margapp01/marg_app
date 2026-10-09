import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Network reachability (connectivity_plus). Exposes a coarse online/offline
/// signal — "online" means at least one active transport (wifi/mobile/ethernet/
/// vpn). This is reachability, not a guarantee the API is reachable; the
/// read-through cache still covers request failures while "online".
class ConnectivityService {
  ConnectivityService([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  static bool _isOnline(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  /// The current online/offline status.
  Future<bool> isOnline() async => _isOnline(await _connectivity.checkConnectivity());

  /// Emits whenever connectivity changes.
  Stream<bool> get onStatusChange => _connectivity.onConnectivityChanged.map(_isOnline);
}

final connectivityServiceProvider = Provider<ConnectivityService>((ref) => ConnectivityService());

/// Live online/offline status: seeds with the current value, then tracks
/// changes. Widgets watch this for the offline banner + auto-refresh.
final connectivityStatusProvider = StreamProvider<bool>((ref) async* {
  final service = ref.watch(connectivityServiceProvider);
  yield await service.isOnline();
  yield* service.onStatusChange;
});
