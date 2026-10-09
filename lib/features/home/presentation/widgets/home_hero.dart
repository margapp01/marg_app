import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';

/// The Home hero: a full-bleed temple photograph fading into the page, the
/// greeting in the display serif, the menu + notification bell, and the search
/// entry floating over the bottom edge.
class HomeHero extends StatelessWidget {
  const HomeHero({
    required this.name,
    required this.unread,
    required this.onMenu,
    required this.onNotifications,
    required this.onSearch,
    super.key,
  });

  final String? name;
  final int unread;
  final VoidCallback onMenu;
  final VoidCallback onNotifications;
  final VoidCallback onSearch;

  /// Half the search bar hangs below the photo.
  static const double _searchHeight = AppSearchBar.height;

  /// Hero tag shared with the Search screen's bar.
  static final String searchHeroTag = AppSearchBar.heroTagFor('home');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final top = context.viewPadding.top;
    final photoHeight = top + context.responsive(compact: 280.0, medium: 320.0, expanded: 360.0);
    final greeting = name == null || name!.isEmpty ? l10n.homeGreeting : l10n.homeGreetingNamed(name!);

    return SizedBox(
      height: photoHeight + _searchHeight / 2,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: photoHeight,
            child: ExcludeSemantics(
              child: Image.asset(
                BrandAssets.homeHero,
                fit: BoxFit.cover,
                alignment: const Alignment(0.55, 0),
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
          // Cream wash on the left keeps the greeting legible…
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: photoHeight,
            child: const DecoratedBox(decoration: BoxDecoration(gradient: AppGradients.heroFade)),
          ),
          // …and the photo melts into the page at the bottom.
          Positioned(
            left: 0,
            right: 0,
            top: photoHeight - 90,
            height: 90,
            child: const DecoratedBox(decoration: BoxDecoration(gradient: AppGradients.heroBottomFade)),
          ),
          Positioned(
            left: AppSpacing.xs,
            right: AppSpacing.xs,
            top: top,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(AppIcons.menu, color: context.scheme.secondary),
                  tooltip: l10n.homeMenu,
                  onPressed: onMenu,
                ),
                const Spacer(),
                NotificationBell(count: unread, onTap: onNotifications),
              ],
            ),
          ),
          Positioned(
            left: AppSpacing.lg,
            top: top + 60,
            width: context.screenSize.width * 0.58,
            child: FadeIn(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting 🙏',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.displayText.headlineMedium,
                  ),
                  const Gap(AppSpacing.sm),
                  Text(
                    l10n.homeTagline,
                    style: context.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: 0,
            height: _searchHeight,
            child: AppSearchBar(
              hint: l10n.homeSearchHint,
              onTap: onSearch,
              heroTag: searchHeroTag,
              trailing: SearchBarAction(icon: AppIcons.tune, tooltip: l10n.searchFilterTitle, onPressed: onSearch),
            ),
          ),
        ],
      ),
    );
  }
}
