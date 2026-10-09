import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/explore_models.dart';
import '../controllers/explore_controllers.dart';
import '../widgets/explore_filter_sheet.dart';
import '../widgets/explore_widgets.dart';

/// Screen 2 — Nearby temples with radius + category filters and a name search.
class NearbyTemplesPage extends ConsumerStatefulWidget {
  const NearbyTemplesPage({super.key});

  @override
  ConsumerState<NearbyTemplesPage> createState() => _NearbyTemplesPageState();
}

class _NearbyTemplesPageState extends ConsumerState<NearbyTemplesPage> {
  ExploreFilter _filter = const ExploreFilter();
  String _query = '';

  Future<void> _openFilters() async {
    final result = await showExploreFilterSheet(context, _filter, showRadius: true, showSort: false);
    if (result != null) setState(() => _filter = result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locAsync = ref.watch(exploreLocationProvider);

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(
        title: Text(l10n.exNearbyTemples),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.tune),
            tooltip: l10n.exFilters,
            onPressed: _openFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: AppSpacing.screenH.add(const EdgeInsets.only(top: AppSpacing.sm)),
            child: AppSearchBar(
              hint: l10n.exSearchNearbyHint,
              onChanged: (v) => setState(() => _query = v),
              onClear: () => setState(() => _query = ''),
            ),
          ),
          const Gap(AppSpacing.sm),
          _FilterSummary(filter: _filter, onEdit: _openFilters, onClearDeity: () => setState(() => _filter = _filter.copyWith(deity: null))),
          Expanded(
            child: locAsync.when(
              loading: () => const LoadingView(),
              error: (_, _) => ErrorView(
                title: l10n.exErrorTitle,
                message: l10n.exLocationError,
                onRetry: () => ref.invalidate(exploreLocationProvider),
              ),
              data: (loc) => _Results(
                location: loc,
                filter: _filter,
                query: _query,
                onWiden: (km) => setState(() => _filter = _filter.copyWith(radiusKm: km)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Within 25 km · Shiva ✕ · Edit" — what the list is showing, editable.
class _FilterSummary extends StatelessWidget {
  const _FilterSummary({required this.filter, required this.onEdit, required this.onClearDeity});
  final ExploreFilter filter;
  final VoidCallback onEdit;
  final VoidCallback onClearDeity;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final deity = filter.deity;
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.screenH,
        children: [
          Center(
            child: AppFilterChip(
              label: l10n.exWithinKm(filter.radiusKm),
              icon: AppIcons.nearby,
              selected: true,
              onSelected: (_) => onEdit(),
            ),
          ),
          if (deity != null) ...[
            const Gap.h(AppSpacing.sm),
            Center(
              child: InputChip(
                label: Text(deityLabel(l10n, deity.wire)),
                onDeleted: onClearDeity,
                deleteButtonTooltipMessage: l10n.exReset,
              ),
            ),
          ],
          const Gap.h(AppSpacing.sm),
          Center(
            child: AppFilterChip(label: l10n.exFilters, icon: AppIcons.tune, selected: false, onSelected: (_) => onEdit()),
          ),
        ],
      ),
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({required this.location, required this.filter, required this.query, required this.onWiden});
  final ExploreLocation location;
  final ExploreFilter filter;
  final String query;

  /// Widens the search to the given radius (km).
  final ValueChanged<int> onWiden;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final key = (lat: location.latitude, lng: location.longitude, radiusKm: filter.radiusKm, deity: filter.deity);
    final async = ref.watch(exploreNearbyProvider(key));

    return async.when(
      loading: () => const LoadingView(),
      error: (_, _) => ErrorView(
        title: l10n.exErrorTitle,
        message: l10n.exErrorBody,
        onRetry: () => ref.invalidate(exploreNearbyProvider(key)),
      ),
      data: (all) {
        final temples = query.trim().isEmpty
            ? all
            : all.where((t) => t.name.toLowerCase().contains(query.trim().toLowerCase())).toList();
        if (temples.isEmpty) {
          // Widen step by step up to the backend's 200 km; past that, browse
          // by state instead.
          final wider = widerRadius(filter.radiusKm);
          return EmptyView(
            art: StateArt.location,
            icon: AppIcons.nearby,
            title: l10n.exNoNearby,
            message: l10n.exNoNearbyWithin(filter.radiusKm),
            action: wider != null
                ? AppButton.primary(
                    label: l10n.exWidenTo(wider),
                    icon: AppIcons.nearby,
                    expand: false,
                    onPressed: () => onWiden(wider),
                  )
                : AppButton.primary(
                    label: l10n.exExploreByState,
                    icon: AppIcons.map,
                    expand: false,
                    onPressed: () => context.pushNamed(RouteNames.exploreStates),
                  ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(exploreNearbyProvider(key));
            await ref.read(exploreLocationProvider.notifier).locate();
          },
          child: ListView.separated(
            padding: AppSpacing.screenAll,
            itemCount: temples.length + 1,
            separatorBuilder: (_, _) => const Gap(AppSpacing.md),
            itemBuilder: (context, i) {
              if (i == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Row(
                    children: [
                      if (!location.precise) ...[
                        Icon(AppIcons.info, size: 14, color: context.colors.textSecondary),
                        const Gap(AppSpacing.xxs),
                        Expanded(
                          child: Text(
                            l10n.exApproxAreaNote,
                            style: context.caption.copyWith(color: context.colors.textSecondary),
                          ),
                        ),
                      ] else
                        Text(
                          l10n.exNearbyCount(temples.length, filter.radiusKm),
                          style: context.caption.copyWith(color: context.colors.textSecondary),
                        ),
                    ],
                  ),
                );
              }
              final t = temples[i - 1];
              return ExploreTempleCard(
                temple: t,
                onTap: () =>
                    context.pushNamed(RouteNames.templeDetail, pathParameters: {RoutePaths.templeIdParam: t.slug}),
                onNavigate: () => context.pushNamed(RouteNames.directions, extra: t.directionsArgs),
              );
            },
          ),
        );
      },
    );
  }
}
