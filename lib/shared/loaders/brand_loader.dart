import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/constants/brand_assets.dart';
import '../../app/theme/app_durations.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';

/// MARG's loader: the logo mark on a white disc, circled by a saffron-to-gold
/// arc. Used wherever the app waits on a whole screen or a blocking step
/// (page loads, the loading dialog, overlays). With reduced motion the arc
/// stays still. Small inline waits (buttons, "load more") keep their spinners.
class BrandLoader extends StatefulWidget {
  const BrandLoader({this.size = 76, this.message, super.key});

  /// Outer diameter of the ring.
  final double size;

  /// Optional caption under the loader (also the screen-reader label).
  final String? message;

  @override
  State<BrandLoader> createState() => _BrandLoaderState();
}

class _BrandLoaderState extends State<BrandLoader> with SingleTickerProviderStateMixin {
  /// One full turn of the arc.
  static const Duration _turn = Duration(milliseconds: 1400);

  late final AnimationController _spin = AnimationController(vsync: this, duration: _turn);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (still) {
      _spin.stop();
    } else if (!_spin.isAnimating) {
      _spin.repeat();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final ring = size * 0.06;
    final disc = size - ring * 3;
    final arc = _ArcPainter(
      start: context.scheme.primary,
      end: context.colors.gold,
      track: context.scheme.primary.withValues(alpha: 0.12),
      stroke: ring,
    );

    final loader = SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RotationTransition(turns: _spin, child: CustomPaint(size: Size.square(size), painter: arc)),
          Container(
            width: disc,
            height: disc,
            decoration: BoxDecoration(
              color: context.colors.card,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: context.scheme.secondary.withValues(alpha: 0.12),
                  blurRadius: ring * 3,
                  offset: Offset(0, ring),
                ),
              ],
            ),
            padding: EdgeInsets.all(disc * 0.2),
            child: Image.asset(
              BrandAssets.logoMark,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              excludeFromSemantics: true,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );

    final message = widget.message;
    return Semantics(
      label: message ?? MaterialLocalizations.of(context).modalBarrierDismissLabel,
      liveRegion: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          loader,
          if (message != null) ...[
            const Gap(AppSpacing.md),
            AnimatedSwitcher(
              duration: AppDurations.normal,
              child: Text(
                message,
                key: ValueKey(message),
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.withColor(context.colors.textSecondary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A faint full track with a bright arc fading from [start] to [end].
class _ArcPainter extends CustomPainter {
  const _ArcPainter({required this.start, required this.end, required this.track, required this.stroke});

  final Color start;
  final Color end;
  final Color track;
  final double stroke;

  /// Length of the bright arc (about 3/4 of the circle).
  static const double _sweep = math.pi * 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final circle = rect.deflate(stroke / 2);
    canvas.drawArc(
      circle,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = track
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    canvas.drawArc(
      circle,
      0,
      _sweep,
      false,
      Paint()
        ..shader = SweepGradient(
          endAngle: _sweep,
          colors: [end.withValues(alpha: 0), start, end],
          stops: const [0, 0.55, 1],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.start != start || old.end != end || old.track != track || old.stroke != stroke;
}
