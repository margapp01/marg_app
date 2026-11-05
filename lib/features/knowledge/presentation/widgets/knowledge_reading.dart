import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/knowledge_models.dart';

/// Stories whose tags name the festival: a tag equal to the whole name, or to
/// one of its words longer than two letters ("Diwali" on "Diwali", "Navratri"
/// on "Chaitra Navratri"). The website applies the same rule.
List<Blog> storiesForFestival(String name, List<Blog> blogs, {int limit = 3}) {
  final full = name.toLowerCase();
  final words = full.split(RegExp(r'\s+')).where((w) => w.length > 2).toSet();
  return blogs
      .where((b) => b.tags.any((t) {
            final tag = t.toLowerCase();
            return tag == full || words.contains(tag);
          }))
      .take(limit)
      .toList();
}

/// The photo header of a festival or story: the cover image under a dark
/// fade, round back/share buttons, and the [pills], [title] and [subtitle]
/// laid over its foot — the same language as Temple Detail. Without an image
/// it falls back to a plain pinned app bar.
class KnowledgeHeroAppBar extends StatelessWidget {
  const KnowledgeHeroAppBar({
    required this.title,
    this.imageUrl,
    this.onShare,
    this.pills = const [],
    this.subtitle,
    this.showTitle = true,
    super.key,
  });

  final String title;
  final String? imageUrl;
  final VoidCallback? onShare;
  final List<Widget> pills;

  /// A line under the title, such as the date.
  final Widget? subtitle;

  /// Off when the page sets the title below the photo itself (stories).
  final bool showTitle;

  static const double _expandedHeight = 300;

  void _back(BuildContext context) => context.canPop() ? context.pop() : context.goNamed(RouteNames.knowledge);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final image = imageUrl;
    if (image == null) {
      return SliverAppBar(
        pinned: true,
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          if (onShare != null) IconButton(icon: Icon(AppIcons.share), tooltip: l10n.kbShare, onPressed: onShare),
        ],
      );
    }
    return SliverAppBar(
      expandedHeight: _expandedHeight,
      pinned: true,
      stretch: true,
      backgroundColor: context.scheme.secondary,
      foregroundColor: Colors.white,
      leading: PhotoIconButton(
        icon: AppIcons.back,
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: () => _back(context),
      ),
      actions: [
        if (onShare != null) PhotoIconButton(icon: AppIcons.share, tooltip: l10n.kbShare, onPressed: onShare!),
        const Gap.h(AppSpacing.sm),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            AppNetworkImage(url: image, placeholderIcon: AppIcons.festival),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                  stops: [0.35, 1.0],
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
                  if (pills.isNotEmpty) Wrap(spacing: AppSpacing.xs, runSpacing: AppSpacing.xs, children: pills),
                  if (showTitle) ...[
                    const Gap(AppSpacing.sm),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.displayText.headlineLarge.withColor(Colors.white),
                    ),
                  ],
                  if (subtitle != null) ...[
                    const Gap(AppSpacing.xxs),
                    DefaultTextStyle.merge(
                      style: context.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      child: IconTheme.merge(data: const IconThemeData(color: Colors.white70, size: 16), child: subtitle!),
                    ),
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

/// The invitation every festival and story ends with: visit a temple near
/// you, check in, and collect its Sacred Card. A parchment panel, like the
/// hero surfaces of the collection hubs.
class TempleVisitCta extends StatelessWidget {
  const TempleVisitCta({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ParchmentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IllustratedIcon(fallbackIcon: AppIcons.temple, color: context.scheme.primary),
              const Gap.h(AppSpacing.md),
              Expanded(child: Text(title, style: context.displayText.titleLarge.withColor(context.scheme.secondary))),
            ],
          ),
          const Gap(AppSpacing.md),
          Text(l10n.kbVisitBody, style: context.textTheme.bodyMedium?.copyWith(height: 1.5)),
          const Gap(AppSpacing.lg),
          AppButton.primary(
            label: l10n.kbVisitCta,
            icon: AppIcons.nearby,
            onPressed: () => context.goNamed(RouteNames.exploreNearby),
          ),
        ],
      ),
    );
  }
}

/// "In this article": the story's section headings, folded away until opened
/// so a long story starts straight away; tapping one jumps to it.
class ArticleContents extends StatelessWidget {
  const ArticleContents({required this.headings, required this.onSelect, super.key});

  final List<String> headings;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      variant: AppCardVariant.outlined,
      padding: EdgeInsets.zero,
      child: ExpandableSection(
        leading: Icon(AppIcons.blog, color: context.scheme.primary),
        title: Row(
          children: [
            Flexible(child: Text(l10n.kbInThisArticle)),
            const Gap.h(AppSpacing.sm),
            AppBadge(label: '${headings.length}', tone: AppBadgeTone.neutral),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GoldRule(),
            const Gap(AppSpacing.xs),
            for (var i = 0; i < headings.length; i++)
              InkWell(
                borderRadius: AppRadius.smAll,
                onTap: () => onSelect(i),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
                  child: Row(
                    children: [
                      Icon(AppIcons.chevronRight, size: 18, color: context.scheme.primary),
                      const Gap.h(AppSpacing.xs),
                      Expanded(child: Text(headings[i], style: context.textTheme.bodyMedium?.medium)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
