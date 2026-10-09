import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:marg_app/app/localization/app_localizations.dart';
import 'package:marg_app/app/router/route_names.dart';
import 'package:marg_app/features/explore/presentation/pages/browse_temples_page.dart';
import 'package:marg_app/features/home/domain/entities/home_dashboard.dart';
import 'package:marg_app/features/home/presentation/controllers/home_controller.dart';
import 'package:marg_app/features/search/data/repository/search_repository_impl.dart';
import 'package:marg_app/features/search/domain/entities/search_models.dart';
import 'package:marg_app/features/search/domain/repository/search_repository.dart';
import 'package:marg_app/features/search/presentation/pages/search_page.dart';
import 'package:marg_app/features/search/presentation/widgets/search_visuals.dart';
import 'package:marg_app/shared/design_system.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Every query finds one place — Ujjain.
class _PlaceRepo implements SearchRepository {
  @override
  Future<SearchResults> search({
    required String query,
    SearchScope scope = SearchScope.all,
    SearchSort sort = SearchSort.relevance,
    int limit = 8,
    CancelToken? cancelToken,
  }) async =>
      SearchResults.fromJson({
        'query': query,
        'results': {
          'cities': [
            {'type': 'city', 'id': 'c9', 'title': 'Ujjain', 'subtitle': 'Madhya Pradesh'},
          ],
        },
      }, sort: sort);
}

/// Home data never arrives — discovery falls back to its static content.
class _NoHome extends HomeController {
  @override
  Future<HomeDashboard> build() => Future.error(StateError('offline'));
}

/// Search sits above the tab shell exactly as in the app: a root-level
/// route pushed from Home, with Browse living inside the Explore branch.
GoRouter _router() => GoRouter(
      initialLocation: '/home',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (_, _, shell) => Scaffold(body: shell),
          branches: [
            StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (_, _) => const Text('home'))]),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/explore',
                  name: RouteNames.explore,
                  builder: (_, _) => const Text('explore'),
                  routes: [
                    GoRoute(
                      path: 'browse',
                      name: RouteNames.exploreBrowse,
                      builder: (_, state) => Text('browse ${(state.extra! as BrowseArgs).query.cityId}'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        GoRoute(path: '/search', name: RouteNames.search, builder: (_, _) => const SearchPage()),
      ],
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('backend enum subtitles read as words; free text passes through', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    SearchHit hit(SearchType type, String subtitle) => SearchHit(type: type, id: 'x', title: 'X', subtitle: subtitle);

    expect(searchSubtitle(l10n, hit(SearchType.route, 'CUSTOM')), l10n.ryTypeCustom);
    expect(searchSubtitle(l10n, hit(SearchType.route, 'JYOTIRLINGA')), l10n.ryTypeJyotirlinga);
    expect(searchSubtitle(l10n, hit(SearchType.card, 'MYTHIC')), l10n.scRarityMythic);
    expect(searchSubtitle(l10n, hit(SearchType.card, 'Lord of Time')), 'Lord of Time');
    expect(searchSubtitle(l10n, hit(SearchType.page, 'PRIVACY')), isNull);
    expect(searchSubtitle(l10n, hit(SearchType.festival, 'Jagannath')), 'Jagannath');
  });

  testWidgets('a place result opens its temples in Explore without stacking a second shell', (tester) async {
    final router = _router();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          searchRepositoryProvider.overrideWithValue(_PlaceRepo()),
          homeControllerProvider.overrideWith(_NoHome.new),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    unawaited(router.pushNamed(RouteNames.search));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'ujj');
    await tester.pump(const Duration(milliseconds: 400)); // debounce
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ujjain'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('browse c9'), findsOneWidget);
  });
}
