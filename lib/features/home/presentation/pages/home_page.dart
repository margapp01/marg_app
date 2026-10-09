import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/app_shell.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../shared/design_system.dart';
import '../../../../shared/offline/offline_banner.dart';
import '../../../notifications/presentation/controllers/notification_controllers.dart';
import '../../domain/entities/home_dashboard.dart';
import '../controllers/home_controller.dart';
import '../widgets/home_card_journey.dart';
import '../widgets/home_content_cards.dart';
import '../widgets/home_hero.dart';
import '../widgets/home_list_sections.dart';
import '../widgets/home_progress_cards.dart';
import '../widgets/home_quick_actions.dart';
import '../widgets/home_skeleton.dart';

/// The production Home screen. Everything comes from the single
/// `GET /home/dashboard` call; sections open their own screens on tap and
/// hide themselves when the backend has nothing for them.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(homeControllerProvider);

    final Widget body;
    if (async.hasValue) {
      final dashboard = async.requireValue;
      final unread = ref.watch(unreadCountProvider).valueOrNull ?? dashboard.unreadNotifications;
      body = RefreshIndicator(
        edgeOffset: context.viewPadding.top,
        onRefresh: () {
          ref.invalidate(unreadCountProvider);
          return ref.read(homeControllerProvider.notifier).refresh();
        },
        child: _HomeContent(dashboard: dashboard, unread: unread),
      );
    } else if (async.hasError) {
      body = SafeArea(child: _HomeError(offline: _isOffline(async.error!)));
    } else {
      body = const SafeArea(child: HomeSkeleton());
    }

    // The hero photo runs under the status bar; keep its icons dark.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(backgroundColor: context.scheme.surface, body: body),
    );
  }
}

bool _isOffline(Object error) =>
    error is DioException &&
    (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.error is Exception && error.type == DioExceptionType.unknown);

