import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../core/location/location_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/design_system.dart';
import '../../../directions/domain/route_plan.dart';
import '../../../directions/presentation/travel_mode_ui.dart';
import '../../domain/entities/visit_temple.dart';
import '../controllers/temple_visit_controller.dart';
import '../controllers/visit_route_provider.dart';
import 'visit_components.dart';

// ─────────────────────────── Navigation ───────────────────────────

/// The road there: a route preview on the map, distance / time / arrival on
/// the real router for the chosen mode (walking only when the temple is
/// near), and in-app turn-by-turn on "Start Navigation".
class NavigationPhase extends ConsumerStatefulWidget {
  const NavigationPhase({required this.state, required this.onStartNavigation, required this.onArrived, super.key});

  final TempleVisitState state;
  final ValueChanged<TravelMode> onStartNavigation;
  final VoidCallback onArrived;

  @override
  ConsumerState<NavigationPhase> createState() => _NavigationPhaseState();
}

class _NavigationPhaseState extends ConsumerState<NavigationPhase> {
  TravelMode _mode = TravelMode.drive;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final temple = widget.state.temple;
    final loc = widget.state.location;
    final origin = loc == null ? null : LatLng(loc.latitude, loc.longitude);
    final dest = temple == null ? null : LatLng(temple.latitude, temple.longitude);
    final straight = widget.state.distanceMeters;
    final modes = straight == null ? const [TravelMode.drive, TravelMode.bike] : TravelMode.forDistance(straight);
    final mode = modes.contains(_mode) ? _mode : TravelMode.drive;

    final route = origin == null || dest == null
        ? null
        : ref.watch(visitRouteProvider((from: origin, to: dest, mode: mode)));
    final plan = route?.valueOrNull;
    final seconds = plan?.durationSeconds;
    final arrival = seconds == null
        ? null
        : DateFormat.jm(
            Localizations.localeOf(context).toLanguageTag(),
          ).format(DateTime.now().add(Duration(seconds: seconds.round())));

    return VisitPhaseBody(
      content: [
        VisitTempleBanner(
          label: l10n.tvDestination,
          name: temple?.name ?? '',
          location: temple?.location,
          imageUrl: temple?.imageUrl,
        ),
        const Gap(AppSpacing.md),
        if (dest != null)
          _RoutePreview(origin: origin, destination: dest, plan: plan, imageUrl: temple?.imageUrl).fadeIn(),
        const Gap(AppSpacing.md),
        ParchmentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Metric(
                      icon: AppIcons.route,
                      color: context.palette.accentSaffron,
                      value: formatDistance(plan?.distanceMeters ?? straight),
                      label: l10n.tvDistanceLeft,
                    ),
                    const GoldRule(vertical: true),
                    _Metric(
                      icon: AppIcons.timer,
                      color: context.palette.accentBlue,
                      value: seconds == null ? '—' : formatTravelTime(l10n, seconds),
                      label: l10n.tvEta,
                      busy: route?.isLoading ?? false,
                    ),
                    const GoldRule(vertical: true),
                    _Metric(
                      icon: AppIcons.flag,
                      color: context.palette.accentViolet,
                      value: arrival ?? '—',
                      label: l10n.tvArrivalTime,
                    ),
                  ],
                ),
              ),
              const Gap(AppSpacing.md),
              GoldRuleHeader(label: l10n.tvTravelMode),
              const Gap(AppSpacing.sm),
              PillTabs(
                labels: [for (final m in modes) _modeLabel(l10n, m)],
                selected: modes.indexOf(mode),
                onChanged: (i) => setState(() => _mode = modes[i]),
              ),
            ],
          ),
        ).fadeIn(delay: AppDurations.stagger * 2),
        const Gap(AppSpacing.lg),
        _InAppHint(text: l10n.tvNavigationHint),
      ],
      actions: [
        AppButton.primary(
          label: l10n.tvStartNavigation,
          icon: AppIcons.navigation,
          onPressed: () => widget.onStartNavigation(mode),
        ),
        const Gap(AppSpacing.sm),
        AppButton.outlined(label: l10n.tvIveArrived, icon: AppIcons.location, onPressed: widget.onArrived),
      ],
    );
  }

  String _modeLabel(AppLocalizations l10n, TravelMode m) => switch (m) {
    TravelMode.drive => l10n.tvModeDriving,
    TravelMode.bike => l10n.tvModeBike,
    TravelMode.walk => l10n.tvModeWalking,
  };
}

