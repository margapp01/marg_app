import 'package:flutter/material.dart';

import '../../app/theme/app_durations.dart';
import '../images/brand_logo.dart';

/// A centred circular spinner with an optional [size] and [color].
class CircularLoader extends StatelessWidget {
  const CircularLoader({
    this.size = 28,
    this.color,
    this.strokeWidth = 3,
    super.key,
  });

  final double size;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) => Center(
    child: SizedBox.square(
      dimension: size,
      child: CircularProgressIndicator(strokeWidth: strokeWidth, color: color),
    ),
  );
}

/// A slim indeterminate progress bar (top-of-content loading).
class LinearLoader extends StatelessWidget {
  const LinearLoader({this.color, super.key});

  final Color? color;

  @override
  Widget build(BuildContext context) =>
      LinearProgressIndicator(minHeight: 3, color: color);
}

/// A premium branded loader — the MARG logo gently pulsing. Use for full-screen
/// waits (splash, first load) where a plain spinner feels too utilitarian.
class AnimatedLoader extends StatefulWidget {
  const AnimatedLoader({this.size = 44, super.key});

  final double size;

  @override
  State<AnimatedLoader> createState() => _AnimatedLoaderState();
}

class _AnimatedLoaderState extends State<AnimatedLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.shimmer,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.5, end: 1).animate(_controller),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.04).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
          ),
          child: BrandLogo(size: widget.size),
        ),
      ),
    );
  }
}
