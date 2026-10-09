import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../core/location/location_service.dart';
import '../../../../shared/design_system.dart';
import '../../../directions/domain/route_plan.dart';
import '../../../routes/domain/entities/yatra_route.dart';
import '../controllers/temple_visit_controller.dart';
import '../widgets/visit_flow_phases.dart';
import '../widgets/visit_outcome_phases.dart';

/// Hosts the full temple-visit journey as a single-route state machine:
/// Navigate → Arrival → Check-in → Verifying → Success, or Failure. One
/// controller drives every phase.
///
/// Success is the summary and the visit's last stop: the card reveal,
/// passport stamp, achievement and next temple open from it on request, and
/// Back from any of them returns to it — kept alive underneath, so it never
/// replays its celebration or loses its scroll.
class TempleVisitPage extends ConsumerWidget {
  const TempleVisitPage({required this.slug, super.key});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(templeVisitControllerProvider(slug));
    final controller = ref.read(templeVisitControllerProvider(slug).notifier);
    final l10n = AppLocalizations.of(context);

    final phase = state.phase;
    return PopScope(
      // A reward screen goes back to the summary; verifying can't be left.
      canPop: !phase.opensFromSummary && phase != TempleVisitPhase.verifying,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) controller.backToSummary();
      },
      child: Scaffold(
        backgroundColor: context.scheme.surface,
        appBar: _appBar(context, l10n, phase),
        body: AnimatedSwitcher(
          duration: AppDurations.normal,
          switchInCurve: AppCurves.enter,
          switchOutCurve: AppCurves.exit,
          child: KeyedSubtree(
            // The summary and its reward screens share one subtree.
            key: ValueKey(phase.isReward ? TempleVisitPhase.success : phase),
            child: _body(context, ref, l10n, state, controller),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget? _appBar(BuildContext context, AppLocalizations l10n, TempleVisitPhase phase) {
    // Success and the card reveal are immersive (the reveal draws its own
    // header on the night sky).
    if (phase == TempleVisitPhase.success || phase == TempleVisitPhase.cardUnlock) return null;
    final title = switch (phase) {
      TempleVisitPhase.navigation => l10n.tvNavTitle,
      TempleVisitPhase.arrival => l10n.tvArrivalTitle,
      TempleVisitPhase.checkin => l10n.tvCheckinTitle,
      TempleVisitPhase.verifying => l10n.tvVerifyingTitle,
      TempleVisitPhase.passportUpdate => l10n.tvPassportBarTitle,
      TempleVisitPhase.achievement => l10n.tvAchievementBarTitle,
      TempleVisitPhase.continueJourney => l10n.tvContinueTitle,
      TempleVisitPhase.failure => l10n.tvFailureBarTitle,
      _ => l10n.tvTitle,
    };
    return AppBar(
      title: Text(title, style: context.textTheme.titleMedium?.semiBold.withColor(context.scheme.secondary)),
      centerTitle: true,
      // Verifying can't be interrupted.
      automaticallyImplyLeading: phase != TempleVisitPhase.verifying,
      // A reward screen always has Back (to the summary).
      leading: phase.opensFromSummary ? const BackButton() : null,
      backgroundColor: context.scheme.surface,
      elevation: 0,
    );
  }

  Widget _body(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    TempleVisitState state,
    TempleVisitController controller,
  ) {
    switch (state.phase) {
      case TempleVisitPhase.loading:
        return const LoadingView();
      case TempleVisitPhase.templeError:
        return ErrorView(title: l10n.tvErrorTitle, message: l10n.tvErrorBody, onRetry: controller.retryLoad);
      case TempleVisitPhase.navigation:
        return NavigationPhase(
          state: state,
          onStartNavigation: (mode) => _openDirections(context, state, mode),
          onArrived: controller.goToArrival,
        );
      case TempleVisitPhase.arrival:
        return ArrivalPhase(
          state: state,
          onCheckIn: controller.goToCheckin,
          onRefresh: controller.refreshLocation,
          onOpenSettings: () => ref.read(locationServiceProvider).openSettings(),
        );
      case TempleVisitPhase.checkin:
        return CheckinPhase(
          state: state,
          onConfirm: controller.submitCheckIn,
          onRefresh: controller.refreshLocation,
          onOpenSettings: () => ref.read(locationServiceProvider).openSettings(),
        );
      case TempleVisitPhase.verifying:
        return VerifyingPhase(state: state);
      case TempleVisitPhase.success:
      case TempleVisitPhase.cardUnlock:
      case TempleVisitPhase.passportUpdate:
      case TempleVisitPhase.achievement:
      case TempleVisitPhase.continueJourney:
        return _rewards(context, state, controller);
      case TempleVisitPhase.failure:
        final failure = state.failure;
        return FailurePhase(failure: failure!, onRetry: controller.retryCheckIn, onGoBack: () => _pop(context));
    }
  }

  /// The success summary, with the reward screen the devotee opened (if
  /// any) laid over it — the summary stays mounted underneath, paused and
  /// out of reach until it's back on top.
  Widget _rewards(BuildContext context, TempleVisitState state, TempleVisitController controller) {
    final onSummary = state.phase == TempleVisitPhase.success;
    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          ignoring: !onSummary,
          child: ExcludeSemantics(
            excluding: !onSummary,
            child: TickerMode(
              enabled: onSummary,
              child: SuccessPhase(state: state, onOpen: controller.openReward, onDone: () => _pop(context)),
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: AppDurations.normal,
          switchInCurve: AppCurves.enter,
          switchOutCurve: AppCurves.exit,
          child: onSummary
              ? const SizedBox.shrink()
              : ColoredBox(
                  key: ValueKey(state.phase),
                  color: context.scheme.surface,
                  child: _reward(context, state, controller),
                ),
        ),
      ],
    );
  }

  Widget _reward(BuildContext context, TempleVisitState state, TempleVisitController controller) {
    switch (state.phase) {
      case TempleVisitPhase.cardUnlock:
        final card = state.result?.rewards.card;
        if (card == null) return const SizedBox.shrink();
        return CardUnlockPhase(
          card: card,
          animate: !state.cardSeen,
          onBack: controller.backToSummary,
          onViewCollection: () => _pushTo(context, RouteNames.cards),
          onDone: () => _pop(context),
        );
      case TempleVisitPhase.passportUpdate:
        return PassportUpdatePhase(state: state, onViewPassport: () => _leaveTo(context, RouteNames.passport));
      case TempleVisitPhase.achievement:
        return AchievementPhase(state: state, onViewAll: () => _pushTo(context, RouteNames.achievements));
      case TempleVisitPhase.continueJourney:
        return ContinueJourneyPhase(
          state: state,
          onNavigateNext: (nextSlug, temple) => _navigateNext(context, nextSlug, temple),
          onViewRoute: (routeSlug) => routeSlug == null
              ? _pushTo(context, RouteNames.routes)
              : context.pushNamed(RouteNames.routeDetail, pathParameters: {RoutePaths.routeSlugParam: routeSlug}),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _leaveTo(BuildContext context, String routeName) => context.goNamed(routeName);
  void _pushTo(BuildContext context, String routeName) => context.pushNamed(routeName);
  void _pop(BuildContext context) => context.canPop() ? context.pop() : context.goNamed(RouteNames.home);

  /// In-app directions in the chosen [mode]; on arrival "Check in" returns
  /// here.
  void _openDirections(BuildContext context, TempleVisitState state, TravelMode mode) {
    final temple = state.temple;
    if (temple == null) return;
    context.pushNamed(
      RouteNames.directions,
      extra: DirectionsArgs(
        name: temple.name,
        latitude: temple.latitude,
        longitude: temple.longitude,
        place: temple.location,
        imageUrl: temple.imageUrl,
        templeSlug: temple.slug,
        returnOnArrival: true,
        initialMode: mode,
      ),
    );
  }

  /// Straight into directions to the route's next temple (its own page when
  /// the route's details didn't load).
  void _navigateNext(BuildContext context, String slug, RouteTempleInfo? temple) {
    if (temple == null) {
      context.pushReplacementNamed(RouteNames.templeDetail, pathParameters: {RoutePaths.templeIdParam: slug});
      return;
    }
    context.pushReplacementNamed(
      RouteNames.directions,
      extra: DirectionsArgs(
        name: temple.name,
        latitude: temple.latitude,
        longitude: temple.longitude,
        place: temple.location,
        imageUrl: temple.imageUrl,
        templeSlug: slug,
      ),
    );
  }
}
