import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repository/notification_repository.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/hub_content.dart';
import '../../domain/entities/notification_prefs.dart';

/// Unread badge count (`/my/notifications/unread-count`).
final unreadCountProvider = FutureProvider.autoDispose<int>(
  (ref) => ref.watch(notificationRepositoryProvider).unreadCount(),
);

/// The count for a bell's badge: 0 until known, so headers only rebuild when
/// the number itself changes.
final unreadBadgeProvider = Provider.autoDispose<int>((ref) => ref.watch(unreadCountProvider).valueOrNull ?? 0);

/// The paginated notification feed — shared by the Center, Activity Feed and
/// History (they're three presentations of one stream). Type/date/search filters
/// are applied by the pages client-side over this list.
class NotificationFeedState {
  const NotificationFeedState({required this.items, required this.page, required this.totalPages, this.loadingMore = false});
  final List<AppNotification> items;
  final int page;
  final int totalPages;
  final bool loadingMore;

  bool get hasMore => page < totalPages;

  NotificationFeedState copyWith({List<AppNotification>? items, int? page, int? totalPages, bool? loadingMore}) =>
      NotificationFeedState(
        items: items ?? this.items,
        page: page ?? this.page,
        totalPages: totalPages ?? this.totalPages,
        loadingMore: loadingMore ?? this.loadingMore,
      );
}

class NotificationFeedController extends AutoDisposeAsyncNotifier<NotificationFeedState> {
  static const _limit = 20;

  @override
  Future<NotificationFeedState> build() async {
    final page = await ref.watch(notificationRepositoryProvider).list(page: 1, limit: _limit);
    return NotificationFeedState(items: page.items, page: page.page, totalPages: page.totalPages);
  }

  Future<void> loadMore() async {
    final s = state.valueOrNull;
    if (s == null || !s.hasMore || s.loadingMore) return;
    state = AsyncData(s.copyWith(loadingMore: true));
    try {
      final next = await ref.read(notificationRepositoryProvider).list(page: s.page + 1, limit: _limit);
      state = AsyncData(s.copyWith(items: [...s.items, ...next.items], page: next.page, totalPages: next.totalPages, loadingMore: false));
    } catch (_) {
      state = AsyncData(s.copyWith(loadingMore: false));
    }
  }

  Future<void> refresh() async {
    ref.invalidate(unreadCountProvider);
    state = await AsyncValue.guard(build);
  }

  /// Optimistically marks one notification read, then persists.
  Future<void> markRead(String id) async {
    final s = state.valueOrNull;
    if (s == null) return;
    final target = s.items.where((n) => n.id == id);
    if (target.isEmpty || target.first.isRead) return;
    state = AsyncData(s.copyWith(items: [for (final n in s.items) if (n.id == id) n.copyWith(isRead: true, readAt: DateTime.now()) else n]));
    ref.invalidate(unreadCountProvider);
    try {
      await ref.read(notificationRepositoryProvider).markRead(id);
    } catch (_) {/* best-effort; a refresh reconciles */}
  }

  /// Marks everything read — at once in the feed, then on the server; the
  /// unread badge refreshes once the server has answered. Returns false (and
  /// reloads the feed) if the request failed.
  Future<bool> markAllRead() async {
    final s = state.valueOrNull;
    if (s == null) return false;
    state = AsyncData(s.copyWith(items: [for (final n in s.items) n.copyWith(isRead: true, readAt: n.readAt ?? DateTime.now())]));
    try {
      await ref.read(notificationRepositoryProvider).markAllRead();
      return true;
    } catch (_) {
      unawaited(refresh());
      return false;
    } finally {
      ref.invalidate(unreadCountProvider);
    }
  }
}

final notificationFeedProvider =
    AutoDisposeAsyncNotifierProvider<NotificationFeedController, NotificationFeedState>(NotificationFeedController.new);

/// A single notification's detail; marks it read on open.
final notificationDetailProvider = FutureProvider.autoDispose.family<AppNotification, String>((ref, id) async {
  final repo = ref.watch(notificationRepositoryProvider);
  final n = await repo.detail(id);
  if (!n.isRead) {
    // Fire-and-forget; keep the feed + badge in sync.
    unawaited(ref.read(notificationFeedProvider.notifier).markRead(id));
  }
  return n;
});

// ── Preferences ─────────────────────────────────────────────────────────────

class PreferencesController extends AutoDisposeAsyncNotifier<NotificationPreferences> {
  @override
  Future<NotificationPreferences> build() => ref.watch(notificationRepositoryProvider).preferences();

  Future<void> toggle(String key, bool value) async {
    final current = state.valueOrNull;
    state = const AsyncLoading<NotificationPreferences>().copyWithPrevious(state);
    try {
      state = AsyncData(await ref.read(notificationRepositoryProvider).updatePreferences({key: value}));
    } catch (e, st) {
      state = current == null ? AsyncError(e, st) : AsyncData(current); // revert
    }
  }
}

final preferencesProvider =
    AutoDisposeAsyncNotifierProvider<PreferencesController, NotificationPreferences>(PreferencesController.new);

// ── Festivals + Quotes ──────────────────────────────────────────────────────

final upcomingFestivalsProvider = FutureProvider.autoDispose<List<Festival>>(
  (ref) => ref.watch(notificationRepositoryProvider).upcomingFestivals(),
);

final festivalProvider = FutureProvider.autoDispose.family<Festival, String>(
  (ref, slug) => ref.watch(notificationRepositoryProvider).festival(slug),
);

final dailyQuoteProvider = FutureProvider.autoDispose<Quote?>(
  (ref) => ref.watch(notificationRepositoryProvider).dailyQuote(),
);

final previousQuotesProvider = FutureProvider.autoDispose<List<Quote>>(
  (ref) => ref.watch(notificationRepositoryProvider).quotes(page: 1, limit: 30),
);
