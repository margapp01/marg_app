import 'package:flutter/material.dart';
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

/// Festival detail: a photo hero (countdown, deity, where it is observed,
/// name and date), the festival's story and significance (`description`),
/// the stories and guides tagged with it, and an invitation to celebrate it
/// at a temple nearby.
class FestivalDetailPage extends ConsumerWidget {
  const FestivalDetailPage({required this.slug, super.key});
  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(festivalDetailProvider(slug));

    return Scaffold(
      backgroundColor: context.scheme.surface,
      body: async.when(
        loading: () => Scaffold(appBar: AppBar(title: Text(l10n.kbFestival)), body: const LoadingView()),
        error: (_, _) => Scaffold(
          appBar: AppBar(title: Text(l10n.kbFestival)),
          body: ErrorView(title: l10n.kbErrorTitle, message: l10n.kbErrorBody, onRetry: () => ref.invalidate(festivalDetailProvider(slug))),
        ),
        data: (f) => _Body(festival: f, slug: slug),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.festival, required this.slug});
  final Festival festival;
  final String slug;

  void _share(BuildContext context, AppLocalizations l10n) => showKnowledgeShare(
        context,
        ShareContent(
          title: festival.name,
          subtitle: festival.deity,
          heroImageUrl: festival.imageUrl,
          message: ShareMessage(
            kind: ShareKind.festival,
            itemId: slug,
            path: SharePaths.festival(slug),
            text: ShareCopy.festival(l10n, name: festival.name, date: festival.startDate != null ? festivalDate(festival.startDate) : null),
          ),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final f = festival;
    final countdown = countdownLabel(l10n, f);
    final stories = ref.watch(knowledgeBlogsProvider).maybeWhen(
          data: (blogs) => storiesForFestival(f.name, blogs),
          orElse: () => const <Blog>[],
        );

    return CustomScrollView(
      slivers: [
        KnowledgeHeroAppBar(
          title: f.name,
          imageUrl: f.imageUrl,
          onShare: () => _share(context, l10n),
          pills: [
            if (countdown != null) PhotoPill(label: countdown, icon: AppIcons.timer, color: context.scheme.primary),
            if (f.deity != null) PhotoPill(label: f.deity!, icon: AppIcons.temple, color: context.scheme.primary),
            if (f.scope != null)
              PhotoPill(label: f.scope == 'NATIONAL' ? l10n.kbAcrossIndia : l10n.kbRegional, icon: AppIcons.location),
          ],
          subtitle: Row(
            children: [
              Icon(AppIcons.calendar),
              const Gap.h(AppSpacing.xxs),
              Text(festivalDate(f.startDate)),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxxl + context.viewPadding.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (f.imageUrl == null) ...[
                  Text(f.name, style: context.displayText.headlineMedium.withColor(context.scheme.secondary)),
                  const Gap(AppSpacing.xs),
                  Text(festivalDate(f.startDate), style: context.textTheme.bodyMedium?.semiBold),
                  const Gap(AppSpacing.lg),
                ],
                if (f.description != null && f.description!.isNotEmpty) ...[
                  GoldRuleHeader(label: l10n.kbAboutFestival(f.name)),
                  const Gap(AppSpacing.md),
                  HtmlContentView(html: f.description!),
                  const Gap(AppSpacing.xxl),
                ],
                TempleVisitCta(title: l10n.kbVisitFestivalTitle(f.name)),
                if (stories.isNotEmpty) ...[
                  const Gap(AppSpacing.xxl),
                  GoldRuleHeader(label: l10n.kbStoriesAndGuides, count: stories.length),
                  const Gap(AppSpacing.md),
                  for (final b in stories) ...[
                    BlogListTile(
                      blog: b,
                      onTap: () => context.pushNamed(RouteNames.knowledgeBlogDetail, pathParameters: {'slug': b.slug}),
                    ),
                    const Gap(AppSpacing.sm),
                  ],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
