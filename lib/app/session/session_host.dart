import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/location/location_access.dart';
import '../../features/explore/presentation/controllers/explore_controllers.dart';
import '../../features/home/presentation/controllers/home_controller.dart';
import '../../features/notifications/presentation/controllers/notification_controllers.dart';
import '../../features/notifications/presentation/controllers/push_messaging.dart';
import '../../features/notifications/presentation/widgets/notification_link.dart';
import '../../shared/design_system.dart';
import '../localization/app_localizations.dart';
import '../router/route_names.dart';

/// Signed-in session services that live with the app shell:
///  - the location ask, once per launch while access is missing;
///  - keeping the saved location fresh (Nearby Temples + daily nudges), and
///    reloading location-aware screens when access is first granted;
///  - push notifications: registration, opening a tapped notification, and
///    an in-app banner for one that arrives while the app is open.
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _start() async {
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

  Future<void> _onResume() async {
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
        : context.pushNamed(dest.routeName, pathParameters: dest.pathParameters);
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
