import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/explore_models.dart';
import '../controllers/explore_controllers.dart';
import '../widgets/explore_filter_sheet.dart';
import '../widgets/explore_widgets.dart';

/// Screen 3 — the interactive explore map on the shared [BharatMap] (OSM
/// tiles + Akhand Bharat / Bharat outlines), with zoom-aware marker
/// clustering and a selection sheet.
class ExploreMapPage extends ConsumerStatefulWidget {
  const ExploreMapPage({super.key});

  @override
  ConsumerState<ExploreMapPage> createState() => _ExploreMapPageState();
}

class _ExploreMapPageState extends ConsumerState<ExploreMapPage> {
  final _controller = MapController();
  ExploreFilter _filter = const ExploreFilter();
  double _zoom = 10;
  ExploreTemple? _selected;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locAsync = ref.watch(exploreLocationProvider);

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(
        title: Text(l10n.exMap),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.tune),
            tooltip: l10n.exFilters,
            onPressed: () async {
              final r = await showExploreFilterSheet(context, _filter, showRadius: true, showSort: false);
              if (r != null) setState(() => _filter = r);
            },
          ),
        ],
      ),
      body: locAsync.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(
          title: l10n.exErrorTitle,
          message: l10n.exLocationError,
          onRetry: () => ref.invalidate(exploreLocationProvider),
        ),
        data: (loc) => _MapBody(
          controller: _controller,
          center: LatLng(loc.latitude, loc.longitude),
          location: loc,
          filter: _filter,
          zoom: _zoom,
          selected: _selected,
          onZoom: (z) => setState(() => _zoom = z),
          onSelect: (t) => setState(() => _selected = t),
          onClearSelect: () => setState(() => _selected = null),
          onRecenter: () async {
            await ref.read(exploreLocationProvider.notifier).locate();
            final l = ref.read(exploreLocationProvider).valueOrNull;
            if (l != null) _controller.move(LatLng(l.latitude, l.longitude), 12);
          },
        ),
      ),
    );
  }
}

class _MapBody extends ConsumerWidget {
  const _MapBody({
    required this.controller,
    required this.center,
    required this.location,
    required this.filter,
    required this.zoom,
    required this.selected,
    required this.onZoom,
    required this.onSelect,
    required this.onClearSelect,
    required this.onRecenter,
  });

  final MapController controller;
  final LatLng center;
  final ExploreLocation location;
  final ExploreFilter filter;
  final double zoom;
  final ExploreTemple? selected;
  final ValueChanged<double> onZoom;
  final ValueChanged<ExploreTemple> onSelect;
  final VoidCallback onClearSelect;
  final Future<void> Function() onRecenter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final key = (lat: location.latitude, lng: location.longitude, radiusKm: filter.radiusKm, deity: filter.deity);
    final async = ref.watch(exploreNearbyProvider(key));
    final temples = async.valueOrNull ?? const <ExploreTemple>[];
    final clusters = _cluster(temples, zoom);

    return Stack(
      children: [
        BharatMap(
          controller: controller,
          attributionAlignment: Alignment.topLeft,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 11,
            minZoom: 3,
            maxZoom: 18,
            onTap: (_, _) => onClearSelect(),
            onPositionChanged: (pos, _) => onZoom(pos.zoom),
            interactionOptions: BharatMap.interaction,
          ),
          layers: [
            MarkerLayer(
              markers: [
                Marker(
                  point: center,
                  width: 22,
                  height: 22,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.scheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black38)],
                    ),
                  ),
                ),
                for (final c in clusters)
                  Marker(
                    point: c.center,
                    width: c.isCluster ? 44 : 40,
                    height: c.isCluster ? 44 : 40,
                    child: c.isCluster
                        ? _ClusterPin(
                            count: c.temples.length,
                            onTap: () => controller.move(c.center, (zoom + 2).clamp(3, 18)),
                          )
                        : _TemplePin(
                            selected: selected?.id == c.temples.first.id,
                            onTap: () => onSelect(c.temples.first),
                          ),
                  ),
              ],
            ),
          ],
        ),
        if (async.isLoading)
          const Positioned(
            top: AppSpacing.md,
            left: 0,
            right: 0,
            child: Center(child: _LoadingChip()),
          ),
        Positioned(
          right: AppSpacing.md,
          bottom: selected == null ? AppSpacing.xl : 200,
          child: FloatingActionButton.small(
            heroTag: 'recenter',
            onPressed: onRecenter,
            child: const Icon(AppIcons.myLocation),
          ),
        ),
        if (selected != null)
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.lg,
            child: _SelectionCard(
              temple: selected!,
              onClose: onClearSelect,
              onDetails: () => context.pushNamed(
                RouteNames.templeDetail,
                pathParameters: {RoutePaths.templeIdParam: selected!.slug},
              ),
              onNavigate: () => context.pushNamed(RouteNames.directions, extra: selected!.directionsArgs),
            ),
          ),
        if (!async.isLoading && temples.isEmpty)
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.lg,
            child: _InfoBanner(text: location.precise ? l10n.exNoNearby : l10n.exApproxAreaNote),
          ),
      ],
    );
  }
}

