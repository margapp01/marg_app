import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../shared/design_system.dart';
import '../../data/repository/knowledge_repository.dart';
import '../../domain/entities/knowledge_models.dart';
import '../controllers/knowledge_controllers.dart';
import '../widgets/knowledge_widgets.dart';

/// Screen 2 — Blog Library. Search (via the unified `/search`), category chips
/// (derived from the loaded blogs), a featured (newest) article, and the list.
class BlogLibraryPage extends ConsumerStatefulWidget {
  const BlogLibraryPage({this.initialCategory, super.key});
  final String? initialCategory;

  @override
  ConsumerState<BlogLibraryPage> createState() => _BlogLibraryPageState();
}

class _BlogLibraryPageState extends ConsumerState<BlogLibraryPage> {
  late String? _category = widget.initialCategory;
  String _query = '';

  void _open(Blog b) => context.pushNamed(RouteNames.knowledgeBlogDetail, pathParameters: {'slug': b.slug});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final searching = _query.trim().length >= 2;

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.kbBlogs)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
            child: AppSearchBar(
              hint: l10n.kbSearchArticles,
              onChanged: (v) => setState(() => _query = v),
              onClear: () => setState(() => _query = ''),
            ),
          ),
          Expanded(
            child: searching ? _SearchResults(query: _query, onOpen: _open) : _Browse(
              category: _category,
              onCategory: (c) => setState(() => _category = c),
              onOpen: _open,
            ),
          ),
        ],
      ),
    );
  }
}

class _Browse extends ConsumerWidget {
  const _Browse({required this.category, required this.onCategory, required this.onOpen});
  final String? category;
  final ValueChanged<String?> onCategory;
  final ValueChanged<Blog> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(knowledgeBlogsProvider);
    return async.when(
      loading: () => const LoadingView(),
      error: (_, _) => ErrorView(title: l10n.kbErrorTitle, message: l10n.kbErrorBody, onRetry: () => ref.invalidate(knowledgeBlogsProvider)),
      data: (blogs) {
        if (blogs.isEmpty) {
          return EmptyView(art: StateArt.noResults, icon: AppIcons.blog, title: l10n.kbNoArticles, message: l10n.kbNoArticlesBody);
        }
        final categories = KnowledgeRepository.categoriesOf(blogs);
        final filtered = category == null ? blogs : blogs.where((b) => b.category == category).toList();
        final featured = filtered.isNotEmpty ? filtered.first : null;
        final rest = filtered.length > 1 ? filtered.sublist(1) : const <Blog>[];

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(knowledgeBlogsProvider),
          child: ListView(
            padding: AppSpacing.screenAll,
            children: [
              if (categories.isNotEmpty) ...[
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: AppFilterChip(label: l10n.kbAll, selected: category == null, onSelected: (_) => onCategory(null)),
                      ),
                      for (final c in categories)
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: AppFilterChip(label: c, selected: category == c, onSelected: (_) => onCategory(c)),
                        ),
                    ],
                  ),
                ),
                const Gap(AppSpacing.md),
              ],
              if (featured != null) ...[
                BlogCard(blog: featured, featured: true, onTap: () => onOpen(featured)),
                const Gap(AppSpacing.md),
              ],
              for (final b in rest) ...[
                BlogListTile(blog: b, onTap: () => onOpen(b)),
                const Gap(AppSpacing.sm),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.query, required this.onOpen});
  final String query;
  final ValueChanged<Blog> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(blogSearchProvider(query));
    return async.when(
      loading: () => const LoadingView(),
      error: (_, _) => ErrorView(title: l10n.kbErrorTitle, message: l10n.kbErrorBody, onRetry: () => ref.invalidate(blogSearchProvider(query))),
      data: (results) {
        if (results.isEmpty) {
          return EmptyView(art: StateArt.noResults, icon: AppIcons.search, title: l10n.kbNoResults, message: l10n.kbNoResultsBody);
        }
        return ListView.separated(
          padding: AppSpacing.screenAll,
          itemCount: results.length,
          separatorBuilder: (_, _) => const Gap(AppSpacing.sm),
          itemBuilder: (context, i) => BlogListTile(blog: results[i], onTap: () => onOpen(results[i])),
        );
      },
    );
  }
}
