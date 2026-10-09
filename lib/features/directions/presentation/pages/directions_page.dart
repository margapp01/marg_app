import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../core/geo/map_launcher.dart';
import '../../../../core/location/location_access.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/design_system.dart';
import '../../domain/route_plan.dart';
import '../controllers/directions_controller.dart';
import '../travel_mode_ui.dart';

/// In-app directions to a temple: the road route on a street map, live
/// position (re-routing when the pilgrim strays), time / distance / arrival
/// time, Drive or Walk, turn-by-turn steps, and "Open in Maps" as a fallback.
/// On arrival it offers the check-in.
class DirectionsPage extends ConsumerStatefulWidget {
  const DirectionsPage({required this.args, super.key});

  final DirectionsArgs args;

  @override
  ConsumerState<DirectionsPage> createState() => _DirectionsPageState();
}

class _DirectionsPageState extends ConsumerState<DirectionsPage> {
  final _map = MapController();
  bool _mapReady = false;
  bool _fitted = false;

  static const double _initialZoom = 13;
  static const double _followZoom = 16.5;

  /// Screen-space room kept clear of the top bar and the bottom panel when
  /// framing the route.
  static const EdgeInsets _fitPadding = EdgeInsets.fromLTRB(56, 120, 56, 340);

  AutoDisposeFamilyNotifierProvider<DirectionsController, DirectionsState, DirectionsArgs> get _provider =>
      directionsProvider(widget.args);

  void _onState(DirectionsState? previous, DirectionsState next) {
    if (!_mapReady) return;
    final origin = next.origin;
    if (next.following && origin != null) {
      _map.move(origin, math.max(_map.camera.zoom, _followZoom));
    } else if (!_fitted && next.plan.hasValue) {
      _fitRoute(next);
    }
  }

  void _fitRoute(DirectionsState s) {
    final points = [...?s.plan.valueOrNull?.points, ?s.origin, widget.args.point];
    if (points.length < 2) return;
    _fitted = true;
    _map.fitCamera(CameraFit.coordinates(coordinates: points, padding: _fitPadding, maxZoom: _followZoom));
  }

  void _recenter(DirectionsState s) {
    final origin = s.origin;
    if (origin == null) return;
    ref.read(_provider.notifier).setFollowing(on: true);
    _map.move(origin, math.max(_map.camera.zoom, _followZoom));
  }

