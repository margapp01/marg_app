import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../shared/design_system.dart';
import '../../../explore/domain/entities/explore_models.dart';
import '../../../explore/presentation/pages/browse_temples_page.dart';
import '../../domain/entities/search_models.dart';
import '../controllers/search_controller.dart';
import '../states/search_state.dart';
import '../widgets/search_discovery.dart';
import '../widgets/search_filter_sheet.dart';
import '../widgets/search_result_tile.dart';
import '../widgets/search_states.dart';
import '../widgets/search_visuals.dart';

/// Global Search & Discovery. Type-ahead (debounced, cancel-previous) over
/// `GET /search`, grouped results, a discovery view before typing, and full
/// loading / empty / offline / error states.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({this.heroTag, super.key});

  /// Hero tag of the entry pill that opened this screen (Home / Explore), so
  /// the pill glides into the header.
  final String? heroTag;

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _open(String name, String param, String slug) => context.pushNamed(name, pathParameters: {param: slug});

  void _submitTerm(String term) {
    _controller.value = TextEditingValue(
      text: term,
      selection: TextSelection.collapsed(offset: term.length),
    );
    ref.read(searchControllerProvider.notifier).submit(term);
  }

  Future<void> _openFilters() async {
    final current = ref.read(searchControllerProvider).filter;
    final next = await showSearchFilterSheet(context, current);
    if (next != null) ref.read(searchControllerProvider.notifier).applyFilter(next);
  }

  /// Every result type opens its real screen; a place opens its temples.
  void _openHit(SearchHit hit) {
    final slug = hit.slug ?? hit.id;
    switch (hit.type) {
      case SearchType.temple:
        _open(RouteNames.templeDetail, RoutePaths.templeIdParam, slug);
      case SearchType.route:
        _open(RouteNames.routeDetail, RoutePaths.routeSlugParam, slug);
      case SearchType.festival:
        _open(RouteNames.knowledgeFestivalDetail, RoutePaths.knowledgeSlugParam, slug);
      case SearchType.blog:
        _open(RouteNames.knowledgeBlogDetail, RoutePaths.knowledgeSlugParam, slug);
      case SearchType.faq:
        context.pushNamed(RouteNames.knowledgeFaq);
      case SearchType.page:
        _open(RouteNames.knowledgeStaticPage, RoutePaths.knowledgePageKindParam, slug);
      // Tab-branch routes are reached with go — pushing one above this
      // root-level page would stack a second tab shell.
      case SearchType.city:
        context.goNamed(
          RouteNames.exploreBrowse,
          extra: BrowseArgs(
            title: hit.title,
            query: (deity: null, stateId: null, cityId: hit.id, sort: ExploreSort.popular),
          ),
        );
      case SearchType.card:
        _open(RouteNames.cardDetail, RoutePaths.cardIdParam, hit.id);
      case SearchType.achievement:
        _open(RouteNames.achievementDetail, RoutePaths.achievementIdParam, hit.id);
      case SearchType.unknown:
        break;
    }
  }

  void _browse(SearchBrowse target) {
    switch (target) {
      case SearchBrowse.temples:
        context.goNamed(RouteNames.explore);
      case SearchBrowse.routes:
        context.goNamed(RouteNames.routesDiscover);
      case SearchBrowse.festivals:
        context.pushNamed(RouteNames.knowledgeFestivals);
      case SearchBrowse.blogs:
        context.pushNamed(RouteNames.knowledgeBlogs);
      case SearchBrowse.faqs:
        context.pushNamed(RouteNames.knowledgeFaq);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(searchControllerProvider);
    final notifier = ref.read(searchControllerProvider.notifier);

    return AppScaffold(
      body: Column(
        children: [
          // Header: back · search pill · saffron filter button (Explore style).
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(AppIcons.back, color: context.scheme.secondary),
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  onPressed: () => context.canPop() ? context.pop() : context.goNamed(RouteNames.home),
                ),
                Expanded(
                  child: AppSearchBar(
                    hint: l10n.searchHint,
                    controller: _controller,
                    autofocus: true,
                    heroTag: widget.heroTag,
                    onChanged: notifier.onQueryChanged,
                    onSubmitted: notifier.submit,
                    onClear: () => notifier.onQueryChanged(''),
                    trailing: SearchBarAction(icon: AppIcons.tune, tooltip: l10n.searchFilterTitle, onPressed: _openFilters),
                  ),
                ),
              ],
            ),
          ),
          if (state.isSearching) _ScopeChips(current: state.filter.scope, onSelect: (s) {
            notifier.applyFilter(state.filter.copyWith(scope: s));
          }),
          Expanded(child: _body(context, state, notifier)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, SearchState state, SearchController notifier) {
    if (!state.isSearching) {
      return SearchDiscovery(
        recent: state.recent,
        onTermTap: _submitTerm,
        onRemoveRecent: notifier.removeRecent,
        onClearRecent: notifier.clearRecent,
        onBrowse: _browse,
        onOpenTemple: (slug) => _open(RouteNames.templeDetail, RoutePaths.templeIdParam, slug),
        onOpenFestival: (slug) => _open(RouteNames.knowledgeFestivalDetail, RoutePaths.knowledgeSlugParam, slug),
        onOpenBlog: (slug) => _open(RouteNames.knowledgeBlogDetail, RoutePaths.knowledgeSlugParam, slug),
      );
    }
    return switch (state.status) {
      SearchStatus.loading => const SearchSkeleton(),
      SearchStatus.offline => SearchInlineError(offline: true, onRetry: notifier.retry),
      SearchStatus.error => SearchInlineError(offline: false, onRetry: notifier.retry),
      SearchStatus.empty => SearchEmptyState(
          query: state.query.trim(),
          onViewNearby: () => context.goNamed(RouteNames.exploreNearby),
          suggestions: const ['Kashi Vishwanath', 'Somnath Temple', 'Mahakal'],
          onSuggestion: _submitTerm,
        ),
      SearchStatus.results => _Results(
          results: state.results!,
          showViewAll: state.filter.scope == SearchScope.all,
          onOpen: _openHit,
          onViewAll: (type) => notifier.applyFilter(state.filter.copyWith(scope: _scopeOf(type))),
        ),
      SearchStatus.idle => const SizedBox.shrink(),
    };
  }
}

