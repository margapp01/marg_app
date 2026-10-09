import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/constants/brand_assets.dart';
import '../../core/extensions/context_extensions.dart';

/// Height ÷ width of the wide landscape scenes (mountains, lake, pedestal).
const double _landscape = 0.68;

/// Height ÷ width of the tall temple-arch scenes.
const double _arch = 1.03;

/// The illustrated scenes used by empty / offline / not-found states. Each
/// maps to one transparent watercolour asset in [BrandAssets] and records its
/// shape, so every scene renders at full size without layout jumps.
enum StateArt {
  journey(BrandAssets.stateJourney),
  noVisits(BrandAssets.stateNoVisits),
  bookmarks(BrandAssets.stateBookmarks),
  savedPlaces(BrandAssets.stateSavedPlaces),
  noResults(BrandAssets.stateNoResults),
  notFound(BrandAssets.stateNotFound),
  location(BrandAssets.stateLocation),
  notifications(BrandAssets.stateNotifications),
  certificates(BrandAssets.stateCertificates),
  collection(BrandAssets.stateCollection),
  error(BrandAssets.stateError),
  offline(BrandAssets.stateOffline, _arch),
  empty(BrandAssets.stateEmpty, _arch),
  comingSoon(BrandAssets.stateComingSoon, _arch),
  unexpected(BrandAssets.stateUnexpected, _arch),
  timeout(BrandAssets.stateTimeout, _arch),
  permission(BrandAssets.statePermission, _arch),
  cards(BrandAssets.stateCards, _arch),
  achievements(BrandAssets.stateAchievements, _arch),
  leaderboard(BrandAssets.stateLeaderboard, _arch),
  referrals(BrandAssets.stateReferrals, _arch),
  festivals(BrandAssets.stateFestivals, _arch),
  knowledge(BrandAssets.stateKnowledge, _arch);

  const StateArt(this.asset, [this.aspect = _landscape]);

  final String asset;

  /// Height ÷ width of the scene.
  final double aspect;
}

/// Renders a [StateArt] scene sized to the available width, capped so it
/// never crowds the copy on short or landscape screens.
class StateArtImage extends StatelessWidget {
  const StateArtImage(this.art, {super.key});

  final StateArt art;

  static const double _maxWidth = 340;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final byHeight = context.screenSize.height * 0.3 / art.aspect;
        final width = math.min(math.min(constraints.maxWidth, _maxWidth), byHeight);
        return ExcludeSemantics(
          child: Image.asset(
            art.asset,
            width: width,
            height: width * art.aspect,
            fit: BoxFit.contain,
            cacheWidth: (width * MediaQuery.devicePixelRatioOf(context)).round(),
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
