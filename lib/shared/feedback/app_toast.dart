import 'package:flutter/material.dart';

import '../../app/theme/app_durations.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';
import 'app_snackbar.dart';

/// A lightweight top-of-screen toast rendered via the [Overlay], for brief
/// confirmations that shouldn't shift layout or depend on a [Scaffold]
/// messenger. For actionable messages prefer [AppSnackbar].
abstract final class AppToast {
  static void show(
    BuildContext context,
    String message, {
    FeedbackType type = FeedbackType.info,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: message,
        type: type,
        duration: duration,
      ),
    );
    overlay.insert(entry);
    Future<void>.delayed(duration + AppDurations.normal * 2, entry.remove);
  }
}

class _ToastWidget extends StatefulWidget {
  const _ToastWidget({
    required this.message,
    required this.type,
    required this.duration,
  });

  final String message;
  final FeedbackType type;
  final Duration duration;

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.normal,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
    Future<void>.delayed(widget.duration, () {
      if (mounted) _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  (IconData, Color) get _style => switch (widget.type) {
        FeedbackType.success => (AppIcons.success, context.colors.success),
        FeedbackType.error => (AppIcons.error, context.scheme.error),
        FeedbackType.warning => (AppIcons.warning, context.colors.warning),
        FeedbackType.info => (AppIcons.info, context.colors.info),
      };

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _style;
    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    return Positioned(
      top: context.viewPadding.top + AppSpacing.md,
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      child: IgnorePointer(
        child: FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.3),
              end: Offset.zero,
            ).animate(curved),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: context.scheme.inverseSurface,
                  borderRadius: AppRadius.control,
                  boxShadow: AppShadows.lg,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: color, size: 20),
                    const SizedBox(width: AppSpacing.md),
                    Flexible(
                      child: Text(
                        widget.message,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.scheme.onInverseSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
