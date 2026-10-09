import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/hub_content.dart';

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

/// (icon, colour) for a notification kind — the single visual vocabulary shared
/// by the Center, Activity Feed, History and Detail.
(IconData, Color) notificationVisual(BuildContext context, NotificationKind kind) {
  switch (kind) {
    case NotificationKind.visit:
      return (AppIcons.visit, context.colors.success);
    case NotificationKind.card:
      return (AppIcons.card, context.colors.info);
    case NotificationKind.achievement:
      return (AppIcons.achievement, context.colors.gold);
    case NotificationKind.route:
      return (AppIcons.route, context.scheme.primary);
    case NotificationKind.passport:
      return (AppIcons.passport, context.scheme.primary);
    case NotificationKind.trust:
      return (AppIcons.trustScore, context.colors.gold);
    case NotificationKind.marketing:
      return (AppIcons.notifications, context.scheme.primary);
    case NotificationKind.system:
    case NotificationKind.unknown:
      return (AppIcons.info, context.colors.textSecondary);
  }
}

/// Short timestamp: time-of-day when today, else a short date.
String notifTime(DateTime dt) {
  final now = DateTime.now();
  if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:${dt.minute.toString().padLeft(2, '0')} $period';
  }
  return '${dt.day} ${_months[dt.month - 1]}';
}

String fullDate(DateTime dt) => '${dt.day} ${_months[dt.month - 1]} ${dt.year}';

/// Recency buckets for the inbox. Returns ordered (labelKey, items) groups.
enum RecencyBucket { today, yesterday, thisWeek, earlier }

List<(RecencyBucket, List<AppNotification>)> groupByRecency(List<AppNotification> items) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final weekStart = today.subtract(const Duration(days: 7));
  final buckets = <RecencyBucket, List<AppNotification>>{
    for (final b in RecencyBucket.values) b: [],
  };
  for (final n in items) {
    final d = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
    if (!d.isBefore(today)) {
      buckets[RecencyBucket.today]!.add(n);
    } else if (!d.isBefore(yesterday)) {
      buckets[RecencyBucket.yesterday]!.add(n);
    } else if (!d.isBefore(weekStart)) {
      buckets[RecencyBucket.thisWeek]!.add(n);
    } else {
      buckets[RecencyBucket.earlier]!.add(n);
    }
  }
  return [
    for (final b in RecencyBucket.values)
      if (buckets[b]!.isNotEmpty) (b, buckets[b]!),
  ];
}

String recencyLabel(AppLocalizations l10n, RecencyBucket b) {
  switch (b) {
    case RecencyBucket.today:
      return l10n.ntToday;
    case RecencyBucket.yesterday:
      return l10n.ntYesterday;
    case RecencyBucket.thisWeek:
      return l10n.ntThisWeek;
    case RecencyBucket.earlier:
      return l10n.ntEarlier;
  }
}

/// An inbox-style notification row (icon/image, title, message, time, unread dot).
class NotificationTile extends StatelessWidget {
  const NotificationTile({required this.notification, required this.onTap, super.key});
  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = notificationVisual(context, notification.kind);
    final unread = !notification.isRead;
    return Semantics(
      button: true,
      label: '${notification.title}. ${notification.message}. ${unread ? AppLocalizations.of(context).ntUnread : ''}',
      child: Material(
        color: unread ? context.scheme.primary.withValues(alpha: 0.05) : Colors.transparent,
        borderRadius: AppRadius.lgAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.lgAll,
          child: Padding(
            padding: AppSpacing.allMd,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Leading(notification: notification, icon: icon, color: color),
                const Gap(AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(notification.title, style: context.textTheme.bodyMedium?.semiBold, maxLines: 1, overflow: TextOverflow.ellipsis)),
                          const Gap(AppSpacing.xs),
                          Text(notifTime(notification.createdAt), style: context.overline.copyWith(color: context.colors.textSecondary)),
                        ],
                      ),
                      const Gap(AppSpacing.xxs),
                      Text(notification.message, style: context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                if (unread) ...[
                  const Gap(AppSpacing.sm),
                  Container(margin: const EdgeInsets.only(top: 6), width: 8, height: 8, decoration: BoxDecoration(color: context.scheme.primary, shape: BoxShape.circle)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Leading extends StatelessWidget {
  const _Leading({required this.notification, required this.icon, required this.color});
  final AppNotification notification;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (notification.imageUrl != null) {
      return ClipRRect(borderRadius: AppRadius.mdAll, child: AppNetworkImage(url: notification.imageUrl!, width: 44, height: 44));
    }
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: AppRadius.mdAll),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

/// A featured festival banner with a countdown ("10 Days to go").
class FestivalBanner extends StatelessWidget {
  const FestivalBanner({required this.festival, required this.onTap, super.key});
  final Festival festival;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final days = festival.daysUntil;
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: AppRadius.lgAll,
        child: Stack(
          children: [
            if (festival.imageUrl != null)
              Positioned.fill(child: AppNetworkImage(url: festival.imageUrl!, fit: BoxFit.cover))
            else
              Positioned.fill(child: ColoredBox(color: context.colors.templeStone.withValues(alpha: 0.4))),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withValues(alpha: 0.1), Colors.black.withValues(alpha: 0.7)]),
                ),
              ),
            ),
            Padding(
              padding: AppSpacing.allLg,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 56),
                  Text(festival.name, style: context.brandText.headlineSmall.copyWith(color: Colors.white)),
                  if (festival.startDate != null)
                    Text(fullDate(festival.startDate!), style: context.textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.9))),
                  const Gap(AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                    decoration: BoxDecoration(color: context.colors.gold, borderRadius: AppRadius.fullAll),
                    child: Text(
                      festival.isToday ? l10n.ntToday : (days != null ? '$days ${l10n.ntDaysToGo}' : ''),
                      style: context.caption.copyWith(color: Colors.black, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A compact festival row (icon + name + date + countdown).
class FestivalRow extends StatelessWidget {
  const FestivalRow({required this.festival, required this.onTap, super.key});
  final Festival festival;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final days = festival.daysUntil;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: context.colors.gold.withValues(alpha: 0.14), borderRadius: AppRadius.mdAll),
            child: festival.imageUrl != null
                ? ClipRRect(borderRadius: AppRadius.mdAll, child: AppNetworkImage(url: festival.imageUrl!, width: 42, height: 42))
                : Icon(AppIcons.aarti, color: context.colors.gold, size: 22),
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(festival.name, style: context.textTheme.bodyMedium?.semiBold, maxLines: 1, overflow: TextOverflow.ellipsis),
                if (festival.startDate != null)
                  Text(fullDate(festival.startDate!), style: context.caption.copyWith(color: context.colors.textSecondary)),
              ],
            ),
          ),
          const Gap(AppSpacing.sm),
          Text(
            festival.isToday ? l10n.ntToday : (days != null ? '$days ${l10n.ntDays}' : ''),
            style: context.textTheme.bodySmall?.semiBold.copyWith(color: context.scheme.primary),
          ),
        ],
      ),
    );
  }
}
