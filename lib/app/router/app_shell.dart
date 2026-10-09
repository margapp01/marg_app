import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/widgets/home_drawer.dart';
import '../../shared/design_system.dart';
import '../localization/app_localizations.dart';
import '../session/session_host.dart';

/// The persistent five-tab shell: Home · Explore · Yatra · Passport · Profile.
/// Each tab keeps its own navigation stack (state survives tab switches);
/// re-tapping the active tab pops it back to its root, and system Back at the
/// root of any other tab returns to Home. Back at Home asks before leaving
/// (Back once more exits). Hosts the app menu drawer so it covers the tab bar
/// too.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  /// Opens the app menu from any tab (Home's ☰).
  static void openMenu() => _scaffoldKey.currentState?.openDrawer();

  void _onTab(int index) => navigationShell.goBranch(
    index,
    initialLocation: index == navigationShell.currentIndex,
  );

  /// Reached only when Back has nothing left to pop inside the current tab.
  void _onBackAtTabRoot(BuildContext context, bool didPop) {
    if (didPop) return;
    final scaffold = _scaffoldKey.currentState;
    if (scaffold?.isDrawerOpen ?? false) {
      scaffold!.closeDrawer();
    } else if (navigationShell.currentIndex != _homeIndex) {
      navigationShell.goBranch(_homeIndex);
    } else {
      _confirmExit(context);
    }
  }

  static Future<void> _confirmExit(BuildContext context) async {
    final exit = await AppSheets.show<bool>(
      context,
      padded: false,
      builder: (_) => const _ExitSheet(),
    );
    if (exit ?? false) await SystemNavigator.pop();
  }

  static const int _homeIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => _onBackAtTabRoot(context, didPop),
      child: SessionHost(
        child: Scaffold(
          key: _scaffoldKey,
          drawer: const HomeDrawer(),
          body: navigationShell,
          bottomNavigationBar: AppBottomNav(
            currentIndex: navigationShell.currentIndex,
            onDestinationSelected: _onTab,
            items: [
              AppNavItem(icon: AppIcons.home, label: l10n.navHome),
              AppNavItem(icon: AppIcons.explore, label: l10n.navExplore),
              AppNavItem(icon: AppIcons.temple, label: l10n.navYatra),
              AppNavItem(icon: AppIcons.passport, label: l10n.navPassport),
              AppNavItem(icon: AppIcons.profile, label: l10n.navProfile),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Leaving so soon?" — Stay, Exit, or press Back again to exit. Tapping
/// outside or swiping it away keeps the pilgrim in the app.
class _ExitSheet extends StatelessWidget {
  const _ExitSheet();

  static const double _markSize = 64;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    void close({required bool exit}) => Navigator.of(context).pop(exit);
    return BackButtonListener(
      onBackButtonPressed: () async {
        close(exit: true);
        return true;
      },
      child: AppSheetLayout(
        actions: [
          AppButton.primary(
            label: l10n.navExitStay,
            onPressed: () => close(exit: false),
          ),
          AppButton.outlined(
            label: l10n.navExitConfirm,
            icon: AppIcons.logout,
            onPressed: () => close(exit: true),
          ),
        ],
        child: Column(
          children: [
            Image.asset(
              BrandAssets.logoMark,
              width: _markSize,
              height: _markSize,
              excludeFromSemantics: true,
            ).scaleIn(),
            const Gap(AppSpacing.md),
            Semantics(
              header: true,
              child: Text(
                l10n.navExitTitle,
                textAlign: TextAlign.center,
                style: context.displayText.titleLarge.withColor(
                  context.scheme.secondary,
                ),
              ),
            ),
            const Gap(AppSpacing.xs),
            Text(
              l10n.navExitMessage,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.withColor(
                context.colors.textSecondary,
              ),
            ),
            const Gap(AppSpacing.md),
            AppBadge(
              label: l10n.navExitBackHint,
              icon: AppIcons.back,
              tone: AppBadgeTone.gold,
            ),
          ],
        ),
      ),
    );
  }
}
