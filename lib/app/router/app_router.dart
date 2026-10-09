import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/achievements/domain/entities/achievement.dart';
import '../../features/achievements/presentation/pages/achievement_categories_page.dart';
import '../../features/achievements/presentation/pages/achievement_celebration_page.dart';
import '../../features/achievements/presentation/pages/achievement_detail_page.dart';
import '../../features/achievements/presentation/pages/achievement_gallery_page.dart';
import '../../features/achievements/presentation/pages/achievement_milestones_page.dart';
import '../../features/achievements/presentation/pages/achievement_recent_page.dart';
import '../../features/achievements/presentation/pages/achievement_stats_page.dart';
import '../../features/achievements/presentation/pages/achievements_dashboard_page.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/pages/setup_page.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/cards/presentation/pages/card_detail_page.dart';
import '../../features/cards/presentation/pages/card_gallery_page.dart';
import '../../features/cards/presentation/pages/collection_groups_page.dart';
import '../../features/cards/presentation/pages/collection_stats_page.dart';
import '../../features/cards/presentation/pages/my_collection_page.dart';
import '../../features/cards/presentation/pages/recently_unlocked_page.dart';
import '../../features/collections/leaderboards/presentation/pages/leaderboards_page.dart';
import '../../features/directions/domain/route_plan.dart';
import '../../features/directions/presentation/pages/directions_page.dart';
import '../../features/explore/presentation/pages/browse_temples_page.dart';
import '../../features/explore/presentation/pages/categories_page.dart';
import '../../features/explore/presentation/pages/collections_page.dart';
import '../../features/explore/presentation/pages/explore_dashboard_page.dart';
import '../../features/explore/presentation/pages/explore_map_page.dart';
import '../../features/explore/presentation/pages/explore_statistics_page.dart';
import '../../features/explore/presentation/pages/nearby_temples_page.dart';
import '../../features/explore/presentation/pages/saved_temples_page.dart';
import '../../features/explore/presentation/pages/state_explorer_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/knowledge/presentation/pages/about_marg_page.dart';
import '../../features/knowledge/presentation/pages/announcements_page.dart';
import '../../features/knowledge/presentation/pages/blog_detail_page.dart';
import '../../features/knowledge/presentation/pages/blog_library_page.dart';
import '../../features/knowledge/presentation/pages/daily_quotes_page.dart';
import '../../features/knowledge/presentation/pages/faq_center_page.dart';
import '../../features/knowledge/presentation/pages/festival_detail_page.dart';
import '../../features/knowledge/presentation/pages/festivals_page.dart';
import '../../features/knowledge/presentation/pages/knowledge_hub_page.dart';
import '../../features/knowledge/presentation/pages/static_page_page.dart';
import '../../features/notifications/presentation/pages/activity_feed_page.dart';
import '../../features/notifications/presentation/pages/daily_quote_page.dart';
import '../../features/notifications/presentation/pages/festival_updates_page.dart';
import '../../features/notifications/presentation/pages/notification_center_page.dart';
import '../../features/notifications/presentation/pages/notification_detail_page.dart';
import '../../features/notifications/presentation/pages/notification_history_page.dart';
import '../../features/notifications/presentation/pages/notification_settings_page.dart';
import '../../features/notifications/presentation/pages/share_activity_page.dart';
import '../../features/passport/presentation/pages/passport_certificates_page.dart';
import '../../features/passport/presentation/pages/passport_collection_page.dart';
import '../../features/passport/presentation/pages/passport_dashboard_page.dart';
import '../../features/passport/presentation/pages/passport_map_page.dart';
import '../../features/passport/presentation/pages/passport_public_page.dart';
import '../../features/passport/presentation/pages/passport_routes_page.dart';
import '../../features/passport/presentation/pages/passport_share_page.dart';
import '../../features/passport/presentation/pages/passport_statistics_page.dart';
import '../../features/passport/presentation/pages/passport_temples_page.dart';
import '../../features/passport/presentation/pages/passport_timeline_page.dart';
import '../../features/profile/domain/entities/cms_content.dart';
import '../../features/profile/presentation/pages/app_preferences_page.dart';
import '../../features/profile/presentation/pages/delete_account_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/help_support_page.dart';
import '../../features/profile/presentation/pages/my_devices_page.dart';
import '../../features/profile/presentation/pages/my_statistics_page.dart';
import '../../features/profile/presentation/pages/privacy_security_page.dart';
import '../../features/profile/presentation/pages/profile_dashboard_page.dart';
import '../../features/profile/presentation/pages/spiritual_preferences_page.dart';
import '../../features/profile/presentation/pages/static_page_page.dart';
import '../../features/referrals/presentation/pages/community_ranking_page.dart';
import '../../features/referrals/presentation/pages/invite_friends_page.dart';
import '../../features/referrals/presentation/pages/referral_analytics_page.dart';
import '../../features/referrals/presentation/pages/referral_dashboard_page.dart';
import '../../features/referrals/presentation/pages/referral_faq_page.dart';
import '../../features/referrals/presentation/pages/referral_rewards_page.dart';
import '../../features/referrals/presentation/pages/referral_timeline_page.dart';
import '../../features/referrals/presentation/pages/share_journey_page.dart';
import '../../features/routes/presentation/pages/discover_routes_page.dart';
import '../../features/routes/presentation/pages/my_yatras_page.dart';
import '../../features/routes/presentation/pages/route_detail_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/temple_detail/presentation/pages/temple_detail_page.dart';
import '../../features/temple_visit/presentation/pages/temple_visit_page.dart';
import '../../shared/design_system.dart';
import '../localization/app_localizations.dart';
import 'app_shell.dart';
import 'route_guards.dart';
import 'route_names.dart';
import 'route_paths.dart';