/// A grid cluster: a lat/lng cell whose size shrinks as zoom grows.
class _Cluster {
  _Cluster(this.center, this.temples);
  final LatLng center;
  final List<ExploreTemple> temples;
  bool get isCluster => temples.length > 1;
}

List<_Cluster> _cluster(List<ExploreTemple> temples, double zoom) {
  if (temples.isEmpty) return const [];
  // Cell size in degrees shrinks with zoom → markers separate as you zoom in.
  final cell = 180 / (1 << (zoom.round().clamp(3, 16)));
  final buckets = <String, List<ExploreTemple>>{};
  for (final t in temples) {
    final gx = (t.longitude / cell).floor();
    final gy = (t.latitude / cell).floor();
    buckets.putIfAbsent('$gx:$gy', () => []).add(t);
  }
  return [
    for (final group in buckets.values)
      _Cluster(
        LatLng(
          group.map((t) => t.latitude).reduce((a, b) => a + b) / group.length,
          group.map((t) => t.longitude).reduce((a, b) => a + b) / group.length,
        ),
        group,
      ),
  ];
}

class _TemplePin extends StatelessWidget {
  const _TemplePin({required this.selected, required this.onTap});
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        AppIcons.location,
        size: selected ? 40 : 32,
        color: selected ? context.colors.gold : context.scheme.primary,
        shadows: const [Shadow(blurRadius: 3, color: Colors.black45)],
      ),
    );
  }
}

class _ClusterPin extends StatelessWidget {
  const _ClusterPin({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.scheme.primary,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black38)],
        ),
        child: Text('$count', style: context.textTheme.labelMedium?.bold.copyWith(color: Colors.white)),
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
    required this.temple,
    required this.onClose,
    required this.onDetails,
    required this.onNavigate,
  });
  final ExploreTemple temple;
  final VoidCallback onClose;
  final VoidCallback onDetails;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TempleThumb(temple: temple, width: 56, height: 56),
              const Gap(AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      temple.name,
                      style: context.textTheme.titleSmall?.semiBold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (temple.location.isNotEmpty)
                      Text(
                        temple.location,
                        style: context.caption.copyWith(color: context.colors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (temple.formattedDistance != null)
                      Text(temple.formattedDistance!, style: context.caption.copyWith(color: context.scheme.primary)),
                  ],
                ),
              ),
              IconButton(icon: const Icon(AppIcons.close), onPressed: onClose, iconSize: 20),
            ],
          ),
          const Gap(AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: AppButton.outlined(
                  label: l10n.exNavigate,
                  icon: AppIcons.directions,
                  size: AppButtonSize.small,
                  onPressed: onNavigate,
                ),
              ),
              const Gap(AppSpacing.sm),
              Expanded(
                child: AppButton.primary(
                  label: l10n.exViewDetails,
                  icon: AppIcons.temple,
                  size: AppButtonSize.small,
                  onPressed: onDetails,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => AppCard(
    child: Row(
      children: [
        Icon(AppIcons.info, size: 18, color: context.colors.textSecondary),
        const Gap(AppSpacing.sm),
        Expanded(
          child: Text(text, style: context.caption.copyWith(color: context.colors.textSecondary)),
        ),
      ],
    ),
  );
}

class _LoadingChip extends StatelessWidget {
  const _LoadingChip();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
    decoration: BoxDecoration(color: context.colors.card, borderRadius: AppRadius.fullAll, boxShadow: AppShadows.sm),
    child: const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
  );
}
