import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../app/constants/app_constants.dart';
import '../../../../core/location/captured_location.dart';
import '../../../../core/location/location_service.dart';
import '../../../../core/services/device_context_service.dart';
import '../../../temple_detail/presentation/controllers/temple_detail_controller.dart';
import '../../data/repository/temple_visit_repository_impl.dart';
import '../../domain/entities/checkin_failure.dart';
import '../../domain/entities/checkin_request.dart';
import '../../domain/entities/checkin_result.dart';
import '../../domain/entities/visit_route_progress.dart';
import '../../domain/entities/visit_temple.dart';
import '../../domain/repository/temple_visit_repository.dart';

/// The stages of the visit journey, in order.
enum TempleVisitPhase {
  loading,
  templeError,
  navigation,
  arrival,
  checkin,
  verifying,
  success,
  // Opened from the success summary when the devotee asks; Back returns there.
  cardUnlock,
  passportUpdate,
  achievement,
  continueJourney,
  failure;

  /// The success summary and the screens opened from it.
  bool get isReward => this == success || opensFromSummary;

  /// A screen opened from the success summary (Back returns there).
  bool get opensFromSummary =>
      this == cardUnlock || this == passportUpdate || this == achievement || this == continueJourney;
}

@immutable
class TempleVisitState {
  const TempleVisitState({
    this.phase = TempleVisitPhase.loading,
    this.temple,
    this.location,
    this.locationStatus,
    this.distanceMeters,
    this.capturing = false,
    this.submitting = false,
    this.result,
    this.routeProgress,
    this.failure,
    this.cardSeen = false,
  });

  final TempleVisitPhase phase;
  final VisitTemple? temple;
  final CapturedLocation? location;
  final LocationStatus? locationStatus;
  final double? distanceMeters;
  final bool capturing;
  final bool submitting;
  final CheckinResult? result;
  final VisitRouteProgress? routeProgress;
  final CheckinFailure? failure;

  /// The card has been revealed once — reopening it shows the face at once.
  final bool cardSeen;

  bool get hasLocation => location != null;

  bool get withinGeofence {
    final d = distanceMeters;
    final t = temple;
    return d != null && t != null && d <= t.geofenceRadius;
  }

  /// Accuracy quality bucket for UI (good ≤ 20m, fair ≤ 50m, else poor).
  LocationAccuracyLevel get accuracyLevel {
    final a = location?.accuracyMeters;
    if (a == null) return LocationAccuracyLevel.unknown;
    if (a <= 20) return LocationAccuracyLevel.high;
    if (a <= 50) return LocationAccuracyLevel.medium;
    return LocationAccuracyLevel.low;
  }

  TempleVisitState copyWith({
    TempleVisitPhase? phase,
    VisitTemple? temple,
    CapturedLocation? location,
    LocationStatus? locationStatus,
    double? distanceMeters,
    bool? capturing,
    bool? submitting,
    CheckinResult? result,
    VisitRouteProgress? routeProgress,
    CheckinFailure? failure,
    bool? cardSeen,
    bool clearFailure = false,
    bool clearLocationStatus = false,
  }) {
    return TempleVisitState(
      phase: phase ?? this.phase,
      temple: temple ?? this.temple,
      location: location ?? this.location,
      locationStatus: clearLocationStatus ? null : (locationStatus ?? this.locationStatus),
      distanceMeters: distanceMeters ?? this.distanceMeters,
      capturing: capturing ?? this.capturing,
      submitting: submitting ?? this.submitting,
      result: result ?? this.result,
      routeProgress: routeProgress ?? this.routeProgress,
      failure: clearFailure ? null : (failure ?? this.failure),
      cardSeen: cardSeen ?? this.cardSeen,
    );
  }
}

enum LocationAccuracyLevel { unknown, low, medium, high }

class TempleVisitController extends AutoDisposeFamilyNotifier<TempleVisitState, String> {
  TempleVisitRepository get _repo => ref.read(templeVisitRepositoryProvider);
  LocationService get _location => ref.read(locationServiceProvider);
  DeviceContextService get _device => ref.read(deviceContextServiceProvider);

  @override
  TempleVisitState build(String slug) {
    Future.microtask(_init);
    return const TempleVisitState();
  }

  Future<void> _init() async {
    try {
      final temple = await _repo.temple(arg);
      state = state.copyWith(phase: TempleVisitPhase.navigation, temple: temple);
      await refreshLocation();
    } catch (_) {
      state = state.copyWith(phase: TempleVisitPhase.templeError);
    }
  }

  /// Reload after a temple-load error.
  Future<void> retryLoad() async {
    state = const TempleVisitState();
    await _init();
  }

