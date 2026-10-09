import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/profile/presentation/controllers/profile_controllers.dart';
import 'localization/app_localizations.dart';
import 'localization/locale_provider.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/app_typography.dart';

/// Root widget: wires router, theme, and localization together.
class MargApp extends ConsumerWidget {
  const MargApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final localeOverride = ref.watch(localeControllerProvider);
    // Honor the user's "Reduce Animations" preference app-wide (real effect).
    final reduceAnimations = ref.watch(appPreferencesProvider).valueOrNull?.reduceAnimations ?? false;

    return MaterialApp.router(
      routerConfig: router,
      theme: AppTheme.light,
      // Dark mode (V2): set darkTheme + themeMode here; tokens/extensions
      // are already structured for it.
      locale: localeOverride, // null → follow device locale
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      // Responsive + accessible type: scale every text style by device size ×
      // the user's text-scale setting (clamped for readability). Applied once
      // here so widgets never touch textScaler themselves.
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: AppTypography.responsiveTextScaler(context),
          disableAnimations: reduceAnimations || MediaQuery.of(context).disableAnimations,
        ),
        child: child!,
      ),
    );
  }
}
