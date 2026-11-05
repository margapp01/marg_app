import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/knowledge_models.dart';
import '../controllers/knowledge_controllers.dart';
import '../widgets/knowledge_reading.dart';
import '../widgets/knowledge_share.dart';
import '../widgets/knowledge_widgets.dart';

/// Screen 3 — Blog Detail. A premium reading experience: a photo hero, the
/// title in the display face, date and reading time, the excerpt as a lede,
/// "In this article" for long stories, the body rendered from HTML (credited
/// figures, section headings), an invitation to visit a temple nearby, tags
/// and related stories. Bookmarking is intentionally absent — the backend
/// has no bookmark store.
class BlogDetailPage extends ConsumerWidget {
  const BlogDetailPage({required this.slug, super.key});
  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(blogDetailProvider(slug));

    return Scaffold(
      backgroundColor: context.scheme.surface,
      body: async.when(
        loading: () => Scaffold(appBar: AppBar(title: Text(l10n.kbBlogDetail)), body: const LoadingView()),
        error: (_, _) => Scaffold(
          appBar: AppBar(title: Text(l10n.kbBlogDetail)),
          body: ErrorView(title: l10n.kbErrorTitle, message: l10n.kbErrorBody, onRetry: () => ref.invalidate(blogDetailProvider(slug))),
        ),
        data: (blog) => _Article(blog: blog),
      ),
    );
  }
}

class _Article extends StatefulWidget {
  const _Article({required this.blog});
  final Blog blog;

  @override
  State<_Article> createState() => _ArticleState();
}

class _ArticleState extends State<_Article> {
  /// Fewer sections than this read fine without a contents list.
  static const int _contentsMinSections = 3;

  final ScrollController _scroll = ScrollController();
  late List<HtmlBlock> _intro;
  late List<DocumentSection> _sections;
  late List<GlobalKey> _sectionKeys;

  @override
  void initState() {
    super.initState();
    _parse();
  }

  @override
  void didUpdateWidget(_Article old) {
    super.didUpdateWidget(old);
    if (old.blog.contentHtml != widget.blog.contentHtml) _parse();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _parse() {
    final doc = splitDocument(parseHtmlBlocks(widget.blog.contentHtml));
    _intro = doc.intro;
    _sections = doc.sections;
    _sectionKeys = [for (final _ in _sections) GlobalKey()];
  }

  /// Scrolls section [index] to just under the pinned app bar.
  void _jumpTo(int index) {
    final box = _sectionKeys[index].currentContext?.findRenderObject();
    if (box == null) return;
    final reveal = RenderAbstractViewport.of(box).getOffsetToReveal(box, 0).offset;
    final target = (reveal - kToolbarHeight - context.viewPadding.top).clamp(0.0, _scroll.position.maxScrollExtent);
    final motion = MediaQuery.disableAnimationsOf(context) ? Duration.zero : AppDurations.slow;
    if (motion == Duration.zero) {
      _scroll.jumpTo(target);
    } else {
      _scroll.animateTo(target, duration: motion, curve: AppCurves.standard);
    }
  }

  void _share(AppLocalizations l10n) {
    final b = widget.blog;
    showKnowledgeShare(
      context,
      ShareContent(
        title: b.title,
        subtitle: b.excerpt,
        heroImageUrl: b.coverImageUrl,
        message: ShareMessage(
          kind: ShareKind.blog,
          itemId: b.slug,
          path: SharePaths.blog(b.slug),
          text: ShareCopy.blog(l10n, title: b.title, excerpt: b.excerpt),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final blog = widget.blog;
    final muted = context.caption.copyWith(color: context.colors.textSecondary);
    final heading = context.displayText.titleLarge.withColor(context.scheme.secondary);

    return CustomScrollView(
      controller: _scroll,
      slivers: [
        KnowledgeHeroAppBar(
          title: blog.title,
          imageUrl: blog.coverImageUrl,
          showTitle: false,
          onShare: () => _share(l10n),
          pills: [
            if (blog.category != null) PhotoPill(label: blog.category!, icon: AppIcons.blog, color: context.scheme.primary),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxxl + context.viewPadding.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (blog.coverImageUrl == null && blog.category != null) ...[
                  CategoryPill(label: blog.category!),
                  const Gap(AppSpacing.sm),
                ],
                Text(blog.title, style: context.displayText.headlineMedium.withColor(context.scheme.secondary)),
                const Gap(AppSpacing.sm),
                Row(
                  children: [
                    Icon(AppIcons.calendar, size: 15, color: context.colors.textSecondary),
                    const Gap.h(AppSpacing.xxs),
                    Text(knowledgeDate(blog.publishedAt), style: muted),
                    const Gap.h(AppSpacing.md),
                    Icon(AppIcons.timer, size: 15, color: context.colors.textSecondary),
                    const Gap.h(AppSpacing.xxs),
                    Text(readTime(context, blog), style: muted),
                  ],
                ),
                if (blog.excerpt != null && blog.contentHtml.isNotEmpty) ...[
                  const Gap(AppSpacing.lg),
                  Text(
                    blog.excerpt!,
                    style: context.textTheme.titleMedium?.copyWith(color: context.colors.textSecondary, height: 1.5),
                  ),
                ],
                const Gap(AppSpacing.lg),
                const GoldRule(),
                const Gap(AppSpacing.lg),
                if (_sections.length >= _contentsMinSections) ...[
                  ArticleContents(headings: [for (final s in _sections) s.heading], onSelect: _jumpTo),
                  const Gap(AppSpacing.xl),
                ],
                if (blog.contentHtml.isEmpty && blog.excerpt != null)
                  Text(blog.excerpt!, style: context.textTheme.bodyLarge?.copyWith(height: 1.6)),
                if (_intro.isNotEmpty) HtmlContentView.blocks(_intro),
                for (var i = 0; i < _sections.length; i++)
                  Padding(
                    key: _sectionKeys[i],
                    padding: EdgeInsets.only(top: i == 0 && _intro.isEmpty ? 0 : AppSpacing.xxl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(header: true, child: Text(_sections[i].heading, style: heading)),
                        if (_sections[i].blocks.isNotEmpty) ...[
                          const Gap(AppSpacing.md),
                          HtmlContentView.blocks(_sections[i].blocks),
                        ],
                      ],
                    ),
                  ),
                const Gap(AppSpacing.xxl),
                TempleVisitCta(title: l10n.kbVisitTitle),
                if (blog.tags.isNotEmpty) ...[
                  const Gap(AppSpacing.xl),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [for (final t in blog.tags) CategoryPill(label: '#$t')],
                  ),
                ],
                const Gap(AppSpacing.xl),
                _Related(slug: blog.slug, l10n: l10n),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Related extends ConsumerWidget {
  const _Related({required this.slug, required this.l10n});
  final String slug;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(relatedBlogsProvider(slug));
    return async.maybeWhen(
      data: (related) {
        if (related.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GoldRuleHeader(label: l10n.kbRelatedArticles),
            const Gap(AppSpacing.md),
            for (final b in related) ...[
              BlogListTile(
                blog: b,
                onTap: () => context.pushReplacementNamed(RouteNames.knowledgeBlogDetail, pathParameters: {'slug': b.slug}),
              ),
              const Gap(AppSpacing.sm),
            ],
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