  /// Capture a fresh GPS fix and recompute the geofence distance.
  Future<void> refreshLocation() async {
    if (state.capturing) return;
    state = state.copyWith(capturing: true);
    final res = await _location.capture();
    final temple = state.temple;
    if (res.isSuccess && temple != null) {
      final loc = res.location!;
      final distance = Geolocator.distanceBetween(
        loc.latitude, loc.longitude, temple.latitude, temple.longitude,
      );
      state = state.copyWith(
        capturing: false,
        location: loc,
        distanceMeters: distance,
        locationStatus: LocationStatus.success,
      );
    } else {
      state = state.copyWith(capturing: false, locationStatus: res.status);
    }
  }

  void goToArrival() {
    state = state.copyWith(phase: TempleVisitPhase.arrival);
    unawaited(refreshLocation());
  }

  void goToCheckin() {
    state = state.copyWith(phase: TempleVisitPhase.checkin);
    unawaited(refreshLocation());
  }

  void backToNavigation() => state = state.copyWith(phase: TempleVisitPhase.navigation);

  /// Run the check-in: capture a fresh fix, submit, and choreograph the
  /// verification. Backend is the sole authority on the verdict.
  Future<void> submitCheckIn() async {
    final temple = state.temple;
    if (temple == null || state.submitting) return;

    // A check-in needs a fresh fix.
    await refreshLocation();
    final loc = state.location;
    if (loc == null) {
      // No GPS → stay on the check-in screen; the widget surfaces the status.
      state = state.copyWith(phase: TempleVisitPhase.checkin);
      return;
    }

    state = state.copyWith(phase: TempleVisitPhase.verifying, submitting: true, clearFailure: true);

    final device = await _loadDevice();
    final request = CheckinRequest(
      latitude: loc.latitude,
      longitude: loc.longitude,
      isMockLocation: loc.isMocked,
      isRooted: device.isRooted,
      deviceId: device.deviceId,
      appVersion: device.appVersion,
      platform: device.platform,
      deviceModel: device.deviceModel,
      altitude: loc.altitudeMeters,
    );

    // Choreograph: run the request and a minimum-duration floor together.
    final floor = Future<void>.delayed(AppConstants.visitVerificationFloor);
    try {
      final result = await _repo.checkIn(temple.id, request);
      _refreshTempleDetail();
      // Route progress enriches the passport / continue screens (best-effort).
      final progress = result.verified ? await _repo.routeProgress(temple.id) : null;
      await floor;
      state = state.copyWith(
        phase: TempleVisitPhase.success,
        submitting: false,
        result: result,
        routeProgress: progress,
      );
    } on CheckinFailure catch (f) {
      if (f.kind == CheckinFailureKind.alreadyCheckedIn) _refreshTempleDetail();
      await floor;
      state = state.copyWith(phase: TempleVisitPhase.failure, submitting: false, failure: f);
    } catch (e) {
      await floor;
      state = state.copyWith(
        phase: TempleVisitPhase.failure,
        submitting: false,
        failure: CheckinFailure.offline('$e'),
      );
    }
  }

  /// The Temple Detail underneath shows this temple's visit count and whether
  /// today's check-in is done — reload it once the server has answered.
  void _refreshTempleDetail() => ref.invalidate(templeDetailControllerProvider(arg));

  /// Opens one of the visit's rewards from the success summary — the card
  /// reveal, the passport stamp, the achievement or the next temple. All
  /// optional: the devotee can finish from the summary at any time.
  void openReward(TempleVisitPhase phase) {
    assert(phase.opensFromSummary, '$phase is not opened from the summary');
    state = state.copyWith(phase: phase);
  }

  /// Back from a reward screen to the success summary.
  void backToSummary() {
    if (!state.phase.opensFromSummary) return;
    state = state.copyWith(
      phase: TempleVisitPhase.success,
      cardSeen: state.cardSeen || state.phase == TempleVisitPhase.cardUnlock,
    );
  }

  /// Retry a failed check-in — back to the confirmation step.
  void retryCheckIn() {
    state = state.copyWith(phase: TempleVisitPhase.checkin, clearFailure: true);
    unawaited(refreshLocation());
  }

  /// Never let device-info collection break a check-in.
  Future<DeviceContext> _loadDevice() async {
    try {
      return await _device.load();
    } catch (_) {
      return DeviceContext.unknown;
    }
  }
}

final templeVisitControllerProvider =
    NotifierProvider.autoDispose.family<TempleVisitController, TempleVisitState, String>(
  TempleVisitController.new,
);