/// One number of the journey ledger — an illustrated mark, the value in the
/// display serif (a spinner while the route loads) and its label.
class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.color, required this.value, required this.label, this.busy = false});

  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final bool busy;

  static const double _icon = 36;
  static const double _spinner = 20;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        label: '$label $value',
        excludeSemantics: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IllustratedIcon(fallbackIcon: icon, color: color, size: _icon),
            const Gap(AppSpacing.sm),
            AnimatedSwitcher(
              duration: AppDurations.normal,
              child: busy
                  ? const SizedBox.square(
                      key: ValueKey('busy'),
                      dimension: _spinner,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : FittedBox(
                      key: ValueKey(value),
                      fit: BoxFit.scaleDown,
                      child: Text(
                        value,
                        maxLines: 1,
                        style: context.displayText.titleLarge.withColor(context.scheme.secondary),
                      ),
                    ),
            ),
            const Gap(AppSpacing.xxs),
            Text(
              label,
              textAlign: TextAlign.center,
              style: context.caption.copyWith(color: context.colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Turn-by-turn directions open right here in MARG", signed with the mark.
class _InAppHint extends StatelessWidget {
  const _InAppHint({required this.text});

  final String text;

  static const double _mark = 28;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          BrandAssets.logoMark,
          height: _mark,
          excludeFromSemantics: true,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
        const Gap.h(AppSpacing.sm),
        Flexible(
          child: Text(text, style: context.caption.copyWith(color: context.colors.textSecondary)),
        ),
      ],
    );
  }
}

/// A still street map framing the pilgrim, the route and the temple pin.
class _RoutePreview extends StatelessWidget {
  const _RoutePreview({required this.origin, required this.destination, required this.plan, this.imageUrl});

  final LatLng? origin;
  final LatLng destination;
  final RoutePlan? plan;
  final String? imageUrl;

  static const double _height = 220;
  static const double _maxZoom = 16;
  static const double _soloZoom = 14;

