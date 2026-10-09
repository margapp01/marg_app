import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../../home/domain/entities/home_dashboard.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../domain/entities/search_models.dart';
import 'search_visuals.dart';

/// Where a "Browse" shortcut leads (the page decides the actual route).
enum SearchBrowse { temples, routes, festivals, blogs, faqs }

/// Pre-typing discovery: recent (local) and trending (curated — the backend
/// has no trending endpoint) searches, "Browse" shortcuts, and popular temples,
/// festivals and blogs reused from the already-cached Home dashboard (no extra
/// network calls). Sections with no data are hidden.
class SearchDiscovery extends ConsumerWidget {
  const SearchDiscovery({
    required this.recent,
    required this.onTermTap,
    required this.onRemoveRecent,
    required this.onClearRecent,
    required this.onBrowse,
    required this.onOpenTemple,
    required this.onOpenFestival,
    required this.onOpenBlog,
    super.key,
  });

  final List<String> recent;
  final ValueChanged<String> onTermTap;
  final ValueChanged<String> onRemoveRecent;
  final VoidCallback onClearRecent;
  final ValueChanged<SearchBrowse> onBrowse;

  /// Each receives the item's slug.
  final ValueChanged<String> onOpenTemple;
  final ValueChanged<String> onOpenFestival;
  final ValueChanged<String> onOpenBlog;

  static const _trending = <String>['Mahakal', 'Vaishno Devi', 'Jagannath Puri', 'Ujjain', 'Tirupati Balaji'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final dashboard = ref.watch(homeControllerProvider).valueOrNull;
    final temples = dashboard?.nearbyTemples ?? const <NearbyTemple>[];
    final festivals = dashboard?.upcomingFestivals ?? const <HomeFestival>[];
    final blogs = dashboard?.blogs ?? const <HomeBlog>[];

    return ListView(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.huge),
      children: [
        if (recent.isNotEmpty) ...[
          _Section(
            title: l10n.searchRecent,
            action: TextButton(onPressed: onClearRecent, child: Text(l10n.searchClearAll)),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final term in recent)
                  InputChip(
                    avatar: Icon(AppIcons.history, size: 18, color: context.colors.textSecondary),
                    label: Text(term),
                    onPressed: () => onTermTap(term),
                    onDeleted: () => onRemoveRecent(term),
                  ),
              ],
            ),
          ),
        ],
        _Section(
          title: l10n.searchTrending,
          titleIcon: AppIcons.trending,
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final term in _trending)
                ActionChip(
                  avatar: Icon(AppIcons.search, size: 16, color: context.scheme.primary),
                  label: Text(term),
                  onPressed: () => onTermTap(term),
                ),
            ],
          ),
        ),
        _Section(title: l10n.searchBrowse, child: _BrowseRow(onBrowse: onBrowse)),
        if (temples.isNotEmpty)
          _Section(
            title: l10n.searchPopularTemples,
            padded: false,
            child: SizedBox(
              height: 214,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xs),
                itemCount: temples.length,
                separatorBuilder: (_, _) => const Gap.h(AppSpacing.md),
                itemBuilder: (context, i) {
                  final t = temples[i];
                  return SizedBox(
                    width: 156,
                    child: TempleCardBase(
                      dense: true,
                      imageHeight: 104,
                      name: t.name,
                      location: t.place,
                      imageUrl: t.imageUrl,
                      onTap: () => onOpenTemple(t.slug),
                    ),
                  );
                },
              ),
            ),
          ),
        if (festivals.isNotEmpty)
          _Section(
            title: l10n.searchPopularFestivals,
            child: AppCard(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Column(
                children: [
                  for (final f in festivals.take(3))
                    _DiscoveryRow(
                      leading: _DateBadge(date: f.startDate),
                      title: f.name,
                      subtitle: f.deity,
                      onTap: () => onOpenFestival(f.slug),
                    ),
                ],
              ),
            ),
          ),
        if (blogs.isNotEmpty)
          _Section(
            title: l10n.searchPopularBlogs,
            child: AppCard(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Column(
                children: [
                  for (final b in blogs.take(3))
                    _DiscoveryRow(
                      leading: _Thumb(imageUrl: b.coverImageUrl, type: SearchType.blog),
                      title: b.title,
                      subtitle: b.category,
                      onTap: () => onOpenBlog(b.slug),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// A titled discovery block with the screen gutter (or full-bleed rails).
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.titleIcon, this.action, this.padded = true});

  final String title;
  final IconData? titleIcon;
  final Widget? action;
  final Widget child;
  final bool padded;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppSpacing.screenH,
            child: SizedBox(
              height: 40,
              child: Row(
                children: [
                  Text(title, style: context.textTheme.titleMedium?.bold.withColor(context.scheme.secondary)),
                  if (titleIcon != null) ...[
                    const Gap.h(AppSpacing.xs),
                    Icon(titleIcon, size: 18, color: context.scheme.primary),
                  ],
                  const Spacer(),
                  ?action,
                ],
              ),
            ),
          ),
          const Gap(AppSpacing.xs),
          if (padded) Padding(padding: AppSpacing.screenH, child: child) else child,
        ],
      ),
    );
  }
}