  void _showRoute(DirectionsState s) {
    ref.read(_provider.notifier).setFollowing(on: false);
    _fitRoute(s);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = ref.watch(_provider);
    ref.listen(_provider, _onState);
    final plan = s.plan.valueOrNull;
    final saffron = context.scheme.primary;

    return Scaffold(
      backgroundColor: context.scheme.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: BharatMap(
              controller: _map,
              tiles: MapTiles.streets,
              showBoundaries: false,
              attributionAlignment: Alignment.topRight,
              options: MapOptions(
                initialCenter: widget.args.point,
                initialZoom: _initialZoom,
                interactionOptions: BharatMap.interaction,
                onMapReady: () {
                  _mapReady = true;
                  _onState(null, ref.read(_provider));
                },
                onPositionChanged: (_, hasGesture) {
                  if (hasGesture && ref.read(_provider).following) {
                    ref.read(_provider.notifier).setFollowing(on: false);
                  }
                },
              ),
              layers: [
                if (plan != null && plan.points.length > 1)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: plan.points,
                        strokeWidth: 6,
                        color: saffron,
                        borderStrokeWidth: 3,
                        borderColor: context.colors.card,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: widget.args.point,
                      width: PhotoPin.widthFor(PhotoPin.defaultSize),
                      height: PhotoPin.heightFor(PhotoPin.defaultSize),
                      alignment: Alignment.topCenter,
                      child: PhotoPin(imageUrl: widget.args.imageUrl),
                    ),
                    if (s.origin != null)
                      Marker(point: s.origin!, width: YouAreHereDot.size, height: YouAreHereDot.size, child: const YouAreHereDot()),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: AppSpacing.allMd,
                child: _MapButton(
                  icon: AppIcons.back,
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  onTap: () => context.canPop() ? context.pop() : context.goNamed(RouteNames.home),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, AppSpacing.md, AppSpacing.sm),
                  child: Column(
                    children: [
                      if (plan != null) ...[
                        _MapButton(icon: AppIcons.fitRoute, tooltip: l10n.dirShowRoute, onTap: () => _showRoute(s)),
                        const Gap(AppSpacing.sm),
                      ],
                      if (s.origin != null)
                        _MapButton(
                          icon: AppIcons.myLocation,
                          tooltip: l10n.dirMyLocation,
                          active: s.following,
                          onTap: () => _recenter(s),
                        ),
                    ],
                  ),
                ),
                _Panel(args: widget.args),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The bottom card: destination, then whichever state applies — locating,
/// location needed, finding a route, the route summary, no route, or arrived.
class _Panel extends ConsumerWidget {
  const _Panel({required this.args});

  final DirectionsArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final s = ref.watch(directionsProvider(args));
    final controller = ref.read(directionsProvider(args).notifier);

    final Widget body;
    if (s.access == null || (s.access == LocationAccess.granted && s.origin == null && s.plan.isLoading)) {
      body = _Status(key: const ValueKey('locating'), text: l10n.dirLocating);
    } else if (s.access != LocationAccess.granted) {
      body = _Message(
        key: const ValueKey('location'),
        icon: AppIcons.location,
        title: l10n.dirNeedLocationTitle,
        body: l10n.dirNeedLocationBody(args.name),
        action: AppButton.primary(
          label: l10n.locAllow,
          icon: AppIcons.myLocation,
          onPressed: () async {
            if (await LocationPermissionSheet.show(context)) await controller.start();
          },
        ),
      );
    } else if (s.arrived) {
      body = _Arrived(key: const ValueKey('arrived'), args: args);
    } else {
      body = s.plan.when(
        skipLoadingOnRefresh: false,
        skipLoadingOnReload: true,
        loading: () => s.plan.hasValue
            ? _Summary(key: const ValueKey('summary'), args: args, plan: s.plan.value!, state: s, busy: true)
            : _Status(key: const ValueKey('routing'), text: l10n.dirFinding),
        error: (_, _) => _Message(
          key: const ValueKey('error'),
          icon: AppIcons.route,
          title: l10n.dirNoRouteTitle,
          body: l10n.dirNoRouteBody,
          action: Row(
            children: [
              Expanded(child: AppButton.primary(label: l10n.commonRetry, onPressed: controller.retry)),
              const Gap.h(AppSpacing.sm),
              Expanded(
                child: AppButton.outlined(
                  label: l10n.dirOpenInMaps,
                  onPressed: () => openExternalDirections(latitude: args.latitude, longitude: args.longitude),
                ),
              ),
            ],
          ),
        ),
        data: (plan) => _Summary(key: const ValueKey('summary'), args: args, plan: plan, state: s),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        boxShadow: AppShadows.lg,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Destination(args: args),
              const Gap(AppSpacing.md),
              AnimatedSize(
                duration: AppDurations.normal,
                curve: AppCurves.standard,
                alignment: Alignment.topCenter,
                child: AnimatedSwitcher(duration: AppDurations.normal, child: body),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Destination extends StatelessWidget {
  const _Destination({required this.args});
  final DirectionsArgs args;

  static const double _thumb = 48;

  @override
  Widget build(BuildContext context) {
    final sand = ColoredBox(
      color: context.colors.templeSand,
      child: Icon(AppIcons.temple, color: context.colors.templeStone),
    );
    return Row(
      children: [
        ClipRRect(
          borderRadius: AppRadius.mdAll,
          child: SizedBox.square(
            dimension: _thumb,
            child: args.imageUrl == null ? sand : AppNetworkImage(url: args.imageUrl!, fit: BoxFit.cover, fallback: sand),
          ),
        ),
        const Gap.h(AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                args.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.displayText.titleLarge.withColor(context.scheme.secondary),
              ),
              if (args.place != null)
                Text(
                  args.place!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.caption.copyWith(color: context.colors.textSecondary),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Time, distance and arrival time (live as the pilgrim moves), the travel
/// mode, and the Start / steps / external-maps actions.
class _Summary extends ConsumerWidget {
  const _Summary({required this.args, required this.plan, required this.state, this.busy = false, super.key});

  final DirectionsArgs args;
  final RoutePlan plan;
  final DirectionsState state;
  final bool busy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(directionsProvider(args).notifier);
    final origin = state.origin;
    final seconds = origin == null ? plan.durationSeconds : plan.remainingSeconds(origin);
    final meters = origin == null ? plan.distanceMeters : plan.remainingMeters(origin);
    final arriveAt = DateTime.now().add(Duration(seconds: seconds.round()));
    final clock = DateFormat.jm(Localizations.localeOf(context).toLanguageTag()).format(arriveAt);
    final modes = state.modes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PillTabs(
          labels: [for (final m in modes) travelModeLabel(l10n, m)],
          selected: modes.indexOf(state.mode),
          onChanged: (i) => controller.setMode(modes[i]),
        ),
        const Gap(AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatTravelTime(l10n, seconds),
                    style: context.displayText.headlineSmall.withColor(context.colors.success),
                  ),
                  Text(
                    [formatDistance(meters), if (plan.summary != null) l10n.dirVia(plan.summary!)].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.withColor(context.colors.textSecondary),
                  ),
                ],
              ),
            ),
            if (busy)
              const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
            else
              AppBadge(label: l10n.dirArriveBy(clock), icon: AppIcons.flag, tone: AppBadgeTone.primary),
          ],
        ),
        const Gap(AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppButton.primary(
                label: state.following ? l10n.dirStop : l10n.dirStart,
                icon: state.following ? AppIcons.close : AppIcons.navigation,
                onPressed: () => controller.setFollowing(on: !state.following),
              ),
            ),
            if (plan.steps.isNotEmpty) ...[
              const Gap.h(AppSpacing.sm),
              AppIconButton(
                icon: AppIcons.stepsList,
                tooltip: l10n.dirSteps,
                variant: AppIconButtonVariant.outlined,
                onPressed: () => _showSteps(context, plan),
              ),
            ],
            const Gap.h(AppSpacing.sm),
            AppIconButton(
              icon: AppIcons.openExternal,
              tooltip: l10n.dirOpenInMaps,
              variant: AppIconButtonVariant.outlined,
              onPressed: () => openExternalDirections(latitude: args.latitude, longitude: args.longitude),
            ),
          ],
        ),
      ],
    );
  }

  void _showSteps(BuildContext context, RoutePlan plan) {
    final l10n = AppLocalizations.of(context);
    AppSheets.show<void>(
      context,
      padded: false,
      builder: (context) => AppSheetLayout(
        title: l10n.dirSteps,
        subtitle: [formatTravelTime(l10n, plan.durationSeconds), formatDistance(plan.distanceMeters)].join(' · '),
        child: Column(
          children: [
            for (final (i, step) in plan.steps.indexed) ...[
              if (i > 0) const AppDivider(),
              _StepRow(step: step),
            ],
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step});
  final RouteStep step;

  IconData get _icon => switch ((step.maneuver, step.modifier)) {
        ('arrive', _) => AppIcons.flag,
        ('roundabout' || 'rotary' || 'roundabout turn', _) => AppIcons.roundabout,
        (_, 'uturn') => AppIcons.uTurn,
        (_, 'slight left') => AppIcons.turnSlightLeft,
        (_, 'slight right') => AppIcons.turnSlightRight,
        (_, 'left' || 'sharp left') => AppIcons.turnLeft,
        (_, 'right' || 'sharp right') => AppIcons.turnRight,
        _ => AppIcons.straight,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          IllustratedIcon(fallbackIcon: _icon, color: context.scheme.secondary, size: 36),
          const Gap.h(AppSpacing.md),
          Expanded(child: Text(step.instruction, style: context.textTheme.bodyMedium)),
          const Gap.h(AppSpacing.sm),
          Text(formatDistance(step.distanceMeters), style: context.caption.copyWith(color: context.colors.textSecondary)),
        ],
      ),
    );
  }
}

class _Arrived extends StatelessWidget {
  const _Arrived({required this.args, super.key});
  final DirectionsArgs args;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final slug = args.templeSlug;
    return _Message(
      icon: AppIcons.verified,
      color: context.colors.success,
      title: l10n.dirArrivedTitle,
      body: l10n.dirArrivedBody(args.name),
      action: slug == null
          ? AppButton.primary(label: l10n.dirDone, onPressed: () => context.pop())
          : AppButton.primary(
              label: l10n.dirCheckIn,
              icon: AppIcons.verified,
              onPressed: () => args.returnOnArrival
                  ? context.pop()
                  : context.pushReplacementNamed(
                      RouteNames.templeVisit,
                      pathParameters: {RoutePaths.templeIdParam: slug},
                    ),
            ),
    );
  }
}

/// A spinner with a line of status text.
class _Status extends StatelessWidget {
  const _Status({required this.text, super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          const Gap.h(AppSpacing.md),
          Flexible(child: Text(text, style: context.textTheme.bodyMedium?.withColor(context.colors.textSecondary))),
        ],
      ),
    );
  }
}

/// Icon, title, one line and an action — the panel's non-route states.
class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.title, required this.body, required this.action, this.color, super.key});

  final IconData icon;
  final String title;
  final String body;
  final Widget action;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IllustratedIcon(fallbackIcon: icon, color: color ?? context.scheme.primary, size: 44),
            const Gap.h(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.textTheme.titleSmall?.semiBold.withColor(context.scheme.secondary)),
                  Text(body, style: context.textTheme.bodySmall?.withColor(context.colors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
        const Gap(AppSpacing.md),
        action,
      ],
    );
  }
}

/// A round floating map control.
class _MapButton extends StatelessWidget {
  const _MapButton({required this.icon, required this.tooltip, required this.onTap, this.active = false});

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool active;

  static const double _size = 48;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: active ? context.scheme.secondary : context.colors.card,
        shape: const CircleBorder(),
        elevation: 3,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox.square(
            dimension: _size,
            child: Icon(icon, color: active ? context.colors.card : context.scheme.secondary),
          ),
        ),
      ),
    );
  }
}
