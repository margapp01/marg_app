import 'package:flutter/material.dart';

import '../../app/theme/app_curves.dart';
import '../../app/theme/app_durations.dart';
import '../../app/theme/app_spacing.dart';
import '../components/app_card.dart';

/// A tappable [AppCard] that gives tactile press feedback (a subtle scale-down
/// while held). Use for prominent, tap-forward cards — temple tiles, featured
/// items — where the press should feel physical.
class AnimatedCard extends StatefulWidget {
  const AnimatedCard({
    required this.child,
    required this.onTap,
    this.padding,
    this.variant = AppCardVariant.elevated,
    super.key,
  });

  final Widget child;
  final VoidCallback onTap;
  final EdgeInsetsGeometry? padding;
  final AppCardVariant variant;

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (mounted) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: AppDurations.fast,
        curve: AppCurves.standard,
        child: AppCard(
          variant: widget.variant,
          padding: widget.padding ?? AppSpacing.allLg,
          child: widget.child,
        ),
      ),
    );
  }
}