/// Pastel shortcut tiles into the browse screens.
class _BrowseRow extends StatelessWidget {
  const _BrowseRow({required this.onBrowse});

  final ValueChanged<SearchBrowse> onBrowse;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    final items = <(SearchBrowse, SearchType, String, Color)>[
      (SearchBrowse.temples, SearchType.temple, l10n.titleTemples, p.tilePeach),
      (SearchBrowse.routes, SearchType.route, l10n.titleRoutes, p.tileSky),
      (SearchBrowse.festivals, SearchType.festival, l10n.searchGroupFestivals, p.tileRose),
      (SearchBrowse.blogs, SearchType.blog, l10n.searchGroupBlogs, p.tileButter),
      (SearchBrowse.faqs, SearchType.faq, l10n.searchGroupFaqs, p.tileLavender),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (browse, type, label, tint) in items) ...[
          Expanded(
            child: Semantics(
              button: true,
              label: label,
              child: InkWell(
                onTap: () => onBrowse(browse),
                borderRadius: AppRadius.mdAll,
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(color: tint, borderRadius: AppRadius.mdAll),
                      child: Icon(searchTypeIcon(type), color: searchTypeColor(context, type)),
                    ),
                    const Gap(AppSpacing.xs),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.labelMedium?.semiBold.withColor(context.scheme.secondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (browse != items.last.$1) const Gap.h(AppSpacing.xs),
        ],
      ],
    );
  }
}

class _DiscoveryRow extends StatelessWidget {
  const _DiscoveryRow({required this.leading, required this.title, required this.onTap, this.subtitle});

  final Widget leading;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            leading,
            const Gap.h(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.textTheme.titleSmall?.semiBold),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary),
                    ),
                ],
              ),
            ),
            Icon(AppIcons.chevronRight, color: context.colors.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// "11 / Oct" in a soft saffron tile, like the Home festivals list.
class _DateBadge extends StatelessWidget {
  const _DateBadge({required this.date});

  final DateTime? date;

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  @override
  Widget build(BuildContext context) {
    final primary = context.scheme.primary;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: primary.withValues(alpha: 0.25)),
      ),
      child: date == null
          ? Icon(AppIcons.calendar, color: primary)
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${date!.day}', style: context.textTheme.titleMedium?.bold.withColor(primary)),
                Text(_months[date!.month - 1], style: context.textTheme.labelSmall?.withColor(primary)),
              ],
            ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.imageUrl, required this.type});

  final String? imageUrl;
  final SearchType type;

  @override
  Widget build(BuildContext context) {
    final accent = searchTypeColor(context, type);
    final placeholder = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(color: accent.withValues(alpha: 0.12), borderRadius: AppRadius.mdAll),
      child: Icon(searchTypeIcon(type), color: accent),
    );
    if (imageUrl == null) return placeholder;
    return AppNetworkImage(
      url: imageUrl!,
      width: 48,
      height: 48,
      borderRadius: AppRadius.mdAll,
      fallback: placeholder,
    );
  }
}
