import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/passport_lists.dart';
import '../controllers/passport_controllers.dart';

/// A temple on the passport map — its visits folded into one pin.
class _Place {
  _Place(this.point);

  final VisitPoint point;
  int visits = 1;
  bool verified = false;

  LatLng get latLng => LatLng(point.latitude, point.longitude);
}

/// Passport Map — every temple visited as a photo pin (green when verified,
/// saffron while pending) with the journey's numbers on top and a swipeable
/// strip of the temples below: swipe or tap a pin to fly there, tap a card
/// to open the temple.
class PassportMapPage extends ConsumerStatefulWidget {
  const PassportMapPage({super.key});

  @override
  ConsumerState<PassportMapPage> createState() => _PassportMapPageState();
}

class _PassportMapPageState extends ConsumerState<PassportMapPage> {
  final _map = MapController();
  final _pages = PageController(viewportFraction: 0.86);
  int? _selected;

  static const double _pin = 44;
  static const double _selectedPin = 60;
  static const double _stripHeight = 104;
  static const double _focusZoom = 7;
  static const double _fitMaxZoom = 9;

  /// Room for the stats card above and the attribution below.
  static const EdgeInsets _fitPadding = EdgeInsets.fromLTRB(48, 120, 48, 56);

  @override
  void dispose() {
    _map.dispose();
    _pages.dispose();
    super.dispose();
  }

  static List<_Place> _fold(List<VisitPoint> points) {
    final byTemple = <String, _Place>{};
    for (final p in points) {
      final place = byTemple.putIfAbsent(p.slug ?? '${p.latitude},${p.longitude}', () => _Place(p));
      if (!identical(place.point, p)) place.visits++;
      place.verified = place.verified || p.verified;
    }
    return byTemple.values.toList();
  }

  CameraFit _fitAll(List<_Place> places) => CameraFit.coordinates(
        coordinates: [for (final p in places) p.latLng],
        padding: _fitPadding,
        maxZoom: _fitMaxZoom,
      );

  void _focus(List<_Place> places, int i, {bool syncStrip = false}) {
    setState(() => _selected = i);
    _map.move(places[i].latLng, math.max(_map.camera.zoom, _focusZoom));
    if (syncStrip && _pages.hasClients) {
      _pages.animateToPage(i, duration: AppDurations.normal, curve: AppCurves.standard);
    }
  }

