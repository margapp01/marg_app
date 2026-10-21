import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/route_detail_bundle.dart';
import '../../domain/entities/yatra_route.dart';
import 'route_map_schematic.dart';

/// An embedded map of a route on the shared [BharatMap]: round temple
/// markers numbered in route order and coloured by completion, joined by fine
/// dashed arcs with a direction chevron on each leg. The arcs follow one
/// geographic trail through neighbouring temples ([ArcPath.trailOrder]) so the
/// line never zig-zags across the country, while the numbers keep the route's
/// own order. Legs between two completed temples turn green; the next stop
/// (and the first few completed ones) carry a name tag. Falls back to the
/// self-painted schematic when fewer than two temples carry coordinates.
class RouteMapView extends StatelessWidget {
  const RouteMapView({required this.bundle, this.height = 320, super.key});

  final RouteDetailBundle bundle;
  final double height;

  /// Dash, gap (logical pixels) — short and tight, like a pencilled route.
  static const List<double> _dash = [6, 5];
  static const double _lineWidth = 2.2;
  static const double _pin = 40;
  static const double _nextPin = 52;
  static const double _arrow = 12;
  static const double _tagWidth = 150;
  static const double _tagHeight = 28;

  /// Completed stops are named only while they're few enough not to crowd.
  static const int _maxCompletedTags = 3;

  @override
  Widget build(BuildContext context) {
    final entries = bundle.route.temples
        .where((t) => !(t.temple.latitude == 0 && t.temple.longitude == 0))
        .toList(growable: false);

    if (entries.length < 2) {
      // Not enough located temples for a real map — keep the honest schematic.
      return RouteMapSchematic(bundle: bundle, height: height);
    }

    final points = [for (final e in entries) LatLng(e.temple.latitude, e.temple.longitude)];
    final statuses = [for (final e in entries) bundle.statusOf(e)];
    final stopNumber = {for (final (i, t) in bundle.route.temples.indexed) t.temple.id: i + 1};
    final walked = context.colors.success;
    final ahead = context.scheme.secondary.withValues(alpha: 0.55);

    final trail = ArcPath.trailOrder(points);
    final hops = [for (var i = 1; i < trail.length; i++) (from: trail[i - 1], to: trail[i])];

    // A leg is walked once both of its temples are done.
    bool isWalked(({int from, int to}) hop) =>
        statuses[hop.from] == TempleJourneyStatus.completed && statuses[hop.to] == TempleJourneyStatus.completed;

    final legs = [
      for (final hop in hops)
        Polyline(
          points: ArcPath.geo([points[hop.from], points[hop.to]]),
          strokeWidth: _lineWidth,
          color: isWalked(hop) ? walked : ahead,
          strokeCap: StrokeCap.round,
          pattern: StrokePattern.dashed(segments: _dash),
        ),
    ];
    final arrows = [
      for (final hop in hops)
        if (ArcPath.midpoint(points[hop.from], points[hop.to]) case (:final point, :final angle))
          Marker(
            point: point,
            width: _arrow,
            height: _arrow,
            child: Transform.rotate(
              angle: angle,
              child: CustomPaint(painter: _Chevron(isWalked(hop) ? walked : context.scheme.primary, context.colors.card)),
            ),
          ),
    ];

    // The next stop is drawn last (on top) and larger.
    final order = [for (var i = 0; i < entries.length; i++) i]
      ..sort((a, b) => (statuses[a] == TempleJourneyStatus.current ? 1 : 0)
          .compareTo(statuses[b] == TempleJourneyStatus.current ? 1 : 0));
    final completed = statuses.where((s) => s == TempleJourneyStatus.completed).length;
    bool tagged(int i) =>
        statuses[i] == TempleJourneyStatus.current ||
        (statuses[i] == TempleJourneyStatus.completed && completed <= _maxCompletedTags);

    return ClipRRect(
      borderRadius: AppRadius.lgAll,
      child: SizedBox(
        height: height,
        child: RepaintBoundary(
          child: BharatMap(
            options: MapOptions(
              initialCameraFit: CameraFit.coordinates(
                coordinates: points,
                padding: const EdgeInsets.fromLTRB(40, 96, 40, 40),
              ),
              interactionOptions: BharatMap.interaction,
            ),
            layers: [
              PolylineLayer(polylines: legs),
              MarkerLayer(markers: arrows),
              MarkerLayer(
                markers: [
                  for (final i in order)
                    _pinMarker(context, entries[i], points[i], statuses[i], stopNumber[entries[i].temple.id] ?? i + 1),
                ],
              ),
              MarkerLayer(
                markers: [
                  for (final i in order)
                    if (tagged(i)) _tagMarker(context, entries[i], points[i], statuses[i]),
                ],
              ),
              const _Legend(),
            ],
          ),
        ),
      ),
    );
  }