/// A child path segment under [parent] (`/explore/nearby` → `nearby`), so
/// nested routes keep the absolute paths in [RoutePaths] as the single source.
String _sub(String full, String parent) => full.substring(parent.length + 1);

/// Screen-view tracking. Each navigator needs its own observer instance.
List<NavigatorObserver> _analytics() => [FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)];

/// App router. Deep links resolve because every screen has a stable path;
/// the auth guard protects the authenticated area and re-runs whenever the
/// auth state changes (via [refresh]).
///
/// The five primary tabs (Home · Explore · Yatra · Passport · Profile) live
/// in a [StatefulShellRoute] so each keeps its own stack; everything else is
/// a root-level route that opens full-screen above the tab bar.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);
  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: RoutePaths.splash,
    refreshListenable: refresh,
    redirect: composeGuards([authGuard(ref)]),
    observers: _analytics(),
    // An unknown/malformed path (stale share link, typo'd deep link) must never
    // show GoRouter's raw debug page — render the shared error state instead.
    errorBuilder: (context, state) => _RouteNotFound(location: state.uri.toString()),
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (_, _) => const SplashPage(),
      ),
      GoRoute(
        path: RoutePaths.auth,
        name: RouteNames.auth,
        builder: (_, _) => const SignInPage(),
      ),
      GoRoute(
        path: RoutePaths.setup,
        name: RouteNames.setup,
        builder: (_, _) => const SetupPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            observers: _analytics(),
            routes: [
              GoRoute(
                path: RoutePaths.home,
                name: RouteNames.home,
                builder: (_, _) => const HomePage(),
              ),
            ],
          ),
          // ── Explore Bharat ──────────────────────────────────────────────
          StatefulShellBranch(
            observers: _analytics(),
            routes: [
              GoRoute(
                path: RoutePaths.explore,
                name: RouteNames.explore,
                builder: (_, _) => const ExploreDashboardPage(),
                routes: [
                  GoRoute(
                    path: _sub(RoutePaths.exploreNearby, RoutePaths.explore),
                    name: RouteNames.exploreNearby,
                    builder: (_, _) => const NearbyTemplesPage(),
                  ),
                  GoRoute(
                    path: _sub(RoutePaths.exploreMap, RoutePaths.explore),
                    name: RouteNames.exploreMap,
                    builder: (_, _) => const ExploreMapPage(),
                  ),
                  GoRoute(
                    path: _sub(RoutePaths.exploreCategories, RoutePaths.explore),
                    name: RouteNames.exploreCategories,
                    builder: (_, _) => const CategoriesPage(),
                  ),
                  GoRoute(
                    path: _sub(RoutePaths.exploreStates, RoutePaths.explore),
                    name: RouteNames.exploreStates,
                    builder: (_, _) => const StateExplorerPage(),
                  ),
                  GoRoute(
                    path: _sub(RoutePaths.exploreCollections, RoutePaths.explore),
                    name: RouteNames.exploreCollections,
                    builder: (_, _) => const CollectionsPage(),
                  ),
                  GoRoute(
                    path: _sub(RoutePaths.exploreBrowse, RoutePaths.explore),
                    name: RouteNames.exploreBrowse,
                    // Needs its query; a bare deep link has none.
                    redirect: (_, state) => state.extra is BrowseArgs ? null : RoutePaths.explore,
                    builder: (_, state) => BrowseTemplesPage(args: state.extra! as BrowseArgs),
                  ),
                  GoRoute(
                    path: _sub(RoutePaths.exploreStatistics, RoutePaths.explore),
                    name: RouteNames.exploreStatistics,
                    builder: (_, _) => const ExploreStatisticsPage(),
                  ),
                  GoRoute(
                    path: _sub(RoutePaths.exploreSaved, RoutePaths.explore),
                    name: RouteNames.exploreSaved,
                    builder: (_, _) => const SavedTemplesPage(),
                  ),
                ],
              ),
            ],
          ),
          // ── Yatra (routes) ──────────────────────────────────────────────
          StatefulShellBranch(
            observers: _analytics(),
            routes: [
              GoRoute(
                path: RoutePaths.routes,
                name: RouteNames.routes,
                builder: (_, _) => const MyYatrasPage(),
                routes: [
                  GoRoute(
                    path: _sub(RoutePaths.routesDiscover, RoutePaths.routes),
                    name: RouteNames.routesDiscover,
                    builder: (_, _) => const DiscoverRoutesPage(),
                  ),
                  // Route detail has its own bottom CTA — full-screen above the tabs.
                  GoRoute(
                    path: _sub(RoutePaths.routeDetail, RoutePaths.routes),
                    name: RouteNames.routeDetail,
                    parentNavigatorKey: rootKey,
                    builder: (_, state) => RouteDetailPage(
                      slug: state.pathParameters[RoutePaths.routeSlugParam] ?? '',
                    ),
                  ),
                ],
              ),
            ],
          ),
          // ── Spiritual Passport ──────────────────────────────────────────
          StatefulShellBranch(
            observers: _analytics(),
            routes: [
              GoRoute(
                path: RoutePaths.passport,
                name: RouteNames.passport,
                builder: (_, _) => const PassportDashboardPage(),
                routes: [
                  GoRoute(
                    path: _sub(RoutePaths.passportTimeline, RoutePaths.passport),
                    name: RouteNames.passportTimeline,
                    builder: (_, _) => const PassportTimelinePage(),
                  ),
                  GoRoute(
                    path: _sub(RoutePaths.passportMap, RoutePaths.passport),
                    name: RouteNames.passportMap,
                    builder: (_, _) => const PassportMapPage(),
                  ),
                  GoRoute(
                    path: _sub(RoutePaths.passportCollection, RoutePaths.passport),
                    name: RouteNames.passportCollection,
                    builder: (_, _) => const PassportCollectionPage(),
                  ),
                  GoRoute(
                    path: _sub(RoutePaths.passportRoutes, RoutePaths.passport),
                    name: RouteNames.passportRoutes,
                    builder: (_, _) => const PassportRoutesPage(),
                  ),
                  GoRoute(
                    path: _sub(RoutePaths.passportTemples, RoutePaths.passport),
                    name: RouteNames.passportTemples,
                    builder: (_, _) => const PassportTemplesPage(),
                  ),
                  GoRoute(
                    path: _sub(RoutePaths.passportStatistics, RoutePaths.passport),
                    name: RouteNames.passportStatistics,
                    builder: (_, _) => const PassportStatisticsPage(),
                  ),
                  GoRoute(
                    path: _sub(RoutePaths.passportCertificates, RoutePaths.passport),
                    name: RouteNames.passportCertificates,
                    builder: (_, _) => const PassportCertificatesPage(),
                  ),
                  GoRoute(
                    path: _sub(RoutePaths.passportShare, RoutePaths.passport),
                    name: RouteNames.passportShare,
                    builder: (_, _) => const PassportSharePage(),
                  ),
                  GoRoute(
                    path: _sub(RoutePaths.passportPublic, RoutePaths.passport),
                    name: RouteNames.passportPublic,
                    builder: (_, _) => const PassportPublicPage(),
                  ),
                ],
              ),
            ],
          ),
          // ── Profile, Account & Personalization ──────────────────────────
          StatefulShellBranch(
            observers: _analytics(),
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                name: RouteNames.profile,
                builder: (_, _) => const ProfileDashboardPage(),
                routes: [
                  GoRoute(
                    path: _sub(RoutePaths.profileEdit, RoutePaths.profile),
                    name: RouteNames.profileEdit,
                    builder: (_, _) => const EditProfilePage(),
                  ),
                  GoRoute(
                    path: _sub(RoutePaths.profilePreferences, RoutePaths.profile),
                    name: RouteNames.profilePreferences,
                    builder: (_, _) => const SpiritualPreferencesPage(),
                  ),
                  GoRoute(
                    path: _sub(RoutePaths.profilePrivacy, RoutePaths.profile),
                    name: RouteNames.profilePrivacy,
                    builder: (_, _) => const PrivacySecurityPage(),
                  ),
                  GoRoute(
                    path: _sub(RoutePaths.profileDevices, RoutePaths.profile),
                    name: RouteNames.profileDevices,
                    builder: (_, _) => const MyDevicesPage(),
                  ),
                  GoRoute(
                    path: _sub(RoutePaths.profileStatistics, RoutePaths.profile),
                    name: RouteNames.profileStatistics,
                    builder: (_, _) => const MyStatisticsPage(),
                  ),
                  GoRoute(
                    path: _sub(RoutePaths.profileAppPreferences, RoutePaths.profile),
                    name: RouteNames.profileAppPreferences,
                    builder: (_, _) => const AppPreferencesPage(),
                  ),
                  GoRoute(
                    path: _sub(RoutePaths.profileHelp, RoutePaths.profile),
                    name: RouteNames.profileHelp,
                    builder: (_, _) => const HelpSupportPage(),
                  ),
                  GoRoute(
                    path: _sub(RoutePaths.profileDelete, RoutePaths.profile),
                    name: RouteNames.profileDelete,
                    builder: (_, _) => const DeleteAccountPage(),
                  ),
                  GoRoute(
                    path: _sub(RoutePaths.profileStaticPage, RoutePaths.profile),
                    name: RouteNames.profileStaticPage,
                    builder: (_, state) => StaticPageScreen(
                      kind: PageKind.values.firstWhere(
                        (k) => k.name == state.pathParameters[RoutePaths.staticPageKindParam],
                        orElse: () => PageKind.about,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      // ── Full-screen destinations (above the tab bar) ──────────────────────
      GoRoute(
        path: RoutePaths.search,
        name: RouteNames.search,
        pageBuilder: (_, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          transitionDuration: AppDurations.slow,
          reverseTransitionDuration: AppDurations.normal,
          transitionsBuilder: AppPageTransitions.fadeThrough,
          child: SearchPage(heroTag: state.extra is String ? state.extra! as String : null),
        ),
      ),
      GoRoute(
        path: RoutePaths.templeDetail,
        name: RouteNames.templeDetail,
        builder: (_, state) => TempleDetailPage(
          slug: state.pathParameters[RoutePaths.templeIdParam] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.directions,
        name: RouteNames.directions,
        // Needs its destination; a bare deep link has none.
        redirect: (_, state) => state.extra is DirectionsArgs ? null : RoutePaths.explore,
        builder: (_, state) => DirectionsPage(args: state.extra! as DirectionsArgs),
      ),
      GoRoute(
        path: RoutePaths.templeVisit,
        name: RouteNames.templeVisit,
        builder: (_, state) => TempleVisitPage(
          slug: state.pathParameters[RoutePaths.templeIdParam] ?? '',
        ),
      ),
      // Legacy deep links from before the tab shell.
      GoRoute(path: RoutePaths.temples, redirect: (_, _) => RoutePaths.explore),
      GoRoute(path: RoutePaths.visits, redirect: (_, _) => RoutePaths.passportTimeline),
      GoRoute(path: RoutePaths.settings, redirect: (_, _) => RoutePaths.profileAppPreferences),
      GoRoute(
        path: RoutePaths.cardGallery,
        name: RouteNames.cardGallery,
        builder: (_, state) => CardGalleryPage(args: (state.extra as GalleryArgs?) ?? const GalleryArgs()),
      ),
      GoRoute(
        path: RoutePaths.cardDetail,
        name: RouteNames.cardDetail,
        builder: (_, state) => CardDetailPage(cardId: state.pathParameters[RoutePaths.cardIdParam] ?? ''),
      ),
      GoRoute(
        path: RoutePaths.cardSeries,
        name: RouteNames.cardSeries,
        builder: (_, _) => const CollectionGroupsPage(mode: CollectionGroupMode.series),
      ),
      GoRoute(
        path: RoutePaths.cardSeasons,
        name: RouteNames.cardSeasons,
        builder: (_, _) => const CollectionGroupsPage(mode: CollectionGroupMode.season),
      ),
      GoRoute(
        path: RoutePaths.cardStats,
        name: RouteNames.cardStats,
        builder: (_, _) => const CollectionStatsPage(),
      ),
      GoRoute(
        path: RoutePaths.cardsRecent,
        name: RouteNames.cardsRecent,
        builder: (_, _) => const RecentlyUnlockedPage(),
      ),
      GoRoute(
        path: RoutePaths.cards,
        name: RouteNames.cards,
        builder: (_, _) => const MyCollectionPage(),
      ),
      GoRoute(
        path: RoutePaths.achievementGallery,
        name: RouteNames.achievementGallery,
        builder: (_, state) => AchievementGalleryPage(args: (state.extra as AchievementGalleryArgs?) ?? const AchievementGalleryArgs()),
      ),
      GoRoute(
        path: RoutePaths.achievementCategories,
        name: RouteNames.achievementCategories,
        builder: (_, _) => const AchievementCategoriesPage(),
      ),
      GoRoute(
        path: RoutePaths.achievementMilestones,
        name: RouteNames.achievementMilestones,
        builder: (_, _) => const AchievementMilestonesPage(),
      ),
      GoRoute(
        path: RoutePaths.achievementRecent,
        name: RouteNames.achievementRecent,
        builder: (_, _) => const AchievementRecentPage(),
      ),
      GoRoute(
        path: RoutePaths.achievementStats,
        name: RouteNames.achievementStats,
        builder: (_, _) => const AchievementStatsPage(),
      ),
      GoRoute(
        path: RoutePaths.achievementCelebration,
        name: RouteNames.achievementCelebration,
        builder: (_, state) => AchievementCelebrationPage(achievement: state.extra! as Achievement),
      ),
      GoRoute(
        path: RoutePaths.achievementDetail,
        name: RouteNames.achievementDetail,
        builder: (_, state) => AchievementDetailPage(
          achievementId: state.pathParameters[RoutePaths.achievementIdParam] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.achievements,
        name: RouteNames.achievements,
        builder: (_, _) => const AchievementsDashboardPage(),
      ),
      GoRoute(
        path: RoutePaths.leaderboards,
        name: RouteNames.leaderboards,
        builder: (_, _) => const LeaderboardsPage(),
      ),
      // ── Referral, Community & Social Sharing ────────────────────────────
      GoRoute(
        path: RoutePaths.referrals,
        name: RouteNames.referrals,
        builder: (_, _) => const ReferralDashboardPage(),
      ),
      GoRoute(
        path: RoutePaths.referralInvite,
        name: RouteNames.referralInvite,
        builder: (_, _) => const InviteFriendsPage(),
      ),
      GoRoute(
        path: RoutePaths.referralTimeline,
        name: RouteNames.referralTimeline,
        builder: (_, _) => const ReferralTimelinePage(),
      ),
      GoRoute(
        path: RoutePaths.referralRewards,
        name: RouteNames.referralRewards,
        builder: (_, _) => const ReferralRewardsPage(),
      ),
      GoRoute(
        path: RoutePaths.referralRanking,
        name: RouteNames.referralRanking,
        builder: (_, _) => const CommunityRankingPage(),
      ),
      GoRoute(
        path: RoutePaths.referralShare,
        name: RouteNames.referralShare,
        builder: (_, _) => const ShareJourneyPage(),
      ),
      GoRoute(
        path: RoutePaths.referralAnalytics,
        name: RouteNames.referralAnalytics,
        builder: (_, _) => const ReferralAnalyticsPage(),
      ),
      GoRoute(
        path: RoutePaths.referralFaq,
        name: RouteNames.referralFaq,
        builder: (_, _) => const ReferralFaqPage(),
      ),
      // ── Knowledge Hub & Spiritual Content ───────────────────────────────
      GoRoute(
        path: RoutePaths.knowledge,
        name: RouteNames.knowledge,
        builder: (_, _) => const KnowledgeHubPage(),
      ),
      GoRoute(
        path: RoutePaths.knowledgeBlogs,
        name: RouteNames.knowledgeBlogs,
        builder: (_, state) => BlogLibraryPage(initialCategory: state.uri.queryParameters['category']),
      ),
      GoRoute(
        path: RoutePaths.knowledgeBlogDetail,
        name: RouteNames.knowledgeBlogDetail,
        builder: (_, state) => BlogDetailPage(slug: state.pathParameters[RoutePaths.knowledgeSlugParam] ?? ''),
      ),
      GoRoute(
        path: RoutePaths.knowledgeQuotes,
        name: RouteNames.knowledgeQuotes,
        builder: (_, _) => const DailyQuotesPage(),
      ),
      GoRoute(
        path: RoutePaths.knowledgeFestivals,
        name: RouteNames.knowledgeFestivals,
        builder: (_, _) => const FestivalsPage(),
      ),
      GoRoute(
        path: RoutePaths.knowledgeFestivalDetail,
        name: RouteNames.knowledgeFestivalDetail,
        builder: (_, state) => FestivalDetailPage(slug: state.pathParameters[RoutePaths.knowledgeSlugParam] ?? ''),
      ),
      GoRoute(
        path: RoutePaths.knowledgeAnnouncements,
        name: RouteNames.knowledgeAnnouncements,
        builder: (_, _) => const AnnouncementsPage(),
      ),
      GoRoute(
        path: RoutePaths.knowledgeFaq,
        name: RouteNames.knowledgeFaq,
        builder: (_, _) => const FaqCenterPage(),
      ),
      GoRoute(
        path: RoutePaths.knowledgeAbout,
        name: RouteNames.knowledgeAbout,
        builder: (_, _) => const AboutMargPage(),
      ),
      GoRoute(
        path: RoutePaths.knowledgeStaticPage,
        name: RouteNames.knowledgeStaticPage,
        builder: (_, state) => KnowledgeStaticPagePage(kindWire: state.pathParameters[RoutePaths.knowledgePageKindParam] ?? 'about'),
      ),
      // ── Notification Center & Activity Hub ──────────────────────────────
      GoRoute(
        path: RoutePaths.notifications,
        name: RouteNames.notifications,
        builder: (_, _) => const NotificationCenterPage(),
      ),
      GoRoute(
        path: RoutePaths.notificationActivity,
        name: RouteNames.notificationActivity,
        builder: (_, _) => const ActivityFeedPage(),
      ),
      GoRoute(
        path: RoutePaths.notificationFestivals,
        name: RouteNames.notificationFestivals,
        builder: (_, _) => const FestivalUpdatesPage(),
      ),
      GoRoute(
        path: RoutePaths.notificationQuote,
        name: RouteNames.notificationQuote,
        builder: (_, _) => const DailyQuotePage(),
      ),
      GoRoute(
        path: RoutePaths.notificationSettings,
        name: RouteNames.notificationSettings,
        builder: (_, _) => const NotificationSettingsPage(),
      ),
      GoRoute(
        path: RoutePaths.notificationHistory,
        name: RouteNames.notificationHistory,
        builder: (_, _) => const NotificationHistoryPage(),
      ),
      GoRoute(
        path: RoutePaths.notificationDetail,
        name: RouteNames.notificationDetail,
        builder: (_, state) => NotificationDetailPage(id: state.pathParameters[RoutePaths.notifIdParam] ?? ''),
      ),
      GoRoute(
        path: RoutePaths.notificationShare,
        name: RouteNames.notificationShare,
        builder: (_, state) => ShareActivityPage(id: state.pathParameters[RoutePaths.notifIdParam] ?? ''),
      ),
    ],
  );
});

/// Shown when a deep link / path doesn't match any route. Uses the shared
/// [ErrorView] so an unresolvable link looks like every other error state
/// instead of GoRouter's debug page, and offers a way back into the app.
class _RouteNotFound extends StatelessWidget {
  const _RouteNotFound({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: ErrorView(
        art: StateArt.notFound,
        icon: AppIcons.search,
        title: l10n.routeNotFoundTitle,
        message: l10n.routeNotFoundBody,
        retryLabel: l10n.routeGoHome,
        onRetry: () => context.goNamed(RouteNames.home),
      ),
    );
  }
}
