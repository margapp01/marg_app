import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/localization/locale_provider.dart';
import '../../../../core/location/location_access.dart';
import '../../data/directions_api.dart';
import '../../domain/route_plan.dart';

/// Everything the directions screen shows.
class DirectionsState {
  const DirectionsState({
    this.access,
    this.origin,
    this.plan = const AsyncLoading<RoutePlan>(),
    this.mode = TravelMode.drive,
    this.modes = TravelMode.values,
    this.following = false,
    this.arrived = false,
  });

  /// Null while checking.
  final LocationAccess? access;

  /// The pilgrim's live position, once known.
  final LatLng? origin;
  final AsyncValue<RoutePlan> plan;
  final TravelMode mode;

  /// The modes offered for this trip — walking only when the temple is near.
  final List<TravelMode> modes;

  /// Camera follows the pilgrim (turn-by-turn style).
  final bool following;
  final bool arrived;

  DirectionsState copyWith({
    LocationAccess? access,
    LatLng? origin,
    AsyncValue<RoutePlan>? plan,
    TravelMode? mode,
    List<TravelMode>? modes,
    bool? following,
    bool? arrived,
  }) =>
      DirectionsState(
        access: access ?? this.access,
        origin: origin ?? this.origin,
        plan: plan ?? this.plan,
        mode: mode ?? this.mode,
        modes: modes ?? this.modes,
        following: following ?? this.following,
        arrived: arrived ?? this.arrived,
      );
}

/// Routes the pilgrim to [DirectionsArgs] and keeps it live: tracks position
/// every few metres, re-routes when they stray from the line, and notices
/// arrival. Stops tracking when the screen closes.
class DirectionsController extends AutoDisposeFamilyNotifier<DirectionsState, DirectionsArgs> {
  StreamSubscription<Position>? _positions;
  DateTime _lastRouted = DateTime.fromMillisecondsSinceEpoch(0);
  bool _routing = false;

  /// Bumped per request; a response for an older one is dropped.
  int _request = 0;

  static const double _arrivalMeters = 60;
  static const double _offRouteMeters = 60;
  static const Duration _rerouteGap = Duration(seconds: 20);
  static const Duration _fixTimeout = Duration(seconds: 12);

  @override
  DirectionsState build(DirectionsArgs arg) {
    ref.onDispose(() => _positions?.cancel());
    Future.microtask(start);
    return DirectionsState(mode: arg.initialMode);
  }

  /// (Re)checks location access, finds the pilgrim, routes and starts tracking.
  Future<void> start() async {
    final access = await ref.read(locationAccessProvider.notifier).refresh();
    state = state.copyWith(access: access);
    if (access != LocationAccess.granted) return;
    final fix = await _currentFix();
    if (fix == null) {
      state = state.copyWith(plan: AsyncError<RoutePlan>(StateError('No location fix'), StackTrace.current));
      return;
    }
    final modes = TravelMode.forDistance(const Distance()(fix, arg.point));
    state = state.copyWith(
      origin: fix,
      arrived: _isArrival(fix),
      modes: modes,
      mode: modes.contains(state.mode) ? state.mode : TravelMode.drive,
    );
    await _route();
    _positions ??= Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5),
    ).listen(_onPosition, onError: (Object _) {});
  }

  Future<void> retry() => state.origin == null ? start() : _route();

  Future<void> setMode(TravelMode mode) async {
    if (mode == state.mode || !state.modes.contains(mode)) return;
    // Drop the other mode's line and time at once — never show a drive time
    // under "Walk" while the walking route loads.
    state = state.copyWith(mode: mode, plan: const AsyncLoading<RoutePlan>());
    await _route();
  }

  void setFollowing({required bool on}) => state = state.copyWith(following: on);

  Future<LatLng?> _currentFix() async {
    try {
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: _fixTimeout),
      );
      return LatLng(p.latitude, p.longitude);
    } catch (_) {
      try {
        final last = await Geolocator.getLastKnownPosition();
        return last == null ? null : LatLng(last.latitude, last.longitude);
      } catch (_) {
        return null;
      }
    }
  }

  /// Fetches a route from the current origin. [quiet] keeps the current line
  /// on screen (and on failure) — used for automatic re-routes, which skip
  /// while a request is in flight. A user-driven request (start, retry, mode
  /// switch) always goes out and supersedes any in flight.
  Future<void> _route({bool quiet = false}) async {
    final origin = state.origin;
    if (origin == null || (quiet && _routing)) return;
    final request = ++_request;
    final mode = state.mode;
    _routing = true;
    _lastRouted = DateTime.now();
    if (!quiet) state = state.copyWith(plan: const AsyncLoading<RoutePlan>().copyWithPrevious(state.plan));
    final language = ref.read(localeControllerProvider)?.languageCode ?? 'en';
    final next = await AsyncValue.guard(
      () => ref.read(directionsApiProvider).route(origin, arg.point, mode, language: language),
    );
    if (request != _request) return;
    _routing = false;
    if (quiet && next.hasError) return;
    state = state.copyWith(plan: next);
  }

  void _onPosition(Position p) {
    final at = LatLng(p.latitude, p.longitude);
    final arrived = state.arrived || _isArrival(at);
    state = state.copyWith(origin: at, arrived: arrived);
    final plan = state.plan.valueOrNull;
    if (plan == null || arrived) return;
    if (plan.offRouteMeters(at) > _offRouteMeters && DateTime.now().difference(_lastRouted) > _rerouteGap) {
      unawaited(_route(quiet: true));
    }
  }

  bool _isArrival(LatLng at) => const Distance()(at, arg.point) <= _arrivalMeters;
}

final directionsProvider =
    NotifierProvider.autoDispose.family<DirectionsController, DirectionsState, DirectionsArgs>(DirectionsController.new);