IconData _scopeIcon(SearchScope scope) => switch (scope) {
      SearchScope.all => AppIcons.search,
      SearchScope.temples => searchTypeIcon(SearchType.temple),
      SearchScope.routes => searchTypeIcon(SearchType.route),
      SearchScope.festivals => searchTypeIcon(SearchType.festival),
      SearchScope.blogs => searchTypeIcon(SearchType.blog),
      SearchScope.faqs => searchTypeIcon(SearchType.faq),
      SearchScope.pages => searchTypeIcon(SearchType.page),
    };

SearchScope _scopeOf(SearchType type) => switch (type) {
      SearchType.temple => SearchScope.temples,
      SearchType.route => SearchScope.routes,
      SearchType.festival => SearchScope.festivals,
      SearchType.blog => SearchScope.blogs,
      SearchType.faq => SearchScope.faqs,
      SearchType.page => SearchScope.pages,
      _ => SearchScope.all,
    };

class _ScopeChips extends StatelessWidget {
  const _ScopeChips({required this.current, required this.onSelect});

  final SearchScope current;
  final ValueChanged<SearchScope> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String label(SearchScope s) => switch (s) {
          SearchScope.all => l10n.searchScopeAll,
          SearchScope.temples => l10n.titleTemples,
          SearchScope.routes => l10n.titleRoutes,
          SearchScope.festivals => l10n.searchGroupFestivals,
          SearchScope.blogs => l10n.searchGroupBlogs,
          SearchScope.faqs => l10n.searchGroupFaqs,
          SearchScope.pages => l10n.searchGroupPages,
        };
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.screenH,
        itemCount: SearchScope.values.length,
        separatorBuilder: (_, _) => const Gap.h(AppSpacing.sm),
        itemBuilder: (context, i) {
          final scope = SearchScope.values[i];
          return Center(
            child: AppFilterChip(
              label: label(scope),
              icon: _scopeIcon(scope),
              selected: current == scope,
              onSelected: (_) => onSelect(scope),
            ),
          );
        },
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.results, required this.showViewAll, required this.onOpen, required this.onViewAll});

  final SearchResults results;

  /// "View All" narrows the search to a group — only meaningful from "All".
  final bool showViewAll;
  final ValueChanged<SearchHit> onOpen;
  final ValueChanged<SearchType> onViewAll;

  String _groupLabel(AppLocalizations l10n, SearchType type) => switch (type) {
        SearchType.temple => l10n.titleTemples,
        SearchType.route => l10n.titleRoutes,
        SearchType.festival => l10n.searchGroupFestivals,
        SearchType.blog => l10n.searchGroupBlogs,
        SearchType.faq => l10n.searchGroupFaqs,
        SearchType.page => l10n.searchGroupPages,
        SearchType.city => l10n.searchGroupPlaces,
        SearchType.card => l10n.searchGroupCards,
        SearchType.achievement => l10n.searchGroupAchievements,
        SearchType.unknown => '',
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FadeIn(
      child: ListView.builder(
        padding: AppSpacing.screenAll,
        itemCount: results.groups.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                l10n.searchResultsCount(results.total),
                style: context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary),
              ),
            );
          }
          final group = results.groups[index - 1];
          return RepaintBoundary(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: _groupLabel(l10n, group.type),
                  onViewAll: showViewAll && _scopeOf(group.type) != SearchScope.all ? () => onViewAll(group.type) : null,
                  viewAllLabel: l10n.commonViewAll,
                ),
                for (final hit in group.hits) ...[
                  SearchResultTile(hit: hit, onTap: () => onOpen(hit)),
                  const Gap(AppSpacing.sm),
                ],
                const Gap(AppSpacing.lg),
              ],
            ),
          );
        },
      ),
    );
  }
}
