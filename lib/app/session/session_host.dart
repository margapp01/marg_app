import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/location/location_access.dart';
import '../../core/services/connectivity_service.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/explore/presentation/controllers/explore_controllers.dart';
import '../../features/home/presentation/controllers/home_controller.dart';
import '../../features/notifications/presentation/controllers/notification_controllers.dart';
import '../../features/notifications/presentation/controllers/push_messaging.dart';
import '../../features/notifications/presentation/widgets/notification_link.dart';
import '../../features/referrals/data/referral_attribution.dart';
import '../../features/temple_detail/presentation/controllers/temple_detail_controller.dart';
import '../../features/temple_visit/data/offline_checkins.dart';
import '../../shared/design_system.dart';
import '../localization/app_localizations.dart';
import '../router/app_navigation.dart';
import '../router/route_names.dart';
import '../router/web_links.dart';

/// Signed-in session services that live with the app shell:
///  - opening a shared link that arrived before sign-in, and crediting the
///    friend whose invite brought a new pilgrim;
///  - the location ask, once per launch while access is missing;
///  - keeping the saved location fresh (Nearby Temples + daily nudges), and
///    reloading location-aware screens when access is first granted;
///  - push notifications: registration, opening a tapped notification, and
///    an in-app banner for one that arrives while the app is open;
///  - submitting check-ins saved without network at a shrine — on launch, on
///    resume and when the network returns — and saying how each one went.
class SessionHost extends ConsumerStatefulWidget {
  const SessionHost({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<SessionHost> createState() => _SessionHostState();
}

class _SessionHostState extends ConsumerState<SessionHost> {
  late final AppLifecycleListener _lifecycle;
  bool _asked = false;
  bool _granted = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _onResume);
    ref.listenManual<AsyncValue<bool>>(connectivityStatusProvider, (prev, next) {
      if (next.valueOrNull == true && prev?.valueOrNull == false) unawaited(_syncOfflineCheckins());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    _openPendingLink();
    unawaited(_creditReferral());
    unawaited(_syncOfflineCheckins());
    final access = await ref.read(locationAccessProvider.future);
    _granted = access == LocationAccess.granted;
    if (!mounted) return;
    if (!_granted && !_asked) {
      _asked = true;
      // The system dialogs first; the explainer sheet only if they didn't land.
      final asked = await ref.read(locationAccessProvider.notifier).askDirectly();
      if (asked != LocationAccess.granted && mounted) await LocationPermissionSheet.show(context);
      _noteAccess(ref.read(locationAccessProvider).valueOrNull ?? asked);
    }
    unawaited(_syncLocation());
    if (!mounted) return;
    await ref.read(pushMessagingProvider).start(onOpen: _open, onForeground: _banner);
  }

  void _openPendingLink() {
    final link = ref.read(pendingWebLinkProvider);
    if (link == null || !mounted) return;
    ref.read(pendingWebLinkProvider.notifier).state = null;
    context.go(link);
  }

  Future<void> _creditReferral() async {
    try {
      final attribution = ref.read(referralAttributionProvider);
      await attribution.captureInstallReferrer();
      await attribution.applyPending(joinedAt: ref.read(authControllerProvider).user?.onboardingCompletedAt);
    } catch (_) {/* best-effort; retried next launch */}
  }

  Future<void> _onResume() async {
    unawaited(_syncOfflineCheckins());
    _noteAccess(await ref.read(locationAccessProvider.notifier).refresh());
    await _syncLocation();
  }

  /// Reloads location-aware screens the first time access turns on.
  void _noteAccess(LocationAccess access) {
    final granted = access == LocationAccess.granted;
    if (granted && !_granted) _reloadLocationAware();
    _granted = granted;
  }

  Future<void> _syncLocation() async {
    if (ref.read(locationAccessProvider).valueOrNull != LocationAccess.granted) return;
    await ref.read(locationSyncProvider).syncIfStale();
  }

  Future<void> _syncOfflineCheckins() async {
    final userId = ref.read(authControllerProvider).user?.id;
    if (userId == null) return;
    final List<OfflineSyncOutcome> outcomes;
    try {
      outcomes = await ref.read(offlineCheckinSyncProvider).run(userId);
    } catch (_) {
      return; // Still saved; retried on the next launch, resume or reconnect.
    }
    if (outcomes.isEmpty || !mounted) return;
    ref.invalidate(homeControllerProvider);
    final l10n = AppLocalizations.of(context);
    for (final o in outcomes) {
      final temple = o.checkin.templeName;
      if (o.checkin.slug.isNotEmpty) ref.invalidate(templeDetailControllerProvider(o.checkin.slug));
      switch (o.result) {
        case OfflineSyncResult.verified:
          AppSnackbar.success(context, l10n.tvOfflineVerified(temple));
        case OfflineSyncResult.notVerified:
          AppSnackbar.info(context, l10n.tvOfflineNotVerified(temple));
        case OfflineSyncResult.rejected:
          AppSnackbar.warning(context, l10n.tvOfflineRejected(temple, o.message ?? ''));
        case OfflineSyncResult.expired:
          AppSnackbar.warning(context, l10n.tvOfflineExpired(temple));
      }
    }
  }

  void _reloadLocationAware() {
    ref
      ..invalidate(homeControllerProvider)
      ..invalidate(exploreLocationProvider);
  }

  void _open(RemoteMessage message) {
    if (!mounted) return;
    final dest = resolveLink(
      actionUrl: message.data['actionUrl'] as String?,
      screen: message.data['screen'] as String?,
    );
    dest == null
        ? context.pushNamed(RouteNames.notifications)
        : context.openNamed(dest.routeName, pathParameters: dest.pathParameters);
  }

  void _banner(RemoteMessage message) {
    ref
      ..invalidate(unreadCountProvider)
      ..invalidate(notificationFeedProvider);
    final title = message.notification?.title;
    if (!mounted || title == null) return;
    AppSnackbar.info(
      context,
      title,
      actionLabel: AppLocalizations.of(context).ntOpen,
      onAction: () => _open(message),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
