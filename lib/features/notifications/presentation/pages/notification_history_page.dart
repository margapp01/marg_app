import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/app_notification.dart';
import '../controllers/notification_controllers.dart';
import '../widgets/notification_widgets.dart';

enum _HistoryTab { all, read, unread }

/// Screen 7 — Notification History: All / Read / Unread (Archived is not a
/// backend concept, so it's not shown), with search + date grouping.
class NotificationHistoryPage extends ConsumerStatefulWidget {
  const NotificationHistoryPage({super.key});

  @override
  ConsumerState<NotificationHistoryPage> createState() => _NotificationHistoryPageState();
}

class _NotificationHistoryPageState extends ConsumerState<NotificationHistoryPage> {
  final _scroll = ScrollController();
  _HistoryTab _tab = _HistoryTab.all;
  String _query = '';
  bool _searching = false;

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

  bool _matches(AppNotification n) {
    final tabOk = switch (_tab) {
      _HistoryTab.all => true,
      _HistoryTab.read => n.isRead,
      _HistoryTab.unread => !n.isRead,
    };
    if (!tabOk) return false;
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return n.title.toLowerCase().contains(q) || n.message.toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final feed = ref.watch(notificationFeedProvider);

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(
        title: _searching
            ? AppSearchBar(hint: l10n.ntSearchHint, autofocus: true, onChanged: (v) => setState(() => _query = v))
            : Text(l10n.ntHistory),
        actions: [
          IconButton(
            icon: Icon(_searching ? AppIcons.close : AppIcons.search),
            onPressed: () => setState(() {
              _searching = !_searching;
              if (!_searching) _query = '';
            }),
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
                _chip(l10n.ntAll, _HistoryTab.all),
                const Gap(AppSpacing.sm),
                _chip(l10n.ntRead, _HistoryTab.read),
                const Gap(AppSpacing.sm),
                _chip(l10n.ntUnread, _HistoryTab.unread),
                const Spacer(),
              ],
            ),
          ),
          Expanded(
            child: feed.when(
              loading: () => const LoadingView(),
              error: (_, _) => ErrorView(title: l10n.ntErrorTitle, message: l10n.ntErrorBody, onRetry: () => ref.read(notificationFeedProvider.notifier).refresh()),
              data: (state) {
                final items = state.items.where(_matches).toList();
                if (items.isEmpty) {
                  return EmptyView(art: StateArt.notifications, icon: AppIcons.history, title: l10n.ntNoResultsTitle, message: l10n.ntNoResultsBody);
                }
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

  Widget _chip(String label, _HistoryTab tab) => Center(child: AppFilterChip(label: label, selected: _tab == tab, onSelected: (_) => setState(() => _tab = tab)));
}
