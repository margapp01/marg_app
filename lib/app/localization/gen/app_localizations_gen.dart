import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_gen_en.dart';
import 'app_localizations_gen_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations_gen.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MARG'**
  String get appTitle;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @placeholderBody.
  ///
  /// In en, this message translates to:
  /// **'We\'re preparing this for you. Please check back soon.'**
  String get placeholderBody;

  /// No description provided for @titleAuth.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get titleAuth;

  /// No description provided for @titleSetup.
  ///
  /// In en, this message translates to:
  /// **'Setup'**
  String get titleSetup;

  /// No description provided for @titleHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get titleHome;

  /// No description provided for @titleTemples.
  ///
  /// In en, this message translates to:
  /// **'Temples'**
  String get titleTemples;

  /// No description provided for @titleTempleDetail.
  ///
  /// In en, this message translates to:
  /// **'Temple details'**
  String get titleTempleDetail;

  /// No description provided for @titlePassport.
  ///
  /// In en, this message translates to:
  /// **'Spiritual Passport'**
  String get titlePassport;

  /// No description provided for @titleVisits.
  ///
  /// In en, this message translates to:
  /// **'Visits'**
  String get titleVisits;

  /// No description provided for @titleRoutes.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get titleRoutes;

  /// No description provided for @titleCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get titleCards;

  /// No description provided for @titleAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get titleAchievements;

  /// No description provided for @titleLeaderboards.
  ///
  /// In en, this message translates to:
  /// **'Leaderboards'**
  String get titleLeaderboards;

  /// No description provided for @titleReferrals.
  ///
  /// In en, this message translates to:
  /// **'Referrals'**
  String get titleReferrals;

  /// No description provided for @titleNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get titleNotifications;

  /// No description provided for @titleProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get titleProfile;

  /// No description provided for @titleSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get titleSettings;

  /// No description provided for @homeTagline.
  ///
  /// In en, this message translates to:
  /// **'Every sacred journey begins with a single step.'**
  String get homeTagline;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search temples, places, routes...'**
  String get homeSearchHint;

  /// No description provided for @homeActionMyRoutes.
  ///
  /// In en, this message translates to:
  /// **'My Yatra Routes'**
  String get homeActionMyRoutes;

  /// No description provided for @homeActionNearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby Temples'**
  String get homeActionNearby;

  /// No description provided for @homeActionCards.
  ///
  /// In en, this message translates to:
  /// **'Collect Cards'**
  String get homeActionCards;

  /// No description provided for @homeActionAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get homeActionAchievements;

  /// No description provided for @homeSectionYatraProgress.
  ///
  /// In en, this message translates to:
  /// **'My Yatra Progress'**
  String get homeSectionYatraProgress;

  /// No description provided for @homeSectionNearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby Temples'**
  String get homeSectionNearby;

  /// No description provided for @homeSectionDailyInspiration.
  ///
  /// In en, this message translates to:
  /// **'Daily Inspiration'**
  String get homeSectionDailyInspiration;

  /// No description provided for @homeSectionFestivals.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Festivals'**
  String get homeSectionFestivals;

  /// No description provided for @homeSectionActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get homeSectionActivity;

  /// No description provided for @homeSectionLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get homeSectionLeaderboard;

  /// No description provided for @homeSectionExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore More'**
  String get homeSectionExplore;

  /// No description provided for @commonViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get commonViewAll;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @homeProgressTemples.
  ///
  /// In en, this message translates to:
  /// **'Temples'**
  String get homeProgressTemples;

  /// No description provided for @homeProgressCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get homeProgressCards;

  /// No description provided for @homeProgressRoutes.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get homeProgressRoutes;

  /// No description provided for @homeProgressComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get homeProgressComplete;

  /// No description provided for @homeRankLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Rank'**
  String get homeRankLabel;

  /// No description provided for @homeRankUnranked.
  ///
  /// In en, this message translates to:
  /// **'Not ranked yet'**
  String get homeRankUnranked;

  /// No description provided for @homePointsSuffix.
  ///
  /// In en, this message translates to:
  /// **'pts'**
  String get homePointsSuffix;

  /// No description provided for @homeReferralTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite & Earn'**
  String get homeReferralTitle;

  /// No description provided for @homeReferralSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Invite your friends to MARG and earn points'**
  String get homeReferralSubtitle;

  /// No description provided for @homeInviteNow.
  ///
  /// In en, this message translates to:
  /// **'Invite Now'**
  String get homeInviteNow;

  /// No description provided for @homeNearbyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enable location to see temples near you'**
  String get homeNearbyEmpty;

  /// No description provided for @homeErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your dashboard'**
  String get homeErrorTitle;

  /// No description provided for @homeErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again.'**
  String get homeErrorMessage;

  /// No description provided for @homeOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get homeOfflineTitle;

  /// No description provided for @homeOfflineMessage.
  ///
  /// In en, this message translates to:
  /// **'Reconnect to load the latest.'**
  String get homeOfflineMessage;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navYatra.
  ///
  /// In en, this message translates to:
  /// **'Yatra'**
  String get navYatra;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search & Discovery'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search temples, routes, festivals...'**
  String get searchHint;

  /// No description provided for @searchRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get searchRecent;

  /// No description provided for @searchTrending.
  ///
  /// In en, this message translates to:
  /// **'Trending Searches'**
  String get searchTrending;

  /// No description provided for @searchClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get searchClearAll;

  /// No description provided for @searchPopularTemples.
  ///
  /// In en, this message translates to:
  /// **'Popular Temples'**
  String get searchPopularTemples;

  /// No description provided for @searchPopularFestivals.
  ///
  /// In en, this message translates to:
  /// **'Popular Festivals'**
  String get searchPopularFestivals;

  /// No description provided for @searchPopularBlogs.
  ///
  /// In en, this message translates to:
  /// **'Popular Blogs'**
  String get searchPopularBlogs;

  /// No description provided for @searchNoRecent.
  ///
  /// In en, this message translates to:
  /// **'Your recent searches will appear here.'**
  String get searchNoRecent;

  /// No description provided for @searchGroupFestivals.
  ///
  /// In en, this message translates to:
  /// **'Festivals'**
  String get searchGroupFestivals;

  /// No description provided for @searchGroupBlogs.
  ///
  /// In en, this message translates to:
  /// **'Blogs'**
  String get searchGroupBlogs;

  /// No description provided for @searchGroupFaqs.
  ///
  /// In en, this message translates to:
  /// **'FAQs'**
  String get searchGroupFaqs;

  /// No description provided for @searchGroupPages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get searchGroupPages;

  /// No description provided for @searchScopeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get searchScopeAll;

  /// No description provided for @searchFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get searchFilterTitle;

  /// No description provided for @searchFilterSearchIn.
  ///
  /// In en, this message translates to:
  /// **'Search In'**
  String get searchFilterSearchIn;

  /// No description provided for @searchFilterReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get searchFilterReset;

  /// No description provided for @searchFilterApply.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get searchFilterApply;

  /// No description provided for @searchFilterSortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get searchFilterSortBy;

  /// No description provided for @searchSortRelevance.
  ///
  /// In en, this message translates to:
  /// **'Relevance'**
  String get searchSortRelevance;

  /// No description provided for @searchSortAlphabetical.
  ///
  /// In en, this message translates to:
  /// **'Alphabetical (A–Z)'**
  String get searchSortAlphabetical;

  /// No description provided for @searchEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Results Found'**
  String get searchEmptyTitle;

  /// No description provided for @searchNoResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results found for'**
  String get searchNoResultsFor;

  /// No description provided for @searchEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try different keywords or check spelling.'**
  String get searchEmptySubtitle;

  /// No description provided for @searchViewNearby.
  ///
  /// In en, this message translates to:
  /// **'View Nearby Temples'**
  String get searchViewNearby;

  /// No description provided for @searchOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'You are offline'**
  String get searchOfflineTitle;

  /// No description provided for @searchOfflineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Showing your recent searches. Reconnect to search.'**
  String get searchOfflineSubtitle;

  /// No description provided for @searchErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get searchErrorTitle;

  /// No description provided for @searchViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get searchViewDetails;

  /// No description provided for @tdVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified Temple'**
  String get tdVerified;

  /// No description provided for @tdOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get tdOpen;

  /// No description provided for @tdClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get tdClosed;

  /// No description provided for @tdAway.
  ///
  /// In en, this message translates to:
  /// **'away'**
  String get tdAway;

  /// No description provided for @tdCrowd.
  ///
  /// In en, this message translates to:
  /// **'Crowd'**
  String get tdCrowd;

  /// No description provided for @tdWaitTime.
  ///
  /// In en, this message translates to:
  /// **'Wait Time'**
  String get tdWaitTime;

  /// No description provided for @tdBestTimeToday.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Best Time to Visit'**
  String get tdBestTimeToday;

  /// No description provided for @tdIntelligenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Temple Intelligence (Live)'**
  String get tdIntelligenceTitle;

  /// No description provided for @tdUpdatedLive.
  ///
  /// In en, this message translates to:
  /// **'Updated just now'**
  String get tdUpdatedLive;

  /// No description provided for @tdOccupancy.
  ///
  /// In en, this message translates to:
  /// **'Occupancy'**
  String get tdOccupancy;

  /// No description provided for @tdCapacity.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get tdCapacity;

  /// No description provided for @tdPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get tdPeople;

  /// No description provided for @tdPeakHours.
  ///
  /// In en, this message translates to:
  /// **'Peak Hours'**
  String get tdPeakHours;

  /// No description provided for @tdConfidence.
  ///
  /// In en, this message translates to:
  /// **'confidence'**
  String get tdConfidence;

  /// No description provided for @tdAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get tdAbout;

  /// No description provided for @tdReadMore.
  ///
  /// In en, this message translates to:
  /// **'Read More'**
  String get tdReadMore;

  /// No description provided for @tdReadLess.
  ///
  /// In en, this message translates to:
  /// **'Read Less'**
  String get tdReadLess;

  /// No description provided for @tdInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Temple Information'**
  String get tdInfoTitle;

  /// No description provided for @tdTimings.
  ///
  /// In en, this message translates to:
  /// **'Timings'**
  String get tdTimings;

  /// No description provided for @tdDeity.
  ///
  /// In en, this message translates to:
  /// **'Deity'**
  String get tdDeity;

  /// No description provided for @tdArchitecture.
  ///
  /// In en, this message translates to:
  /// **'Architecture'**
  String get tdArchitecture;

  /// No description provided for @tdHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tdHistory;

  /// No description provided for @tdFacilities.
  ///
  /// In en, this message translates to:
  /// **'Facilities'**
  String get tdFacilities;

  /// No description provided for @tdRouteIntegration.
  ///
  /// In en, this message translates to:
  /// **'Part of These Yatras'**
  String get tdRouteIntegration;

  /// No description provided for @tdCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get tdCompleted;

  /// No description provided for @tdViewRoute.
  ///
  /// In en, this message translates to:
  /// **'View Route'**
  String get tdViewRoute;

  /// No description provided for @tdContinueJourney.
  ///
  /// In en, this message translates to:
  /// **'Continue Journey'**
  String get tdContinueJourney;

  /// No description provided for @tdMyProgress.
  ///
  /// In en, this message translates to:
  /// **'My Progress'**
  String get tdMyProgress;

  /// No description provided for @tdVisited.
  ///
  /// In en, this message translates to:
  /// **'Visited'**
  String get tdVisited;

  /// No description provided for @tdCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get tdCheckIn;

  /// No description provided for @tdCardCollected.
  ///
  /// In en, this message translates to:
  /// **'Card Collected'**
  String get tdCardCollected;

  /// No description provided for @tdStampAdded.
  ///
  /// In en, this message translates to:
  /// **'Stamp Added'**
  String get tdStampAdded;

  /// No description provided for @tdNotVisitedYet.
  ///
  /// In en, this message translates to:
  /// **'Not visited yet'**
  String get tdNotVisitedYet;

  /// No description provided for @tdGallery.
  ///
  /// In en, this message translates to:
  /// **'Temple Gallery'**
  String get tdGallery;

  /// No description provided for @tdNearbyTemples.
  ///
  /// In en, this message translates to:
  /// **'Nearby Temples'**
  String get tdNearbyTemples;

  /// No description provided for @tdNavigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get tdNavigate;

  /// No description provided for @tdViewPassport.
  ///
  /// In en, this message translates to:
  /// **'View Passport'**
  String get tdViewPassport;

  /// No description provided for @tdMinutesShort.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get tdMinutesShort;

  /// No description provided for @tdCrowdLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get tdCrowdLow;

  /// No description provided for @tdCrowdModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get tdCrowdModerate;

  /// No description provided for @tdCrowdHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get tdCrowdHigh;

  /// No description provided for @tdCrowdVeryHigh.
  ///
  /// In en, this message translates to:
  /// **'Very High'**
  String get tdCrowdVeryHigh;

  /// No description provided for @tdErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this temple'**
  String get tdErrorTitle;

  /// No description provided for @tvTitle.
  ///
  /// In en, this message translates to:
  /// **'Temple Visit'**
  String get tvTitle;

  /// No description provided for @tvNavTitle.
  ///
  /// In en, this message translates to:
  /// **'Navigation to Temple'**
  String get tvNavTitle;

  /// No description provided for @tvArrivalTitle.
  ///
  /// In en, this message translates to:
  /// **'Arrival Detection'**
  String get tvArrivalTitle;

  /// No description provided for @tvCheckinTitle.
  ///
  /// In en, this message translates to:
  /// **'Check-In'**
  String get tvCheckinTitle;

  /// No description provided for @tvCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Temple Card Unlocked'**
  String get tvCardTitle;

  /// No description provided for @tvPassportBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Passport Updated'**
  String get tvPassportBarTitle;

  /// No description provided for @tvAchievementBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievement Unlocked'**
  String get tvAchievementBarTitle;

  /// No description provided for @tvContinueTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue Your Journey'**
  String get tvContinueTitle;

  /// No description provided for @tvFailureBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Check-In Failed'**
  String get tvFailureBarTitle;

  /// No description provided for @tvDistanceLeft.
  ///
  /// In en, this message translates to:
  /// **'Distance Left'**
  String get tvDistanceLeft;

  /// No description provided for @tvEta.
  ///
  /// In en, this message translates to:
  /// **'ETA'**
  String get tvEta;

  /// No description provided for @tvArrivalTime.
  ///
  /// In en, this message translates to:
  /// **'Arrival Time'**
  String get tvArrivalTime;

  /// No description provided for @tvMinShort.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get tvMinShort;

  /// No description provided for @tvTravelMode.
  ///
  /// In en, this message translates to:
  /// **'Travel Mode'**
  String get tvTravelMode;

  /// No description provided for @tvModeDriving.
  ///
  /// In en, this message translates to:
  /// **'Driving'**
  String get tvModeDriving;

  /// No description provided for @tvModeWalking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get tvModeWalking;

  /// No description provided for @tvNavigationHint.
  ///
  /// In en, this message translates to:
  /// **'Turn-by-turn directions open right here in MARG.'**
  String get tvNavigationHint;

  /// No description provided for @tvStartNavigation.
  ///
  /// In en, this message translates to:
  /// **'Start Navigation'**
  String get tvStartNavigation;

  /// No description provided for @tvIveArrived.
  ///
  /// In en, this message translates to:
  /// **'I\'ve Arrived'**
  String get tvIveArrived;

  /// No description provided for @tvArrivalApproaching.
  ///
  /// In en, this message translates to:
  /// **'Approaching the Temple'**
  String get tvArrivalApproaching;

  /// No description provided for @tvWelcomeTo.
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get tvWelcomeTo;

  /// No description provided for @tvArrivalWithin.
  ///
  /// In en, this message translates to:
  /// **'You are within the sacred area.'**
  String get tvArrivalWithin;

  /// No description provided for @tvArrivalMoveCloser.
  ///
  /// In en, this message translates to:
  /// **'Move closer to the temple to check in.'**
  String get tvArrivalMoveCloser;

  /// No description provided for @tvGeofence.
  ///
  /// In en, this message translates to:
  /// **'Temple Area'**
  String get tvGeofence;

  /// No description provided for @tvGeofenceInside.
  ///
  /// In en, this message translates to:
  /// **'Within temple area'**
  String get tvGeofenceInside;

  /// No description provided for @tvAccuracy.
  ///
  /// In en, this message translates to:
  /// **'GPS Accuracy'**
  String get tvAccuracy;

  /// No description provided for @tvAccuracyHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get tvAccuracyHigh;

  /// No description provided for @tvAccuracyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get tvAccuracyMedium;

  /// No description provided for @tvAccuracyLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get tvAccuracyLow;

  /// No description provided for @tvAccuracyUnknown.
  ///
  /// In en, this message translates to:
  /// **'Detecting…'**
  String get tvAccuracyUnknown;

  /// No description provided for @tvImAtTheTemple.
  ///
  /// In en, this message translates to:
  /// **'I am at the Temple'**
  String get tvImAtTheTemple;

  /// No description provided for @tvRefreshLocation.
  ///
  /// In en, this message translates to:
  /// **'Refresh Location'**
  String get tvRefreshLocation;

  /// No description provided for @tvLocationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission is needed to verify your visit.'**
  String get tvLocationDenied;

  /// No description provided for @tvEnableLocation.
  ///
  /// In en, this message translates to:
  /// **'Enable Location'**
  String get tvEnableLocation;

  /// No description provided for @tvConfirmArrival.
  ///
  /// In en, this message translates to:
  /// **'Confirm Your Arrival'**
  String get tvConfirmArrival;

  /// No description provided for @tvGpsLocation.
  ///
  /// In en, this message translates to:
  /// **'GPS Location'**
  String get tvGpsLocation;

  /// No description provided for @tvGpsWaiting.
  ///
  /// In en, this message translates to:
  /// **'Acquiring signal…'**
  String get tvGpsWaiting;

  /// No description provided for @tvVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get tvVerified;

  /// No description provided for @tvCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get tvCurrentLocation;

  /// No description provided for @tvDevice.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get tvDevice;

  /// No description provided for @tvConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Please confirm that you are physically at the temple to check in.'**
  String get tvConfirmHint;

  /// No description provided for @tvTermsNotice.
  ///
  /// In en, this message translates to:
  /// **'By checking in, you agree to our Terms & Conditions.'**
  String get tvTermsNotice;

  /// No description provided for @tvCheckInNow.
  ///
  /// In en, this message translates to:
  /// **'Check-In Now'**
  String get tvCheckInNow;

  /// No description provided for @tvStepLocation.
  ///
  /// In en, this message translates to:
  /// **'Verifying Location'**
  String get tvStepLocation;

  /// No description provided for @tvStepLocationSub.
  ///
  /// In en, this message translates to:
  /// **'Checking GPS & geofence'**
  String get tvStepLocationSub;

  /// No description provided for @tvStepDevice.
  ///
  /// In en, this message translates to:
  /// **'Checking Device'**
  String get tvStepDevice;

  /// No description provided for @tvStepDeviceSub.
  ///
  /// In en, this message translates to:
  /// **'Validating device integrity'**
  String get tvStepDeviceSub;

  /// No description provided for @tvStepRoute.
  ///
  /// In en, this message translates to:
  /// **'Checking Route'**
  String get tvStepRoute;

  /// No description provided for @tvStepRouteSub.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your journey'**
  String get tvStepRouteSub;

  /// No description provided for @tvStepHistory.
  ///
  /// In en, this message translates to:
  /// **'Checking Visit History'**
  String get tvStepHistory;

  /// No description provided for @tvStepHistorySub.
  ///
  /// In en, this message translates to:
  /// **'Verifying previous visits'**
  String get tvStepHistorySub;

  /// No description provided for @tvStepPassport.
  ///
  /// In en, this message translates to:
  /// **'Updating Passport'**
  String get tvStepPassport;

  /// No description provided for @tvStepPassportSub.
  ///
  /// In en, this message translates to:
  /// **'Recording your visit'**
  String get tvStepPassportSub;

  /// No description provided for @tvStepFinalize.
  ///
  /// In en, this message translates to:
  /// **'Finalizing'**
  String get tvStepFinalize;

  /// No description provided for @tvStepFinalizeSub.
  ///
  /// In en, this message translates to:
  /// **'Almost done…'**
  String get tvStepFinalizeSub;

  /// No description provided for @tvVerifyingWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait while we verify your visit. This may take a few seconds.'**
  String get tvVerifyingWait;

  /// No description provided for @tvVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Visit Verified!'**
  String get tvVerifiedTitle;

  /// No description provided for @tvCardUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Card Unlocked'**
  String get tvCardUnlocked;

  /// No description provided for @tvPassportUpdated.
  ///
  /// In en, this message translates to:
  /// **'Passport Updated'**
  String get tvPassportUpdated;

  /// No description provided for @tvTrustScore.
  ///
  /// In en, this message translates to:
  /// **'Trust Score'**
  String get tvTrustScore;

  /// No description provided for @tvCardUnlockedBody.
  ///
  /// In en, this message translates to:
  /// **'You have unlocked a new card!'**
  String get tvCardUnlockedBody;

  /// No description provided for @tvViewCollection.
  ///
  /// In en, this message translates to:
  /// **'View Collection'**
  String get tvViewCollection;

  /// No description provided for @tvPassportTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Spiritual Passport'**
  String get tvPassportTitle;

  /// No description provided for @tvTemplesCompleted.
  ///
  /// In en, this message translates to:
  /// **'Temples Completed'**
  String get tvTemplesCompleted;

  /// No description provided for @tvTemplesVisited.
  ///
  /// In en, this message translates to:
  /// **'Temples Visited'**
  String get tvTemplesVisited;

  /// No description provided for @tvTemplesRemaining.
  ///
  /// In en, this message translates to:
  /// **'Temples Remaining'**
  String get tvTemplesRemaining;

  /// No description provided for @tvPassportProgress.
  ///
  /// In en, this message translates to:
  /// **'Passport Progress'**
  String get tvPassportProgress;

  /// No description provided for @tvViewFullPassport.
  ///
  /// In en, this message translates to:
  /// **'View Full Passport'**
  String get tvViewFullPassport;

  /// No description provided for @tvAchievementTitle.
  ///
  /// In en, this message translates to:
  /// **'New Achievement!'**
  String get tvAchievementTitle;

  /// No description provided for @tvViewAllAchievements.
  ///
  /// In en, this message translates to:
  /// **'View All Achievements'**
  String get tvViewAllAchievements;

  /// No description provided for @tvJourneyContinuesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Journey Continues'**
  String get tvJourneyContinuesTitle;

  /// No description provided for @tvNextTemple.
  ///
  /// In en, this message translates to:
  /// **'Next Temple'**
  String get tvNextTemple;

  /// No description provided for @tvNavigateNextTemple.
  ///
  /// In en, this message translates to:
  /// **'Navigate to Next Temple'**
  String get tvNavigateNextTemple;

  /// No description provided for @tvViewFullRoute.
  ///
  /// In en, this message translates to:
  /// **'View Full Route'**
  String get tvViewFullRoute;

  /// No description provided for @tvJourneyNoRoute.
  ///
  /// In en, this message translates to:
  /// **'This temple isn\'t part of a route yet. Explore more to begin a pilgrimage.'**
  String get tvJourneyNoRoute;

  /// No description provided for @tvDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get tvDone;

  /// No description provided for @tvFailureTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to Verify Visit'**
  String get tvFailureTitle;

  /// No description provided for @tvTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tvTryAgain;

  /// No description provided for @tvGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get tvGoBack;

  /// No description provided for @tvHintOutsideTitle.
  ///
  /// In en, this message translates to:
  /// **'You are outside the temple area'**
  String get tvHintOutsideTitle;

  /// No description provided for @tvHintOutsideBody.
  ///
  /// In en, this message translates to:
  /// **'Move closer to the temple.'**
  String get tvHintOutsideBody;

  /// No description provided for @tvHintAccuracyTitle.
  ///
  /// In en, this message translates to:
  /// **'Poor GPS accuracy'**
  String get tvHintAccuracyTitle;

  /// No description provided for @tvHintAccuracyBody.
  ///
  /// In en, this message translates to:
  /// **'Please enable high accuracy mode.'**
  String get tvHintAccuracyBody;

  /// No description provided for @tvHintConnectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection'**
  String get tvHintConnectionTitle;

  /// No description provided for @tvHintConnectionBody.
  ///
  /// In en, this message translates to:
  /// **'A stable connection is required.'**
  String get tvHintConnectionBody;

  /// No description provided for @tvHintMockTitle.
  ///
  /// In en, this message translates to:
  /// **'Mock location detected'**
  String get tvHintMockTitle;

  /// No description provided for @tvHintMockBody.
  ///
  /// In en, this message translates to:
  /// **'Turn off mock location apps and try again.'**
  String get tvHintMockBody;

  /// No description provided for @tvHintDuplicateTitle.
  ///
  /// In en, this message translates to:
  /// **'Already checked in'**
  String get tvHintDuplicateTitle;

  /// No description provided for @tvHintDuplicateBody.
  ///
  /// In en, this message translates to:
  /// **'You have already recorded a visit here today.'**
  String get tvHintDuplicateBody;

  /// No description provided for @tvHintRateTitle.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts'**
  String get tvHintRateTitle;

  /// No description provided for @tvHintRateBody.
  ///
  /// In en, this message translates to:
  /// **'Please wait a moment before trying again.'**
  String get tvHintRateBody;

  /// No description provided for @tvErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load temple'**
  String get tvErrorTitle;

  /// No description provided for @tvErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again.'**
  String get tvErrorBody;

  /// No description provided for @ryTitle.
  ///
  /// In en, this message translates to:
  /// **'My Yatras'**
  String get ryTitle;

  /// No description provided for @ryDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover Routes'**
  String get ryDiscover;

  /// No description provided for @ryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get ryAll;

  /// No description provided for @ryInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get ryInProgress;

  /// No description provided for @ryCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get ryCompleted;

  /// No description provided for @ryContinueJourney.
  ///
  /// In en, this message translates to:
  /// **'Continue Journey'**
  String get ryContinueJourney;

  /// No description provided for @ryTemples.
  ///
  /// In en, this message translates to:
  /// **'Temples'**
  String get ryTemples;

  /// No description provided for @ryTemplesCompleted.
  ///
  /// In en, this message translates to:
  /// **'Temples Completed'**
  String get ryTemplesCompleted;

  /// No description provided for @ryTemplesVisited.
  ///
  /// In en, this message translates to:
  /// **'Temples Visited'**
  String get ryTemplesVisited;

  /// No description provided for @ryTotalTemples.
  ///
  /// In en, this message translates to:
  /// **'Total Temples'**
  String get ryTotalTemples;

  /// No description provided for @ryRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get ryRemaining;

  /// No description provided for @ryKm.
  ///
  /// In en, this message translates to:
  /// **'KM'**
  String get ryKm;

  /// No description provided for @ryDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get ryDays;

  /// No description provided for @ryNoYatras.
  ///
  /// In en, this message translates to:
  /// **'No Yatras yet'**
  String get ryNoYatras;

  /// No description provided for @ryNoYatrasBody.
  ///
  /// In en, this message translates to:
  /// **'Start a sacred route to begin your pilgrimage journey.'**
  String get ryNoYatrasBody;

  /// No description provided for @ryNoInFilter.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get ryNoInFilter;

  /// No description provided for @ryNoRoutes.
  ///
  /// In en, this message translates to:
  /// **'No routes found'**
  String get ryNoRoutes;

  /// No description provided for @ryNoRoutesBody.
  ///
  /// In en, this message translates to:
  /// **'Try a different category.'**
  String get ryNoRoutesBody;

  /// No description provided for @ryErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load routes'**
  String get ryErrorTitle;

  /// No description provided for @ryErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again.'**
  String get ryErrorBody;

  /// No description provided for @ryTypeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get ryTypeAll;

  /// No description provided for @ryTypeJyotirlinga.
  ///
  /// In en, this message translates to:
  /// **'Jyotirlinga'**
  String get ryTypeJyotirlinga;

  /// No description provided for @ryTypeShaktiPeeth.
  ///
  /// In en, this message translates to:
  /// **'Shakti Peeth'**
  String get ryTypeShaktiPeeth;

  /// No description provided for @ryTypeCharDham.
  ///
  /// In en, this message translates to:
  /// **'Char Dham'**
  String get ryTypeCharDham;

  /// No description provided for @ryTypeCustom.
  ///
  /// In en, this message translates to:
  /// **'Other Routes'**
  String get ryTypeCustom;

  /// No description provided for @ryTabTemples.
  ///
  /// In en, this message translates to:
  /// **'Temples'**
  String get ryTabTemples;

  /// No description provided for @ryTabTimeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get ryTabTimeline;

  /// No description provided for @ryTabMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get ryTabMap;

  /// No description provided for @ryTabRewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get ryTabRewards;

  /// No description provided for @ryStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get ryStatusCompleted;

  /// No description provided for @ryStatusCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get ryStatusCurrent;

  /// No description provided for @ryStatusUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get ryStatusUpcoming;

  /// No description provided for @ryVisited.
  ///
  /// In en, this message translates to:
  /// **'Visited'**
  String get ryVisited;

  /// No description provided for @ryViewNextTemple.
  ///
  /// In en, this message translates to:
  /// **'View Next Temple'**
  String get ryViewNextTemple;

  /// No description provided for @ryMapUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Map needs at least two temple locations.'**
  String get ryMapUnavailable;

  /// No description provided for @ryRouteReward.
  ///
  /// In en, this message translates to:
  /// **'Route Reward'**
  String get ryRouteReward;

  /// No description provided for @ryYourStats.
  ///
  /// In en, this message translates to:
  /// **'Your Stats'**
  String get ryYourStats;

  /// No description provided for @ryCongratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get ryCongratulations;

  /// No description provided for @ryCompletedRoutePrefix.
  ///
  /// In en, this message translates to:
  /// **'You have completed'**
  String get ryCompletedRoutePrefix;

  /// No description provided for @ryCertificate.
  ///
  /// In en, this message translates to:
  /// **'Certificate'**
  String get ryCertificate;

  /// No description provided for @ryCertificateTitle.
  ///
  /// In en, this message translates to:
  /// **'Certificate of Completion'**
  String get ryCertificateTitle;

  /// No description provided for @ryCertifyThat.
  ///
  /// In en, this message translates to:
  /// **'This is to certify that'**
  String get ryCertifyThat;

  /// No description provided for @ryHasCompleted.
  ///
  /// In en, this message translates to:
  /// **'has successfully completed'**
  String get ryHasCompleted;

  /// No description provided for @ryBlessings.
  ///
  /// In en, this message translates to:
  /// **'May the divine blessings be with you always.'**
  String get ryBlessings;

  /// No description provided for @ryCertDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get ryCertDate;

  /// No description provided for @ryCertIssuer.
  ///
  /// In en, this message translates to:
  /// **'MARG Temple Yatra'**
  String get ryCertIssuer;

  /// No description provided for @ryPilgrim.
  ///
  /// In en, this message translates to:
  /// **'Pilgrim'**
  String get ryPilgrim;

  /// No description provided for @ryShareAchievement.
  ///
  /// In en, this message translates to:
  /// **'Share Achievement'**
  String get ryShareAchievement;

  /// No description provided for @ryShareBody.
  ///
  /// In en, this message translates to:
  /// **'I completed the'**
  String get ryShareBody;

  /// No description provided for @ryViewPassport.
  ///
  /// In en, this message translates to:
  /// **'View Passport'**
  String get ryViewPassport;

  /// No description provided for @ryRewardsLockedHint.
  ///
  /// In en, this message translates to:
  /// **'Complete all temples to unlock the certificate and route reward.'**
  String get ryRewardsLockedHint;

  /// No description provided for @scTitle.
  ///
  /// In en, this message translates to:
  /// **'My Sacred Collection'**
  String get scTitle;

  /// No description provided for @scSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get scSearch;

  /// No description provided for @scSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search cards'**
  String get scSearchHint;

  /// No description provided for @scGallery.
  ///
  /// In en, this message translates to:
  /// **'Card Gallery'**
  String get scGallery;

  /// No description provided for @scAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get scAll;

  /// No description provided for @scCollectionProgress.
  ///
  /// In en, this message translates to:
  /// **'Collection Progress'**
  String get scCollectionProgress;

  /// No description provided for @scCardsUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Cards unlocked'**
  String get scCardsUnlocked;

  /// No description provided for @scCardsOwned.
  ///
  /// In en, this message translates to:
  /// **'owned'**
  String get scCardsOwned;

  /// No description provided for @scMissing.
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get scMissing;

  /// No description provided for @scMissingCards.
  ///
  /// In en, this message translates to:
  /// **'Missing Cards'**
  String get scMissingCards;

  /// No description provided for @scExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get scExplore;

  /// No description provided for @scSeries.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get scSeries;

  /// No description provided for @scSeasons.
  ///
  /// In en, this message translates to:
  /// **'Seasons'**
  String get scSeasons;

  /// No description provided for @scStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get scStatistics;

  /// No description provided for @scRecentlyUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Recently Unlocked'**
  String get scRecentlyUnlocked;

  /// No description provided for @scCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Sacred Card'**
  String get scCardTitle;

  /// No description provided for @scErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load cards'**
  String get scErrorTitle;

  /// No description provided for @scErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again.'**
  String get scErrorBody;

  /// No description provided for @scNoCards.
  ///
  /// In en, this message translates to:
  /// **'No cards found'**
  String get scNoCards;

  /// No description provided for @scNoCardsBody.
  ///
  /// In en, this message translates to:
  /// **'Try a different filter.'**
  String get scNoCardsBody;

  /// No description provided for @scNoGroupsBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get scNoGroupsBody;

  /// No description provided for @scNoSeries.
  ///
  /// In en, this message translates to:
  /// **'No series yet'**
  String get scNoSeries;

  /// No description provided for @scNoSeasons.
  ///
  /// In en, this message translates to:
  /// **'No seasons yet'**
  String get scNoSeasons;

  /// No description provided for @scNoRecent.
  ///
  /// In en, this message translates to:
  /// **'No cards yet'**
  String get scNoRecent;

  /// No description provided for @scNoRecentBody.
  ///
  /// In en, this message translates to:
  /// **'Visit temples to unlock sacred cards.'**
  String get scNoRecentBody;

  /// No description provided for @scLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get scLocked;

  /// No description provided for @scUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get scUnlocked;

  /// No description provided for @scHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get scHistory;

  /// No description provided for @scViewTemple.
  ///
  /// In en, this message translates to:
  /// **'View Temple'**
  String get scViewTemple;

  /// No description provided for @scShareCard.
  ///
  /// In en, this message translates to:
  /// **'Share Card'**
  String get scShareCard;

  /// No description provided for @scShareFallback.
  ///
  /// In en, this message translates to:
  /// **'I unlocked the'**
  String get scShareFallback;

  /// No description provided for @scTapToFlip.
  ///
  /// In en, this message translates to:
  /// **'Tap the card to flip'**
  String get scTapToFlip;

  /// No description provided for @scEdition.
  ///
  /// In en, this message translates to:
  /// **'Edition'**
  String get scEdition;

  /// No description provided for @scLimited.
  ///
  /// In en, this message translates to:
  /// **'Limited'**
  String get scLimited;

  /// No description provided for @scYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get scYes;

  /// No description provided for @scByRarity.
  ///
  /// In en, this message translates to:
  /// **'By Rarity'**
  String get scByRarity;

  /// No description provided for @scSeriesCompletion.
  ///
  /// In en, this message translates to:
  /// **'Series Completion'**
  String get scSeriesCompletion;

  /// No description provided for @scSeasonCompletion.
  ///
  /// In en, this message translates to:
  /// **'Season Completion'**
  String get scSeasonCompletion;

  /// No description provided for @scOwned.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get scOwned;

  /// No description provided for @scComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get scComplete;

  /// No description provided for @scRarityCommon.
  ///
  /// In en, this message translates to:
  /// **'Common'**
  String get scRarityCommon;

  /// No description provided for @scRarityRare.
  ///
  /// In en, this message translates to:
  /// **'Rare'**
  String get scRarityRare;

  /// No description provided for @scRarityEpic.
  ///
  /// In en, this message translates to:
  /// **'Epic'**
  String get scRarityEpic;

  /// No description provided for @scRarityLegendary.
  ///
  /// In en, this message translates to:
  /// **'Legendary'**
  String get scRarityLegendary;

  /// No description provided for @scRarityMythic.
  ///
  /// In en, this message translates to:
  /// **'Mythic'**
  String get scRarityMythic;

  /// No description provided for @scNew.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get scNew;

  /// No description provided for @scUnlockedOn.
  ///
  /// In en, this message translates to:
  /// **'Unlocked on'**
  String get scUnlockedOn;

  /// No description provided for @scMintNumber.
  ///
  /// In en, this message translates to:
  /// **'Mint no.'**
  String get scMintNumber;

  /// No description provided for @scShareHeadline.
  ///
  /// In en, this message translates to:
  /// **'I unlocked a Sacred Card on my spiritual journey'**
  String get scShareHeadline;

  /// No description provided for @ryPlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get ryPlanned;

  /// No description provided for @rySaveRoute.
  ///
  /// In en, this message translates to:
  /// **'Save to My Yatras'**
  String get rySaveRoute;

  /// No description provided for @rySaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get rySaved;

  /// No description provided for @rySavedToPlanned.
  ///
  /// In en, this message translates to:
  /// **'Saved to your journeys'**
  String get rySavedToPlanned;

  /// No description provided for @ryRemovedFromPlanned.
  ///
  /// In en, this message translates to:
  /// **'Removed from your journeys'**
  String get ryRemovedFromPlanned;

  /// No description provided for @ryDownloadCertificate.
  ///
  /// In en, this message translates to:
  /// **'Download Certificate'**
  String get ryDownloadCertificate;

  /// No description provided for @ryCertUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Certificate isn\'t available yet.'**
  String get ryCertUnavailable;

  /// No description provided for @acTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get acTitle;

  /// No description provided for @acQuote.
  ///
  /// In en, this message translates to:
  /// **'Every step of devotion is a step towards divinity'**
  String get acQuote;

  /// No description provided for @acSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get acSearch;

  /// No description provided for @acSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search achievements'**
  String get acSearchHint;

  /// No description provided for @acExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get acExplore;

  /// No description provided for @acGallery.
  ///
  /// In en, this message translates to:
  /// **'All Achievements'**
  String get acGallery;

  /// No description provided for @acCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get acCategories;

  /// No description provided for @acMilestones.
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get acMilestones;

  /// No description provided for @acStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get acStatistics;

  /// No description provided for @acRecent.
  ///
  /// In en, this message translates to:
  /// **'Recently Unlocked'**
  String get acRecent;

  /// No description provided for @acDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievement Detail'**
  String get acDetailTitle;

  /// No description provided for @acOverallProgress.
  ///
  /// In en, this message translates to:
  /// **'Overall Progress'**
  String get acOverallProgress;

  /// No description provided for @acCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get acCompleted;

  /// No description provided for @acInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get acInProgress;

  /// No description provided for @acLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get acLocked;

  /// No description provided for @acAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get acAll;

  /// No description provided for @acPointsEarned.
  ///
  /// In en, this message translates to:
  /// **'Points Earned'**
  String get acPointsEarned;

  /// No description provided for @acTrustScore.
  ///
  /// In en, this message translates to:
  /// **'Trust Score'**
  String get acTrustScore;

  /// No description provided for @acPoints.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get acPoints;

  /// No description provided for @acEarned.
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get acEarned;

  /// No description provided for @acStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get acStatusCompleted;

  /// No description provided for @acErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load achievements'**
  String get acErrorTitle;

  /// No description provided for @acErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again.'**
  String get acErrorBody;

  /// No description provided for @acNoResults.
  ///
  /// In en, this message translates to:
  /// **'No achievements found'**
  String get acNoResults;

  /// No description provided for @acNoResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Try a different filter.'**
  String get acNoResultsBody;

  /// No description provided for @acNoRecent.
  ///
  /// In en, this message translates to:
  /// **'No achievements yet'**
  String get acNoRecent;

  /// No description provided for @acNoRecentBody.
  ///
  /// In en, this message translates to:
  /// **'Complete your journey to earn achievements.'**
  String get acNoRecentBody;

  /// No description provided for @acNoMilestones.
  ///
  /// In en, this message translates to:
  /// **'No milestones yet'**
  String get acNoMilestones;

  /// No description provided for @acNoMilestonesBody.
  ///
  /// In en, this message translates to:
  /// **'Begin visiting temples to reach milestones.'**
  String get acNoMilestonesBody;

  /// No description provided for @acMilestonesBanner.
  ///
  /// In en, this message translates to:
  /// **'Keep going, Devotee'**
  String get acMilestonesBanner;

  /// No description provided for @acMilestonesBannerSub.
  ///
  /// In en, this message translates to:
  /// **'Every milestone is a blessing.'**
  String get acMilestonesBannerSub;

  /// No description provided for @acYourProgress.
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get acYourProgress;

  /// No description provided for @acReward.
  ///
  /// In en, this message translates to:
  /// **'Reward'**
  String get acReward;

  /// No description provided for @acUnlockedOn.
  ///
  /// In en, this message translates to:
  /// **'Unlocked On'**
  String get acUnlockedOn;

  /// No description provided for @acShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get acShare;

  /// No description provided for @acShareAchievement.
  ///
  /// In en, this message translates to:
  /// **'Share Achievement'**
  String get acShareAchievement;

  /// No description provided for @acShareBody.
  ///
  /// In en, this message translates to:
  /// **'I earned a sacred achievement on MARG!'**
  String get acShareBody;

  /// No description provided for @acBrandTagline.
  ///
  /// In en, this message translates to:
  /// **'MARG · Connecting Devotees to Divine'**
  String get acBrandTagline;

  /// No description provided for @acByRarity.
  ///
  /// In en, this message translates to:
  /// **'By Rarity'**
  String get acByRarity;

  /// No description provided for @acByCategory.
  ///
  /// In en, this message translates to:
  /// **'By Category'**
  String get acByCategory;

  /// No description provided for @acTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get acTotal;

  /// No description provided for @acCompletionPct.
  ///
  /// In en, this message translates to:
  /// **'Completion'**
  String get acCompletionPct;

  /// No description provided for @acUnlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievement Unlocked!'**
  String get acUnlockedTitle;

  /// No description provided for @acViewAchievement.
  ///
  /// In en, this message translates to:
  /// **'View Achievement'**
  String get acViewAchievement;

  /// No description provided for @acContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get acContinue;

  /// No description provided for @acCatTemple.
  ///
  /// In en, this message translates to:
  /// **'Temple Explorer'**
  String get acCatTemple;

  /// No description provided for @acCatRoute.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get acCatRoute;

  /// No description provided for @acCatCard.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get acCatCard;

  /// No description provided for @acCatSeries.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get acCatSeries;

  /// No description provided for @acCatSeason.
  ///
  /// In en, this message translates to:
  /// **'Seasons'**
  String get acCatSeason;

  /// No description provided for @acCatTrust.
  ///
  /// In en, this message translates to:
  /// **'Trust'**
  String get acCatTrust;

  /// No description provided for @acCatSpecial.
  ///
  /// In en, this message translates to:
  /// **'Special'**
  String get acCatSpecial;

  /// No description provided for @ppTitle.
  ///
  /// In en, this message translates to:
  /// **'Spiritual Passport'**
  String get ppTitle;

  /// No description provided for @ppSpiritualPassport.
  ///
  /// In en, this message translates to:
  /// **'Spiritual Passport'**
  String get ppSpiritualPassport;

  /// No description provided for @ppJourneyOverview.
  ///
  /// In en, this message translates to:
  /// **'Journey Overview'**
  String get ppJourneyOverview;

  /// No description provided for @ppTimeline.
  ///
  /// In en, this message translates to:
  /// **'Journey Timeline'**
  String get ppTimeline;

  /// No description provided for @ppMap.
  ///
  /// In en, this message translates to:
  /// **'Passport Map'**
  String get ppMap;

  /// No description provided for @ppCollection.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get ppCollection;

  /// No description provided for @ppRoutes.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get ppRoutes;

  /// No description provided for @ppTemples.
  ///
  /// In en, this message translates to:
  /// **'Temples'**
  String get ppTemples;

  /// No description provided for @ppStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get ppStatistics;

  /// No description provided for @ppCertificates.
  ///
  /// In en, this message translates to:
  /// **'Certificates'**
  String get ppCertificates;

  /// No description provided for @ppSharePassport.
  ///
  /// In en, this message translates to:
  /// **'Share Passport'**
  String get ppSharePassport;

  /// No description provided for @ppPublicPassport.
  ///
  /// In en, this message translates to:
  /// **'Public Passport'**
  String get ppPublicPassport;

  /// No description provided for @ppTimelineHint.
  ///
  /// In en, this message translates to:
  /// **'Every step, in order'**
  String get ppTimelineHint;

  /// No description provided for @ppMapHint.
  ///
  /// In en, this message translates to:
  /// **'Your visits across Bharat'**
  String get ppMapHint;

  /// No description provided for @ppCollectionHint.
  ///
  /// In en, this message translates to:
  /// **'Series & seasons'**
  String get ppCollectionHint;

  /// No description provided for @ppRoutesHint.
  ///
  /// In en, this message translates to:
  /// **'Sacred routes walked'**
  String get ppRoutesHint;

  /// No description provided for @ppTemplesHint.
  ///
  /// In en, this message translates to:
  /// **'Every darshan logged'**
  String get ppTemplesHint;

  /// No description provided for @ppStatisticsHint.
  ///
  /// In en, this message translates to:
  /// **'Your journey in numbers'**
  String get ppStatisticsHint;

  /// No description provided for @ppCertificatesHint.
  ///
  /// In en, this message translates to:
  /// **'Route completion awards'**
  String get ppCertificatesHint;

  /// No description provided for @ppPublicPassportHint.
  ///
  /// In en, this message translates to:
  /// **'What others see'**
  String get ppPublicPassportHint;

  /// No description provided for @ppErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get ppErrorTitle;

  /// No description provided for @ppErrorBody.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your passport. Please try again.'**
  String get ppErrorBody;

  /// No description provided for @ppAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get ppAll;

  /// No description provided for @ppAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get ppAchievements;

  /// No description provided for @ppCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get ppCards;

  /// No description provided for @ppCardsCollected.
  ///
  /// In en, this message translates to:
  /// **'Cards Collected'**
  String get ppCardsCollected;

  /// No description provided for @ppSeries.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get ppSeries;

  /// No description provided for @ppSeasons.
  ///
  /// In en, this message translates to:
  /// **'Seasons'**
  String get ppSeasons;

  /// No description provided for @ppRecentUnlocks.
  ///
  /// In en, this message translates to:
  /// **'Recent Unlocks'**
  String get ppRecentUnlocks;

  /// No description provided for @ppNoGroups.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get ppNoGroups;

  /// No description provided for @ppNoGroupsBody.
  ///
  /// In en, this message translates to:
  /// **'Collect cards to complete series and seasons.'**
  String get ppNoGroupsBody;

  /// No description provided for @ppCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get ppCompleted;

  /// No description provided for @ppInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get ppInProgress;

  /// No description provided for @ppExploreRoutes.
  ///
  /// In en, this message translates to:
  /// **'Explore Routes'**
  String get ppExploreRoutes;

  /// No description provided for @ppExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get ppExplore;

  /// No description provided for @ppNoRoutes.
  ///
  /// In en, this message translates to:
  /// **'No routes yet'**
  String get ppNoRoutes;

  /// No description provided for @ppNoRoutesBody.
  ///
  /// In en, this message translates to:
  /// **'Start a sacred route to see it here.'**
  String get ppNoRoutesBody;

  /// No description provided for @ppTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get ppTotal;

  /// No description provided for @ppVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get ppVerified;

  /// No description provided for @ppPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get ppPending;

  /// No description provided for @ppNoTemples.
  ///
  /// In en, this message translates to:
  /// **'No temple visits yet'**
  String get ppNoTemples;

  /// No description provided for @ppNoTemplesBody.
  ///
  /// In en, this message translates to:
  /// **'Your visited temples will appear here.'**
  String get ppNoTemplesBody;

  /// No description provided for @ppNoMap.
  ///
  /// In en, this message translates to:
  /// **'No places to map yet'**
  String get ppNoMap;

  /// No description provided for @ppNoMapBody.
  ///
  /// In en, this message translates to:
  /// **'Verified visits with a location will appear on the map.'**
  String get ppNoMapBody;

  /// No description provided for @ppVisitsPlotted.
  ///
  /// In en, this message translates to:
  /// **'Visits'**
  String get ppVisitsPlotted;

  /// No description provided for @ppVerifiedVisits.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get ppVerifiedVisits;

  /// No description provided for @ppTemplesVisited.
  ///
  /// In en, this message translates to:
  /// **'Temples'**
  String get ppTemplesVisited;

  /// No description provided for @ppTrustScore.
  ///
  /// In en, this message translates to:
  /// **'Trust Score'**
  String get ppTrustScore;

  /// No description provided for @ppLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get ppLevel;

  /// No description provided for @ppNextLevel.
  ///
  /// In en, this message translates to:
  /// **'Next Level'**
  String get ppNextLevel;

  /// No description provided for @ppRisingStar.
  ///
  /// In en, this message translates to:
  /// **'Rising'**
  String get ppRisingStar;

  /// No description provided for @ppMemberSince.
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get ppMemberSince;

  /// No description provided for @ppPassportId.
  ///
  /// In en, this message translates to:
  /// **'Passport ID'**
  String get ppPassportId;

  /// No description provided for @ppRoutesCompleted.
  ///
  /// In en, this message translates to:
  /// **'Routes Completed'**
  String get ppRoutesCompleted;

  /// No description provided for @ppGlobalRank.
  ///
  /// In en, this message translates to:
  /// **'Global Rank'**
  String get ppGlobalRank;

  /// No description provided for @ppLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get ppLeaderboard;

  /// No description provided for @ppReferrals.
  ///
  /// In en, this message translates to:
  /// **'Referrals'**
  String get ppReferrals;

  /// No description provided for @ppMonthlyActivity.
  ///
  /// In en, this message translates to:
  /// **'Monthly Activity'**
  String get ppMonthlyActivity;

  /// No description provided for @ppNoActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get ppNoActivity;

  /// No description provided for @ppNoActivityBody.
  ///
  /// In en, this message translates to:
  /// **'Your recent activity will appear here.'**
  String get ppNoActivityBody;

  /// No description provided for @ppCompletionBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Completion Breakdown'**
  String get ppCompletionBreakdown;

  /// No description provided for @ppCompletion.
  ///
  /// In en, this message translates to:
  /// **'Completion'**
  String get ppCompletion;

  /// No description provided for @ppPointsToNext.
  ///
  /// In en, this message translates to:
  /// **'points to'**
  String get ppPointsToNext;

  /// No description provided for @ppShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get ppShare;

  /// No description provided for @ppShareAsImage.
  ///
  /// In en, this message translates to:
  /// **'Share as Image'**
  String get ppShareAsImage;

  /// No description provided for @ppShareLink.
  ///
  /// In en, this message translates to:
  /// **'Share Link'**
  String get ppShareLink;

  /// No description provided for @ppShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the share image.'**
  String get ppShareFailed;

  /// No description provided for @ppLinkUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Public link is unavailable right now.'**
  String get ppLinkUnavailable;

  /// No description provided for @ppPublicNote.
  ///
  /// In en, this message translates to:
  /// **'This is exactly what other pilgrims see when they open your public passport link.'**
  String get ppPublicNote;

  /// No description provided for @ppDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get ppDownload;

  /// No description provided for @ppNoCertificates.
  ///
  /// In en, this message translates to:
  /// **'No certificates yet'**
  String get ppNoCertificates;

  /// No description provided for @ppNoCertificatesBody.
  ///
  /// In en, this message translates to:
  /// **'Complete a route to earn a certificate.'**
  String get ppNoCertificatesBody;

  /// No description provided for @ppCertUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Certificate is unavailable right now.'**
  String get ppCertUnavailable;

  /// No description provided for @ppTierSeeker.
  ///
  /// In en, this message translates to:
  /// **'Seeker'**
  String get ppTierSeeker;

  /// No description provided for @ppTierExplorer.
  ///
  /// In en, this message translates to:
  /// **'Explorer'**
  String get ppTierExplorer;

  /// No description provided for @ppTierPilgrim.
  ///
  /// In en, this message translates to:
  /// **'Pilgrim'**
  String get ppTierPilgrim;

  /// No description provided for @ppTierDevotee.
  ///
  /// In en, this message translates to:
  /// **'Devotee'**
  String get ppTierDevotee;

  /// No description provided for @ppTierSage.
  ///
  /// In en, this message translates to:
  /// **'Sage'**
  String get ppTierSage;

  /// No description provided for @ppTierSaint.
  ///
  /// In en, this message translates to:
  /// **'Saint'**
  String get ppTierSaint;

  /// No description provided for @ppTierMahayogi.
  ///
  /// In en, this message translates to:
  /// **'Mahayogi'**
  String get ppTierMahayogi;

  /// No description provided for @exTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore Bharat'**
  String get exTitle;

  /// No description provided for @exSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search temples, cities, states…'**
  String get exSearchHint;

  /// No description provided for @exSearchNearbyHint.
  ///
  /// In en, this message translates to:
  /// **'Search nearby temples'**
  String get exSearchNearbyHint;

  /// No description provided for @exNearYou.
  ///
  /// In en, this message translates to:
  /// **'Near your location'**
  String get exNearYou;

  /// No description provided for @exApproxArea.
  ///
  /// In en, this message translates to:
  /// **'Approximate area'**
  String get exApproxArea;

  /// No description provided for @exApproxAreaNote.
  ///
  /// In en, this message translates to:
  /// **'Showing an approximate area — tap locate for temples near you.'**
  String get exApproxAreaNote;

  /// No description provided for @exLocate.
  ///
  /// In en, this message translates to:
  /// **'Locate me'**
  String get exLocate;

  /// No description provided for @exLocationError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t get your location. Please try again.'**
  String get exLocationError;

  /// No description provided for @exNearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get exNearby;

  /// No description provided for @exNearbyTemples.
  ///
  /// In en, this message translates to:
  /// **'Nearby Temples'**
  String get exNearbyTemples;

  /// No description provided for @exMap.
  ///
  /// In en, this message translates to:
  /// **'Explore Map'**
  String get exMap;

  /// No description provided for @exCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get exCategories;

  /// No description provided for @exCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get exCategory;

  /// No description provided for @exStates.
  ///
  /// In en, this message translates to:
  /// **'States'**
  String get exStates;

  /// No description provided for @exStateExplorer.
  ///
  /// In en, this message translates to:
  /// **'State Explorer'**
  String get exStateExplorer;

  /// No description provided for @exCollections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get exCollections;

  /// No description provided for @exStatistics.
  ///
  /// In en, this message translates to:
  /// **'Explore Statistics'**
  String get exStatistics;

  /// No description provided for @exExploreByState.
  ///
  /// In en, this message translates to:
  /// **'Explore by State'**
  String get exExploreByState;

  /// No description provided for @exPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular Temples'**
  String get exPopular;

  /// No description provided for @exRecentlyVisited.
  ///
  /// In en, this message translates to:
  /// **'Recently Visited'**
  String get exRecentlyVisited;

  /// No description provided for @exStateTemples.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 temple} other{{count} temples}}'**
  String exStateTemples(int count);

  /// No description provided for @exVisited.
  ///
  /// In en, this message translates to:
  /// **'Visited'**
  String get exVisited;

  /// No description provided for @exViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get exViewAll;

  /// No description provided for @exViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get exViewDetails;

  /// No description provided for @exNavigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get exNavigate;

  /// No description provided for @exFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get exFilters;

  /// No description provided for @exReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get exReset;

  /// No description provided for @exApply.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get exApply;

  /// No description provided for @exRadius.
  ///
  /// In en, this message translates to:
  /// **'Radius'**
  String get exRadius;

  /// No description provided for @exSort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get exSort;

  /// No description provided for @exSortPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get exSortPopular;

  /// No description provided for @exSortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get exSortNewest;

  /// No description provided for @exSortName.
  ///
  /// In en, this message translates to:
  /// **'A–Z'**
  String get exSortName;

  /// No description provided for @exAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get exAll;

  /// No description provided for @exErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get exErrorTitle;

  /// No description provided for @exErrorBody.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load this right now. Please try again.'**
  String get exErrorBody;

  /// No description provided for @exNoTemples.
  ///
  /// In en, this message translates to:
  /// **'No temples found'**
  String get exNoTemples;

  /// No description provided for @exNoTemplesBody.
  ///
  /// In en, this message translates to:
  /// **'Try a different filter or search.'**
  String get exNoTemplesBody;

  /// No description provided for @exNoNearby.
  ///
  /// In en, this message translates to:
  /// **'No temples nearby'**
  String get exNoNearby;

  /// No description provided for @exNoStates.
  ///
  /// In en, this message translates to:
  /// **'No states yet'**
  String get exNoStates;

  /// No description provided for @exNoStatesBody.
  ///
  /// In en, this message translates to:
  /// **'States with temples will appear here.'**
  String get exNoStatesBody;

  /// No description provided for @exTemples.
  ///
  /// In en, this message translates to:
  /// **'Temples'**
  String get exTemples;

  /// No description provided for @exDiscoverBharat.
  ///
  /// In en, this message translates to:
  /// **'Discover Bharat'**
  String get exDiscoverBharat;

  /// No description provided for @exDeityShiva.
  ///
  /// In en, this message translates to:
  /// **'Shiva Temples'**
  String get exDeityShiva;

  /// No description provided for @exDeityVishnu.
  ///
  /// In en, this message translates to:
  /// **'Vishnu Temples'**
  String get exDeityVishnu;

  /// No description provided for @exDeityDevi.
  ///
  /// In en, this message translates to:
  /// **'Devi Temples'**
  String get exDeityDevi;

  /// No description provided for @exDeityHanuman.
  ///
  /// In en, this message translates to:
  /// **'Hanuman Temples'**
  String get exDeityHanuman;

  /// No description provided for @exDeityGanesha.
  ///
  /// In en, this message translates to:
  /// **'Ganesha Temples'**
  String get exDeityGanesha;

  /// No description provided for @exDeityOther.
  ///
  /// In en, this message translates to:
  /// **'Other Temples'**
  String get exDeityOther;

  /// No description provided for @exCollPopular.
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get exCollPopular;

  /// No description provided for @exCollPopularSub.
  ///
  /// In en, this message translates to:
  /// **'The most-viewed temples across Bharat'**
  String get exCollPopularSub;

  /// No description provided for @exCollNewest.
  ///
  /// In en, this message translates to:
  /// **'Newly Added'**
  String get exCollNewest;

  /// No description provided for @exCollNewestSub.
  ///
  /// In en, this message translates to:
  /// **'Temples recently added to MARG'**
  String get exCollNewestSub;

  /// No description provided for @exCollDeitySub.
  ///
  /// In en, this message translates to:
  /// **'Popular temples for this deity'**
  String get exCollDeitySub;

  /// No description provided for @exTemplesExplored.
  ///
  /// In en, this message translates to:
  /// **'Temples Explored'**
  String get exTemplesExplored;

  /// No description provided for @exThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get exThisMonth;

  /// No description provided for @exNearestTemple.
  ///
  /// In en, this message translates to:
  /// **'Nearest Temple'**
  String get exNearestTemple;

  /// No description provided for @exFarthestTemple.
  ///
  /// In en, this message translates to:
  /// **'Farthest Temple'**
  String get exFarthestTemple;

  /// No description provided for @exMonthlyExploration.
  ///
  /// In en, this message translates to:
  /// **'Monthly Exploration'**
  String get exMonthlyExploration;

  /// No description provided for @exNoActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get exNoActivity;

  /// No description provided for @exNoStats.
  ///
  /// In en, this message translates to:
  /// **'No exploration yet'**
  String get exNoStats;

  /// No description provided for @exNoStatsBody.
  ///
  /// In en, this message translates to:
  /// **'Visit temples to see your exploration statistics.'**
  String get exNoStatsBody;

  /// No description provided for @exStatsNote.
  ///
  /// In en, this message translates to:
  /// **'Derived from your verified visits. Distance travelled isn\'t available yet.'**
  String get exStatsNote;

  /// No description provided for @ntTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Center'**
  String get ntTitle;

  /// No description provided for @ntActivityFeed.
  ///
  /// In en, this message translates to:
  /// **'Activity Feed'**
  String get ntActivityFeed;

  /// No description provided for @ntHistory.
  ///
  /// In en, this message translates to:
  /// **'Notification History'**
  String get ntHistory;

  /// No description provided for @ntDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get ntDetailTitle;

  /// No description provided for @ntSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get ntSettingsTitle;

  /// No description provided for @ntSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage what you want to be notified about'**
  String get ntSettingsSubtitle;

  /// No description provided for @ntFestivals.
  ///
  /// In en, this message translates to:
  /// **'Festival Updates'**
  String get ntFestivals;

  /// No description provided for @ntDailyQuote.
  ///
  /// In en, this message translates to:
  /// **'Daily Quote'**
  String get ntDailyQuote;

  /// No description provided for @ntShareActivity.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get ntShareActivity;

  /// No description provided for @ntAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get ntAll;

  /// No description provided for @ntUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get ntUnread;

  /// No description provided for @ntRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get ntRead;

  /// No description provided for @ntSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get ntSystem;

  /// No description provided for @ntVisits.
  ///
  /// In en, this message translates to:
  /// **'Visits'**
  String get ntVisits;

  /// No description provided for @ntAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get ntAchievements;

  /// No description provided for @ntCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get ntCards;

  /// No description provided for @ntRoutes.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get ntRoutes;

  /// No description provided for @ntTrust.
  ///
  /// In en, this message translates to:
  /// **'Trust'**
  String get ntTrust;

  /// No description provided for @ntPassport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get ntPassport;

  /// No description provided for @ntUpdates.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get ntUpdates;

  /// No description provided for @ntToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get ntToday;

  /// No description provided for @ntYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get ntYesterday;

  /// No description provided for @ntThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Earlier This Week'**
  String get ntThisWeek;

  /// No description provided for @ntEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get ntEarlier;

  /// No description provided for @ntMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get ntMarkAllRead;

  /// No description provided for @ntUnreadCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unread notification} other{{count} unread notifications}}'**
  String ntUnreadCount(int count);

  /// No description provided for @ntUnreadHint.
  ///
  /// In en, this message translates to:
  /// **'Tap any to open it'**
  String get ntUnreadHint;

  /// No description provided for @ntAllCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get ntAllCaughtUp;

  /// No description provided for @ntMarkAllFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t mark all as read. Please try again.'**
  String get ntMarkAllFailed;

  /// No description provided for @ntEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up!'**
  String get ntEmptyTitle;

  /// No description provided for @ntEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No new notifications at the moment. We\'ll notify you when something exciting happens.'**
  String get ntEmptyBody;

  /// No description provided for @ntExploreTemples.
  ///
  /// In en, this message translates to:
  /// **'Explore Temples'**
  String get ntExploreTemples;

  /// No description provided for @ntErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get ntErrorTitle;

  /// No description provided for @ntErrorBody.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load this right now. Please try again.'**
  String get ntErrorBody;

  /// No description provided for @ntFilterActivity.
  ///
  /// In en, this message translates to:
  /// **'Filter Activity'**
  String get ntFilterActivity;

  /// No description provided for @ntActivityType.
  ///
  /// In en, this message translates to:
  /// **'Activity Type'**
  String get ntActivityType;

  /// No description provided for @ntDateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get ntDateRange;

  /// No description provided for @ntAllTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get ntAllTime;

  /// No description provided for @ntThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get ntThisMonth;

  /// No description provided for @ntCustomRange.
  ///
  /// In en, this message translates to:
  /// **'Custom Range'**
  String get ntCustomRange;

  /// No description provided for @ntReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get ntReset;

  /// No description provided for @ntApplyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get ntApplyFilters;

  /// No description provided for @ntNoActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get ntNoActivityTitle;

  /// No description provided for @ntNoActivityBody.
  ///
  /// In en, this message translates to:
  /// **'Your spiritual journey will appear here as you explore.'**
  String get ntNoActivityBody;

  /// No description provided for @ntUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get ntUpcoming;

  /// No description provided for @ntUpcomingFestivals.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Festivals'**
  String get ntUpcomingFestivals;

  /// No description provided for @ntNoFestivals.
  ///
  /// In en, this message translates to:
  /// **'No festivals right now'**
  String get ntNoFestivals;

  /// No description provided for @ntNoFestivalsBody.
  ///
  /// In en, this message translates to:
  /// **'Upcoming festivals will appear here.'**
  String get ntNoFestivalsBody;

  /// No description provided for @ntDaysToGo.
  ///
  /// In en, this message translates to:
  /// **'Days to go'**
  String get ntDaysToGo;

  /// No description provided for @ntDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get ntDays;

  /// No description provided for @ntPreviousQuotes.
  ///
  /// In en, this message translates to:
  /// **'Previous Quotes'**
  String get ntPreviousQuotes;

  /// No description provided for @ntNoQuote.
  ///
  /// In en, this message translates to:
  /// **'No quote today'**
  String get ntNoQuote;

  /// No description provided for @ntNoQuoteBody.
  ///
  /// In en, this message translates to:
  /// **'Check back later for your daily inspiration.'**
  String get ntNoQuoteBody;

  /// No description provided for @ntShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get ntShare;

  /// No description provided for @ntReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get ntReceived;

  /// No description provided for @ntReadOn.
  ///
  /// In en, this message translates to:
  /// **'Read on'**
  String get ntReadOn;

  /// No description provided for @ntOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get ntOpen;

  /// No description provided for @ntOpenTemple.
  ///
  /// In en, this message translates to:
  /// **'View Temple'**
  String get ntOpenTemple;

  /// No description provided for @ntOpenCard.
  ///
  /// In en, this message translates to:
  /// **'View Card'**
  String get ntOpenCard;

  /// No description provided for @ntOpenRoute.
  ///
  /// In en, this message translates to:
  /// **'View Route'**
  String get ntOpenRoute;

  /// No description provided for @ntOpenAchievement.
  ///
  /// In en, this message translates to:
  /// **'View Achievement'**
  String get ntOpenAchievement;

  /// No description provided for @ntOpenPassport.
  ///
  /// In en, this message translates to:
  /// **'View Passport'**
  String get ntOpenPassport;

  /// No description provided for @ntOpenReferrals.
  ///
  /// In en, this message translates to:
  /// **'View Referrals'**
  String get ntOpenReferrals;

  /// No description provided for @ntSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search notifications'**
  String get ntSearchHint;

  /// No description provided for @ntNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get ntNoResultsTitle;

  /// No description provided for @ntNoResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or filter.'**
  String get ntNoResultsBody;

  /// No description provided for @ntChannels.
  ///
  /// In en, this message translates to:
  /// **'Delivery Channels'**
  String get ntChannels;

  /// No description provided for @ntCategoriesHeader.
  ///
  /// In en, this message translates to:
  /// **'What you\'re notified about'**
  String get ntCategoriesHeader;

  /// No description provided for @ntPush.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get ntPush;

  /// No description provided for @ntPushHint.
  ///
  /// In en, this message translates to:
  /// **'Alerts on this device'**
  String get ntPushHint;

  /// No description provided for @ntEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get ntEmail;

  /// No description provided for @ntTempleAlerts.
  ///
  /// In en, this message translates to:
  /// **'Temple Alerts'**
  String get ntTempleAlerts;

  /// No description provided for @ntTempleAlertsHint.
  ///
  /// In en, this message translates to:
  /// **'New temples & updates'**
  String get ntTempleAlertsHint;

  /// No description provided for @ntNearbyAlerts.
  ///
  /// In en, this message translates to:
  /// **'Nearby Temples'**
  String get ntNearbyAlerts;

  /// No description provided for @ntNearbyAlertsHint.
  ///
  /// In en, this message translates to:
  /// **'When you\'re near a temple'**
  String get ntNearbyAlertsHint;

  /// No description provided for @ntRouteUpdates.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get ntRouteUpdates;

  /// No description provided for @ntAchievementUpdates.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get ntAchievementUpdates;

  /// No description provided for @ntCardUpdates.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get ntCardUpdates;

  /// No description provided for @ntFestivalReminders.
  ///
  /// In en, this message translates to:
  /// **'Festival Reminders'**
  String get ntFestivalReminders;

  /// No description provided for @ntMarketing.
  ///
  /// In en, this message translates to:
  /// **'Marketing & Updates'**
  String get ntMarketing;

  /// No description provided for @ntMarketingHint.
  ///
  /// In en, this message translates to:
  /// **'News, offers, announcements'**
  String get ntMarketingHint;

  /// No description provided for @ntHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay in the loop'**
  String get ntHeroTitle;

  /// No description provided for @ntEnabledCount.
  ///
  /// In en, this message translates to:
  /// **'{on} of {total} on'**
  String ntEnabledCount(int on, int total);

  /// No description provided for @ntEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Updates in your inbox'**
  String get ntEmailHint;

  /// No description provided for @ntRouteUpdatesHint.
  ///
  /// In en, this message translates to:
  /// **'Yatra progress and completions'**
  String get ntRouteUpdatesHint;

  /// No description provided for @ntAchievementUpdatesHint.
  ///
  /// In en, this message translates to:
  /// **'New achievements unlocked'**
  String get ntAchievementUpdatesHint;

  /// No description provided for @ntCardUpdatesHint.
  ///
  /// In en, this message translates to:
  /// **'New cards and series updates'**
  String get ntCardUpdatesHint;

  /// No description provided for @ntFestivalRemindersHint.
  ///
  /// In en, this message translates to:
  /// **'Festival alerts and countdowns'**
  String get ntFestivalRemindersHint;

  /// No description provided for @ntShareAsImage.
  ///
  /// In en, this message translates to:
  /// **'Share as Image'**
  String get ntShareAsImage;

  /// No description provided for @ntShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the share image.'**
  String get ntShareFailed;

  /// No description provided for @ntSpiritualJourney.
  ///
  /// In en, this message translates to:
  /// **'My Spiritual Journey'**
  String get ntSpiritualJourney;

  /// No description provided for @pfTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get pfTitle;

  /// No description provided for @pfPilgrim.
  ///
  /// In en, this message translates to:
  /// **'Pilgrim'**
  String get pfPilgrim;

  /// No description provided for @pfErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get pfErrorTitle;

  /// No description provided for @pfErrorBody.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load this right now. Please try again.'**
  String get pfErrorBody;

  /// No description provided for @pfLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get pfLevel;

  /// No description provided for @pfSpiritualProgress.
  ///
  /// In en, this message translates to:
  /// **'Spiritual Progress'**
  String get pfSpiritualProgress;

  /// No description provided for @pfGroupAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get pfGroupAccount;

  /// No description provided for @pfGroupApp.
  ///
  /// In en, this message translates to:
  /// **'App & Support'**
  String get pfGroupApp;

  /// No description provided for @pfGroupDisplay.
  ///
  /// In en, this message translates to:
  /// **'Performance & Data'**
  String get pfGroupDisplay;

  /// No description provided for @pfGroupRegion.
  ///
  /// In en, this message translates to:
  /// **'Language & Region'**
  String get pfGroupRegion;

  /// No description provided for @pfGroupAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get pfGroupAppearance;

  /// No description provided for @pfPrefsHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Make MARG yours'**
  String get pfPrefsHeroTitle;

  /// No description provided for @pfPrefsHeroBody.
  ///
  /// In en, this message translates to:
  /// **'Choose your language, units and how the app looks and loads.'**
  String get pfPrefsHeroBody;

  /// No description provided for @pfPrefsFootnote.
  ///
  /// In en, this message translates to:
  /// **'Language is saved to your account. Other preferences stay on this device.'**
  String get pfPrefsFootnote;

  /// No description provided for @pfSpiritualHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Your spiritual path'**
  String get pfSpiritualHeroTitle;

  /// No description provided for @pfSpiritualHeroBody.
  ///
  /// In en, this message translates to:
  /// **'Tell us what moves you — MARG tailors temples, yatras and reminders to it.'**
  String get pfSpiritualHeroBody;

  /// No description provided for @pfYatraTypes.
  ///
  /// In en, this message translates to:
  /// **'Preferred Yatras'**
  String get pfYatraTypes;

  /// No description provided for @pfFestivalInterests.
  ///
  /// In en, this message translates to:
  /// **'Festival interests'**
  String get pfFestivalInterests;

  /// No description provided for @pfFestivalInterestsHint.
  ///
  /// In en, this message translates to:
  /// **'Get reminders for these festivals.'**
  String get pfFestivalInterestsHint;

  /// No description provided for @pfNearbyRadius.
  ///
  /// In en, this message translates to:
  /// **'Nearby radius'**
  String get pfNearbyRadius;

  /// No description provided for @pfNearbyRadiusHint.
  ///
  /// In en, this message translates to:
  /// **'Alerts and suggestions for temples within this range.'**
  String get pfNearbyRadiusHint;

  /// No description provided for @pfRadiusKm.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String pfRadiusKm(int km);

  /// No description provided for @pfSavePreferences.
  ///
  /// In en, this message translates to:
  /// **'Save Preferences'**
  String get pfSavePreferences;

  /// No description provided for @pfSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get pfSaveChanges;

  /// No description provided for @pfStatsHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Your journey in numbers'**
  String get pfStatsHeroTitle;

  /// No description provided for @pfStatsHeroBody.
  ///
  /// In en, this message translates to:
  /// **'Every visit, card and milestone on your path.'**
  String get pfStatsHeroBody;

  /// No description provided for @pfDevicesHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Your devices'**
  String get pfDevicesHeroTitle;

  /// No description provided for @pfDevicesHeroBody.
  ///
  /// In en, this message translates to:
  /// **'Phones signed in to your MARG account.'**
  String get pfDevicesHeroBody;

  /// No description provided for @pfLogoutOthersTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out other devices?'**
  String get pfLogoutOthersTitle;

  /// No description provided for @pfLogoutOthersBody.
  ///
  /// In en, this message translates to:
  /// **'They\'ll need to sign in again to use MARG.'**
  String get pfLogoutOthersBody;

  /// No description provided for @pfLogoutOthersHint.
  ///
  /// In en, this message translates to:
  /// **'This signs you out on every device except this one.'**
  String get pfLogoutOthersHint;

  /// No description provided for @pfPersonalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal details'**
  String get pfPersonalDetails;

  /// No description provided for @pfChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get pfChangePhoto;

  /// No description provided for @pfGroupLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get pfGroupLegal;

  /// No description provided for @pfGroupSupport.
  ///
  /// In en, this message translates to:
  /// **'Support & About'**
  String get pfGroupSupport;

  /// No description provided for @pfTrustScore.
  ///
  /// In en, this message translates to:
  /// **'Trust Score'**
  String get pfTrustScore;

  /// No description provided for @pfPassportId.
  ///
  /// In en, this message translates to:
  /// **'Passport ID'**
  String get pfPassportId;

  /// No description provided for @pfJourneySnapshot.
  ///
  /// In en, this message translates to:
  /// **'My Journey Snapshot'**
  String get pfJourneySnapshot;

  /// No description provided for @pfVisits.
  ///
  /// In en, this message translates to:
  /// **'Visits'**
  String get pfVisits;

  /// No description provided for @pfCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get pfCards;

  /// No description provided for @pfRoutes.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get pfRoutes;

  /// No description provided for @pfTemples.
  ///
  /// In en, this message translates to:
  /// **'Temples'**
  String get pfTemples;

  /// No description provided for @pfReferralPoints.
  ///
  /// In en, this message translates to:
  /// **'Referral Points'**
  String get pfReferralPoints;

  /// No description provided for @pfEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get pfEditProfile;

  /// No description provided for @pfPassport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get pfPassport;

  /// No description provided for @pfPreferences.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get pfPreferences;

  /// No description provided for @pfShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get pfShare;

  /// No description provided for @pfShareText.
  ///
  /// In en, this message translates to:
  /// **'on a spiritual journey with MARG'**
  String get pfShareText;

  /// No description provided for @pfSpiritualPreferences.
  ///
  /// In en, this message translates to:
  /// **'Spiritual Preferences'**
  String get pfSpiritualPreferences;

  /// No description provided for @pfPrivacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get pfPrivacySecurity;

  /// No description provided for @pfMyDevices.
  ///
  /// In en, this message translates to:
  /// **'My Devices'**
  String get pfMyDevices;

  /// No description provided for @pfMyStatistics.
  ///
  /// In en, this message translates to:
  /// **'My Statistics'**
  String get pfMyStatistics;

  /// No description provided for @pfAppPreferences.
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get pfAppPreferences;

  /// No description provided for @pfHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get pfHelpSupport;

  /// No description provided for @pfSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get pfSave;

  /// No description provided for @pfSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get pfSaved;

  /// No description provided for @pfSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your changes.'**
  String get pfSaveFailed;

  /// No description provided for @pfCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get pfCancel;

  /// No description provided for @pfFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get pfFullName;

  /// No description provided for @pfNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get pfNameRequired;

  /// No description provided for @pfMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get pfMobile;

  /// No description provided for @pfMobileLocked.
  ///
  /// In en, this message translates to:
  /// **'Set at registration and can\'t be changed here'**
  String get pfMobileLocked;

  /// No description provided for @pfDob.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get pfDob;

  /// No description provided for @pfGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get pfGender;

  /// No description provided for @pfGenderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get pfGenderMale;

  /// No description provided for @pfGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get pfGenderFemale;

  /// No description provided for @pfGenderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get pfGenderOther;

  /// No description provided for @pfGenderPreferNot.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get pfGenderPreferNot;

  /// No description provided for @pfCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get pfCity;

  /// No description provided for @pfLanguage.
  ///
  /// In en, this message translates to:
  /// **'Preferred Language'**
  String get pfLanguage;

  /// No description provided for @pfLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get pfLanguageEnglish;

  /// No description provided for @pfLanguageHindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get pfLanguageHindi;

  /// No description provided for @pfEmailLocked.
  ///
  /// In en, this message translates to:
  /// **'Email is managed by Google and can\'t be changed'**
  String get pfEmailLocked;

  /// No description provided for @pfPhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated'**
  String get pfPhotoUpdated;

  /// No description provided for @pfPhotoFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update your photo.'**
  String get pfPhotoFailed;

  /// No description provided for @pfInterests.
  ///
  /// In en, this message translates to:
  /// **'Temple Interests'**
  String get pfInterests;

  /// No description provided for @pfInterestsHint.
  ///
  /// In en, this message translates to:
  /// **'Choose what matters most to your journey'**
  String get pfInterestsHint;

  /// No description provided for @pfInterestTempleVisits.
  ///
  /// In en, this message translates to:
  /// **'Temple Visits'**
  String get pfInterestTempleVisits;

  /// No description provided for @pfInterestRoutes.
  ///
  /// In en, this message translates to:
  /// **'Sacred Routes'**
  String get pfInterestRoutes;

  /// No description provided for @pfInterestPuja.
  ///
  /// In en, this message translates to:
  /// **'Puja & Pandits'**
  String get pfInterestPuja;

  /// No description provided for @pfInterestCards.
  ///
  /// In en, this message translates to:
  /// **'Collect Cards'**
  String get pfInterestCards;

  /// No description provided for @pfInterestAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get pfInterestAchievements;

  /// No description provided for @pfInterestFestivals.
  ///
  /// In en, this message translates to:
  /// **'Events & Festivals'**
  String get pfInterestFestivals;

  /// No description provided for @pfInterestNearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby Temples'**
  String get pfInterestNearby;

  /// No description provided for @pfInterestOthers.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get pfInterestOthers;

  /// No description provided for @pfGoogleAccount.
  ///
  /// In en, this message translates to:
  /// **'Google Account'**
  String get pfGoogleAccount;

  /// No description provided for @pfManageDevices.
  ///
  /// In en, this message translates to:
  /// **'Manage your devices'**
  String get pfManageDevices;

  /// No description provided for @pfNotificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get pfNotificationSettings;

  /// No description provided for @pfNotificationSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'Manage what you receive'**
  String get pfNotificationSettingsHint;

  /// No description provided for @pfLocationPermission.
  ///
  /// In en, this message translates to:
  /// **'Location Permission'**
  String get pfLocationPermission;

  /// No description provided for @pfLocationPermissionHint.
  ///
  /// In en, this message translates to:
  /// **'Open system settings'**
  String get pfLocationPermissionHint;

  /// No description provided for @pfPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get pfPrivacyPolicy;

  /// No description provided for @pfTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get pfTerms;

  /// No description provided for @pfDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get pfDeleteAccount;

  /// No description provided for @pfDeleteAccountHint.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account'**
  String get pfDeleteAccountHint;

  /// No description provided for @pfLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get pfLogout;

  /// No description provided for @pfLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get pfLogoutConfirm;

  /// No description provided for @pfNoDevices.
  ///
  /// In en, this message translates to:
  /// **'No devices yet'**
  String get pfNoDevices;

  /// No description provided for @pfNoDevicesBody.
  ///
  /// In en, this message translates to:
  /// **'Devices you sign in on will appear here.'**
  String get pfNoDevicesBody;

  /// No description provided for @pfCurrentDevice.
  ///
  /// In en, this message translates to:
  /// **'Current Device'**
  String get pfCurrentDevice;

  /// No description provided for @pfOtherDevices.
  ///
  /// In en, this message translates to:
  /// **'Other Devices'**
  String get pfOtherDevices;

  /// No description provided for @pfThisDevice.
  ///
  /// In en, this message translates to:
  /// **'This Device'**
  String get pfThisDevice;

  /// No description provided for @pfLastActive.
  ///
  /// In en, this message translates to:
  /// **'Last active'**
  String get pfLastActive;

  /// No description provided for @pfLogoutOthers.
  ///
  /// In en, this message translates to:
  /// **'Logout from All Other Devices'**
  String get pfLogoutOthers;

  /// No description provided for @pfTotalVisits.
  ///
  /// In en, this message translates to:
  /// **'Total Visits'**
  String get pfTotalVisits;

  /// No description provided for @pfCardsCollected.
  ///
  /// In en, this message translates to:
  /// **'Cards Collected'**
  String get pfCardsCollected;

  /// No description provided for @pfAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get pfAchievements;

  /// No description provided for @pfVisitsOverTime.
  ///
  /// In en, this message translates to:
  /// **'Visits Over Time'**
  String get pfVisitsOverTime;

  /// No description provided for @pfNoVisitsYet.
  ///
  /// In en, this message translates to:
  /// **'No visits yet'**
  String get pfNoVisitsYet;

  /// No description provided for @pfDetailedMap.
  ///
  /// In en, this message translates to:
  /// **'Detailed map outline'**
  String get pfDetailedMap;

  /// No description provided for @pfDetailedMapHint.
  ///
  /// In en, this message translates to:
  /// **'Sharper borders and coastline on every map (about 3 MB)'**
  String get pfDetailedMapHint;

  /// No description provided for @pfDetailedMapDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get pfDetailedMapDownload;

  /// No description provided for @pfDetailedMapProgress.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String pfDetailedMapProgress(int percent);

  /// No description provided for @pfDetailedMapReady.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get pfDetailedMapReady;

  /// No description provided for @pfDetailedMapSaved.
  ///
  /// In en, this message translates to:
  /// **'Detailed map ready'**
  String get pfDetailedMapSaved;

  /// No description provided for @pfDetailedMapFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t download the map. Check your connection and try again.'**
  String get pfDetailedMapFailed;

  /// No description provided for @pfDetailedMapRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove detailed map?'**
  String get pfDetailedMapRemoveTitle;

  /// No description provided for @pfDetailedMapRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'Maps will use the built-in outline again. You can download it any time.'**
  String get pfDetailedMapRemoveBody;

  /// No description provided for @pfDetailedMapRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get pfDetailedMapRemove;

  /// No description provided for @pfUnits.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get pfUnits;

  /// No description provided for @pfKilometers.
  ///
  /// In en, this message translates to:
  /// **'Kilometers (km)'**
  String get pfKilometers;

  /// No description provided for @pfMiles.
  ///
  /// In en, this message translates to:
  /// **'Miles (mi)'**
  String get pfMiles;

  /// No description provided for @pfTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get pfTheme;

  /// No description provided for @pfThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get pfThemeLight;

  /// No description provided for @pfReduceAnimations.
  ///
  /// In en, this message translates to:
  /// **'Reduce Animations'**
  String get pfReduceAnimations;

  /// No description provided for @pfReduceAnimationsHint.
  ///
  /// In en, this message translates to:
  /// **'Helps improve performance'**
  String get pfReduceAnimationsHint;

  /// No description provided for @pfDataSaver.
  ///
  /// In en, this message translates to:
  /// **'Data Saver'**
  String get pfDataSaver;

  /// No description provided for @pfDataSaverHint.
  ///
  /// In en, this message translates to:
  /// **'Use less data while browsing'**
  String get pfDataSaverHint;

  /// No description provided for @pfHighQualityImages.
  ///
  /// In en, this message translates to:
  /// **'High Quality Images'**
  String get pfHighQualityImages;

  /// No description provided for @pfHighQualityImagesHint.
  ///
  /// In en, this message translates to:
  /// **'Use high quality for images'**
  String get pfHighQualityImagesHint;

  /// No description provided for @pfFaqs.
  ///
  /// In en, this message translates to:
  /// **'FAQs'**
  String get pfFaqs;

  /// No description provided for @pfNoFaqs.
  ///
  /// In en, this message translates to:
  /// **'No FAQs available yet.'**
  String get pfNoFaqs;

  /// No description provided for @pfContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get pfContactSupport;

  /// No description provided for @pfContactSupportHint.
  ///
  /// In en, this message translates to:
  /// **'We are here to help'**
  String get pfContactSupportHint;

  /// No description provided for @pfAbout.
  ///
  /// In en, this message translates to:
  /// **'About MARG'**
  String get pfAbout;

  /// No description provided for @pfVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get pfVersion;

  /// No description provided for @pfRateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate MARG'**
  String get pfRateApp;

  /// No description provided for @pfRateAppHint.
  ///
  /// In en, this message translates to:
  /// **'Share your feedback'**
  String get pfRateAppHint;

  /// No description provided for @pfPageEmpty.
  ///
  /// In en, this message translates to:
  /// **'This page has no content yet.'**
  String get pfPageEmpty;

  /// No description provided for @pfDeleteHeading.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get pfDeleteHeading;

  /// No description provided for @pfDeleteExplain.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent and cannot be undone. Your visits, cards, achievements, routes, passport and settings will be removed.'**
  String get pfDeleteExplain;

  /// No description provided for @pfLossProgress.
  ///
  /// In en, this message translates to:
  /// **'All your progress will be lost'**
  String get pfLossProgress;

  /// No description provided for @pfLossData.
  ///
  /// In en, this message translates to:
  /// **'Your data cannot be recovered'**
  String get pfLossData;

  /// No description provided for @pfLossSignedOut.
  ///
  /// In en, this message translates to:
  /// **'You will be signed out from all devices'**
  String get pfLossSignedOut;

  /// No description provided for @pfDeleteMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get pfDeleteMyAccount;

  /// No description provided for @pfDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get pfDeleteConfirmTitle;

  /// No description provided for @pfDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account and signs you out everywhere. This cannot be undone.'**
  String get pfDeleteConfirmBody;

  /// No description provided for @pfDeleteConfirmCta.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get pfDeleteConfirmCta;

  /// No description provided for @pfDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete your account. Please try again.'**
  String get pfDeleteFailed;

  /// No description provided for @rfTitle.
  ///
  /// In en, this message translates to:
  /// **'Referral Dashboard'**
  String get rfTitle;

  /// No description provided for @rfInviteFriends.
  ///
  /// In en, this message translates to:
  /// **'Invite Friends'**
  String get rfInviteFriends;

  /// No description provided for @rfTimeline.
  ///
  /// In en, this message translates to:
  /// **'Referral Timeline'**
  String get rfTimeline;

  /// No description provided for @rfRewards.
  ///
  /// In en, this message translates to:
  /// **'Referral Rewards'**
  String get rfRewards;

  /// No description provided for @rfCommunityRanking.
  ///
  /// In en, this message translates to:
  /// **'Community Ranking'**
  String get rfCommunityRanking;

  /// No description provided for @rfShareJourney.
  ///
  /// In en, this message translates to:
  /// **'Share Your Journey'**
  String get rfShareJourney;

  /// No description provided for @rfAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Referral Analytics'**
  String get rfAnalytics;

  /// No description provided for @rfFaq.
  ///
  /// In en, this message translates to:
  /// **'Referral FAQ'**
  String get rfFaq;

  /// No description provided for @rfErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get rfErrorTitle;

  /// No description provided for @rfErrorBody.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load this right now. Please try again.'**
  String get rfErrorBody;

  /// No description provided for @rfYourCode.
  ///
  /// In en, this message translates to:
  /// **'Your Referral Code'**
  String get rfYourCode;

  /// No description provided for @rfCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get rfCopy;

  /// No description provided for @rfCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get rfCopied;

  /// No description provided for @rfYourProgress.
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get rfYourProgress;

  /// No description provided for @rfViewMilestones.
  ///
  /// In en, this message translates to:
  /// **'View Milestones'**
  String get rfViewMilestones;

  /// No description provided for @rfInvited.
  ///
  /// In en, this message translates to:
  /// **'Invited'**
  String get rfInvited;

  /// No description provided for @rfJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get rfJoined;

  /// No description provided for @rfPoints.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get rfPoints;

  /// No description provided for @rfPointsEarned.
  ///
  /// In en, this message translates to:
  /// **'Points Earned'**
  String get rfPointsEarned;

  /// No description provided for @rfToNextMilestone.
  ///
  /// In en, this message translates to:
  /// **'referrals to milestone'**
  String get rfToNextMilestone;

  /// No description provided for @rfRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get rfRecentActivity;

  /// No description provided for @rfViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get rfViewAll;

  /// No description provided for @rfNoActivity.
  ///
  /// In en, this message translates to:
  /// **'No referral activity yet'**
  String get rfNoActivity;

  /// No description provided for @rfInviteHeading.
  ///
  /// In en, this message translates to:
  /// **'Invite friends, earn rewards'**
  String get rfInviteHeading;

  /// No description provided for @rfInviteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Invite your friends and earn rewards when they join and explore Bharat with MARG.'**
  String get rfInviteSubtitle;

  /// No description provided for @rfShareVia.
  ///
  /// In en, this message translates to:
  /// **'Share via'**
  String get rfShareVia;

  /// No description provided for @rfYourLink.
  ///
  /// In en, this message translates to:
  /// **'Your Referral Link'**
  String get rfYourLink;

  /// No description provided for @rfScanToJoin.
  ///
  /// In en, this message translates to:
  /// **'Scan to join MARG'**
  String get rfScanToJoin;

  /// No description provided for @rfEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get rfEmail;

  /// No description provided for @rfMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get rfMore;

  /// No description provided for @rfShareMessage.
  ///
  /// In en, this message translates to:
  /// **'Join me on MARG and explore the temples of Bharat!'**
  String get rfShareMessage;

  /// No description provided for @rfAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get rfAll;

  /// No description provided for @rfStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get rfStatusPending;

  /// No description provided for @rfStatusJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get rfStatusJoined;

  /// No description provided for @rfStatusRewarded.
  ///
  /// In en, this message translates to:
  /// **'Rewarded'**
  String get rfStatusRewarded;

  /// No description provided for @rfNoInvites.
  ///
  /// In en, this message translates to:
  /// **'No invites yet'**
  String get rfNoInvites;

  /// No description provided for @rfNoInvitesBody.
  ///
  /// In en, this message translates to:
  /// **'Invite friends to see your referral journey here.'**
  String get rfNoInvitesBody;

  /// No description provided for @rfInvitationSent.
  ///
  /// In en, this message translates to:
  /// **'Invitation Sent'**
  String get rfInvitationSent;

  /// No description provided for @rfFriendJoined.
  ///
  /// In en, this message translates to:
  /// **'Friend Joined'**
  String get rfFriendJoined;

  /// No description provided for @rfRewardCredited.
  ///
  /// In en, this message translates to:
  /// **'Reward Credited'**
  String get rfRewardCredited;

  /// No description provided for @rfHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get rfHowItWorks;

  /// No description provided for @rfRewardHistory.
  ///
  /// In en, this message translates to:
  /// **'Reward History'**
  String get rfRewardHistory;

  /// No description provided for @rfNoRewards.
  ///
  /// In en, this message translates to:
  /// **'No rewards yet'**
  String get rfNoRewards;

  /// No description provided for @rfNoRewardsBody.
  ///
  /// In en, this message translates to:
  /// **'Rewards you earn from referrals will appear here.'**
  String get rfNoRewardsBody;

  /// No description provided for @rfReferralsMilestone.
  ///
  /// In en, this message translates to:
  /// **'referrals'**
  String get rfReferralsMilestone;

  /// No description provided for @rfNoRanking.
  ///
  /// In en, this message translates to:
  /// **'No ranking yet'**
  String get rfNoRanking;

  /// No description provided for @rfNoRankingBody.
  ///
  /// In en, this message translates to:
  /// **'The community leaderboard will appear here.'**
  String get rfNoRankingBody;

  /// No description provided for @rfNational.
  ///
  /// In en, this message translates to:
  /// **'National'**
  String get rfNational;

  /// No description provided for @rfYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get rfYou;

  /// No description provided for @rfAFriend.
  ///
  /// In en, this message translates to:
  /// **'A friend'**
  String get rfAFriend;

  /// No description provided for @rfPts.
  ///
  /// In en, this message translates to:
  /// **'pts'**
  String get rfPts;

  /// No description provided for @rfInvitesSent.
  ///
  /// In en, this message translates to:
  /// **'Invites Sent'**
  String get rfInvitesSent;

  /// No description provided for @rfConversion.
  ///
  /// In en, this message translates to:
  /// **'Conversion'**
  String get rfConversion;

  /// No description provided for @rfInvitesOverview.
  ///
  /// In en, this message translates to:
  /// **'Invites Overview'**
  String get rfInvitesOverview;

  /// No description provided for @rfTopSource.
  ///
  /// In en, this message translates to:
  /// **'Top Performing Source'**
  String get rfTopSource;

  /// No description provided for @rfShareCardHint.
  ///
  /// In en, this message translates to:
  /// **'Create a beautiful share card and inspire others.'**
  String get rfShareCardHint;

  /// No description provided for @rfShareNow.
  ///
  /// In en, this message translates to:
  /// **'Share Now'**
  String get rfShareNow;

  /// No description provided for @rfShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the share image.'**
  String get rfShareFailed;

  /// No description provided for @rfShareTagline.
  ///
  /// In en, this message translates to:
  /// **'Invites you to walk the path of devotion'**
  String get rfShareTagline;

  /// No description provided for @rfSearchFaq.
  ///
  /// In en, this message translates to:
  /// **'Search FAQs'**
  String get rfSearchFaq;

  /// No description provided for @rfNoFaqs.
  ///
  /// In en, this message translates to:
  /// **'No FAQs found'**
  String get rfNoFaqs;

  /// No description provided for @rfNoFaqsBody.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or category.'**
  String get rfNoFaqsBody;

  /// No description provided for @kbKnowledgeHub.
  ///
  /// In en, this message translates to:
  /// **'Knowledge Hub'**
  String get kbKnowledgeHub;

  /// No description provided for @kbBlogs.
  ///
  /// In en, this message translates to:
  /// **'Blogs'**
  String get kbBlogs;

  /// No description provided for @kbQuotes.
  ///
  /// In en, this message translates to:
  /// **'Quotes'**
  String get kbQuotes;

  /// No description provided for @kbFestivals.
  ///
  /// In en, this message translates to:
  /// **'Festivals'**
  String get kbFestivals;

  /// No description provided for @kbAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get kbAnnouncements;

  /// No description provided for @kbFaqs.
  ///
  /// In en, this message translates to:
  /// **'FAQs'**
  String get kbFaqs;

  /// No description provided for @kbDailyQuotes.
  ///
  /// In en, this message translates to:
  /// **'Daily Quotes'**
  String get kbDailyQuotes;

  /// No description provided for @kbBlogDetail.
  ///
  /// In en, this message translates to:
  /// **'Article'**
  String get kbBlogDetail;

  /// No description provided for @kbFestival.
  ///
  /// In en, this message translates to:
  /// **'Festival'**
  String get kbFestival;

  /// No description provided for @kbAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get kbAbout;

  /// No description provided for @kbAboutMarg.
  ///
  /// In en, this message translates to:
  /// **'About MARG'**
  String get kbAboutMarg;

  /// No description provided for @kbQuickAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get kbQuickAccess;

  /// No description provided for @kbLatestArticles.
  ///
  /// In en, this message translates to:
  /// **'Latest Articles'**
  String get kbLatestArticles;

  /// No description provided for @kbViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get kbViewAll;

  /// No description provided for @kbUpcomingFestivals.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Festivals'**
  String get kbUpcomingFestivals;

  /// No description provided for @kbCollections.
  ///
  /// In en, this message translates to:
  /// **'Spiritual Collections'**
  String get kbCollections;

  /// No description provided for @kbVerseOfTheDay.
  ///
  /// In en, this message translates to:
  /// **'Verse of the Day'**
  String get kbVerseOfTheDay;

  /// No description provided for @kbTodaysQuote.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Quote'**
  String get kbTodaysQuote;

  /// No description provided for @kbRelatedArticles.
  ///
  /// In en, this message translates to:
  /// **'Related Articles'**
  String get kbRelatedArticles;

  /// No description provided for @kbSearchArticles.
  ///
  /// In en, this message translates to:
  /// **'Search articles, topics…'**
  String get kbSearchArticles;

  /// No description provided for @kbSearchFaqs.
  ///
  /// In en, this message translates to:
  /// **'Search questions…'**
  String get kbSearchFaqs;

  /// No description provided for @kbAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get kbAll;

  /// No description provided for @kbMinRead.
  ///
  /// In en, this message translates to:
  /// **'min read'**
  String get kbMinRead;

  /// No description provided for @kbJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get kbJustNow;

  /// No description provided for @kbHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'hours ago'**
  String get kbHoursAgo;

  /// No description provided for @kbDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'days ago'**
  String get kbDaysAgo;

  /// No description provided for @kbHappeningNow.
  ///
  /// In en, this message translates to:
  /// **'Happening now'**
  String get kbHappeningNow;

  /// No description provided for @kbTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get kbTomorrow;

  /// No description provided for @kbDaysToGo.
  ///
  /// In en, this message translates to:
  /// **'days to go'**
  String get kbDaysToGo;

  /// No description provided for @kbNews.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get kbNews;

  /// No description provided for @kbMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get kbMaintenance;

  /// No description provided for @kbEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get kbEmergency;

  /// No description provided for @kbShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get kbShare;

  /// No description provided for @kbShareContent.
  ///
  /// In en, this message translates to:
  /// **'Share Content'**
  String get kbShareContent;

  /// No description provided for @kbShareNow.
  ///
  /// In en, this message translates to:
  /// **'Share Now'**
  String get kbShareNow;

  /// No description provided for @kbShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the share image.'**
  String get kbShareFailed;

  /// No description provided for @kbShareTagline.
  ///
  /// In en, this message translates to:
  /// **'Explore the divine wisdom of our heritage.'**
  String get kbShareTagline;

  /// No description provided for @kbCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get kbCopy;

  /// No description provided for @kbCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get kbCopied;

  /// No description provided for @kbSignificance.
  ///
  /// In en, this message translates to:
  /// **'Significance'**
  String get kbSignificance;

  /// No description provided for @kbStillNeedHelp.
  ///
  /// In en, this message translates to:
  /// **'Still need help?'**
  String get kbStillNeedHelp;

  /// No description provided for @kbContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get kbContactSupport;

  /// No description provided for @kbContactSupportBody.
  ///
  /// In en, this message translates to:
  /// **'Our team is here to help you on your journey.'**
  String get kbContactSupportBody;

  /// No description provided for @kbContactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get kbContactUs;

  /// No description provided for @kbPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get kbPrivacyPolicy;

  /// No description provided for @kbTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get kbTerms;

  /// No description provided for @kbSpiritualCompanion.
  ///
  /// In en, this message translates to:
  /// **'Your Spiritual Companion'**
  String get kbSpiritualCompanion;

  /// No description provided for @kbAboutFallback.
  ///
  /// In en, this message translates to:
  /// **'MARG helps devotees connect with the divine, explore sacred places, and grow spiritually.'**
  String get kbAboutFallback;

  /// No description provided for @kbErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get kbErrorTitle;

  /// No description provided for @kbErrorBody.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load this right now. Please try again.'**
  String get kbErrorBody;

  /// No description provided for @kbNoArticles.
  ///
  /// In en, this message translates to:
  /// **'No articles yet'**
  String get kbNoArticles;

  /// No description provided for @kbNoArticlesBody.
  ///
  /// In en, this message translates to:
  /// **'New spiritual articles will appear here soon.'**
  String get kbNoArticlesBody;

  /// No description provided for @kbNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get kbNoResults;

  /// No description provided for @kbNoResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or category.'**
  String get kbNoResultsBody;

  /// No description provided for @kbNoQuote.
  ///
  /// In en, this message translates to:
  /// **'No quote today'**
  String get kbNoQuote;

  /// No description provided for @kbNoQuoteBody.
  ///
  /// In en, this message translates to:
  /// **'Check back soon for daily inspiration.'**
  String get kbNoQuoteBody;

  /// No description provided for @kbNoFestivals.
  ///
  /// In en, this message translates to:
  /// **'No upcoming festivals'**
  String get kbNoFestivals;

  /// No description provided for @kbNoFestivalsBody.
  ///
  /// In en, this message translates to:
  /// **'Upcoming festivals will appear here.'**
  String get kbNoFestivalsBody;

  /// No description provided for @kbNoAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'No announcements'**
  String get kbNoAnnouncements;

  /// No description provided for @kbNoAnnouncementsBody.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up.'**
  String get kbNoAnnouncementsBody;

  /// No description provided for @kbNoFaqs.
  ///
  /// In en, this message translates to:
  /// **'No FAQs found'**
  String get kbNoFaqs;

  /// No description provided for @kbNoFaqsBody.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or category.'**
  String get kbNoFaqsBody;

  /// No description provided for @kbNoContentBody.
  ///
  /// In en, this message translates to:
  /// **'This page has no content yet.'**
  String get kbNoContentBody;

  /// No description provided for @offlineBannerMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline — showing saved content'**
  String get offlineBannerMessage;

  /// No description provided for @suStep.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get suStep;

  /// No description provided for @suOf.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get suOf;

  /// No description provided for @suBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get suBack;

  /// No description provided for @suSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get suSkip;

  /// No description provided for @suContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get suContinue;

  /// No description provided for @suFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get suFinish;

  /// No description provided for @suStepLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get suStepLocation;

  /// No description provided for @suStepProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get suStepProfile;

  /// No description provided for @suStepInterests.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get suStepInterests;

  /// No description provided for @suStepPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get suStepPreferences;

  /// No description provided for @suStepComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get suStepComplete;

  /// No description provided for @suSetupFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not finish setting up your account. Please try again.'**
  String get suSetupFailed;

  /// No description provided for @suPhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get suPhotoTitle;

  /// No description provided for @suTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get suTakePhoto;

  /// No description provided for @suChooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get suChooseGallery;

  /// No description provided for @suRemovePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get suRemovePhoto;

  /// No description provided for @suPhotoError.
  ///
  /// In en, this message translates to:
  /// **'Could not open your photos. Please try again.'**
  String get suPhotoError;

  /// No description provided for @suInvalidMobile.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit mobile number'**
  String get suInvalidMobile;

  /// No description provided for @suLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable location'**
  String get suLocationTitle;

  /// No description provided for @suLocationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'So we can show temples, events and routes near you'**
  String get suLocationSubtitle;

  /// No description provided for @suBenefitTemples.
  ///
  /// In en, this message translates to:
  /// **'Discover temples near you'**
  String get suBenefitTemples;

  /// No description provided for @suBenefitEvents.
  ///
  /// In en, this message translates to:
  /// **'Get notified about nearby events'**
  String get suBenefitEvents;

  /// No description provided for @suBenefitRoutes.
  ///
  /// In en, this message translates to:
  /// **'Personalized pilgrimage routes'**
  String get suBenefitRoutes;

  /// No description provided for @suLocationPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Only used to personalize your experience'**
  String get suLocationPrivacy;

  /// No description provided for @suGettingLocation.
  ///
  /// In en, this message translates to:
  /// **'Getting your location…'**
  String get suGettingLocation;

  /// No description provided for @suLocationEnabled.
  ///
  /// In en, this message translates to:
  /// **'Location enabled'**
  String get suLocationEnabled;

  /// No description provided for @suUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get suUpdate;

  /// No description provided for @suLocationDenied.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t access your location. You can enable it now or skip and set it later.'**
  String get suLocationDenied;

  /// No description provided for @suTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get suTryAgain;

  /// No description provided for @suLocationBlocked.
  ///
  /// In en, this message translates to:
  /// **'Location is turned off for MARG. Open settings to allow it, then try again.'**
  String get suLocationBlocked;

  /// No description provided for @suOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get suOpenSettings;

  /// No description provided for @suProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s set up your profile'**
  String get suProfileTitle;

  /// No description provided for @suProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ve fetched your details from Google'**
  String get suProfileSubtitle;

  /// No description provided for @suFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get suFullName;

  /// No description provided for @suEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get suEmail;

  /// No description provided for @suMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get suMobileNumber;

  /// No description provided for @suDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get suDateOfBirth;

  /// No description provided for @suSelectDob.
  ///
  /// In en, this message translates to:
  /// **'Select your date of birth'**
  String get suSelectDob;

  /// No description provided for @suGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get suGender;

  /// No description provided for @suSelectGender.
  ///
  /// In en, this message translates to:
  /// **'Select gender'**
  String get suSelectGender;

  /// No description provided for @suCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get suCity;

  /// No description provided for @suCityDetected.
  ///
  /// In en, this message translates to:
  /// **'Detected from your location'**
  String get suCityDetected;

  /// No description provided for @suChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get suChangePhoto;

  /// No description provided for @suGenderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get suGenderMale;

  /// No description provided for @suGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get suGenderFemale;

  /// No description provided for @suGenderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get suGenderOther;

  /// No description provided for @suGenderPreferNot.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get suGenderPreferNot;

  /// No description provided for @suInterestsTitle.
  ///
  /// In en, this message translates to:
  /// **'What interests you?'**
  String get suInterestsTitle;

  /// No description provided for @suInterestsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose what you\'d like to explore in MARG'**
  String get suInterestsSubtitle;

  /// No description provided for @suInterestTempleVisits.
  ///
  /// In en, this message translates to:
  /// **'Temple Visits'**
  String get suInterestTempleVisits;

  /// No description provided for @suInterestRouteCompletion.
  ///
  /// In en, this message translates to:
  /// **'Route Completion'**
  String get suInterestRouteCompletion;

  /// No description provided for @suInterestPujaPandit.
  ///
  /// In en, this message translates to:
  /// **'Puja & Pandit'**
  String get suInterestPujaPandit;

  /// No description provided for @suInterestCollectCards.
  ///
  /// In en, this message translates to:
  /// **'Collect Cards'**
  String get suInterestCollectCards;

  /// No description provided for @suInterestAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get suInterestAchievements;

  /// No description provided for @suInterestEventsFestivals.
  ///
  /// In en, this message translates to:
  /// **'Events & Festivals'**
  String get suInterestEventsFestivals;

  /// No description provided for @suInterestNearbyTemples.
  ///
  /// In en, this message translates to:
  /// **'Nearby Temples'**
  String get suInterestNearbyTemples;

  /// No description provided for @suInterestOthers.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get suInterestOthers;

  /// No description provided for @suPreferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your preferences'**
  String get suPreferencesTitle;

  /// No description provided for @suPreferencesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help us personalize your experience'**
  String get suPreferencesSubtitle;

  /// No description provided for @suLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get suLanguage;

  /// No description provided for @suNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get suNotifications;

  /// No description provided for @suLangEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get suLangEnglish;

  /// No description provided for @suLangHindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get suLangHindi;

  /// No description provided for @suNotifTempleTitle.
  ///
  /// In en, this message translates to:
  /// **'Temple & Route Updates'**
  String get suNotifTempleTitle;

  /// No description provided for @suNotifTempleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get updates about temples, routes and new features'**
  String get suNotifTempleSubtitle;

  /// No description provided for @suNotifAchievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements & Cards'**
  String get suNotifAchievementsTitle;

  /// No description provided for @suNotifAchievementsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get notified when you unlock cards and achievements'**
  String get suNotifAchievementsSubtitle;

  /// No description provided for @suNotifEventsTitle.
  ///
  /// In en, this message translates to:
  /// **'Events & Festivals'**
  String get suNotifEventsTitle;

  /// No description provided for @suNotifEventsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stay updated on important events and festivals'**
  String get suNotifEventsSubtitle;

  /// No description provided for @suNotifMarketingTitle.
  ///
  /// In en, this message translates to:
  /// **'Marketing (Optional)'**
  String get suNotifMarketingTitle;

  /// No description provided for @suNotifMarketingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive occasional updates and offers'**
  String get suNotifMarketingSubtitle;

  /// No description provided for @suAllSet.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set! 🎉'**
  String get suAllSet;

  /// No description provided for @suCompleteBody.
  ///
  /// In en, this message translates to:
  /// **'Your profile is ready and you\'re set to begin your spiritual journey with {brand}.'**
  String suCompleteBody(String brand);

  /// No description provided for @suWhatsNext.
  ///
  /// In en, this message translates to:
  /// **'What\'s next?'**
  String get suWhatsNext;

  /// No description provided for @suWhatsNextSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore, collect and grow on your spiritual path'**
  String get suWhatsNextSubtitle;

  /// No description provided for @suNextExploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore Temples'**
  String get suNextExploreTitle;

  /// No description provided for @suNextExploreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover temples and plan visits'**
  String get suNextExploreSubtitle;

  /// No description provided for @suNextRoutesTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete Routes'**
  String get suNextRoutesTitle;

  /// No description provided for @suNextRoutesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your journey across sacred routes'**
  String get suNextRoutesSubtitle;

  /// No description provided for @suNextCardsTitle.
  ///
  /// In en, this message translates to:
  /// **'Collect Cards'**
  String get suNextCardsTitle;

  /// No description provided for @suNextCardsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock cards when you visit temples'**
  String get suNextCardsSubtitle;

  /// No description provided for @suNextAchievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Earn Achievements'**
  String get suNextAchievementsTitle;

  /// No description provided for @suNextAchievementsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete milestones and earn rewards'**
  String get suNextAchievementsSubtitle;

  /// No description provided for @suStartJourney.
  ///
  /// In en, this message translates to:
  /// **'Start My Journey'**
  String get suStartJourney;

  /// No description provided for @suDataSecure.
  ///
  /// In en, this message translates to:
  /// **'Your data is secure & private'**
  String get suDataSecure;

  /// No description provided for @suNotificationsOn.
  ///
  /// In en, this message translates to:
  /// **'on'**
  String get suNotificationsOn;

  /// No description provided for @routeNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get routeNotFoundTitle;

  /// No description provided for @routeNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'This link could not be opened. It may be outdated or incorrect.'**
  String get routeNotFoundBody;

  /// No description provided for @routeGoHome.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get routeGoHome;

  /// No description provided for @commonViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get commonViewDetails;

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// No description provided for @navPassport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get navPassport;

  /// No description provided for @navExitTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaving so soon?'**
  String get navExitTitle;

  /// No description provided for @navExitMessage.
  ///
  /// In en, this message translates to:
  /// **'Your journey will be right here when you return.'**
  String get navExitMessage;

  /// No description provided for @navExitBackHint.
  ///
  /// In en, this message translates to:
  /// **'Press back again to exit'**
  String get navExitBackHint;

  /// No description provided for @navExitStay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get navExitStay;

  /// No description provided for @navExitConfirm.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get navExitConfirm;

  /// No description provided for @locTitle.
  ///
  /// In en, this message translates to:
  /// **'Find temples near you'**
  String get locTitle;

  /// No description provided for @locBody.
  ///
  /// In en, this message translates to:
  /// **'Allow location access so MARG can show temples around you and remind you when one is close by.'**
  String get locBody;

  /// No description provided for @locServiceOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn on device location'**
  String get locServiceOffTitle;

  /// No description provided for @locServiceOffBody.
  ///
  /// In en, this message translates to:
  /// **'Your phone\'s location is off. Turn it on to see temples near you.'**
  String get locServiceOffBody;

  /// No description provided for @locBlockedBody.
  ///
  /// In en, this message translates to:
  /// **'Location access is blocked for MARG. Open settings, tap Permissions → Location, and choose Allow.'**
  String get locBlockedBody;

  /// No description provided for @locAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow location access'**
  String get locAllow;

  /// No description provided for @locTurnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on location'**
  String get locTurnOn;

  /// No description provided for @locOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get locOpenSettings;

  /// No description provided for @locNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get locNotNow;

  /// No description provided for @locBenefitNearby.
  ///
  /// In en, this message translates to:
  /// **'Temples and sacred places around you'**
  String get locBenefitNearby;

  /// No description provided for @locBenefitReminders.
  ///
  /// In en, this message translates to:
  /// **'Morning, afternoon and evening darshan reminders nearby'**
  String get locBenefitReminders;

  /// No description provided for @locBenefitCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Quick, verified temple check-ins'**
  String get locBenefitCheckIn;

  /// No description provided for @dirDrive.
  ///
  /// In en, this message translates to:
  /// **'Drive'**
  String get dirDrive;

  /// No description provided for @dirWalk.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get dirWalk;

  /// No description provided for @dirStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get dirStart;

  /// No description provided for @dirStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get dirStop;

  /// No description provided for @dirOpenInMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Maps'**
  String get dirOpenInMaps;

  /// No description provided for @dirSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get dirSteps;

  /// No description provided for @dirShowRoute.
  ///
  /// In en, this message translates to:
  /// **'Show whole route'**
  String get dirShowRoute;

  /// No description provided for @dirMyLocation.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get dirMyLocation;

  /// No description provided for @dirArriveBy.
  ///
  /// In en, this message translates to:
  /// **'Arrive {time}'**
  String dirArriveBy(String time);

  /// No description provided for @dirVia.
  ///
  /// In en, this message translates to:
  /// **'via {roads}'**
  String dirVia(String roads);

  /// No description provided for @dirLocating.
  ///
  /// In en, this message translates to:
  /// **'Finding your location…'**
  String get dirLocating;

  /// No description provided for @dirFinding.
  ///
  /// In en, this message translates to:
  /// **'Finding the best route…'**
  String get dirFinding;

  /// No description provided for @dirNoRouteTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t find a route'**
  String get dirNoRouteTitle;

  /// No description provided for @dirNoRouteBody.
  ///
  /// In en, this message translates to:
  /// **'Check your connection, or open it in your maps app.'**
  String get dirNoRouteBody;

  /// No description provided for @dirNeedLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Location needed'**
  String get dirNeedLocationTitle;

  /// No description provided for @dirNeedLocationBody.
  ///
  /// In en, this message translates to:
  /// **'Allow location so MARG can guide you to {name}.'**
  String dirNeedLocationBody(String name);

  /// No description provided for @dirArrivedTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'ve arrived'**
  String get dirArrivedTitle;

  /// No description provided for @dirArrivedBody.
  ///
  /// In en, this message translates to:
  /// **'Welcome to {name}. Have a blessed darshan.'**
  String dirArrivedBody(String name);

  /// No description provided for @dirCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get dirCheckIn;

  /// No description provided for @dirDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get dirDone;

  /// No description provided for @dirMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String dirMinutes(int minutes);

  /// No description provided for @dirHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes} min'**
  String dirHoursMinutes(int hours, int minutes);

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Namaste'**
  String get homeGreeting;

  /// No description provided for @homeGreetingNamed.
  ///
  /// In en, this message translates to:
  /// **'Namaste, {name}'**
  String homeGreetingNamed(Object name);

  /// No description provided for @homeActionMyRoutesHint.
  ///
  /// In en, this message translates to:
  /// **'Track your journey'**
  String get homeActionMyRoutesHint;

  /// No description provided for @homeActionNearbyHint.
  ///
  /// In en, this message translates to:
  /// **'Temples near you'**
  String get homeActionNearbyHint;

  /// No description provided for @homeActionCardsHint.
  ///
  /// In en, this message translates to:
  /// **'Unlock sacred cards'**
  String get homeActionCardsHint;

  /// No description provided for @homeActionAchievementsHint.
  ///
  /// In en, this message translates to:
  /// **'Your spiritual milestones'**
  String get homeActionAchievementsHint;

  /// No description provided for @homeActionPassport.
  ///
  /// In en, this message translates to:
  /// **'My Passport'**
  String get homeActionPassport;

  /// No description provided for @homeActionPassportHint.
  ///
  /// In en, this message translates to:
  /// **'Stamps & journey'**
  String get homeActionPassportHint;

  /// No description provided for @homeActionSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved Places'**
  String get homeActionSaved;

  /// No description provided for @homeActionSavedHint.
  ///
  /// In en, this message translates to:
  /// **'Temples you love'**
  String get homeActionSavedHint;

  /// No description provided for @homeBannerCta.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get homeBannerCta;

  /// No description provided for @homeGroupJyotirlinga.
  ///
  /// In en, this message translates to:
  /// **'Jyotirlingas'**
  String get homeGroupJyotirlinga;

  /// No description provided for @homeGroupShaktiPeeth.
  ///
  /// In en, this message translates to:
  /// **'Shakti Peeths'**
  String get homeGroupShaktiPeeth;

  /// No description provided for @homeGroupCharDham.
  ///
  /// In en, this message translates to:
  /// **'Char Dham'**
  String get homeGroupCharDham;

  /// No description provided for @homeGroupOther.
  ///
  /// In en, this message translates to:
  /// **'Other Temples'**
  String get homeGroupOther;

  /// No description provided for @homeProgressCompleted.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total} Completed'**
  String homeProgressCompleted(Object done, Object total);

  /// No description provided for @homeViewYatraMap.
  ///
  /// In en, this message translates to:
  /// **'View Full Yatra Map'**
  String get homeViewYatraMap;

  /// No description provided for @homeSectionPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular Temples'**
  String get homeSectionPopular;

  /// No description provided for @templeOpenUntil.
  ///
  /// In en, this message translates to:
  /// **'Open · till {time}'**
  String templeOpenUntil(Object time);

  /// No description provided for @templeClosedOpensAt.
  ///
  /// In en, this message translates to:
  /// **'Closed · opens {time}'**
  String templeClosedOpensAt(Object time);

  /// No description provided for @templeOpenNow.
  ///
  /// In en, this message translates to:
  /// **'Open now'**
  String get templeOpenNow;

  /// No description provided for @templeClosedNow.
  ///
  /// In en, this message translates to:
  /// **'Closed now'**
  String get templeClosedNow;

  /// No description provided for @homeSectionIntelligence.
  ///
  /// In en, this message translates to:
  /// **'Temple Intelligence'**
  String get homeSectionIntelligence;

  /// No description provided for @homeCrowdSuffix.
  ///
  /// In en, this message translates to:
  /// **'{level} Crowd'**
  String homeCrowdSuffix(Object level);

  /// No description provided for @homeBestTime.
  ///
  /// In en, this message translates to:
  /// **'Best time to visit: {slot}'**
  String homeBestTime(Object slot);

  /// No description provided for @homeWaitMinutes.
  ///
  /// In en, this message translates to:
  /// **'~{minutes} min wait'**
  String homeWaitMinutes(Object minutes);

  /// No description provided for @homeSectionCrowdStatus.
  ///
  /// In en, this message translates to:
  /// **'Crowd Status'**
  String get homeSectionCrowdStatus;

  /// No description provided for @homeCrowdHintLow.
  ///
  /// In en, this message translates to:
  /// **'Short wait'**
  String get homeCrowdHintLow;

  /// No description provided for @homeCrowdHintModerate.
  ///
  /// In en, this message translates to:
  /// **'Some wait'**
  String get homeCrowdHintModerate;

  /// No description provided for @homeCrowdHintHigh.
  ///
  /// In en, this message translates to:
  /// **'Long queues'**
  String get homeCrowdHintHigh;

  /// No description provided for @homeCrowdHintVeryHigh.
  ///
  /// In en, this message translates to:
  /// **'Plan another time'**
  String get homeCrowdHintVeryHigh;

  /// No description provided for @homeSectionCards.
  ///
  /// In en, this message translates to:
  /// **'Sacred Cards'**
  String get homeSectionCards;

  /// No description provided for @homeCardsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Visit a temple to unlock your first sacred card'**
  String get homeCardsEmpty;

  /// No description provided for @homeSectionAchievements.
  ///
  /// In en, this message translates to:
  /// **'Top Achievements'**
  String get homeSectionAchievements;

  /// No description provided for @homeProgressFraction.
  ///
  /// In en, this message translates to:
  /// **'{current} / {target}'**
  String homeProgressFraction(Object current, Object target);

  /// No description provided for @homeThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get homeThisMonth;

  /// No description provided for @homeAllTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get homeAllTime;

  /// No description provided for @homeViewFullLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'View Full Leaderboard'**
  String get homeViewFullLeaderboard;

  /// No description provided for @homeLeaderboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'No rankings yet — be the first to earn points!'**
  String get homeLeaderboardEmpty;

  /// No description provided for @homePoints.
  ///
  /// In en, this message translates to:
  /// **'{points} pts'**
  String homePoints(Object points);

  /// No description provided for @homePointsEarned.
  ///
  /// In en, this message translates to:
  /// **'+{points} pts'**
  String homePointsEarned(Object points);

  /// No description provided for @homeDevotee.
  ///
  /// In en, this message translates to:
  /// **'Devotee'**
  String get homeDevotee;

  /// No description provided for @homeSectionQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get homeSectionQuickActions;

  /// No description provided for @homeToday.
  ///
  /// In en, this message translates to:
  /// **'Today, {time}'**
  String homeToday(Object time);

  /// No description provided for @homeYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday, {time}'**
  String homeYesterday(Object time);

  /// No description provided for @homeHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Need Help?'**
  String get homeHelpTitle;

  /// No description provided for @homeHelpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'re here to help you on your spiritual journey.'**
  String get homeHelpSubtitle;

  /// No description provided for @homeContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get homeContactSupport;

  /// No description provided for @homeMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get homeMenu;

  /// No description provided for @drawerJourney.
  ///
  /// In en, this message translates to:
  /// **'Your Journey'**
  String get drawerJourney;

  /// No description provided for @drawerDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get drawerDiscover;

  /// No description provided for @drawerAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get drawerAccount;

  /// No description provided for @savedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved places yet'**
  String get savedEmptyTitle;

  /// No description provided for @savedEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on any temple to keep it here for your next yatra.'**
  String get savedEmptyBody;

  /// No description provided for @savedVisited.
  ///
  /// In en, this message translates to:
  /// **'Visited'**
  String get savedVisited;

  /// No description provided for @savedRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from Saved Places'**
  String get savedRemoved;

  /// No description provided for @savedRemoveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t remove — please try again'**
  String get savedRemoveFailed;

  /// No description provided for @savedRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from Saved Places'**
  String get savedRemove;

  /// No description provided for @savedExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore Temples'**
  String get savedExplore;

  /// No description provided for @savedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} saved'**
  String savedCount(Object count);

  /// No description provided for @lbThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get lbThisWeek;

  /// No description provided for @lbOverall.
  ///
  /// In en, this message translates to:
  /// **'Overall'**
  String get lbOverall;

  /// No description provided for @lbVisits.
  ///
  /// In en, this message translates to:
  /// **'Visits'**
  String get lbVisits;

  /// No description provided for @lbCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get lbCards;

  /// No description provided for @lbRoutes.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get lbRoutes;

  /// No description provided for @lbAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get lbAchievements;

  /// No description provided for @lbTrust.
  ///
  /// In en, this message translates to:
  /// **'Trust Score'**
  String get lbTrust;

  /// No description provided for @lbReferrals.
  ///
  /// In en, this message translates to:
  /// **'Referrals'**
  String get lbReferrals;

  /// No description provided for @lbBestRank.
  ///
  /// In en, this message translates to:
  /// **'Best #{rank}'**
  String lbBestRank(Object rank);

  /// No description provided for @lbStateRank.
  ///
  /// In en, this message translates to:
  /// **'State #{rank}'**
  String lbStateRank(Object rank);

  /// No description provided for @lbCityRank.
  ///
  /// In en, this message translates to:
  /// **'City #{rank}'**
  String lbCityRank(Object rank);

  /// No description provided for @lbMovedUp.
  ///
  /// In en, this message translates to:
  /// **'Up {count} since last week'**
  String lbMovedUp(Object count);

  /// No description provided for @lbMovedDown.
  ///
  /// In en, this message translates to:
  /// **'Down {count} since last week'**
  String lbMovedDown(Object count);

  /// No description provided for @lbEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No rankings yet'**
  String get lbEmptyTitle;

  /// No description provided for @lbEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Earn points by visiting temples, collecting cards and completing routes.'**
  String get lbEmptyBody;

  /// No description provided for @lbLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get lbLoadMore;

  /// No description provided for @lbYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get lbYou;

  /// No description provided for @lbRankedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} devotees ranked'**
  String lbRankedCount(Object count);

  /// No description provided for @tdPlanVisit.
  ///
  /// In en, this message translates to:
  /// **'Plan Your Visit'**
  String get tdPlanVisit;

  /// No description provided for @tdHowToReach.
  ///
  /// In en, this message translates to:
  /// **'How to Reach'**
  String get tdHowToReach;

  /// No description provided for @tdParking.
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get tdParking;

  /// No description provided for @tdDressCode.
  ///
  /// In en, this message translates to:
  /// **'Dress Code'**
  String get tdDressCode;

  /// No description provided for @tdPhotography.
  ///
  /// In en, this message translates to:
  /// **'Photography'**
  String get tdPhotography;

  /// No description provided for @tdPhotoAllowed.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get tdPhotoAllowed;

  /// No description provided for @tdPhotoRestricted.
  ///
  /// In en, this message translates to:
  /// **'Restricted areas'**
  String get tdPhotoRestricted;

  /// No description provided for @tdPhotoNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Not allowed'**
  String get tdPhotoNotAllowed;

  /// No description provided for @tdPrasad.
  ///
  /// In en, this message translates to:
  /// **'Food & Prasadam'**
  String get tdPrasad;

  /// No description provided for @tdStay.
  ///
  /// In en, this message translates to:
  /// **'Stay Nearby'**
  String get tdStay;

  /// No description provided for @tdRules.
  ///
  /// In en, this message translates to:
  /// **'Rules & Guidelines'**
  String get tdRules;

  /// No description provided for @tdBestSeason.
  ///
  /// In en, this message translates to:
  /// **'Best Season'**
  String get tdBestSeason;

  /// No description provided for @tdReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews & Ratings'**
  String get tdReviews;

  /// No description provided for @tdReviewCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 review} other{{count} reviews}}'**
  String tdReviewCount(num count);

  /// No description provided for @tdNoReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet — be the first to share your darshan experience.'**
  String get tdNoReviews;

  /// No description provided for @tdReviewVisitRequired.
  ///
  /// In en, this message translates to:
  /// **'Visit this temple to share your review — reviews come only from devotees who have been there.'**
  String get tdReviewVisitRequired;

  /// No description provided for @tdWriteReview.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get tdWriteReview;

  /// No description provided for @tdEditReview.
  ///
  /// In en, this message translates to:
  /// **'Edit Your Review'**
  String get tdEditReview;

  /// No description provided for @tdYourRating.
  ///
  /// In en, this message translates to:
  /// **'Your rating'**
  String get tdYourRating;

  /// No description provided for @tdReviewHint.
  ///
  /// In en, this message translates to:
  /// **'Share your darshan experience (optional)'**
  String get tdReviewHint;

  /// No description provided for @tdSubmitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get tdSubmitReview;

  /// No description provided for @tdReviewSaved.
  ///
  /// In en, this message translates to:
  /// **'Thank you! Your review is saved.'**
  String get tdReviewSaved;

  /// No description provided for @tdReviewFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your review. Please try again.'**
  String get tdReviewFailed;

  /// No description provided for @tdVerifiedVisitor.
  ///
  /// In en, this message translates to:
  /// **'Verified visitor'**
  String get tdVerifiedVisitor;

  /// No description provided for @tdSave.
  ///
  /// In en, this message translates to:
  /// **'Save to Saved Places'**
  String get tdSave;

  /// No description provided for @tdSavedToast.
  ///
  /// In en, this message translates to:
  /// **'Saved to your places'**
  String get tdSavedToast;

  /// No description provided for @tdSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update Saved Places'**
  String get tdSaveFailed;

  /// No description provided for @tdStarsLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} stars'**
  String tdStarsLabel(Object count);

  /// No description provided for @siWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get siWelcome;

  /// No description provided for @siSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your spiritual journey'**
  String get siSubtitle;

  /// No description provided for @siGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get siGoogle;

  /// No description provided for @siSecure.
  ///
  /// In en, this message translates to:
  /// **'Secure, simple and seamless'**
  String get siSecure;

  /// No description provided for @exViewTemple.
  ///
  /// In en, this message translates to:
  /// **'View Temple'**
  String get exViewTemple;

  /// No description provided for @exGreeting.
  ///
  /// In en, this message translates to:
  /// **'Har Har Mahadev! 🙏'**
  String get exGreeting;

  /// No description provided for @exCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get exCurrentLocation;

  /// No description provided for @exChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get exChange;

  /// No description provided for @exPopularToday.
  ///
  /// In en, this message translates to:
  /// **'Popular Today'**
  String get exPopularToday;

  /// No description provided for @exDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get exDiscover;

  /// No description provided for @ryEmbarkTitle.
  ///
  /// In en, this message translates to:
  /// **'Embark on a Divine Journey'**
  String get ryEmbarkTitle;

  /// No description provided for @ryEmbarkBody.
  ///
  /// In en, this message translates to:
  /// **'Choose from our sacred routes and complete your pilgrimage.'**
  String get ryEmbarkBody;

  /// No description provided for @ryStartJourney.
  ///
  /// In en, this message translates to:
  /// **'Start Journey'**
  String get ryStartJourney;

  /// No description provided for @ryPlannedYatras.
  ///
  /// In en, this message translates to:
  /// **'Planned Yatras'**
  String get ryPlannedYatras;

  /// No description provided for @ryCompletedYatras.
  ///
  /// In en, this message translates to:
  /// **'Completed Yatras'**
  String get ryCompletedYatras;

  /// No description provided for @siSacredPath.
  ///
  /// In en, this message translates to:
  /// **'Your Sacred Path.'**
  String get siSacredPath;

  /// No description provided for @mapAkhandBharat.
  ///
  /// In en, this message translates to:
  /// **'Akhand Bharat'**
  String get mapAkhandBharat;

  /// No description provided for @suWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Marg! 🙏'**
  String get suWelcomeTitle;

  /// No description provided for @suWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s begin by creating your personal profile'**
  String get suWelcomeSubtitle;

  /// No description provided for @suAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get suAddPhoto;

  /// No description provided for @suAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell Us About You'**
  String get suAboutTitle;

  /// No description provided for @suAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This helps us personalize your experience'**
  String get suAboutSubtitle;

  /// No description provided for @suCityLocation.
  ///
  /// In en, this message translates to:
  /// **'City / Location'**
  String get suCityLocation;

  /// No description provided for @suCityTapToDetect.
  ///
  /// In en, this message translates to:
  /// **'Tap to detect your city'**
  String get suCityTapToDetect;

  /// No description provided for @suBringsTitle.
  ///
  /// In en, this message translates to:
  /// **'What Brings You Here?'**
  String get suBringsTitle;

  /// No description provided for @suBringsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select what interests you the most'**
  String get suBringsSubtitle;

  /// No description provided for @suInterestTempleVisitsSub.
  ///
  /// In en, this message translates to:
  /// **'Plan visits and darshan'**
  String get suInterestTempleVisitsSub;

  /// No description provided for @suInterestRouteCompletionSub.
  ///
  /// In en, this message translates to:
  /// **'Complete sacred yatra routes'**
  String get suInterestRouteCompletionSub;

  /// No description provided for @suInterestPujaPanditSub.
  ///
  /// In en, this message translates to:
  /// **'Puja, rituals and services'**
  String get suInterestPujaPanditSub;

  /// No description provided for @suInterestCollectCardsSub.
  ///
  /// In en, this message translates to:
  /// **'Collect sacred temple cards'**
  String get suInterestCollectCardsSub;

  /// No description provided for @suInterestAchievementsSub.
  ///
  /// In en, this message translates to:
  /// **'Unlock milestones on your journey'**
  String get suInterestAchievementsSub;

  /// No description provided for @suInterestEventsFestivalsSub.
  ///
  /// In en, this message translates to:
  /// **'Never miss a festival'**
  String get suInterestEventsFestivalsSub;

  /// No description provided for @suInterestNearbyTemplesSub.
  ///
  /// In en, this message translates to:
  /// **'Find temples near you'**
  String get suInterestNearbyTemplesSub;

  /// No description provided for @suInterestOthersSub.
  ///
  /// In en, this message translates to:
  /// **'Something else that inspires you'**
  String get suInterestOthersSub;

  /// No description provided for @suSpiritualTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Spiritual Preferences'**
  String get suSpiritualTitle;

  /// No description provided for @suSpiritualSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help us suggest better for you'**
  String get suSpiritualSubtitle;

  /// No description provided for @suPreferredDeities.
  ///
  /// In en, this message translates to:
  /// **'Preferred Deities'**
  String get suPreferredDeities;

  /// No description provided for @suSelectAny.
  ///
  /// In en, this message translates to:
  /// **'(Select any)'**
  String get suSelectAny;

  /// No description provided for @suDeityShiva.
  ///
  /// In en, this message translates to:
  /// **'Shiva'**
  String get suDeityShiva;

  /// No description provided for @suDeityDevi.
  ///
  /// In en, this message translates to:
  /// **'Devi'**
  String get suDeityDevi;

  /// No description provided for @suDeityVishnu.
  ///
  /// In en, this message translates to:
  /// **'Vishnu'**
  String get suDeityVishnu;

  /// No description provided for @suDeityGanesha.
  ///
  /// In en, this message translates to:
  /// **'Ganesha'**
  String get suDeityGanesha;

  /// No description provided for @suDeityHanuman.
  ///
  /// In en, this message translates to:
  /// **'Hanuman'**
  String get suDeityHanuman;

  /// No description provided for @suDeitySurya.
  ///
  /// In en, this message translates to:
  /// **'Surya'**
  String get suDeitySurya;

  /// No description provided for @suVisitFrequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency of Temple Visits'**
  String get suVisitFrequency;

  /// No description provided for @suFreqVeryOften.
  ///
  /// In en, this message translates to:
  /// **'Very Often'**
  String get suFreqVeryOften;

  /// No description provided for @suFreqVeryOftenSub.
  ///
  /// In en, this message translates to:
  /// **'Weekly or more'**
  String get suFreqVeryOftenSub;

  /// No description provided for @suFreqSometimes.
  ///
  /// In en, this message translates to:
  /// **'Sometimes'**
  String get suFreqSometimes;

  /// No description provided for @suFreqSometimesSub.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get suFreqSometimesSub;

  /// No description provided for @suFreqRarely.
  ///
  /// In en, this message translates to:
  /// **'Rarely'**
  String get suFreqRarely;

  /// No description provided for @suFreqRarelySub.
  ///
  /// In en, this message translates to:
  /// **'Few times a year'**
  String get suFreqRarelySub;

  /// No description provided for @suInterestedIn.
  ///
  /// In en, this message translates to:
  /// **'I am interested in'**
  String get suInterestedIn;

  /// No description provided for @suRouteJyotirlinga.
  ///
  /// In en, this message translates to:
  /// **'Jyotirlinga Yatra'**
  String get suRouteJyotirlinga;

  /// No description provided for @suRouteShaktiPeeth.
  ///
  /// In en, this message translates to:
  /// **'Shakti Peeth Yatra'**
  String get suRouteShaktiPeeth;

  /// No description provided for @suRouteCharDham.
  ///
  /// In en, this message translates to:
  /// **'Char Dham Yatra'**
  String get suRouteCharDham;

  /// No description provided for @suRouteNotSure.
  ///
  /// In en, this message translates to:
  /// **'Not Sure Yet'**
  String get suRouteNotSure;

  /// No description provided for @suReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Almost Done! 🎉'**
  String get suReviewTitle;

  /// No description provided for @suReviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review your details and start your spiritual journey'**
  String get suReviewSubtitle;

  /// No description provided for @suCompleteSetup.
  ///
  /// In en, this message translates to:
  /// **'Complete Setup'**
  String get suCompleteSetup;

  /// No description provided for @suUpdateLater.
  ///
  /// In en, this message translates to:
  /// **'You can always update this later in your profile settings.'**
  String get suUpdateLater;

  /// No description provided for @suNotProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get suNotProvided;

  /// No description provided for @searchBrowse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get searchBrowse;

  /// No description provided for @ppTemplesWalked.
  ///
  /// In en, this message translates to:
  /// **'Temples Walked'**
  String get ppTemplesWalked;

  /// No description provided for @ppCertificatesEarned.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 certificate earned} other{{count} certificates earned}}'**
  String ppCertificatesEarned(num count);

  /// No description provided for @ppNextTempleName.
  ///
  /// In en, this message translates to:
  /// **'Next: {name}'**
  String ppNextTempleName(Object name);

  /// No description provided for @ppCompletedOn.
  ///
  /// In en, this message translates to:
  /// **'Completed on {date}'**
  String ppCompletedOn(Object date);

  /// No description provided for @ppStates.
  ///
  /// In en, this message translates to:
  /// **'States'**
  String get ppStates;

  /// No description provided for @ppCertIntro.
  ///
  /// In en, this message translates to:
  /// **'A certificate for every sacred route you complete — download it or share it with family.'**
  String get ppCertIntro;

  /// No description provided for @ppEarned.
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get ppEarned;

  /// No description provided for @ppToEarn.
  ///
  /// In en, this message translates to:
  /// **'To Earn'**
  String get ppToEarn;

  /// No description provided for @ppEarnedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} earned'**
  String ppEarnedCount(Object count);

  /// No description provided for @ppCertOfCompletion.
  ///
  /// In en, this message translates to:
  /// **'Certificate of Completion'**
  String get ppCertOfCompletion;

  /// No description provided for @ppTemplesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 temple} other{{count} temples}}'**
  String ppTemplesCount(num count);

  /// No description provided for @ppTemplesToGo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 temple to go} other{{count} temples to go}}'**
  String ppTemplesToGo(num count);

  /// No description provided for @ppViewRoute.
  ///
  /// In en, this message translates to:
  /// **'View Route'**
  String get ppViewRoute;

  /// No description provided for @ppFirstCertHint.
  ///
  /// In en, this message translates to:
  /// **'Finish a route below to earn your first certificate.'**
  String get ppFirstCertHint;

  /// No description provided for @ppShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get ppShowAll;

  /// No description provided for @ppVisitsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 visit} other{{count} visits}}'**
  String ppVisitsCount(num count);

  /// No description provided for @ppViewTemple.
  ///
  /// In en, this message translates to:
  /// **'View temple'**
  String get ppViewTemple;

  /// No description provided for @ppUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get ppUnderReview;

  /// No description provided for @ppNoFilterMatch.
  ///
  /// In en, this message translates to:
  /// **'Nothing here'**
  String get ppNoFilterMatch;

  /// No description provided for @ppNoFilterMatchBody.
  ///
  /// In en, this message translates to:
  /// **'No temple visits match this filter.'**
  String get ppNoFilterMatchBody;

  /// No description provided for @ryNextStop.
  ///
  /// In en, this message translates to:
  /// **'Next Stop'**
  String get ryNextStop;

  /// No description provided for @ryYourProgress.
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get ryYourProgress;

  /// No description provided for @ryVisitedOf.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} temples visited'**
  String ryVisitedOf(Object done, Object total);

  /// No description provided for @ryKmRoute.
  ///
  /// In en, this message translates to:
  /// **'{km} km route'**
  String ryKmRoute(Object km);

  /// No description provided for @ryToGo.
  ///
  /// In en, this message translates to:
  /// **'{count} to go'**
  String ryToGo(Object count);

  /// No description provided for @ryNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started yet'**
  String get ryNotStarted;

  /// No description provided for @ryYatraComplete.
  ///
  /// In en, this message translates to:
  /// **'Yatra complete'**
  String get ryYatraComplete;

  /// No description provided for @ryJourneySoFar.
  ///
  /// In en, this message translates to:
  /// **'Journey so far'**
  String get ryJourneySoFar;

  /// No description provided for @ryStillAhead.
  ///
  /// In en, this message translates to:
  /// **'Still ahead'**
  String get ryStillAhead;

  /// No description provided for @ryKmCovered.
  ///
  /// In en, this message translates to:
  /// **'KM Covered'**
  String get ryKmCovered;

  /// No description provided for @ryVisitedOn.
  ///
  /// In en, this message translates to:
  /// **'Visited {date}'**
  String ryVisitedOn(Object date);

  /// No description provided for @ryNoVisitsOnRoute.
  ///
  /// In en, this message translates to:
  /// **'Your first darshan on this route will appear here.'**
  String get ryNoVisitsOnRoute;

  /// No description provided for @ryNextBadge.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get ryNextBadge;

  /// No description provided for @exCategoriesIntro.
  ///
  /// In en, this message translates to:
  /// **'Find temples by the deity they honour.'**
  String get exCategoriesIntro;

  /// No description provided for @exMostVisited.
  ///
  /// In en, this message translates to:
  /// **'Most visited: {name}'**
  String exMostVisited(Object name);

  /// No description provided for @rfCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Share your code. When a friend joins MARG, you earn points and rewards.'**
  String get rfCodeHint;

  /// No description provided for @rfToMilestone.
  ///
  /// In en, this message translates to:
  /// **'{milestone, plural, =1{Your first friend to join unlocks a reward} other{{count} more friends to reach {milestone}}}'**
  String rfToMilestone(Object count, num milestone);

  /// No description provided for @rfAllMilestonesDone.
  ///
  /// In en, this message translates to:
  /// **'Every milestone reached — thank you!'**
  String get rfAllMilestonesDone;

  /// No description provided for @rfMilestoneTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 friend joins} other{{count} friends join}}'**
  String rfMilestoneTitle(num count);

  /// No description provided for @rfReached.
  ///
  /// In en, this message translates to:
  /// **'Reached'**
  String get rfReached;

  /// No description provided for @rfNextUp.
  ///
  /// In en, this message translates to:
  /// **'Next up'**
  String get rfNextUp;

  /// No description provided for @rfMilestones.
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get rfMilestones;

  /// No description provided for @rfBonusRareCard.
  ///
  /// In en, this message translates to:
  /// **'Bonus Rare Sacred Card'**
  String get rfBonusRareCard;

  /// No description provided for @rfBonusEpicCard.
  ///
  /// In en, this message translates to:
  /// **'Bonus Epic Sacred Card'**
  String get rfBonusEpicCard;

  /// No description provided for @rfBonusLegendaryCard.
  ///
  /// In en, this message translates to:
  /// **'Bonus Legendary Sacred Card'**
  String get rfBonusLegendaryCard;

  /// No description provided for @rfBonusBadge.
  ///
  /// In en, this message translates to:
  /// **'Special community badge'**
  String get rfBonusBadge;

  /// No description provided for @rfPointsFromReferrals.
  ///
  /// In en, this message translates to:
  /// **'points earned by inviting friends'**
  String get rfPointsFromReferrals;

  /// No description provided for @rfTools.
  ///
  /// In en, this message translates to:
  /// **'Referral Tools'**
  String get rfTools;

  /// No description provided for @rfTileTimeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get rfTileTimeline;

  /// No description provided for @rfTileTimelineHint.
  ///
  /// In en, this message translates to:
  /// **'Every invite, step by step'**
  String get rfTileTimelineHint;

  /// No description provided for @rfTileRewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rfTileRewards;

  /// No description provided for @rfTileRewardsHint.
  ///
  /// In en, this message translates to:
  /// **'Points & milestones'**
  String get rfTileRewardsHint;

  /// No description provided for @rfTileAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get rfTileAnalytics;

  /// No description provided for @rfTileAnalyticsHint.
  ///
  /// In en, this message translates to:
  /// **'How your invites perform'**
  String get rfTileAnalyticsHint;

  /// No description provided for @rfTileRanking.
  ///
  /// In en, this message translates to:
  /// **'Ranking'**
  String get rfTileRanking;

  /// No description provided for @rfTileRankingHint.
  ///
  /// In en, this message translates to:
  /// **'Community leaderboard'**
  String get rfTileRankingHint;

  /// No description provided for @rfTileShare.
  ///
  /// In en, this message translates to:
  /// **'Share Card'**
  String get rfTileShare;

  /// No description provided for @rfTileShareHint.
  ///
  /// In en, this message translates to:
  /// **'Inspire with your journey'**
  String get rfTileShareHint;

  /// No description provided for @rfTileFaq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get rfTileFaq;

  /// No description provided for @rfTileFaqHint.
  ///
  /// In en, this message translates to:
  /// **'Questions answered'**
  String get rfTileFaqHint;

  /// No description provided for @pfHelpHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'How can we help?'**
  String get pfHelpHeroTitle;

  /// No description provided for @pfHelpHeroBody.
  ///
  /// In en, this message translates to:
  /// **'Answers to common questions, our policies, and a direct line to the MARG team.'**
  String get pfHelpHeroBody;

  /// No description provided for @exFiltersHint.
  ///
  /// In en, this message translates to:
  /// **'Refine the temples you see'**
  String get exFiltersHint;

  /// No description provided for @exKm.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String exKm(Object km);

  /// No description provided for @exSortPopularHint.
  ///
  /// In en, this message translates to:
  /// **'Most visited temples first'**
  String get exSortPopularHint;

  /// No description provided for @exSortNewestHint.
  ///
  /// In en, this message translates to:
  /// **'Recently added to MARG'**
  String get exSortNewestHint;

  /// No description provided for @exSortNameHint.
  ///
  /// In en, this message translates to:
  /// **'Alphabetical by name'**
  String get exSortNameHint;

  /// No description provided for @exWithinKm.
  ///
  /// In en, this message translates to:
  /// **'Within {km} km'**
  String exWithinKm(Object km);

  /// No description provided for @exNoNearbyWithin.
  ///
  /// In en, this message translates to:
  /// **'No temples within {km} km of you yet. Try a wider radius.'**
  String exNoNearbyWithin(Object km);

  /// No description provided for @exWidenTo.
  ///
  /// In en, this message translates to:
  /// **'Widen to {km} km'**
  String exWidenTo(Object km);

  /// No description provided for @exNearbyCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 temple} other{{count} temples}} within {km} km'**
  String exNearbyCount(num count, Object km);

  /// No description provided for @searchFilterHint.
  ///
  /// In en, this message translates to:
  /// **'Choose where to look and how to order results'**
  String get searchFilterHint;

  /// No description provided for @searchSortRelevanceHint.
  ///
  /// In en, this message translates to:
  /// **'Best matches first'**
  String get searchSortRelevanceHint;

  /// No description provided for @searchSortAlphabeticalHint.
  ///
  /// In en, this message translates to:
  /// **'A to Z by name'**
  String get searchSortAlphabeticalHint;

  /// No description provided for @searchGroupPlaces.
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get searchGroupPlaces;

  /// No description provided for @searchGroupCards.
  ///
  /// In en, this message translates to:
  /// **'Sacred Cards'**
  String get searchGroupCards;

  /// No description provided for @searchGroupAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get searchGroupAchievements;

  /// No description provided for @tdSacredCard.
  ///
  /// In en, this message translates to:
  /// **'Sacred Card'**
  String get tdSacredCard;

  /// No description provided for @tdCardInCollection.
  ///
  /// In en, this message translates to:
  /// **'In your collection'**
  String get tdCardInCollection;

  /// No description provided for @tdCardHowToCollect.
  ///
  /// In en, this message translates to:
  /// **'Visit and check in here to unlock this card.'**
  String get tdCardHowToCollect;

  /// No description provided for @tdViewCard.
  ///
  /// In en, this message translates to:
  /// **'View card'**
  String get tdViewCard;

  /// No description provided for @tdCollectCard.
  ///
  /// In en, this message translates to:
  /// **'Collect this card'**
  String get tdCollectCard;

  /// No description provided for @tdStepsDone.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} steps done'**
  String tdStepsDone(Object done, Object total);

  /// No description provided for @homeQuestFirstOverline.
  ///
  /// In en, this message translates to:
  /// **'Your first Sacred Card'**
  String get homeQuestFirstOverline;

  /// No description provided for @homeQuestFirstTitle.
  ///
  /// In en, this message translates to:
  /// **'Collect your first card'**
  String get homeQuestFirstTitle;

  /// No description provided for @homeQuestFirstBody.
  ///
  /// In en, this message translates to:
  /// **'Every temple holds a Sacred Card. Visit one and check in — it\'s yours.'**
  String get homeQuestFirstBody;

  /// No description provided for @homeQuestStepVisit.
  ///
  /// In en, this message translates to:
  /// **'Visit a temple'**
  String get homeQuestStepVisit;

  /// No description provided for @homeQuestStepCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get homeQuestStepCheckIn;

  /// No description provided for @homeQuestStepCard.
  ///
  /// In en, this message translates to:
  /// **'Card unlocked'**
  String get homeQuestStepCard;

  /// No description provided for @homeQuestFindTemple.
  ///
  /// In en, this message translates to:
  /// **'Find a temple near you'**
  String get homeQuestFindTemple;

  /// No description provided for @homeQuestContinueOverline.
  ///
  /// In en, this message translates to:
  /// **'Continue your journey'**
  String get homeQuestContinueOverline;

  /// No description provided for @homeQuestCollected.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Sacred Card collected} other{{count} Sacred Cards collected}}'**
  String homeQuestCollected(num count);

  /// No description provided for @homeQuestToMilestone.
  ///
  /// In en, this message translates to:
  /// **'{count} more to reach {milestone} cards'**
  String homeQuestToMilestone(Object count, Object milestone);

  /// No description provided for @homeQuestAllMilestones.
  ///
  /// In en, this message translates to:
  /// **'A true collector — keep going!'**
  String get homeQuestAllMilestones;

  /// No description provided for @homeQuestNextCard.
  ///
  /// In en, this message translates to:
  /// **'Your next card awaits'**
  String get homeQuestNextCard;

  /// No description provided for @homeQuestCollectMore.
  ///
  /// In en, this message translates to:
  /// **'Collect more'**
  String get homeQuestCollectMore;

  /// No description provided for @homeQuestMyCollection.
  ///
  /// In en, this message translates to:
  /// **'My collection'**
  String get homeQuestMyCollection;

  /// No description provided for @exTemplesFoundCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 temple found} other{{count} temples found}}'**
  String exTemplesFoundCount(num count);

  /// No description provided for @searchResultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 result found} other{About {count} results found}}'**
  String searchResultsCount(num count);

  /// No description provided for @tdCheckInAgain.
  ///
  /// In en, this message translates to:
  /// **'Check in again'**
  String get tdCheckInAgain;

  /// No description provided for @tdCheckedInToday.
  ///
  /// In en, this message translates to:
  /// **'Checked in today'**
  String get tdCheckedInToday;

  /// No description provided for @tdVisitCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Visited once} other{Visited {count} times}}'**
  String tdVisitCount(num count);

  /// No description provided for @tdLastVisit.
  ///
  /// In en, this message translates to:
  /// **'Last visit · {date}'**
  String tdLastVisit(Object date);

  /// No description provided for @tdNextCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Checked in today · next check-in from {when}'**
  String tdNextCheckIn(Object when);

  /// No description provided for @tvCardInCollection.
  ///
  /// In en, this message translates to:
  /// **'In Your Collection'**
  String get tvCardInCollection;

  /// No description provided for @dirDaysHours.
  ///
  /// In en, this message translates to:
  /// **'{days} d {hours} h'**
  String dirDaysHours(Object days, Object hours);

  /// No description provided for @dirBike.
  ///
  /// In en, this message translates to:
  /// **'Bike'**
  String get dirBike;

  /// No description provided for @tvModeBike.
  ///
  /// In en, this message translates to:
  /// **'Bike'**
  String get tvModeBike;

  /// No description provided for @tvVerifyingTitle.
  ///
  /// In en, this message translates to:
  /// **'Verifying Your Visit'**
  String get tvVerifyingTitle;

  /// No description provided for @tvGeofenceDetected.
  ///
  /// In en, this message translates to:
  /// **'Temple geofence detected'**
  String get tvGeofenceDetected;

  /// No description provided for @tvAwayFrom.
  ///
  /// In en, this message translates to:
  /// **'{distance} from the temple'**
  String tvAwayFrom(Object distance);

  /// No description provided for @tvGreetShiva.
  ///
  /// In en, this message translates to:
  /// **'Jai Bholenath!'**
  String get tvGreetShiva;

  /// No description provided for @tvGreetVishnu.
  ///
  /// In en, this message translates to:
  /// **'Jai Shri Hari!'**
  String get tvGreetVishnu;

  /// No description provided for @tvGreetDevi.
  ///
  /// In en, this message translates to:
  /// **'Jai Mata Di!'**
  String get tvGreetDevi;

  /// No description provided for @tvGreetGanesha.
  ///
  /// In en, this message translates to:
  /// **'Ganpati Bappa Morya!'**
  String get tvGreetGanesha;

  /// No description provided for @tvGreetHanuman.
  ///
  /// In en, this message translates to:
  /// **'Jai Bajrangbali!'**
  String get tvGreetHanuman;

  /// No description provided for @tvGreetSurya.
  ///
  /// In en, this message translates to:
  /// **'Jai Surya Dev!'**
  String get tvGreetSurya;

  /// No description provided for @tvGreetOther.
  ///
  /// In en, this message translates to:
  /// **'May your journey be blessed!'**
  String get tvGreetOther;

  /// No description provided for @tvRevealCard.
  ///
  /// In en, this message translates to:
  /// **'Reveal Your Card'**
  String get tvRevealCard;

  /// No description provided for @tvShareCard.
  ///
  /// In en, this message translates to:
  /// **'Share Card'**
  String get tvShareCard;

  /// No description provided for @tvShareCardText.
  ///
  /// In en, this message translates to:
  /// **'I just collected the {card} Sacred Card on MARG 🙏'**
  String tvShareCardText(Object card);

  /// No description provided for @tvShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t share right now. Please try again.'**
  String get tvShareFailed;

  /// No description provided for @tvTodayAt.
  ///
  /// In en, this message translates to:
  /// **'Today, {time}'**
  String tvTodayAt(Object time);

  /// No description provided for @tvPointsEarned.
  ///
  /// In en, this message translates to:
  /// **'+{points} Points'**
  String tvPointsEarned(Object points);

  /// No description provided for @tvRouteProgress.
  ///
  /// In en, this message translates to:
  /// **'Route Progress'**
  String get tvRouteProgress;

  /// No description provided for @tvTemplesOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total} temples completed'**
  String tvTemplesOfTotal(Object done, Object total);

  /// No description provided for @tvAway.
  ///
  /// In en, this message translates to:
  /// **'{distance} away'**
  String tvAway(Object distance);

  /// No description provided for @tvStampVerified.
  ///
  /// In en, this message translates to:
  /// **'Darshan Verified'**
  String get tvStampVerified;

  /// No description provided for @tvRouteCompleted.
  ///
  /// In en, this message translates to:
  /// **'You have completed every temple on {route}.'**
  String tvRouteCompleted(Object route);

  /// No description provided for @tvFromThisVisit.
  ///
  /// In en, this message translates to:
  /// **'From This Visit'**
  String get tvFromThisVisit;

  /// No description provided for @tvNextTempleNamed.
  ///
  /// In en, this message translates to:
  /// **'Next: {name}'**
  String tvNextTempleNamed(Object name);

  /// No description provided for @tvAlsoEarned.
  ///
  /// In en, this message translates to:
  /// **'Also Earned'**
  String get tvAlsoEarned;

  /// No description provided for @tvDestination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get tvDestination;

  /// No description provided for @tvCheckingInAt.
  ///
  /// In en, this message translates to:
  /// **'Checking in at'**
  String get tvCheckingInAt;

  /// No description provided for @tvLocationChecks.
  ///
  /// In en, this message translates to:
  /// **'Location Checks'**
  String get tvLocationChecks;

  /// No description provided for @tvVerificationChecks.
  ///
  /// In en, this message translates to:
  /// **'Verification Checks'**
  String get tvVerificationChecks;

  /// No description provided for @ntActivityIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Sacred Journey'**
  String get ntActivityIntroTitle;

  /// No description provided for @ntActivityIntroBody.
  ///
  /// In en, this message translates to:
  /// **'Every visit, card and milestone — as it happened.'**
  String get ntActivityIntroBody;

  /// No description provided for @exStatesIntro.
  ///
  /// In en, this message translates to:
  /// **'Temples across Bharat, state by state.'**
  String get exStatesIntro;

  /// No description provided for @exStatesStatus.
  ///
  /// In en, this message translates to:
  /// **'{states} states · {temples} temples'**
  String exStatesStatus(Object states, Object temples);

  /// No description provided for @exCollectionsIntro.
  ///
  /// In en, this message translates to:
  /// **'Temples grouped by what devotees seek most.'**
  String get exCollectionsIntro;

  /// No description provided for @exStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Exploration'**
  String get exStatsTitle;

  /// No description provided for @exStatsIntro.
  ///
  /// In en, this message translates to:
  /// **'Every verified darshan, across Bharat.'**
  String get exStatsIntro;

  /// No description provided for @exExploringSince.
  ///
  /// In en, this message translates to:
  /// **'Exploring since {date}'**
  String exExploringSince(Object date);

  /// No description provided for @exStatesVisited.
  ///
  /// In en, this message translates to:
  /// **'States Visited'**
  String get exStatesVisited;

  /// No description provided for @exCitiesVisited.
  ///
  /// In en, this message translates to:
  /// **'Cities Visited'**
  String get exCitiesVisited;

  /// No description provided for @exWhereYouveBeen.
  ///
  /// In en, this message translates to:
  /// **'Where You\'ve Been'**
  String get exWhereYouveBeen;

  /// No description provided for @exVisitsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} visits'**
  String exVisitsCount(Object count);

  /// No description provided for @exFromHere.
  ///
  /// In en, this message translates to:
  /// **'From Where You Are'**
  String get exFromHere;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
