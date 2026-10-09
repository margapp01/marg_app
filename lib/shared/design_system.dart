/// MARG design system — one import for the entire reusable UI foundation.
///
/// ```dart
/// import 'package:marg_app/shared/design_system.dart';
/// ```
///
/// Exposes design tokens (colours, type, spacing, radius, shadows, icons,
/// motion, breakpoints), the `context` theme extensions, and every shared
/// widget: buttons, inputs, cards, badges, chips, tiles, dividers, dialogs,
/// sheets, feedback, loaders, empty/error states, app bars, navigation,
/// images, animations, and the app scaffold.
///
/// Prefer this barrel in feature code. Feature widgets should never re-implement
/// anything exported here — extend or configure it instead.
library;

// Tokens & theme
export '../app/constants/brand_assets.dart';
export '../app/theme/theme.dart';
export '../core/extensions/context_extensions.dart';

// Animation utilities
export 'animations/animations.dart';

// Components
export 'app_bar/app_bar.dart';
export 'badges/badges.dart';
export 'buttons/buttons.dart';
export 'cards/cards.dart';
export 'charts/trend_chart.dart';
export 'chips/chips.dart';
export 'components/app_scaffold.dart';
export 'components/crowd.dart';
export 'components/deity.dart';
export 'components/gilt_frame.dart';
export 'components/gold_seal.dart';
export 'components/journey_rail_tile.dart';
export 'components/leaderboard_podium.dart';
export 'components/pilgrim_hero.dart';
export 'components/rank_tier.dart';
export 'components/rarity.dart';
export 'components/section_header.dart';
export 'components/share_image.dart';
export 'components/sunburst_frame.dart';
export 'content/html_content_view.dart';
export 'dialogs/dialogs.dart';
export 'dividers/dividers.dart';
export 'empty/empty.dart';
export 'error/error.dart';
export 'feedback/feedback.dart';
export 'images/images.dart';
export 'inputs/inputs.dart';
export 'loaders/loaders.dart';
export 'maps/bharat_map.dart';
export 'maps/photo_pin.dart';
export 'maps/you_are_here.dart';
export 'navigation/navigation.dart';
export 'sheets/sheets.dart';
export 'tiles/tiles.dart';
