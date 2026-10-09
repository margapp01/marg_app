import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/app_notification.dart';
import '../controllers/notification_controllers.dart';
import '../widgets/activity_filter_sheet.dart';
import '../widgets/notification_widgets.dart';

/// Screen 2 — the Activity Feed: the same notification stream as the
/// devotee's journey rail (like the Passport timeline) — grouped by recency
/// under gold rules, each event a card on the rail — with type + date
/// filters.
class ActivityFeedPage extends ConsumerStatefulWidget {
  const ActivityFeedPage({super.key});

  @override
  ConsumerState<ActivityFeedPage> createState() => _ActivityFeedPageState();
}

class _ActivityFeedPageState extends ConsumerState<ActivityFeedPage> {
  final _scroll = ScrollController();
  ActivityFilter _filter = const ActivityFilter();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 320) {
        ref.read(notificationFeedProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final feed = ref.watch(notificationFeedProvider);

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.ntActivityFeed,
          style: context.textTheme.titleMedium?.semiBold.withColor(context.scheme.secondary),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Badge(isLabelVisible: !_filter.isDefault, child: const Icon(AppIcons.filter)),
            tooltip: l10n.ntFilterActivity,
            onPressed: () async {
              final r = await showActivityFilterSheet(context, _filter);
              if (r != null) setState(() => _filter = r);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: AppSpacing.screenH,
              children: [
                for (final f in NotificationFilter.values) ...[
                  Center(child: AppFilterChip(label: _quickLabel(l10n, f), selected: _filter.type == f, onSelected: (_) => setState(() => _filter = _filter.copyWith(type: f)))),
                  const Gap(AppSpacing.sm),
                ],
              ],
            ),
          ),
          Expanded(
            child: feed.when(
              loading: () => const LoadingView(),
              error: (_, _) => ErrorView(title: l10n.ntErrorTitle, message: l10n.ntErrorBody, onRetry: () => ref.read(notificationFeedProvider.notifier).refresh()),
              data: (state) {
                final items = state.items.where(_filter.matches).toList();
                if (items.isEmpty) {
                  return _Empty(onExplore: () => context.goNamed(RouteNames.explore));
                }
                final groups = groupByRecency(items);
                return RefreshIndicator(
                  onRefresh: () => ref.read(notificationFeedProvider.notifier).refresh(),
                  child: ListView.builder(
                    controller: _scroll,
                    padding: AppSpacing.screenAll,
                    itemCount: groups.length + 2,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: IntroBanner(
                            icon: AppIcons.history,
                            title: l10n.ntActivityIntroTitle,
                            message: l10n.ntActivityIntroBody,
                          ).fadeIn(),
                        );
                      }
                      final gi = index - 1;
                      if (gi == groups.length) {
                        return state.loadingMore
                            ? const Padding(padding: EdgeInsets.all(AppSpacing.md), child: Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))))
                            : const SizedBox.shrink();
                      }
                      final (bucket, list) = groups[gi];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.md),
                            child: GoldRuleHeader(label: recencyLabel(l10n, bucket), count: list.length),
                          ),
                          for (final (i, n) in list.indexed)
                            _FeedEvent(
                              notification: n,
                              isLast: i == list.length - 1,
                              onTap: () => context.pushNamed(RouteNames.notificationDetail, pathParameters: {'id': n.id}),
                            ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _quickLabel(AppLocalizations l10n, NotificationFilter f) => switch (f) {
        NotificationFilter.all => l10n.ntAll,
        NotificationFilter.visits => l10n.ntVisits,
        NotificationFilter.achievements => l10n.ntAchievements,
        NotificationFilter.cards => l10n.ntCards,
        NotificationFilter.routes => l10n.ntRoutes,
        NotificationFilter.trust => l10n.ntTrust,
        NotificationFilter.passport => l10n.ntPassport,
        NotificationFilter.system => l10n.ntSystem,
        NotificationFilter.marketing => l10n.ntUpdates,
      };
}

/// One event on the rail: its kind's mark on the node, the title, the
/// message and when — unread ones outlined in saffron.
class _FeedEvent extends StatelessWidget {
  const _FeedEvent({required this.notification, required this.isLast, required this.onTap});

  final AppNotification notification;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final (icon, color) = notificationVisual(context, n.kind);
    return JourneyRailTile(
      icon: icon,
      color: color,
      title: n.title,
      titleMaxLines: 2,
      subtitle: n.message,
      subtitleMaxLines: 2,
      imageUrl: n.imageUrl,
      caption: notifTime(n.createdAt),
      captionIcon: AppIcons.timer,
      highlighted: !n.isRead,
      isLast: isLast,
      onTap: onTap,
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onExplore});
  final VoidCallback onExplore;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight),
          child: EmptyView(art: StateArt.notifications, 
            icon: AppIcons.history,
            title: l10n.ntNoActivityTitle,
            message: l10n.ntNoActivityBody,
            action: AppButton.primary(label: l10n.ntExploreTemples, icon: AppIcons.explore, expand: false, onPressed: onExplore),
          ),
        ),
      ),
    );
  }
}