  void _showAll(List<_Place> places) {
    setState(() => _selected = null);
    _map.fitCamera(_fitAll(places));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(passportVisitPointsProvider);
    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.ppMap)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          title: l10n.ppErrorTitle,
          message: l10n.ppErrorBody,
          onRetry: () => ref.invalidate(passportVisitPointsProvider),
        ),
        data: (points) {
          if (points.isEmpty) {
            return EmptyView(art: StateArt.noVisits, icon: AppIcons.map, title: l10n.ppNoMap, message: l10n.ppNoMapBody);
          }
          final places = _fold(points);
          final selected = _selected;
          // The picked pin is drawn last so it sits above its neighbours.
          final order = [
            for (var i = 0; i < places.length; i++)
              if (i != selected) i,
            ?selected,
          ];
          return Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: BharatMap(
                          controller: _map,
                          attributionAlignment: Alignment.bottomLeft,
                          options: MapOptions(
                            initialCameraFit: _fitAll(places),
                            minZoom: 3,
                            maxZoom: 16,
                            onTap: (_, _) => setState(() => _selected = null),
                            interactionOptions: BharatMap.interaction,
                          ),
                          layers: [
                            MarkerLayer(
                              markers: [
                                for (final i in order)
                                  _marker(context, places[i], selected: i == selected, onTap: () => _focus(places, i, syncStrip: true)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: AppSpacing.md,
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      child: _MapStats(points: points, places: places).fadeIn(),
                    ),
                    Positioned(
                      right: AppSpacing.md,
                      bottom: AppSpacing.md,
                      child: FloatingActionButton.small(
                        heroTag: 'passport-map-fit',
                        tooltip: l10n.ppShowAll,
                        backgroundColor: context.colors.card,
                        foregroundColor: context.scheme.secondary,
                        onPressed: () => _showAll(places),
                        child: const Icon(AppIcons.fitRoute),
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: SizedBox(
                    height: _stripHeight,
                    child: PageView.builder(
                      controller: _pages,
                      itemCount: places.length,
                      padEnds: false,
                      onPageChanged: (i) => _focus(places, i),
                      itemBuilder: (context, i) => Padding(
                        padding: EdgeInsets.only(left: AppSpacing.lg, right: i == places.length - 1 ? AppSpacing.lg : 0),
                        child: _PlaceCard(place: places[i], selected: i == selected),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Marker _marker(BuildContext context, _Place place, {required bool selected, required VoidCallback onTap}) {
    final size = selected ? _selectedPin : _pin;
    return Marker(
      point: place.latLng,
      width: PhotoPin.widthFor(size),
      height: PhotoPin.heightFor(size),
      alignment: Alignment.topCenter,
      child: GestureDetector(
        onTap: onTap,
        child: Semantics(
          button: true,
          label: place.point.name,
          child: PhotoPin(
            imageUrl: place.point.imageUrl,
            color: place.verified ? context.colors.success : context.palette.accentSaffron,
            size: size,
            selected: selected,
          ),
        ),
      ),
    );
  }
}

/// Temples · Verified · States, floating over the map.
class _MapStats extends StatelessWidget {
  const _MapStats({required this.points, required this.places});
  final List<VisitPoint> points;
  final List<_Place> places;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final states = points.map((v) => v.state).whereType<String>().toSet().length;
    final verified = places.where((pl) => pl.verified).length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.card.withValues(alpha: 0.96),
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: context.colors.gold.withValues(alpha: 0.35)),
        boxShadow: AppShadows.md,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(child: _MiniStat(icon: AppIcons.temple, color: p.accentSaffron, value: places.length, label: l10n.ppTemples)),
            const GoldRule(vertical: true),
            Expanded(child: _MiniStat(icon: AppIcons.verified, color: context.colors.success, value: verified, label: l10n.ppVerified)),
            const GoldRule(vertical: true),
            Expanded(child: _MiniStat(icon: AppIcons.map, color: p.accentBlue, value: states, label: l10n.ppStates)),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.icon, required this.color, required this.value, required this.label});
  final IconData icon;
  final Color color;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label $value',
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IllustratedIcon(fallbackIcon: icon, color: color, size: 30),
          const Gap.h(AppSpacing.xs),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedCount(value: value, style: context.displayText.titleLarge.withColor(context.scheme.secondary)),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.caption.copyWith(color: context.colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One temple in the strip under the map.
class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.place, required this.selected});
  final _Place place;
  final bool selected;

  static const double _thumb = 72;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final v = place.point;
    final slug = v.slug;
    final statusColor = place.verified ? context.colors.success : context.palette.accentAmber;
    return AppCard(
      selected: selected,
      padding: AppSpacing.allSm,
      onTap: slug == null
          ? null
          : () => context.pushNamed(RouteNames.templeDetail, pathParameters: {RoutePaths.templeIdParam: slug}),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppRadius.mdAll,
            child: SizedBox.square(
              dimension: _thumb,
              child: v.imageUrl == null
                  ? const BrandedImageFallback(iconSize: 28)
                  : AppNetworkImage(url: v.imageUrl!, fallback: const BrandedImageFallback(iconSize: 28)),
            ),
          ),
          const Gap.h(AppSpacing.md),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  v.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleSmall?.semiBold.withColor(context.scheme.secondary),
                ),
                if (v.place != null)
                  Text(
                    v.place!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.caption.copyWith(color: context.colors.textSecondary),
                  ),
                const Gap(AppSpacing.xxs),
                Row(
                  children: [
                    Icon(place.verified ? AppIcons.verified : AppIcons.timer, size: 14, color: statusColor, fill: 1),
                    const Gap.h(AppSpacing.xxs),
                    Flexible(
                      child: Text(
                        '${place.verified ? l10n.ppVerified : l10n.ppPending} · ${l10n.ppVisitsCount(place.visits)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.caption.copyWith(color: statusColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(AppIcons.chevronRight, color: context.colors.textDisabled, semanticLabel: l10n.ppViewTemple),
        ],
      ),
    );
  }
}
