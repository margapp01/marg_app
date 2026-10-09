/// URL paths. Deep-link ready: every screen has a stable, shareable path
/// (e.g. marg://…/temples/kashi-vishwanath).
abstract final class RoutePaths {
  static const String splash = '/splash';
  static const String auth = '/auth';
  static const String setup = '/setup';
  static const String home = '/';
  static const String search = '/search';

  /// Legacy deep link — redirects to Explore.
  static const String temples = '/temples';

  /// Path parameter carrying the temple identifier or slug.
  static const String templeIdParam = 'templeId';
  static const String templeDetail = '/temples/:$templeIdParam';

  /// The immersive visit journey (navigate → check-in → verify → rewards).
  static const String templeVisit = '/temples/:$templeIdParam/visit';
  static const String directions = '/directions';

  static const String passport = '/passport';

  /// Spiritual Passport sub-screens.
  static const String passportTimeline = '/passport/timeline';
  static const String passportMap = '/passport/map';
  static const String passportCollection = '/passport/collection';
  static const String passportRoutes = '/passport/routes';
  static const String passportTemples = '/passport/temples';
  static const String passportStatistics = '/passport/statistics';
  static const String passportCertificates = '/passport/certificates';
  static const String passportShare = '/passport/share';
  static const String passportPublic = '/passport/public';

  /// Legacy deep link — redirects to the Passport timeline.
  static const String visits = '/visits';

  /// Explore Bharat — temple discovery hub + sub-screens.
  static const String explore = '/explore';
  static const String exploreNearby = '/explore/nearby';
  static const String exploreMap = '/explore/map';
  static const String exploreCategories = '/explore/categories';
  static const String exploreStates = '/explore/states';
  static const String exploreCollections = '/explore/collections';
  static const String exploreBrowse = '/explore/browse';
  static const String exploreStatistics = '/explore/statistics';

  /// The devotee's saved temples (wishlist).
  static const String exploreSaved = '/explore/saved';

  static const String routes = '/routes';

  /// Discover routes + a single route's journey detail.
  static const String routesDiscover = '/routes/discover';
  static const String routeSlugParam = 'routeSlug';
  static const String routeDetail = '/routes/view/:$routeSlugParam';
  static const String cards = '/cards';

  /// Sacred Cards collection sub-screens.
  static const String cardIdParam = 'cardId';
  static const String cardGallery = '/cards/gallery';
  static const String cardDetail = '/cards/view/:$cardIdParam';
  static const String cardSeries = '/cards/series';
  static const String cardSeasons = '/cards/seasons';
  static const String cardStats = '/cards/stats';
  static const String cardsRecent = '/cards/recent';

  static const String achievements = '/achievements';

  /// Achievements sub-screens.
  static const String achievementIdParam = 'achievementId';
  static const String achievementGallery = '/achievements/gallery';
  static const String achievementDetail = '/achievements/view/:$achievementIdParam';
  static const String achievementCategories = '/achievements/categories';
  static const String achievementMilestones = '/achievements/milestones';
  static const String achievementRecent = '/achievements/recent';
  static const String achievementStats = '/achievements/stats';
  static const String achievementCelebration = '/achievements/celebrate';
  static const String leaderboards = '/leaderboards';
  static const String referrals = '/referrals';

  /// Referral, Community & Social Sharing sub-screens.
  static const String referralInvite = '/referrals/invite';
  static const String referralTimeline = '/referrals/timeline';
  static const String referralRewards = '/referrals/rewards';
  static const String referralRanking = '/referrals/ranking';
  static const String referralShare = '/referrals/share';
  static const String referralAnalytics = '/referrals/analytics';
  static const String referralFaq = '/referrals/faq';
  static const String notifications = '/notifications';

  /// Notification Center & Activity Hub sub-screens.
  static const String notifIdParam = 'id';
  static const String notificationActivity = '/notifications/activity';
  static const String notificationFestivals = '/notifications/festivals';
  static const String notificationQuote = '/notifications/quote';
  static const String notificationSettings = '/notifications/settings';
  static const String notificationHistory = '/notifications/history';
  static const String notificationDetail = '/notifications/detail/:$notifIdParam';
  static const String notificationShare = '/notifications/share/:$notifIdParam';
  static const String profile = '/profile';

  /// Profile, Account & Personalization sub-screens.
  static const String profileEdit = '/profile/edit';
  static const String profilePreferences = '/profile/preferences';
  static const String profilePrivacy = '/profile/privacy';
  static const String profileDevices = '/profile/devices';
  static const String profileStatistics = '/profile/statistics';
  static const String profileAppPreferences = '/profile/app-preferences';
  static const String profileHelp = '/profile/help';
  static const String profileDelete = '/profile/delete';
  static const String staticPageKindParam = 'kind';
  static const String profileStaticPage = '/profile/page/:$staticPageKindParam';

  /// Knowledge Hub — spiritual content hub + sub-screens.
  static const String knowledge = '/knowledge';
  static const String knowledgeBlogs = '/knowledge/blogs';
  static const String knowledgeSlugParam = 'slug';
  static const String knowledgeBlogDetail = '/knowledge/blogs/:$knowledgeSlugParam';
  static const String knowledgeQuotes = '/knowledge/quotes';
  static const String knowledgeFestivals = '/knowledge/festivals';
  static const String knowledgeFestivalDetail = '/knowledge/festivals/:$knowledgeSlugParam';
  static const String knowledgeAnnouncements = '/knowledge/announcements';
  static const String knowledgeFaq = '/knowledge/faq';
  static const String knowledgeAbout = '/knowledge/about';
  static const String knowledgePageKindParam = 'kind';
  static const String knowledgeStaticPage = '/knowledge/page/:$knowledgePageKindParam';

  /// Legacy deep link — redirects to App Preferences.
  static const String settings = '/settings';
}
