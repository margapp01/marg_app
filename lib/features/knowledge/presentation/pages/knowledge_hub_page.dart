import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../shared/design_system.dart';
import '../controllers/knowledge_controllers.dart';
import '../widgets/knowledge_share.dart';
import '../widgets/knowledge_widgets.dart';

/// Screen 1 — Knowledge Hub home. A premium landing page composed from the
/// CMS: a featured hero, the verse of the day, quick categories, latest
/// articles, upcoming festivals, latest announcements, and learning
/// collections. "Continue Reading" is omitted — the backend tracks no history.
class KnowledgeHubPage extends ConsumerWidget {
  const KnowledgeHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(
        title: Text(l10n.kbKnowledgeHub),
        actions: [
          IconButton(
            icon: Icon(AppIcons.notifications),
            tooltip: l10n.kbAnnouncements,
            onPressed: () => context.pushNamed(RouteNames.knowledgeAnnouncements),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref
            ..invalidate(knowledgeBannersProvider)
            ..invalidate(dailyQuoteProvider)
            ..invalidate(knowledgeBlogsProvider)
            ..invalidate(upcomingFestivalsProvider)
            ..invalidate(announcementsProvider);
        },
        child: ListView(
          padding: AppSpacing.screenAll,
          children: [
            const _Hero(),
            const Gap(AppSpacing.lg),
            const _VerseOfTheDay(),
            const Gap(AppSpacing.xl),
            _QuickCategories(l10n: l10n),
            const Gap(AppSpacing.xl),
            _LatestArticles(l10n: l10n),
            const Gap(AppSpacing.xl),
            _UpcomingFestivals(l10n: l10n),
            const Gap(AppSpacing.xl),
            _LatestAnnouncements(l10n: l10n),
            const Gap(AppSpacing.xl),
            _Collections(l10n: l10n),
            const Gap(AppSpacing.xl),
            _AboutLinks(l10n: l10n),
          ],
        ),
      ),
    );
  }
}

class _Hero extends ConsumerWidget {
  const _Hero();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final banners = ref.watch(knowledgeBannersProvider);
    final blogs = ref.watch(knowledgeBlogsProvider);

    // Prefer a CMS banner; fall back to the newest blog as the featured hero.
    final banner = banners.asData?.value.isNotEmpty == true ? banners.asData!.value.first : null;
    final featured = blogs.asData?.value.isNotEmpty == true ? blogs.asData!.value.first : null;
    if (banner == null && featured == null) {
      if (blogs.isLoading || banners.isLoading) {
        return const SizedBox(height: 170, child: LoadingView());
      }
      return const SizedBox.shrink();
    }

    final imageUrl = banner?.imageUrl ?? featured?.coverImageUrl;
    final title = banner?.title ?? featured!.title;
    final subtitle = banner?.subtitle;
    final onTap = banner == null && featured != null
        ? () => context.pushNamed(RouteNames.knowledgeBlogDetail, pathParameters: {'slug': featured.slug})
        : null;