  @override
  Widget build(BuildContext context) {
    final points = [...?plan?.points, ?origin, destination];
    final framed = points.toSet().length > 1;
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: AppRadius.card,
        border: Border.all(color: context.colors.gold.withValues(alpha: 0.6), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.card,
        child: SizedBox(
          height: _height,
          child: BharatMap(
            // A new plan re-frames the camera.
            key: ValueKey(plan),
            tiles: MapTiles.streets,
            showBoundaries: false,
            options: MapOptions(
              initialCenter: destination,
              initialZoom: _soloZoom,
              initialCameraFit: framed
                  ? CameraFit.coordinates(coordinates: points, padding: AppSpacing.allXl, maxZoom: _maxZoom)
                  : null,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
            ),
            layers: [
              if (plan != null && plan!.points.length > 1)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: plan!.points,
                      strokeWidth: 5,
                      color: context.scheme.primary,
                      borderStrokeWidth: 2,
                      borderColor: context.colors.card,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: destination,
                    width: PhotoPin.widthFor(PhotoPin.defaultSize),
                    height: PhotoPin.heightFor(PhotoPin.defaultSize),
                    alignment: Alignment.topCenter,
                    child: PhotoPin(imageUrl: imageUrl),
                  ),
                  if (origin != null)
                    Marker(
                      point: origin!,
                      width: YouAreHereDot.size,
                      height: YouAreHereDot.size,
                      child: const YouAreHereDot(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── Arrival ───────────────────────────

class ArrivalPhase extends StatelessWidget {
  const ArrivalPhase({
    required this.state,
    required this.onCheckIn,
    required this.onRefresh,
    required this.onOpenSettings,
    super.key,
  });

  final TempleVisitState state;
  final VoidCallback onCheckIn;
  final VoidCallback onRefresh;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final temple = state.temple;
    final within = state.withinGeofence;
    final denied = _isDenied(state.locationStatus);
    final away = l10n.tvAwayFrom(formatDistance(state.distanceMeters));

    final location = temple?.location;

    return VisitPhaseBody(
      content: [
        _ArrivalHero(temple: temple, within: within),
        const Gap(AppSpacing.md),
        Text(
          within ? l10n.tvWelcomeTo : l10n.tvArrivalApproaching,
          textAlign: TextAlign.center,
          style: context.textTheme.titleSmall?.withColor(context.colors.textSecondary),
        ).fadeIn(),
        const Gap(AppSpacing.xxs),
        Text(
          temple?.name ?? '',
          textAlign: TextAlign.center,
          style: context.displayText.headlineSmall.withColor(context.scheme.secondary),
        ).fadeIn(delay: AppDurations.stagger * 2),
        if (location != null && location.isNotEmpty)
          Text(
            location,
            textAlign: TextAlign.center,
            style: context.caption.copyWith(color: context.colors.textSecondary),
          ).fadeIn(delay: AppDurations.stagger * 2),
        const Gap(AppSpacing.md),
        Center(
          child: within
              ? AppBadge(label: l10n.tvGeofenceInside, tone: AppBadgeTone.success, icon: AppIcons.verified)
              : AppBadge(label: away, tone: AppBadgeTone.warning, icon: AppIcons.location),
        ).scaleIn(delay: AppDurations.stagger * 3),
        const Gap(AppSpacing.lg),
        GoldRuleHeader(label: l10n.tvLocationChecks),
        const Gap(AppSpacing.sm),
        VisitLedger(
          rows: [
            LocationCheckRow(
              icon: AppIcons.location,
              label: within ? l10n.tvArrivalWithin : l10n.tvArrivalMoveCloser,
              sublabel: within ? l10n.tvGeofenceDetected : away,
              status: within ? CheckRowStatus.done : CheckRowStatus.failed,
            ),
            LocationCheckRow(
              icon: AppIcons.myLocation,
              label: l10n.tvAccuracy,
              sublabel: _accuracyLabel(l10n, state),
              status: _accuracyStatus(state),
            ),
          ],
        ).fadeIn(delay: AppDurations.stagger * 4),
        if (denied) ...[
          const Gap(AppSpacing.md),
          Text(
            l10n.tvLocationDenied,
            textAlign: TextAlign.center,
            style: context.caption.copyWith(color: context.scheme.error),
          ),
        ],
      ],
      actions: [
        if (denied)
          AppButton.primary(label: l10n.tvEnableLocation, icon: AppIcons.settings, onPressed: onOpenSettings)
        else
          AppButton.primary(
            label: l10n.tvImAtTheTemple,
            icon: AppIcons.temple,
            busy: state.capturing,
            onPressed: state.capturing ? null : onCheckIn,
          ),
        const Gap(AppSpacing.sm),
        AppButton.ghost(
          label: l10n.tvRefreshLocation,
          icon: AppIcons.refresh,
          onPressed: state.capturing ? null : onRefresh,
        ),
      ],
    );
  }
}

/// The temple in a framed photo, gold dust in the air and a location pin that
/// drops in and keeps pulsing — saffron, inside a gold ring for the sacred
/// area, once the devotee is within it.
class _ArrivalHero extends StatelessWidget {
  const _ArrivalHero({required this.temple, required this.within});

  final VisitTemple? temple;
  final bool within;

  static const double _height = 240;
  static const double _pin = 64;
  static const double _ring = _pin * 2.2;

  @override
  Widget build(BuildContext context) {
    final url = temple?.imageUrl;
    final accent = within ? context.scheme.primary : context.colors.textSecondary;
    final fallback = ColoredBox(color: context.colors.templeSand);
    return ClipRRect(
      borderRadius: AppRadius.xlAll,
      child: SizedBox(
        height: _height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (url == null) fallback else AppNetworkImage(url: url, fit: BoxFit.cover, fallback: fallback),
            // Only the foot of the photo melts into the page.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.6, 1],
                  colors: [context.scheme.surface.withValues(alpha: 0), context.scheme.surface],
                ),
              ),
            ),
            if (within) SparkleField(color: context.colors.gold, count: 22, burst: true),
            if (within)
              Center(
                child: Container(
                  width: _ring,
                  height: _ring,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.gold.withValues(alpha: 0.12),
                    border: Border.all(color: context.colors.gold.withValues(alpha: 0.8), width: 1.5),
                  ),
                ).scaleIn(delay: AppDurations.slow),
              ),
            Center(
              child: AppEntrance(
                duration: AppDurations.slow,
                curve: AppCurves.pop,
                fromOffset: const Offset(0, -_pin),
                child: GlowPulse(
                  color: accent,
                  radius: _pin,
                  child: Container(
                    width: _pin,
                    height: _pin,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.card,
                      border: Border.all(color: accent, width: 3),
                      boxShadow: AppShadows.md,
                    ),
                    child: Icon(AppIcons.location, size: _pin * 0.55, color: accent, fill: 1),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Check-in confirm ───────────────────────────

class CheckinPhase extends StatelessWidget {
  const CheckinPhase({
    required this.state,
    required this.onConfirm,
    required this.onRefresh,
    required this.onOpenSettings,
    super.key,
  });

  final TempleVisitState state;
  final VoidCallback onConfirm;
  final VoidCallback onRefresh;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final temple = state.temple;
    final within = state.withinGeofence;
    final denied = _isDenied(state.locationStatus);
    final canCheckIn = within && !denied;
    final rows = [
      LocationCheckRow(
        icon: AppIcons.myLocation,
        label: l10n.tvGpsLocation,
        sublabel: state.hasLocation ? l10n.tvVerified : l10n.tvGpsWaiting,
        status: state.hasLocation ? CheckRowStatus.done : CheckRowStatus.active,
      ),
      LocationCheckRow(
        icon: AppIcons.location,
        label: l10n.tvCurrentLocation,
        sublabel: within ? l10n.tvGeofenceInside : l10n.tvAwayFrom(formatDistance(state.distanceMeters)),
        status: within ? CheckRowStatus.done : CheckRowStatus.failed,
      ),
      LocationCheckRow(
        icon: AppIcons.navigation,
        label: l10n.tvAccuracy,
        sublabel: _accuracyLabel(l10n, state),
        status: _accuracyStatus(state),
      ),
      LocationCheckRow(
        icon: AppIcons.smartphone,
        label: l10n.tvDevice,
        sublabel: l10n.tvVerified,
        status: CheckRowStatus.done,
      ),
    ];

    return VisitPhaseBody(
      content: [
        VisitTempleBanner(
          label: l10n.tvCheckingInAt,
          name: temple?.name ?? '',
          location: temple?.location,
          imageUrl: temple?.imageUrl,
        ),
        const Gap(AppSpacing.lg),
        Center(
          child: _StampAwaiting(templeName: temple?.name ?? '', ready: canCheckIn),
        ),
        const Gap(AppSpacing.md),
        Text(
          l10n.tvConfirmArrival,
          textAlign: TextAlign.center,
          style: context.displayText.headlineSmall.withColor(context.scheme.secondary),
        ),
        const Gap(AppSpacing.xxs),
        Text(
          l10n.tvConfirmHint,
          textAlign: TextAlign.center,
          style: context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary),
        ),
        const Gap(AppSpacing.lg),
        GoldRuleHeader(label: l10n.tvVerificationChecks),
        const Gap(AppSpacing.sm),
        VisitLedger(rows: [for (final (i, row) in rows.indexed) row.fadeIn(delay: AppDurations.stagger * (i + 1))]),
      ],
      actions: [
        if (denied)
          AppButton.primary(label: l10n.tvEnableLocation, icon: AppIcons.settings, onPressed: onOpenSettings)
        else
          AppButton.primary(
            label: l10n.tvCheckInNow,
            icon: AppIcons.verified,
            busy: state.capturing,
            onPressed: canCheckIn && !state.capturing ? onConfirm : null,
          ),
        if (!within && !denied) ...[
          const Gap(AppSpacing.sm),
          AppButton.ghost(label: l10n.tvRefreshLocation, icon: AppIcons.refresh, onPressed: onRefresh),
        ],
        const Gap(AppSpacing.sm),
        Text(
          l10n.tvTermsNotice,
          textAlign: TextAlign.center,
          style: context.caption.copyWith(color: context.colors.textSecondary),
        ),
      ],
    );
  }
}

/// Today's passport stamp, faint and tilted, waiting to be struck — it glows
/// once every check passes.
class _StampAwaiting extends StatelessWidget {
  const _StampAwaiting({required this.templeName, required this.ready});

  final String templeName;
  final bool ready;

  static const double _size = 124;
  static const double _tilt = -0.12;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(DateTime.now());
    final stamp = Transform.rotate(
      angle: _tilt,
      child: AnimatedOpacity(
        opacity: ready ? 0.6 : 0.3,
        duration: AppDurations.normal,
        child: VisitStamp(templeName: templeName, date: date, color: context.scheme.primary, size: _size),
      ),
    );
    return ExcludeSemantics(
      child: ready ? GlowPulse(color: context.colors.gold, radius: _size * 0.6, child: stamp) : stamp,
    );
  }
}

// ─────────────────────────── Verifying ───────────────────────────

class VerifyingPhase extends StatefulWidget {
  const VerifyingPhase({required this.state, super.key});

  final TempleVisitState state;

  @override
  State<VerifyingPhase> createState() => _VerifyingPhaseState();
}

class _VerifyingPhaseState extends State<VerifyingPhase> with SingleTickerProviderStateMixin {
  // Paces the checklist across the verification floor the controller waits
  // out, so the last step is still running when the server answers.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final temple = widget.state.temple;
    final steps = <(IconData, String, String)>[
      (AppIcons.location, l10n.tvStepLocation, l10n.tvStepLocationSub),
      (AppIcons.smartphone, l10n.tvStepDevice, l10n.tvStepDeviceSub),
      (AppIcons.route, l10n.tvStepRoute, l10n.tvStepRouteSub),
      (AppIcons.history, l10n.tvStepHistory, l10n.tvStepHistorySub),
      (AppIcons.passport, l10n.tvStepPassport, l10n.tvStepPassportSub),
      (AppIcons.verified, l10n.tvStepFinalize, l10n.tvStepFinalizeSub),
    ];

    return SafeArea(
      child: ListView(
        padding: AppSpacing.screenAll,
        children: [
          VisitTempleBanner(
            label: l10n.tvCheckingInAt,
            name: temple?.name ?? '',
            location: temple?.location,
            imageUrl: temple?.imageUrl,
          ),
          const Gap(AppSpacing.lg),
          ParchmentCard(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final active = (_controller.value * steps.length).floor().clamp(0, steps.length - 1);
                return Column(
                  children: [
                    for (final (i, (icon, title, sub)) in steps.indexed)
                      VerificationStep(
                        icon: icon,
                        title: title,
                        subtitle: sub,
                        status: i < active
                            ? CheckRowStatus.done
                            : i == active
                            ? CheckRowStatus.active
                            : CheckRowStatus.pending,
                        isLast: i == steps.length - 1,
                      ),
                  ],
                );
              },
            ),
          ),
          const Gap(AppSpacing.md),
          Container(
            padding: AppSpacing.allMd,
            decoration: BoxDecoration(
              color: context.palette.heroCream,
              borderRadius: AppRadius.card,
              border: Border.all(color: context.colors.gold.withValues(alpha: 0.4)),
            ),
            child: Text(
              l10n.tvVerifyingWait,
              textAlign: TextAlign.center,
              style: context.caption.copyWith(color: context.colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── shared helpers ───────────────────────────

bool _isDenied(LocationStatus? status) =>
    status == LocationStatus.denied ||
    status == LocationStatus.deniedForever ||
    status == LocationStatus.serviceDisabled;

String _accuracyLabel(AppLocalizations l10n, TempleVisitState state) {
  final a = state.location?.accuracyMeters;
  if (a == null) return l10n.tvAccuracyUnknown;
  final level = switch (state.accuracyLevel) {
    LocationAccuracyLevel.high => l10n.tvAccuracyHigh,
    LocationAccuracyLevel.medium => l10n.tvAccuracyMedium,
    LocationAccuracyLevel.low => l10n.tvAccuracyLow,
    LocationAccuracyLevel.unknown => l10n.tvAccuracyUnknown,
  };
  return '$level (${formatDistance(a)})';
}

CheckRowStatus _accuracyStatus(TempleVisitState state) {
  switch (state.accuracyLevel) {
    case LocationAccuracyLevel.high:
    case LocationAccuracyLevel.medium:
      return CheckRowStatus.done;
    case LocationAccuracyLevel.low:
      return CheckRowStatus.failed;
    case LocationAccuracyLevel.unknown:
      return CheckRowStatus.active;
  }
}
