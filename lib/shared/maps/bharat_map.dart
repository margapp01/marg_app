import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/config/app_config.dart';
import '../../app/constants/app_constants.dart';
import '../../app/localization/app_localizations.dart';
import '../../app/theme/theme.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/geo/bharat_boundaries.dart';

/// Base map style for a [BharatMap].
enum MapTiles {
  /// OpenStreetMap warmed to the cream theme — overviews and browsing.
  warm,

  /// Street-level detail (Mapbox Streets when a token is configured, plain
  /// OpenStreetMap otherwise) — for directions.
  streets,
}

/// The one map used across MARG: OpenStreetMap tiles warmed to the app's
/// palette, the Akhand Bharat outline (saffron, with everything beyond it
/// softly washed out) and Bharat's official boundary (navy) — then the
/// feature's own [layers] (route polylines, temple markers…) on top.
///
/// Features pass their [MapOptions]; use [interaction] for the standard
/// north-up pan + zoom gestures.
class BharatMap extends ConsumerWidget {
  const BharatMap({
    required this.options,
    this.controller,
    this.layers = const [],
    this.showBoundaries = true,
    this.tiles = MapTiles.warm,
    this.attributionAlignment = Alignment.bottomRight,
    super.key,
  });

  final MapOptions options;
  final MapController? controller;

  /// Feature layers drawn above the tiles and boundaries.
  final List<Widget> layers;
  final bool showBoundaries;
  final MapTiles tiles;

  /// Corner for the OpenStreetMap credit — move it clear of the screen's own
  /// overlays (bottom sheets, banners).
  final Alignment attributionAlignment;

  /// Pan + pinch / double-tap zoom, no rotation.
  static const InteractionOptions interaction = InteractionOptions(
    flags:
        InteractiveFlag.pinchZoom |
        InteractiveFlag.drag |
        InteractiveFlag.doubleTapZoom,
  );

  /// Slightly desaturated, warm tiles so the map sits in the cream theme
  /// instead of OSM's saturated defaults. No offset column — offsets render
  /// inconsistently under Impeller.
  static const ColorFilter _warmTiles = ColorFilter.matrix(<double>[
    0.8425, 0.1430, 0.0144, 0, 0, //
    0.0417, 0.9242, 0.0142, 0, 0, //
    0.0400, 0.1345, 0.7656, 0, 0, //
    0, 0, 0, 1, 0, //
  ]);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boundaries = showBoundaries
        ? ref.watch(bharatBoundariesProvider).valueOrNull
        : null;
    final token = ref.watch(appConfigProvider).mapboxToken;
    final mapbox = tiles == MapTiles.streets && token.isNotEmpty;
    return FlutterMap(
      mapController: controller,
      options: options,
      children: [
        if (mapbox)
          TileLayer(
            urlTemplate: AppConstants.mapboxStreetsTileUrl,
            additionalOptions: {'accessToken': token},
            userAgentPackageName: AppConstants.mapUserAgent,
          )
        else
          TileLayer(
            urlTemplate: AppConstants.osmTileUrl,
            userAgentPackageName: AppConstants.mapUserAgent,
            tileBuilder: tiles == MapTiles.warm
                ? (context, tile, _) =>
                      ColorFiltered(colorFilter: _warmTiles, child: tile)
                : null,
          ),
        if (boundaries != null) _BoundaryLayers(boundaries: boundaries),
        ...layers,
        _Attribution(alignment: attributionAlignment, mapbox: mapbox),
      ],
    );
  }
}

/// The required OpenStreetMap credit as a small frosted pill.
class _Attribution extends StatelessWidget {
  const _Attribution({required this.alignment, required this.mapbox});

  final Alignment alignment;
  final bool mapbox;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: alignment,
        child: Container(
          margin: const EdgeInsets.all(AppSpacing.xs),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: context.colors.card.withValues(alpha: 0.75),
            borderRadius: AppRadius.fullAll,
          ),
          child: Text(
            mapbox ? '© Mapbox © OpenStreetMap' : '© OpenStreetMap',
            style: context.overline.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

typedef _BoundaryStyle = ({
  Color saffron,
  Color navy,
  Color wash,
  TextStyle label,
  String labelText,
});

/// Akhand Bharat + Bharat polygons. Built once per data/theme (not per frame —
/// this widget rebuilds on every camera move) so flutter_map keeps its
/// projection cache.
class _BoundaryLayers extends StatefulWidget {
  const _BoundaryLayers({required this.boundaries});

  final BharatBoundaries boundaries;

  @override
  State<_BoundaryLayers> createState() => _BoundaryLayersState();
}

class _BoundaryLayersState extends State<_BoundaryLayers> {
  /// Above this zoom the label would sit over temples and streets.
  static const double _labelMaxZoom = 5.5;

  _BoundaryStyle? _style;
  List<Polygon> _akhand = const [];
  List<Polygon> _akhandLabelled = const [];
  List<Polygon> _india = const [];

  @override
  void didUpdateWidget(_BoundaryLayers oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.boundaries, widget.boundaries)) _style = null;
  }

  void _ensurePolygons(_BoundaryStyle style) {
    if (style == _style) return;
    _style = style;
    Polygon akhand(BoundaryShape s, {String? label}) => Polygon(
      points: s.outer,
      holePointsList: s.holes,
      color: style.saffron.withValues(alpha: 0.10),
      borderColor: style.saffron.withValues(alpha: 0.9),
      borderStrokeWidth: 2.4,
      strokeJoin: StrokeJoin.round,
      label: label,
      labelStyle: style.label,
      labelPlacementCalculator:
          const PolygonLabelPlacementCalculator.polylabel(),
    );
    final shapes = widget.boundaries.akhandBharat;
    _akhand = [for (final s in shapes) akhand(s)];
    _akhandLabelled = [
      if (shapes.isNotEmpty) akhand(shapes.first, label: style.labelText),
      for (final s in shapes.skip(1)) akhand(s),
    ];
    _india = [
      for (final s in widget.boundaries.india)
        Polygon(
          points: s.outer,
          holePointsList: s.holes,
          color: style.saffron.withValues(alpha: 0.06),
          borderColor: style.navy.withValues(alpha: 0.55),
          borderStrokeWidth: 1.2,
          strokeJoin: StrokeJoin.round,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final saffron = context.palette.accentSaffron;
    _ensurePolygons((
      saffron: saffron,
      navy: context.scheme.secondary,
      wash: context.colors.card.withValues(alpha: 0.4),
      label: (context.textTheme.labelLarge ?? const TextStyle()).semiBold
          .copyWith(
            color: Color.lerp(saffron, context.scheme.secondary, 0.35),
            letterSpacing: 2,
          ),
      labelText: AppLocalizations.of(context).mapAkhandBharat.toUpperCase(),
    ));
    final zoom = MapCamera.of(context).zoom;
    return Stack(
      children: [
        PolygonLayer(
          polygons: zoom < _labelMaxZoom ? _akhandLabelled : _akhand,
          invertedFill: _style!.wash,
        ),
        PolygonLayer(polygons: _india, polygonLabels: false),
      ],
    );
  }
}