    return _HeroCard(imageUrl: imageUrl, title: title, subtitle: subtitle, onTap: onTap);
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.imageUrl, required this.title, this.subtitle, this.onTap});
  final String? imageUrl;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: AppRadius.lgAll,
        child: Stack(
          children: [
            if (imageUrl != null)
              AppNetworkImage(url: imageUrl!, height: 180, width: double.infinity, fit: BoxFit.cover)
            else
              Container(height: 180, width: double.infinity, color: context.scheme.primary),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                  ),
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.lg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: context.brandText.headlineSmall.copyWith(color: Colors.white), maxLines: 2, overflow: TextOverflow.ellipsis),
                  if (subtitle != null) ...[
                    const Gap(AppSpacing.xxs),
                    Text(subtitle!, style: context.textTheme.bodyMedium?.copyWith(color: Colors.white70), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerseOfTheDay extends ConsumerWidget {
  const _VerseOfTheDay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dailyQuoteProvider);
    return async.maybeWhen(
      data: (quote) {
        if (quote == null) return const SizedBox.shrink();
        return AppCard(
          onTap: () => context.pushNamed(RouteNames.knowledgeQuotes),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context).kbVerseOfTheDay, style: context.overline.copyWith(color: context.colors.textSecondary)),
              const Gap(AppSpacing.sm),
              QuoteView(quote: quote, showEnglish: false),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _QuickCategories extends StatelessWidget {
  const _QuickCategories({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, String)>[
      (AppIcons.blog, l10n.kbBlogs, RouteNames.knowledgeBlogs),
      (AppIcons.quote, l10n.kbQuotes, RouteNames.knowledgeQuotes),
      (AppIcons.festival, l10n.kbFestivals, RouteNames.knowledgeFestivals),
      (AppIcons.announcement, l10n.kbAnnouncements, RouteNames.knowledgeAnnouncements),
      (AppIcons.faq, l10n.kbFaqs, RouteNames.knowledgeFaq),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.kbQuickAccess),
        const Gap(AppSpacing.sm),
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, _) => const Gap(AppSpacing.md),
            itemBuilder: (context, i) {
              final (icon, label, route) = items[i];
              return _CategoryButton(icon: icon, label: label, onTap: () => context.pushNamed(route));
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryButton extends StatelessWidget {
  const _CategoryButton({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgAll,
        child: SizedBox(
          width: 76,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: context.scheme.primary.withValues(alpha: 0.1), borderRadius: AppRadius.lgAll),
                child: Icon(icon, color: context.scheme.primary),
              ),
              const Gap(AppSpacing.xs),
              Text(label, style: context.caption, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

class _LatestArticles extends ConsumerWidget {
  const _LatestArticles({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(knowledgeBlogsProvider);
    return async.maybeWhen(
      data: (blogs) {
        if (blogs.isEmpty) return const SizedBox.shrink();
        final items = blogs.take(4).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: l10n.kbLatestArticles, onViewAll: () => context.pushNamed(RouteNames.knowledgeBlogs), viewAllLabel: l10n.kbViewAll),
            const Gap(AppSpacing.sm),
            for (final b in items) ...[
              BlogListTile(blog: b, onTap: () => context.pushNamed(RouteNames.knowledgeBlogDetail, pathParameters: {'slug': b.slug})),
              const Gap(AppSpacing.sm),
            ],
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _UpcomingFestivals extends ConsumerWidget {
  const _UpcomingFestivals({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(upcomingFestivalsProvider);
    return async.maybeWhen(
      data: (festivals) {
        if (festivals.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: l10n.kbUpcomingFestivals, onViewAll: () => context.pushNamed(RouteNames.knowledgeFestivals), viewAllLabel: l10n.kbViewAll),
            const Gap(AppSpacing.sm),
            for (final f in festivals.take(3)) ...[
              FestivalTile(festival: f, onTap: () => context.pushNamed(RouteNames.knowledgeFestivalDetail, pathParameters: {'slug': f.slug})),
              const Gap(AppSpacing.sm),
            ],
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _LatestAnnouncements extends ConsumerWidget {
  const _LatestAnnouncements({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(announcementsProvider);
    return async.maybeWhen(
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: l10n.kbAnnouncements, onViewAll: () => context.pushNamed(RouteNames.knowledgeAnnouncements), viewAllLabel: l10n.kbViewAll),
            const Gap(AppSpacing.sm),
            for (final a in items.take(2)) ...[
              AnnouncementCard(
                announcement: a,
                onShare: () => showKnowledgeShare(context, ShareContent(title: a.title, subtitle: a.body, shareText: '${a.title}\n\n${a.body}')),
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

class _Collections extends ConsumerWidget {
  const _Collections({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(knowledgeCategoriesProvider);
    return async.maybeWhen(
      data: (categories) {
        if (categories.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: l10n.kbCollections),
            const Gap(AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final c in categories)
                  ActionChip(
                    avatar: Icon(AppIcons.category, size: 18, color: context.scheme.primary),
                    label: Text(c),
                    onPressed: () => context.pushNamed(RouteNames.knowledgeBlogs, queryParameters: {'category': c}),
                  ),
              ],
            ),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _AboutLinks extends StatelessWidget {
  const _AboutLinks({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final links = <(String, String?)>[
      (l10n.kbAboutMarg, null),
      (l10n.kbPrivacyPolicy, 'PRIVACY'),
      (l10n.kbTerms, 'TERMS'),
      (l10n.kbContactUs, 'CONTACT'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.kbAbout),
        const Gap(AppSpacing.sm),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < links.length; i++) ...[
                if (i > 0) const AppDivider(),
                ListTile(
                  leading: Icon(i == 0 ? AppIcons.info : AppIcons.description, color: context.scheme.primary),
                  title: Text(links[i].$1),
                  trailing: Icon(AppIcons.chevronRight, color: context.colors.textSecondary),
                  onTap: () => links[i].$2 == null
                      ? context.pushNamed(RouteNames.knowledgeAbout)
                      : context.pushNamed(RouteNames.knowledgeStaticPage, pathParameters: {'kind': links[i].$2!.toLowerCase()}),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
