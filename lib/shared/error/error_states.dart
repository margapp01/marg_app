import 'package:flutter/widgets.dart';

import '../../app/theme/app_icons.dart';
import '../empty/state_art.dart';
import 'error_view.dart';

/// Ready-made error states for the app's common failure modes. Each wraps
/// [ErrorView] with the right icon/copy and an optional retry callback.

class OfflineError extends StatelessWidget {
  const OfflineError({this.onRetry, super.key});
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => ErrorView(
        art: StateArt.offline,
        icon: AppIcons.offline,
        title: 'You’re offline',
        message: 'Check your connection and try again.',
        onRetry: onRetry,
      );
}

class TimeoutError extends StatelessWidget {
  const TimeoutError({this.onRetry, super.key});
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => ErrorView(
        art: StateArt.timeout,
        icon: AppIcons.timer,
        title: 'This is taking too long',
        message: 'The request timed out. Please try again.',
        onRetry: onRetry,
      );
}

class ServerError extends StatelessWidget {
  const ServerError({this.onRetry, super.key});
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => ErrorView(
        art: StateArt.error,
        icon: AppIcons.cloudOff,
        title: 'Something went wrong',
        message: 'Our servers had a problem. Please try again shortly.',
        onRetry: onRetry,
      );
}

class UnknownError extends StatelessWidget {
  const UnknownError({this.onRetry, super.key});
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => ErrorView(
        art: StateArt.unexpected,
        icon: AppIcons.error,
        title: 'Unexpected error',
        message: 'Something didn’t work as expected. Please try again.',
        onRetry: onRetry,
      );
}

class PermissionDeniedError extends StatelessWidget {
  const PermissionDeniedError({this.message, this.onRetry, this.retryLabel, super.key});
  final String? message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) => ErrorView(
        art: StateArt.permission,
        icon: AppIcons.block,
        title: 'Permission needed',
        message: message ?? 'Grant the required permission to continue.',
        onRetry: onRetry,
        retryLabel: retryLabel ?? 'Open settings',
      );
}