/// Opens a CMS link (banner / promotion / blog / activity). In-app paths
/// push their screen; web links open externally; blog API paths map to the
/// Knowledge Hub's Blog Detail.
Future<void> _openLink(BuildContext context, String? href) async {
  const blogPrefix = '/cms/blogs/';
  if (href == null || href.isEmpty) return;
  if (href.startsWith(blogPrefix)) {
    await context.pushNamed(
      RouteNames.knowledgeBlogDetail,
      pathParameters: {RoutePaths.knowledgeSlugParam: href.substring(blogPrefix.length)},
    );
  } else if (href.startsWith('http')) {
    final uri = Uri.tryParse(href);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else if (href.startsWith('/')) {
    await context.push(href);
  }
}

/// Scrollable dashboard. Each section is a `RepaintBoundary` so animation in
/// one (carousels, progress) never repaints the rest.
class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.dashboard, required this.unread});

  final HomeDashboard dashboard;

  /// Unread notifications for the bell — live, not the dashboard snapshot.
  final int unread;

  void _templeDetail(BuildContext context, String slug) =>
      context.pushNamed(RouteNames.templeDetail, pathParameters: {RoutePaths.templeIdParam: slug});

  void _onQuickAction(BuildContext context, HomeQuickAction a) {
    switch (a) {
      case HomeQuickAction.myRoutes:
        context.goNamed(RouteNames.routes);
      case HomeQuickAction.nearby:
        context.goNamed(RouteNames.exploreNearby);
      case HomeQuickAction.cards:
        context.pushNamed(RouteNames.cards);
      case HomeQuickAction.achievements:
        context.pushNamed(RouteNames.achievements);
      case HomeQuickAction.passport:
        context.goNamed(RouteNames.passport);
      case HomeQuickAction.saved:
        context.goNamed(RouteNames.exploreSaved);
    }
  }

  void _onShortcut(BuildContext context, HomeShortcut s) {
    switch (s) {
      case HomeShortcut.knowledge:
        context.pushNamed(RouteNames.knowledge);
      case HomeShortcut.festivals:
        context.pushNamed(RouteNames.knowledgeFestivals);
      case HomeShortcut.quotes:
        context.pushNamed(RouteNames.knowledgeQuotes);
      case HomeShortcut.leaderboards:
        context.pushNamed(RouteNames.leaderboards);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final d = dashboard;
    final hasNearby = d.nearbyTemples.isNotEmpty;
    final temples = hasNearby ? d.nearbyTemples : d.popularTemples;
    final quotes = d.inspiration;

    Widget padded(Widget child) => Padding(padding: AppSpacing.screenH, child: child);
    const section = Gap(AppSpacing.xxl);

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.huge),
      children: [
        HomeHero(
          name: d.profile?.name,
          unread: unread,
          onMenu: AppShell.openMenu,
          onNotifications: () => context.pushNamed(RouteNames.notifications),
          onSearch: () => context.pushNamed(RouteNames.search, extra: HomeHero.searchHeroTag),
        ),
        const OfflineBanner(),
        const Gap(AppSpacing.xl),
        padded(RepaintBoundary(child: QuickActionsGrid(onAction: (a) => _onQuickAction(context, a)))),
        section,
        padded(
          RepaintBoundary(
            child: CardJourneyCard(
              collected: d.passport?.cardsCollected ?? d.recentCards.length,
              recent: d.recentCards,
              nextTemple: d.nearbyTemples.firstOrNull ?? d.popularTemples.firstOrNull,
              onFindTemple: () => context.goNamed(RouteNames.exploreNearby),
              onOpenCollection: () => context.pushNamed(RouteNames.cards),
              onOpenTemple: (t) => _templeDetail(context, t.slug),
            ).fadeIn(),
          ),
        ),
        if (d.banners.isNotEmpty) ...[
          section,
          RepaintBoundary(child: BannerCarousel(banners: d.banners, onOpen: (b) => _openLink(context, b.ctaUrl))),
        ],
        if (d.yatraProgress.isNotEmpty) ...[
          section,
          padded(
            RepaintBoundary(
              child: YatraProgressCard(
                groups: d.yatraProgress,
                onViewAll: () => context.goNamed(RouteNames.routes),
                onOpenMap: () => context.goNamed(RouteNames.passportMap),
              ),
            ),
          ),
        ],
        section,
        RepaintBoundary(
          child: TempleRail(
            title: hasNearby || d.popularTemples.isEmpty ? l10n.homeSectionNearby : l10n.homeSectionPopular,
            temples: temples,
            onViewAll: () => context.goNamed(hasNearby ? RouteNames.exploreNearby : RouteNames.explore),
            onOpen: (t) => _templeDetail(context, t.slug),
          ),
        ),
        if (quotes.isNotEmpty) ...[
          section,
          RepaintBoundary(
            child: InspirationCarousel(quotes: quotes, onOpen: () => context.pushNamed(RouteNames.knowledgeQuotes)),
          ),
        ],
        if (d.templeIntelligence.isNotEmpty) ...[
          section,
          padded(
            TempleIntelligenceSection(
              items: d.templeIntelligence,
              onOpen: (t) => _templeDetail(context, t.slug),
            ),
          ),
        ],
        // The card quest above invites a first card; the rail shows the rest.
        if (d.recentCards.isNotEmpty) ...[
          section,
          RepaintBoundary(
            child: SacredCardsRail(
            cards: d.recentCards,
            onViewAll: () => context.pushNamed(RouteNames.cards),
              onOpen: (c) => context.pushNamed(RouteNames.cardDetail, pathParameters: {RoutePaths.cardIdParam: c.id}),
            ),
          ),
        ],
        if (d.achievements.isNotEmpty) ...[
          section,
          padded(
            AchievementsCard(
              achievements: d.achievements,
              onViewAll: () => context.pushNamed(RouteNames.achievements),
              onOpen: (a) => context.pushNamed(
                RouteNames.achievementDetail,
                pathParameters: {RoutePaths.achievementIdParam: a.id},
              ),
            ),
          ),
        ],
        section,
        padded(
          RepaintBoundary(
            child: LeaderboardPodiumCard(
              top: d.leaderboardTop,
              myRank: d.leaderboard,
              myName: d.profile?.name,
              myAvatarUrl: d.profile?.profilePhoto,
              onViewAll: () => context.pushNamed(RouteNames.leaderboards),
            ),
          ),
        ),
        if (d.upcomingFestivals.isNotEmpty) ...[
          section,
          padded(
            FestivalsSection(
              festivals: d.upcomingFestivals.take(4).toList(),
              onViewAll: () => context.pushNamed(RouteNames.knowledgeFestivals),
              onOpen: (f) => context.pushNamed(
                RouteNames.knowledgeFestivalDetail,
                pathParameters: {RoutePaths.knowledgeSlugParam: f.slug},
              ),
            ),
          ),
        ],
        section,
        padded(SectionHeader(title: l10n.homeSectionQuickActions)),
        padded(ShortcutsRow(onShortcut: (s) => _onShortcut(context, s))),
        section,
        padded(InviteEarnCard(onInvite: () => context.pushNamed(RouteNames.referrals))),
        if (d.recentActivity.isNotEmpty) ...[
          section,
          padded(
            RecentActivitySection(
              activities: d.recentActivity.take(4).toList(),
              onViewAll: () => context.pushNamed(RouteNames.notificationActivity),
              onOpen: (a) => _openLink(context, a.href),
            ),
          ),
        ],
        section,
        padded(
          ExploreSection(
            promotions: d.promotions,
            blogs: d.blogs,
            onOpen: (href) => _openLink(context, href),
          ),
        ),
        const Gap(AppSpacing.md),
        padded(NeedHelpCard(onContact: () => context.goNamed(RouteNames.profileHelp))),
      ],
    );
  }
}

class _HomeError extends ConsumerWidget {
  const _HomeError({required this.offline});

  final bool offline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ErrorView(
      art: offline ? StateArt.offline : StateArt.error,
      title: offline ? l10n.homeOfflineTitle : l10n.homeErrorTitle,
      message: offline ? l10n.homeOfflineMessage : l10n.homeErrorMessage,
      retryLabel: l10n.commonRetry,
      onRetry: () => ref.read(homeControllerProvider.notifier).refresh(),
    );
  }
}
