import 'package:flutter/widgets.dart';

import '../../app/theme/app_curves.dart';
import '../../app/theme/app_durations.dart';

/// Reusable page transitions. Pair with go_router's `CustomTransitionPage` so
/// navigation motion is consistent (calm fade-through, or a gentle rise).
abstract final class AppPageTransitions {
  /// Cross-fade with a subtle upward drift — the app default.
  static Widget fadeThrough(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(parent: animation, curve: AppCurves.standard);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.02),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }

  /// Full-height slide-up — modals, detail pushes that feel like sheets.
  static Widget slideUp(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(parent: animation, curve: AppCurves.enter);
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(curved),
      child: child,
    );
  }

  static const Duration duration = AppDurations.normal;
}
