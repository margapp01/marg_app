import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/knowledge_models.dart';
import '../controllers/knowledge_controllers.dart';
import '../widgets/knowledge_share.dart';
import '../widgets/knowledge_widgets.dart';

/// Screen 3 — Blog Detail. A premium reading experience: hero, category, title,
/// publish date + estimated reading time, the article body rendered from HTML,
/// related articles (same category), and share. Bookmarking is intentionally
/// absent — the backend has no bookmark store.
class BlogDetailPage extends ConsumerWidget {
  const BlogDetailPage({required this.slug, super.key});
  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(blogDetailProvider(slug));

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(
        title: Text(l10n.kbBlogDetail),
        actions: [
          async.maybeWhen(
            data: (b) => IconButton(
              icon: Icon(AppIcons.share),
              tooltip: l10n.kbShare,
              onPressed: () => showKnowledgeShare(
                context,
                ShareContent(
                  title: b.title,
                  subtitle: b.excerpt,
                  heroImageUrl: b.coverImageUrl,
                  shareText: '${b.title}${b.excerpt != null ? '\n\n${b.excerpt}' : ''}',
                ),
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: async.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(title: l10n.kbErrorTitle, message: l10n.kbErrorBody, onRetry: () => ref.invalidate(blogDetailProvider(slug))),
        data: (blog) => _Body(blog: blog),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.blog});
  final Blog blog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        if (blog.coverImageUrl != null)
          AppNetworkImage(url: blog.coverImageUrl!, height: 220, width: double.infinity, fit: BoxFit.cover),
        Padding(
          padding: AppSpacing.screenAll,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (blog.category != null) ...[
                CategoryPill(label: blog.category!),
                const Gap(AppSpacing.sm),
              ],
              Text(blog.title, style: context.textTheme.headlineSmall?.bold),
              const Gap(AppSpacing.sm),
              Row(
                children: [
                  Icon(AppIcons.calendar, size: 15, color: context.colors.textSecondary),
                  const Gap(AppSpacing.xxs),
                  Text(knowledgeDate(blog.publishedAt), style: context.caption.copyWith(color: context.colors.textSecondary)),
                  const Gap(AppSpacing.md),
                  Icon(AppIcons.timer, size: 15, color: context.colors.textSecondary),
                  const Gap(AppSpacing.xxs),
                  Text(readTime(context, blog), style: context.caption.copyWith(color: context.colors.textSecondary)),
                ],
              ),
              const Gap(AppSpacing.lg),
              if (blog.excerpt != null && blog.contentHtml.isNotEmpty) ...[
                Text(
                  blog.excerpt!,
                  style: context.textTheme.titleSmall?.copyWith(color: context.colors.textSecondary, height: 1.5, fontStyle: FontStyle.italic),
                ),
                const Gap(AppSpacing.lg),
              ],
              if (blog.contentHtml.isNotEmpty)
                HtmlContentView(html: blog.contentHtml)
              else if (blog.excerpt != null)
                Text(blog.excerpt!, style: context.textTheme.bodyLarge?.copyWith(height: 1.6)),
              if (blog.tags.isNotEmpty) ...[
                const Gap(AppSpacing.lg),
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
            SectionHeader(title: l10n.kbRelatedArticles),
            const Gap(AppSpacing.sm),
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