  static double _sizeFor(TempleJourneyStatus status) => status == TempleJourneyStatus.current ? _nextPin : _pin;

  static Color _colorFor(BuildContext context, TempleJourneyStatus status) => switch (status) {
        TempleJourneyStatus.completed => context.colors.success,
        TempleJourneyStatus.current => context.scheme.primary,
        TempleJourneyStatus.remaining => context.colors.textDisabled,
      };

  Marker _pinMarker(BuildContext context, RouteTempleEntry entry, LatLng point, TempleJourneyStatus status, int stop) {
    final size = _sizeFor(status);
    return Marker(
      point: point,
      width: size,
      height: size,
      child: PhotoPin(
        imageUrl: entry.temple.imageUrl,
        size: size,
        selected: status == TempleJourneyStatus.current,
        color: _colorFor(context, status),
        badge: '$stop',
        tail: false,
      ),
    );
  }

  /// A white name tag just right of the round marker.
  Marker _tagMarker(BuildContext context, RouteTempleEntry entry, LatLng point, TempleJourneyStatus status) {
    final size = _sizeFor(status);
    return Marker(
      point: point,
      width: _tagWidth,
      height: _tagHeight,
      // Place the coordinate left of the tag, level with the marker's centre.
      alignment: Marker.computePixelAlignment(
        width: _tagWidth,
        height: _tagHeight,
        left: -(size / 2 + AppSpacing.xs),
        top: _tagHeight / 2,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
          decoration: BoxDecoration(
            color: context.colors.card,
            borderRadius: AppRadius.fullAll,
            boxShadow: AppShadows.sm,
          ),
          child: Text(
            entry.temple.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelMedium?.bold.withColor(context.scheme.secondary),
          ),
        ),
      ),
    );
  }
}

/// A small filled arrowhead pointing right (rotated by the caller), with a
/// light edge so it reads on any tile.
class _Chevron extends CustomPainter {
  const _Chevron(this.color, this.edge);
  final Color color;
  final Color edge;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final path = Path()
      ..moveTo(w * 0.15, h * 0.12)
      ..lineTo(w * 0.9, h * 0.5)
      ..lineTo(w * 0.15, h * 0.88)
      ..lineTo(w * 0.35, h * 0.5)
      ..close();
    canvas
      ..drawPath(
        path,
        Paint()
          ..color = edge
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeJoin = StrokeJoin.round,
      )
      ..drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_Chevron old) => old.color != color || old.edge != edge;
}

/// Completed / next / upcoming, as a small card over the map's top-right.
class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget row(Color color, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const Gap.h(AppSpacing.xs),
            Text(label, style: context.caption.copyWith(color: context.scheme.secondary)),
          ],
        );
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        margin: AppSpacing.allSm,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: context.colors.card.withValues(alpha: 0.94),
          borderRadius: AppRadius.mdAll,
          boxShadow: AppShadows.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.xxs,
          children: [
            row(context.colors.success, l10n.ryStatusCompleted),
            row(context.scheme.primary, l10n.ryStatusCurrent),
            row(context.colors.textDisabled, l10n.ryStatusUpcoming),
          ],
        ),
      ),
    );
  }
}
