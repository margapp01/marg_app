import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/knowledge_models.dart';

const _months = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// "May 20, 2024" — a stable, locale-neutral article date.
String knowledgeDate(DateTime? d) => d == null ? '' : '${_months[d.month - 1]} ${d.day}, ${d.year}';

/// "20 May 2024" — the day-first form used for festival dates.
String festivalDate(DateTime? d) => d == null ? '' : '${d.day} ${_months[d.month - 1]} ${d.year}';

/// A short "n min read" label from a blog's estimated reading time.
String readTime(BuildContext context, Blog blog) =>
    '${blog.readingMinutes} ${AppLocalizations.of(context).kbMinRead}';

/// A relative "2 hours ago / 3 days ago / Just now" label for announcements.
String relativeTime(BuildContext context, DateTime? d) {
  final l10n = AppLocalizations.of(context);
  if (d == null) return '';
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 60) return l10n.kbJustNow;
  if (diff.inHours < 24) return '${diff.inHours} ${l10n.kbHoursAgo}';
  return '${diff.inDays} ${l10n.kbDaysAgo}';
}

AppBadgeTone announcementTone(AnnouncementKind kind) => switch (kind) {
      AnnouncementKind.emergency => AppBadgeTone.error,
      AnnouncementKind.maintenance => AppBadgeTone.warning,
      AnnouncementKind.festival => AppBadgeTone.gold,
      AnnouncementKind.news || AnnouncementKind.unknown => AppBadgeTone.info,
    };

IconData announcementIcon(AnnouncementKind kind) => switch (kind) {
      AnnouncementKind.emergency => AppIcons.warning,
      AnnouncementKind.maintenance => AppIcons.maintenance,
      AnnouncementKind.festival => AppIcons.festival,
      AnnouncementKind.news || AnnouncementKind.unknown => AppIcons.announcement,
    };

String announcementLabel(BuildContext context, AnnouncementKind kind) {
  final l10n = AppLocalizations.of(context);
  return switch (kind) {
    AnnouncementKind.emergency => l10n.kbEmergency,
    AnnouncementKind.maintenance => l10n.kbMaintenance,
    AnnouncementKind.festival => l10n.kbFestival,
    AnnouncementKind.news || AnnouncementKind.unknown => l10n.kbNews,
  };
}

/// A small pill for a blog category (derived from data, never a fixed set).
class CategoryPill extends StatelessWidget {
  const CategoryPill({required this.label, super.key});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
        decoration: BoxDecoration(
          color: context.scheme.primary.withValues(alpha: 0.1),
          borderRadius: AppRadius.smAll,
        ),
        child: Text(
          label,
          style: context.overline.copyWith(color: context.scheme.primary, fontWeight: FontWeight.w600),
        ),
      );
}

/// A large, cover-led blog card (featured + library grid/list).
class BlogCard extends StatelessWidget {
  const BlogCard({required this.blog, required this.onTap, this.featured = false, super.key});
  final Blog blog;
  final VoidCallback onTap;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (blog.coverImageUrl != null)
            BannerImage(url: blog.coverImageUrl, aspectRatio: featured ? 16 / 9 : 3 / 2, borderRadius: BorderRadius.zero),
          Padding(
            padding: AppSpacing.allMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (blog.category != null) ...[
                  CategoryPill(label: blog.category!),
                  const Gap(AppSpacing.sm),
                ],
                Text(
                  blog.title,
                  style: (featured ? context.textTheme.titleMedium : context.textTheme.titleSmall)?.semiBold,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (featured && blog.excerpt != null) ...[
                  const Gap(AppSpacing.xs),
                  Text(
                    blog.excerpt!,
                    style: context.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const Gap(AppSpacing.sm),
                _MetaRow(blog: blog),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A compact, thumbnail-led blog row (recent / related / search results).
class BlogListTile extends StatelessWidget {
  const BlogListTile({required this.blog, required this.onTap, super.key});
  final Blog blog;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: AppSpacing.allSm,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppRadius.thumb,
            child: SizedBox(
              width: 72,
              height: 72,
              child: blog.coverImageUrl != null
                  ? AppNetworkImage(url: blog.coverImageUrl!, fit: BoxFit.cover)
                  : Container(
                      color: context.scheme.primary.withValues(alpha: 0.08),
                      child: Icon(AppIcons.blog, color: context.scheme.primary),
                    ),
            ),
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(blog.title, style: context.textTheme.titleSmall?.semiBold, maxLines: 2, overflow: TextOverflow.ellipsis),
                const Gap(AppSpacing.xs),
                _MetaRow(blog: blog),
              ],
            ),
          ),
          Icon(AppIcons.chevronRight, color: context.colors.textSecondary),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.blog});
  final Blog blog;

