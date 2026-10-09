import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/search_models.dart';

/// Opens the filter sheet and resolves to the chosen [SearchFilter], or null on
/// cancel. Only the filters `/search` can honestly honour are offered:
/// "Search In" (the `types` param) and sort (server relevance / client A–Z).
Future<SearchFilter?> showSearchFilterSheet(BuildContext context, SearchFilter current) {
  return AppSheets.show<SearchFilter>(
    context,
    padded: false,
    builder: (_) => _FilterSheet(initial: current),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.initial});

  final SearchFilter initial;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late SearchScope _scope = widget.initial.scope;
  late SearchSort _sort = widget.initial.sort;

  static const int _scopeColumns = 4;

  ({String label, IconData icon}) _scopeMeta(BuildContext context, SearchScope s) {
    final l10n = AppLocalizations.of(context);
    return switch (s) {
      SearchScope.all => (label: l10n.searchScopeAll, icon: AppIcons.explore),
      SearchScope.temples => (label: l10n.titleTemples, icon: AppIcons.temple),
      SearchScope.routes => (label: l10n.titleRoutes, icon: AppIcons.route),
      SearchScope.festivals => (label: l10n.searchGroupFestivals, icon: AppIcons.calendar),
      SearchScope.blogs => (label: l10n.searchGroupBlogs, icon: AppIcons.article),
      SearchScope.faqs => (label: l10n.searchGroupFaqs, icon: AppIcons.help),
      SearchScope.pages => (label: l10n.searchGroupPages, icon: AppIcons.description),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    return AppSheetLayout(
      title: l10n.searchFilterTitle,
      subtitle: l10n.searchFilterHint,
      icon: AppIcons.tune,
      trailing: TextButton(
        onPressed: () => setState(() {
          _scope = SearchScope.all;
          _sort = SearchSort.relevance;
        }),
        child: Text(l10n.searchFilterReset),
      ),
      actions: [
        AppButton.primary(
          label: l10n.searchFilterApply,
          icon: AppIcons.check,
          onPressed: () => Navigator.of(context).pop(SearchFilter(scope: _scope, sort: _sort)),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetSection(
            label: l10n.searchFilterSearchIn,
            icon: AppIcons.search,
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: ChoiceGrid(
                columns: _scopeColumns,
                children: [
                  for (final s in SearchScope.values)
                    ChoiceTile(
                      label: _scopeMeta(context, s).label,
                      icon: _scopeMeta(context, s).icon,
                      selected: _scope == s,
                      onTap: () => setState(() => _scope = s),
                    ),
                ],
              ),
            ),
          ),
          AppSheetSection(
            label: l10n.searchFilterSortBy,
            icon: AppIcons.sort,
            child: Column(
              children: [
                OptionCard(
                  icon: AppIcons.star,
                  title: l10n.searchSortRelevance,
                  subtitle: l10n.searchSortRelevanceHint,
                  accent: p.accentSaffron,
                  radio: true,
                  selected: _sort == SearchSort.relevance,
                  onTap: () => setState(() => _sort = SearchSort.relevance),
                ),
                const Gap(AppSpacing.sm),
                OptionCard(
                  icon: AppIcons.sort,
                  title: l10n.searchSortAlphabetical,
                  subtitle: l10n.searchSortAlphabeticalHint,
                  accent: p.accentViolet,
                  radio: true,
                  selected: _sort == SearchSort.alphabetical,
                  onTap: () => setState(() => _sort = SearchSort.alphabetical),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
