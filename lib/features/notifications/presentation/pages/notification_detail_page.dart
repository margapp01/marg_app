import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/app_notification.dart';
import '../controllers/notification_controllers.dart';
import '../widgets/notification_link.dart';
import '../widgets/notification_widgets.dart';

/// Screen 5 — Notification Detail: a large illustration, rich body, a deep-link
/// CTA into the right module, and a share action. Opening marks it read.
class NotificationDetailPage extends ConsumerWidget {
  const NotificationDetailPage({required this.id, super.key});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(notificationDetailProvider(id));

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.ntDetailTitle)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(title: l10n.ntErrorTitle, message: l10n.ntErrorBody, onRetry: () => ref.invalidate(notificationDetailProvider(id))),
        data: (n) => _Detail(notification: n),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.notification});
  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (icon, color) = notificationVisual(context, notification.kind);
    final dest = resolveDestination(notification);

    return ListView(
      padding: AppSpacing.screenAll,
      children: [
        Center(
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.14)),
                clipBehavior: Clip.antiAlias,
                child: notification.imageUrl != null
                    ? AppNetworkImage(url: notification.imageUrl!, width: 120, height: 120)
                    : Icon(icon, size: 56, color: color),
              ),
              if (notification.kind == NotificationKind.visit)
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: context.scheme.surface),
                  child: Icon(AppIcons.success, color: context.colors.success, size: 30),
                ),
            ],
          ),
        ),
        const Gap(AppSpacing.md),
        Text(notification.title, style: context.textTheme.titleLarge?.bold, textAlign: TextAlign.center),
        const Gap(AppSpacing.xxs),
        Text('${notifTime(notification.createdAt)} · ${fullDate(notification.createdAt)}',
            style: context.caption.copyWith(color: context.colors.textSecondary), textAlign: TextAlign.center),
        const Gap(AppSpacing.lg),
        AppCard(
          variant: AppCardVariant.filled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notification.message, style: context.textTheme.bodyMedium?.copyWith(height: 1.5)),
              const Gap(AppSpacing.md),
              const AppDivider(),
              const Gap(AppSpacing.sm),
              _row(context, AppIcons.calendar, l10n.ntReceived, fullDate(notification.createdAt)),
              if (notification.readAt != null) ...[
                const Gap(AppSpacing.xs),
                _row(context, AppIcons.check, l10n.ntReadOn, fullDate(notification.readAt!)),
              ],
            ],
          ),
        ),
        const Gap(AppSpacing.lg),
        if (dest != null)
          AppButton.primary(
            label: _ctaLabel(l10n, dest.routeName),
            icon: AppIcons.chevronRight,
            onPressed: () => openNotificationDestination(context, notification),
          ),
        const Gap(AppSpacing.sm),
        AppButton.outlined(
          label: l10n.ntShare,
          icon: AppIcons.share,
          onPressed: () => context.pushNamed(RouteNames.notificationShare, pathParameters: {'id': notification.id}),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, IconData icon, String label, String value) => Row(
        children: [
          Icon(icon, size: 16, color: context.colors.textSecondary),
          const Gap(AppSpacing.sm),
          Expanded(child: Text(label, style: context.caption.copyWith(color: context.colors.textSecondary))),
          Text(value, style: context.textTheme.bodySmall?.semiBold),
        ],
      );

  String _ctaLabel(AppLocalizations l10n, String routeName) {
    switch (routeName) {
      case RouteNames.templeDetail:
      case RouteNames.explore:
        return l10n.ntOpenTemple;
      case RouteNames.cardDetail:
      case RouteNames.cards:
        return l10n.ntOpenCard;
      case RouteNames.routeDetail:
      case RouteNames.routes:
        return l10n.ntOpenRoute;
      case RouteNames.achievements:
        return l10n.ntOpenAchievement;
      case RouteNames.passport:
        return l10n.ntOpenPassport;
      case RouteNames.referrals:
        return l10n.ntOpenReferrals;
      default:
        return l10n.ntOpen;
    }
  }
}
