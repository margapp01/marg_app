import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

/// The single icon vocabulary for the app — **Material Symbols Rounded**.
///
/// Reference icons by semantic name (`AppIcons.temple`), never by raw
/// [Symbols] constants at call sites, so the visual language stays consistent
/// and swaps happen in one place. Render with the shared `AppIcon` widget.
abstract final class AppIcons {
  // ── Navigation / structure ────────────────────────────────────────────
  static const IconData home = Symbols.home_rounded;
  static const IconData explore = Symbols.explore_rounded;
  static const IconData map = Symbols.map_rounded;
  static const IconData mic = Symbols.mic_rounded;
  static const IconData trending = Symbols.trending_up_rounded;
  static const IconData trendingDown = Symbols.trending_down_rounded;
  static const IconData history = Symbols.history_rounded;
  static const IconData article = Symbols.article_rounded;
  static const IconData help = Symbols.help_rounded;
  static const IconData support = Symbols.support_agent_rounded;
  static const IconData description = Symbols.description_rounded;
  static const IconData profile = Symbols.person_rounded;
  static const IconData settings = Symbols.settings_rounded;
  static const IconData menu = Symbols.menu_rounded;
  static const IconData back = Symbols.arrow_back_ios_new_rounded;
  static const IconData forward = Symbols.chevron_right_rounded;
  static const IconData arrowForward = Symbols.arrow_forward_rounded;
  static const IconData chevronRight = Symbols.chevron_right_rounded;
  static const IconData chevronLeft = Symbols.chevron_left_rounded;
  static const IconData expandMore = Symbols.expand_more_rounded;
  static const IconData expandLess = Symbols.expand_less_rounded;
  static const IconData close = Symbols.close_rounded;
  static const IconData more = Symbols.more_vert_rounded;

  // ── Actions ───────────────────────────────────────────────────────────
  static const IconData search = Symbols.search_rounded;
  static const IconData filter = Symbols.filter_list_rounded;
  static const IconData sort = Symbols.sort_rounded;
  static const IconData add = Symbols.add_rounded;
  static const IconData edit = Symbols.edit_rounded;
  static const IconData delete = Symbols.delete_rounded;
  static const IconData share = Symbols.share_rounded;
  static const IconData refresh = Symbols.refresh_rounded;
  static const IconData check = Symbols.check_rounded;
  static const IconData doneAll = Symbols.done_all_rounded;
  static const IconData logout = Symbols.logout_rounded;
  static const IconData login = Symbols.login_rounded;
  static const IconData camera = Symbols.photo_camera_rounded;
  static const IconData gallery = Symbols.photo_library_rounded;
  static const IconData upload = Symbols.upload_rounded;
  static const IconData copy = Symbols.content_copy_rounded;
  static const IconData qrScan = Symbols.qr_code_scanner_rounded;

  // ── Feedback / status ─────────────────────────────────────────────────
  static const IconData success = Symbols.check_circle_rounded;
  static const IconData unchecked = Symbols.radio_button_unchecked_rounded;
  static const IconData warning = Symbols.warning_rounded;
  static const IconData info = Symbols.info_rounded;
  static const IconData error = Symbols.error_rounded;
  static const IconData verified = Symbols.verified_rounded;
  static const IconData shield = Symbols.shield_rounded;

  // ── Inputs ────────────────────────────────────────────────────────────
  static const IconData visibility = Symbols.visibility_rounded;
  static const IconData visibilityOff = Symbols.visibility_off_rounded;
  static const IconData lock = Symbols.lock_rounded;
  static const IconData mail = Symbols.mail_rounded;
  static const IconData phone = Symbols.phone_rounded;
  static const IconData smartphone = Symbols.smartphone_rounded;
  static const IconData calendar = Symbols.calendar_month_rounded;
  static const IconData language = Symbols.language_rounded;

  // ── Preferences / notification channels ───────────────────────────────
  static const IconData units = Symbols.straighten_rounded;
  static const IconData palette = Symbols.palette_rounded;
  static const IconData motion = Symbols.animation_rounded;
  static const IconData dataSaver = Symbols.data_saver_on_rounded;
  static const IconData imageQuality = Symbols.high_quality_rounded;
  static const IconData pushNotification = Symbols.notifications_active_rounded;

