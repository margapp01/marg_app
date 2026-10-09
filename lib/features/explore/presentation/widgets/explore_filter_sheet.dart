import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/explore_models.dart';
import 'explore_widgets.dart';

/// Search radii for nearby temples, in km — the backend allows up to 200.
const List<int> kExploreRadii = [5, 10, 25, 50, 100, 200];

/// The next wider search radius, or null when already at the widest.
int? widerRadius(int current) {
  for (final r in kExploreRadii) {
    if (r > current) return r;
  }
  return null;
}

/// Presents the Explore filter sheet and returns the chosen [ExploreFilter],
/// or null if dismissed. Only backend-supported filters are offered: radius
/// (nearby only), deity category, and sort order.
Future<ExploreFilter?> showExploreFilterSheet(
  BuildContext context,
  ExploreFilter current, {
  bool showRadius = false,
  bool showSort = true,
}) {
  return AppSheets.show<ExploreFilter>(
    context,
    padded: false,
    builder: (_) => _ExploreFilterSheet(current: current, showRadius: showRadius, showSort: showSort),
  );
}

class _ExploreFilterSheet extends StatefulWidget {
  const _ExploreFilterSheet({required this.current, required this.showRadius, required this.showSort});
  final ExploreFilter current;
  final bool showRadius;
  final bool showSort;

  @override
  State<_ExploreFilterSheet> createState() => _ExploreFilterSheetState();
}

class _ExploreFilterSheetState extends State<_ExploreFilterSheet> {
  late ExploreFilter _filter = widget.current;

  static const int _deityColumns = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final sorts = [
      (ExploreSort.popular, AppIcons.trending, l10n.exSortPopular, l10n.exSortPopularHint, p.accentSaffron),
      (ExploreSort.newest, AppIcons.calendar, l10n.exSortNewest, l10n.exSortNewestHint, p.accentBlue),
      (ExploreSort.nameAsc, AppIcons.sort, l10n.exSortName, l10n.exSortNameHint, p.accentViolet),
    ];
    return AppSheetLayout(
      title: l10n.exFilters,
      subtitle: l10n.exFiltersHint,
      icon: AppIcons.tune,
      trailing: TextButton(onPressed: () => setState(() => _filter = const ExploreFilter()), child: Text(l10n.exReset)),
      actions: [
        AppButton.primary(
          label: l10n.exApply,
          icon: AppIcons.check,
          onPressed: () => Navigator.of(context).pop(_filter),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showRadius)
            AppSheetSection(
              label: l10n.exRadius,
              icon: AppIcons.nearby,
              trailing: AppBadge(label: l10n.exKm(_filter.radiusKm), tone: AppBadgeTone.primary),
              child: _RadiusPicker(
                value: _filter.radiusKm,
                onChanged: (r) => setState(() => _filter = _filter.copyWith(radiusKm: r)),
              ),
            ),
          AppSheetSection(
            label: l10n.exCategory,
            icon: AppIcons.category,
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: ChoiceGrid(
                columns: _deityColumns,
                children: [
                  ChoiceTile(
                    label: l10n.exAll,
                    icon: AppIcons.temple,
                    selected: _filter.deity == null,
                    onTap: () => setState(() => _filter = _filter.copyWith(deity: null)),
                  ),
                  for (final d in ExploreDeity.values)
                    ChoiceTile(
                      label: deityLabel(l10n, d.wire),
                      icon: AppIcons.temple,
                      asset: deityAsset(d.wire),
                      accent: deityColor(context, d.wire),
                      selected: _filter.deity == d,
                      onTap: () => setState(() => _filter = _filter.copyWith(deity: d)),
                    ),
                ],
              ),
            ),
          ),
          if (widget.showSort)
            AppSheetSection(
              label: l10n.exSort,
              icon: AppIcons.sort,
              child: Column(
                children: [
                  for (final (i, (sort, icon, title, hint, accent)) in sorts.indexed) ...[
                    if (i > 0) const Gap(AppSpacing.sm),
                    OptionCard(
                      icon: icon,
                      title: title,
                      subtitle: hint,
                      accent: accent,
                      radio: true,
                      selected: _filter.sort == sort,
                      onTap: () => setState(() => _filter = _filter.copyWith(sort: sort)),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// The radius as a stepped slider over [kExploreRadii], with every stop
/// labelled underneath.
class _RadiusPicker extends StatelessWidget {
  const _RadiusPicker({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stops = kExploreRadii.length;
    final index = kExploreRadii.indexOf(value).clamp(0, stops - 1);
    return LayoutBuilder(
      builder: (context, constraints) {
        // Each label is centred in an equal-width column; insetting the track
        // by half a column puts every stop directly above its label.
        final inset = constraints.maxWidth / (stops * 2);
        return Column(
          children: [
            Slider(
              value: index.toDouble(),
              max: (stops - 1).toDouble(),
              divisions: stops - 1,
              padding: EdgeInsets.symmetric(horizontal: inset, vertical: AppSpacing.md),
              label: l10n.exKm(kExploreRadii[index]),
              semanticFormatterCallback: (v) => l10n.exKm(kExploreRadii[v.round()]),
              onChanged: (v) => onChanged(kExploreRadii[v.round()]),
            ),
            ExcludeSemantics(
              child: Row(
                children: [
                  for (final r in kExploreRadii)
                    Expanded(
                      child: Text(
                        '$r',
                        textAlign: TextAlign.center,
                        style: r == value
                            ? context.caption.bold.copyWith(color: context.scheme.primary)
                            : context.caption.copyWith(color: context.colors.textSecondary),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