  @override
  Widget build(BuildContext context) {
    final date = knowledgeDate(blog.publishedAt);
    return Row(
      children: [
        Icon(AppIcons.timer, size: 14, color: context.colors.textSecondary),
        const Gap(AppSpacing.xxs),
        Text(readTime(context, blog), style: context.caption.copyWith(color: context.colors.textSecondary)),
        if (date.isNotEmpty) ...[
          Text('  ·  ', style: context.caption.copyWith(color: context.colors.textSecondary)),
          Flexible(child: Text(date, style: context.caption.copyWith(color: context.colors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ],
    );
  }
}

/// The verse block — Devanagari original first (when present), then the
/// translation and attribution. Reused on the hub + Daily Quotes screen.
class QuoteView extends StatelessWidget {
  const QuoteView({required this.quote, this.showEnglish = true, super.key});
  final Quote quote;
  final bool showEnglish;

  @override
  Widget build(BuildContext context) {
    final hi = quote.textHi;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(AppIcons.quote, color: context.colors.gold),
        const Gap(AppSpacing.sm),
        if (hi != null) ...[
          Text(hi, textAlign: TextAlign.center, style: context.textTheme.titleMedium?.copyWith(height: 1.7, color: context.scheme.onSurface)),
          if (showEnglish) const Gap(AppSpacing.sm),
        ],
        if (showEnglish || hi == null)
          Text(
            quote.text,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic, color: context.colors.textSecondary, height: 1.6),
          ),
        if (quote.attribution.isNotEmpty) ...[
          const Gap(AppSpacing.md),
          Text('— ${quote.attribution}', style: context.textTheme.labelLarge?.semiBold.copyWith(color: context.scheme.primary)),
        ],
      ],
    );
  }
}

/// A festival row with image, name, date and a localized countdown.
class FestivalTile extends StatelessWidget {
  const FestivalTile({required this.festival, required this.onTap, super.key});
  final Festival festival;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: AppSpacing.allSm,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppRadius.thumb,
            child: SizedBox(
              width: 64,
              height: 64,
              child: festival.imageUrl != null
                  ? AppNetworkImage(url: festival.imageUrl!, fit: BoxFit.cover)
                  : Container(
                      color: context.colors.gold.withValues(alpha: 0.15),
                      child: Icon(AppIcons.festival, color: context.colors.gold),
                    ),
            ),
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(festival.name, style: context.textTheme.titleSmall?.semiBold, maxLines: 1, overflow: TextOverflow.ellipsis),
                const Gap(AppSpacing.xxs),
                Text(festivalDate(festival.startDate), style: context.caption.copyWith(color: context.colors.textSecondary)),
                if (festival.deity != null)
                  Text(festival.deity!, style: context.caption.copyWith(color: context.colors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const Gap(AppSpacing.sm),
          _Countdown(festival: festival),
        ],
      ),
    );
  }
}

class _Countdown extends StatelessWidget {
  const _Countdown({required this.festival});
  final Festival festival;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final n = festival.daysUntil;
    final String text;
    if (festival.isToday) {
      text = l10n.kbHappeningNow;
    } else if (n == null) {
      return const SizedBox.shrink();
    } else if (n == 1) {
      text = l10n.kbTomorrow;
    } else if (n > 1) {
      text = '$n ${l10n.kbDaysToGo}';
    } else {
      return const SizedBox.shrink();
    }
    return Text(
      text,
      textAlign: TextAlign.end,
      style: context.caption.copyWith(color: context.scheme.primary, fontWeight: FontWeight.w700),
    );
  }
}

/// An announcement card — priority-coloured kind badge, title, body, timestamp.
class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({required this.announcement, required this.onShare, super.key});
  final Announcement announcement;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final a = announcement;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppBadge(label: announcementLabel(context, a.kind), tone: announcementTone(a.kind), icon: announcementIcon(a.kind)),
              if (a.pinned) ...[
                const Gap(AppSpacing.sm),
                Icon(AppIcons.bookmark, size: 16, color: context.colors.gold),
              ],
              const Spacer(),
              Text(relativeTime(context, a.createdAt), style: context.caption.copyWith(color: context.colors.textSecondary)),
            ],
          ),
          const Gap(AppSpacing.sm),
          Text(a.title, style: context.textTheme.titleSmall?.semiBold),
          const Gap(AppSpacing.xs),
          Text(a.body, style: context.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary, height: 1.5)),
          const Gap(AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onShare,
              icon: Icon(AppIcons.share, size: 18),
              label: Text(AppLocalizations.of(context).kbShare),
            ),
          ),
        ],
      ),
    );
  }
}