  // ── MARG domain ───────────────────────────────────────────────────────
  static const IconData temple = Symbols.temple_hindu_rounded;
  static const IconData passport = Symbols.book_rounded;
  static const IconData visit = Symbols.where_to_vote_rounded;
  static const IconData route = Symbols.route_rounded;
  static const IconData card = Symbols.style_rounded;
  static const IconData achievement = Symbols.emoji_events_rounded;
  static const IconData leaderboard = Symbols.leaderboard_rounded;
  static const IconData referral = Symbols.card_giftcard_rounded;
  static const IconData trustScore = Symbols.workspace_premium_rounded;
  static const IconData points = Symbols.stars_rounded;
  static const IconData nearby = Symbols.near_me_rounded;
  static const IconData crowd = Symbols.groups_rounded;
  static const IconData location = Symbols.location_on_rounded;
  static const IconData myLocation = Symbols.my_location_rounded;
  static const IconData navigation = Symbols.navigation_rounded;
  static const IconData openExternal = Symbols.open_in_new_rounded;
  static const IconData fitRoute = Symbols.fit_screen_rounded;
  static const IconData stepsList = Symbols.format_list_numbered_rounded;
  static const IconData car = Symbols.directions_car_rounded;
  static const IconData walk = Symbols.directions_walk_rounded;
  static const IconData turnLeft = Symbols.turn_left_rounded;
  static const IconData turnRight = Symbols.turn_right_rounded;
  static const IconData turnSlightLeft = Symbols.turn_slight_left_rounded;
  static const IconData turnSlightRight = Symbols.turn_slight_right_rounded;
  static const IconData straight = Symbols.straight_rounded;
  static const IconData uTurn = Symbols.u_turn_left_rounded;
  static const IconData roundabout = Symbols.roundabout_right_rounded;
  static const IconData flag = Symbols.flag_rounded;
  static const IconData directions = Symbols.directions_rounded;
  static const IconData category = Symbols.category_rounded;
  static const IconData layers = Symbols.layers_rounded;
  static const IconData tune = Symbols.tune_rounded;
  static const IconData publicMap = Symbols.public_rounded;
  static const IconData pandit = Symbols.self_improvement_rounded;
  static const IconData aarti = Symbols.local_fire_department_rounded;
  static const IconData notifications = Symbols.notifications_rounded;
  static const IconData favorite = Symbols.favorite_rounded;
  static const IconData star = Symbols.star_rounded;
  static const IconData starHalf = Symbols.star_half_rounded;
  static const IconData parking = Symbols.local_parking_rounded;
  static const IconData checkroom = Symbols.checkroom_rounded;
  static const IconData restaurant = Symbols.restaurant_rounded;
  static const IconData hotel = Symbols.hotel_rounded;
  static const IconData rule = Symbols.rule_rounded;
  static const IconData season = Symbols.wb_sunny_rounded;

  // ── Knowledge Hub ─────────────────────────────────────────────────────
  static const IconData blog = Symbols.menu_book_rounded;
  static const IconData festival = Symbols.celebration_rounded;
  static const IconData announcement = Symbols.campaign_rounded;
  static const IconData quote = Symbols.format_quote_rounded;
  static const IconData bookmark = Symbols.bookmark_rounded;
  static const IconData faq = Symbols.quiz_rounded;
  static const IconData today = Symbols.today_rounded;
  static const IconData maintenance = Symbols.build_rounded;

  // ── Connectivity / empty ──────────────────────────────────────────────
  static const IconData offline = Symbols.wifi_off_rounded;
  static const IconData cloudOff = Symbols.cloud_off_rounded;
  static const IconData timer = Symbols.schedule_rounded;
  static const IconData block = Symbols.block_rounded;
  static const IconData inbox = Symbols.inbox_rounded;
  static const IconData brokenImage = Symbols.broken_image_rounded;
  static const IconData lotus = Symbols.spa_rounded;

  // ── Onboarding ────────────────────────────────────────────────────────
  static const IconData male = Symbols.male_rounded;
  static const IconData female = Symbols.female_rounded;
  static const IconData genderOther = Symbols.transgender_rounded;
  static const IconData preferNotToSay = Symbols.do_not_disturb_on_rounded;
  static const IconData sun = Symbols.sunny_rounded;
}
