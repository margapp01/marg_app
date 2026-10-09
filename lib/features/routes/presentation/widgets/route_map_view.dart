import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/route_detail_bundle.dart';
import '../../domain/entities/yatra_route.dart';
import 'route_map_schematic.dart';

/// An embedded map of a route on the shared [BharatMap]: temple markers
/// coloured by completion + a connecting polyline. Falls back to the
/// self-painted schematic when fewer than two temples carry coordinates.
class RouteMapView extends StatelessWidget {
  const RouteMapView({required this.bundle, this.height = 320, super.key});

  final RouteDetailBundle bundle;
  final double height;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entries = bundle.route.temples
        .where((t) => !(t.temple.latitude == 0 && t.temple.longitude == 0))
        .toList(growable: false);

    if (entries.length < 2) {
      // Not enough located temples for a real map — keep the honest schematic.
      return RouteMapSchematic(bundle: bundle, height: height);
    }

    final points = [for (final e in entries) LatLng(e.temple.latitude, e.temple.longitude)];
    // The next stop is drawn last (on top) and larger.
    final order = [for (var i = 0; i < entries.length; i++) i]
      ..sort((a, b) => (bundle.statusOf(entries[a]) == TempleJourneyStatus.current ? 1 : 0)
          .compareTo(bundle.statusOf(entries[b]) == TempleJourneyStatus.current ? 1 : 0));
    final markers = [
      for (final i in order) _marker(context, entries[i], points[i]),
    ];

    return Column(
      children: [
        ClipRRect(
          borderRadius: AppRadius.lgAll,
          child: SizedBox(
            height: height,
            child: RepaintBoundary(
              child: BharatMap(
                options: MapOptions(
                  initialCameraFit: CameraFit.coordinates(
                    coordinates: points,
                    padding: const EdgeInsets.fromLTRB(44, 72, 44, 32),
                  ),
                  interactionOptions: BharatMap.interaction,
                ),
                layers: [
                  PolylineLayer(
                    polylines: [
                      // Navy with a white edge so the route reads clearly
                      // against the saffron Akhand Bharat outline.
                      Polyline(
                        points: points,
                        strokeWidth: 3,
                        color: context.scheme.secondary,
                        borderStrokeWidth: 1.5,
                        borderColor: context.colors.card,
                      ),
                    ],
                  ),
                  MarkerLayer(markers: markers),
                ],
              ),
            ),
          ),
        ),
        const Gap(AppSpacing.sm),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.xs,
          children: [
            _Legend(color: context.colors.success, label: l10n.ryStatusCompleted),
            _Legend(color: context.scheme.primary, label: l10n.ryStatusCurrent),
            _Legend(color: context.colors.textDisabled, label: l10n.ryStatusUpcoming),
          ],
        ),
      ],
    );
  }

  static const double _pin = 40;
  static const double _nextPin = 52;

  Marker _marker(BuildContext context, RouteTempleEntry entry, LatLng point) {
    final status = bundle.statusOf(entry);
    final size = status == TempleJourneyStatus.current ? _nextPin : _pin;
    return Marker(
      point: point,
      width: PhotoPin.widthFor(size),
      height: PhotoPin.heightFor(size),
      alignment: Alignment.topCenter,
      child: PhotoPin(
        imageUrl: entry.temple.imageUrl,
        size: size,
        selected: status == TempleJourneyStatus.current,
        color: switch (status) {
          TempleJourneyStatus.completed => context.colors.success,
          TempleJourneyStatus.current => context.scheme.primary,
          TempleJourneyStatus.remaining => context.colors.textDisabled,
        },
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const Gap(AppSpacing.xxs),
        Text(label, style: context.caption.copyWith(color: context.colors.textSecondary)),
      ],
    );
  }
}
