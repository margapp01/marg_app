import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/app_notification.dart';
import '../controllers/notification_controllers.dart';
import '../widgets/notification_widgets.dart';

enum _CenterTab { all, unread, system }

/// Screen 1 — the Notification Center: a premium inbox grouped by recency with
/// All / Unread / System tabs, mark-all-read, infinite scroll and pull-refresh.
class NotificationCenterPage extends ConsumerStatefulWidget {
  const NotificationCenterPage({super.key});

  @override
  ConsumerState<NotificationCenterPage> createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends ConsumerState<NotificationCenterPage> {
  final _scroll = ScrollController();
  _CenterTab _tab = _CenterTab.all;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 320) {
      ref.read(notificationFeedProvider.notifier).loadMore();
    }
  }

  bool _matches(AppNotification n) => switch (_tab) {
        _CenterTab.all => true,
        _CenterTab.unread => !n.isRead,
        _CenterTab.system => n.kind == NotificationKind.system || n.kind == NotificationKind.marketing,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final feed = ref.watch(notificationFeedProvider);
    final unread = ref.watch(unreadCountProvider).valueOrNull ?? 0;

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(
        title: Text(l10n.ntTitle),
        actions: [
          IconButton(icon: const Icon(AppIcons.history), tooltip: l10n.ntHistory, onPressed: () => context.pushNamed(RouteNames.notificationHistory)),
          IconButton(icon: const Icon(AppIcons.settings), tooltip: l10n.ntSettingsTitle, onPressed: () => context.pushNamed(RouteNames.notificationSettings)),
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
                _tabChip(l10n.ntAll, _CenterTab.all),
                const Gap(AppSpacing.sm),
                _tabChip(unread > 0 ? '${l10n.ntUnread} $unread' : l10n.ntUnread, _CenterTab.unread),
                const Gap(AppSpacing.sm),
                _tabChip(l10n.ntSystem, _CenterTab.system),
              ],
            ),
          ),
          _UnreadBar(count: unread),
          Expanded(
            child: feed.when(
              loading: () => const LoadingView(),
              error: (_, _) => ErrorView(title: l10n.ntErrorTitle, message: l10n.ntErrorBody, onRetry: () => ref.read(notificationFeedProvider.notifier).refresh()),
              data: (state) {
                final items = state.items.where(_matches).toList();
                if (items.isEmpty) return _EmptyInbox(tab: _tab);
                final groups = groupByRecency(items);
                return RefreshIndicator(
                  onRefresh: () => ref.read(notificationFeedProvider.notifier).refresh(),
                  child: ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                    itemCount: groups.length + 1,
                    itemBuilder: (context, gi) {
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
                            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xs),
                            child: Text(recencyLabel(l10n, bucket), style: context.textTheme.labelMedium?.semiBold.copyWith(color: context.colors.textSecondary)),
                          ),
                          for (final n in list)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                              child: NotificationTile(
                                notification: n,
                                onTap: () => context.pushNamed(RouteNames.notificationDetail, pathParameters: {'id': n.id}),
                              ),
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

  Widget _tabChip(String label, _CenterTab tab) => Center(
        child: AppFilterChip(label: label, selected: _tab == tab, onSelected: (_) => setState(() => _tab = tab)),
      );
}

/// "N unread" with a one-tap Mark all read; collapses away once the inbox is
/// caught up.
class _UnreadBar extends ConsumerStatefulWidget {
  const _UnreadBar({required this.count});
  final int count;

  @override
  ConsumerState<_UnreadBar> createState() => _UnreadBarState();
}

class _UnreadBarState extends ConsumerState<_UnreadBar> {
  bool _busy = false;

  Future<void> _markAll() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    final ok = await ref.read(notificationFeedProvider.notifier).markAllRead();
    if (!mounted) return;
    setState(() => _busy = false);
    ok
        ? AppToast.show(context, l10n.ntAllCaughtUp, type: FeedbackType.success)
        : AppToast.show(context, l10n.ntMarkAllFailed, type: FeedbackType.error);
  }

  static const double _iconSize = 40;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final saffron = context.scheme.primary;
    final show = widget.count > 0;
    return AnimatedSize(
      duration: AppDurations.normal,
      curve: AppCurves.standard,
      alignment: Alignment.topCenter,
      child: !show
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xs, AppSpacing.lg, AppSpacing.sm),
              child: Container(
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.sm, AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Color.alphaBlend(saffron.withValues(alpha: 0.07), context.colors.card),
                  borderRadius: AppRadius.card,
                  border: Border.all(color: saffron.withValues(alpha: 0.22)),
                ),
                child: Row(
                  children: [
                    Badge.count(
                      count: widget.count,
                      backgroundColor: saffron,
                      textColor: context.colors.card,
                      child: IllustratedIcon(fallbackIcon: AppIcons.notifications, color: saffron, size: _iconSize),
                    ),
                    const Gap.h(AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.ntUnreadCount(widget.count),
                            style: context.textTheme.titleSmall?.semiBold.withColor(context.scheme.secondary),
                          ),
                          Text(
                            l10n.ntUnreadHint,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.caption.copyWith(color: context.colors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const Gap.h(AppSpacing.sm),
                    AppButton.secondary(
                      label: l10n.ntMarkAllRead,
                      icon: AppIcons.doneAll,
                      size: AppButtonSize.small,
                      expand: false,
                      busy: _busy,
                      onPressed: _busy ? null : _markAll,
                    ),
                  ],
                ),
              ),
            ).fadeIn(),
    );
  }
}

class _EmptyInbox extends StatelessWidget {
  const _EmptyInbox({required this.tab});
  final _CenterTab tab;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight),
          child: EmptyView(art: StateArt.notifications, 
            icon: AppIcons.notifications,
            title: l10n.ntEmptyTitle,
            message: l10n.ntEmptyBody,
            action: AppButton.primary(
              label: l10n.ntExploreTemples,
              icon: AppIcons.explore,
              expand: false,
              onPressed: () => context.goNamed(RouteNames.explore),
            ),
          ),
        ),
      ),
    );
  }
}
