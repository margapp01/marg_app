import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/constants/app_constants.dart';
import '../../../../shared/design_system.dart';
import 'card_widgets.dart';

/// The back of every Sacred Card: night-blue with a gold mandala, the lotus
/// emblem and the MARG mark, in the same gilt frame as the face.
class SacredCardBack extends StatelessWidget {
  const SacredCardBack({super.key});

  @override
  Widget build(BuildContext context) {
    final gold = context.colors.gold;
    return GiltFrame(
      accent: gold,
      large: true,
      aspectRatio: SacredCardFace.aspect,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.night),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _MandalaPainter(color: gold)),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CardEmblem(size: 72),
                const Gap(AppSpacing.md),
                Text(
                  AppConstants.appName,
                  style: context.brandText.titleMedium.copyWith(color: gold, letterSpacing: 6),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Concentric dotted rings and petals — the card back's mandala.
class _MandalaPainter extends CustomPainter {
  const _MandalaPainter({required this.color});

  final Color color;

  static const int _petals = 16;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final maxR = size.shortestSide * 0.46;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color.withValues(alpha: 0.28);
    final dot = Paint()..color = color.withValues(alpha: 0.35);

    for (final f in const [0.45, 0.7, 1.0]) {
      canvas.drawCircle(c, maxR * f, line);
    }
    for (var i = 0; i < _petals; i++) {
      final a = i * 2 * math.pi / _petals;
      final inner = c + Offset(math.cos(a), math.sin(a)) * maxR * 0.45;
      final outer = c + Offset(math.cos(a), math.sin(a)) * maxR * 0.7;
      final mid = a + math.pi / _petals;
      final tip = c + Offset(math.cos(mid), math.sin(mid)) * maxR;
      canvas.drawLine(inner, outer, line);
      canvas.drawLine(outer, tip, line);
      canvas.drawCircle(tip, 1.8, dot);
    }
  }

  @override
  bool shouldRepaint(_MandalaPainter old) => old.color != color;
}

/// The unlock moment: the card rises face-down, gathers light, flips with a
/// flash and lands face-up — then floats with a sheen passing over it.
/// [onRevealed] fires as the face turns into view (cue for sparkles, the
/// rarity banner and a haptic tap). With reduced motion — or [animate] off,
/// for a card already revealed — the face shows at once and [onRevealed]
/// fires after the first frame.
class CardReveal extends StatefulWidget {
  const CardReveal({required this.front, this.onRevealed, this.animate = true, super.key});

  /// The card face (usually a [SacredCardFace]).
  final Widget front;
  final VoidCallback? onRevealed;
  final bool animate;

  @override
  State<CardReveal> createState() => _CardRevealState();
}

class _CardRevealState extends State<CardReveal> with SingleTickerProviderStateMixin {
  static const Duration _duration = Duration(milliseconds: 2400);

  // The beats of the reveal, as fractions of [_duration].
  static const Interval _rise = Interval(0, 0.25, curve: AppCurves.pop);
  static const Interval _charge = Interval(0.25, 0.42);
  static const Interval _flip = Interval(0.42, 0.66, curve: AppCurves.emphasize);
  static const Interval _flash = Interval(0.46, 0.76);
  static const Interval _settle = Interval(0.66, 1, curve: Curves.elasticOut);

  /// Point of the flip where the face turns into view.
  static const double _faceUp = 0.54;
  static const double _wobble = 0.05;

  late final AnimationController _controller = AnimationController(vsync: this, duration: _duration);
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_watchFlip);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.status != AnimationStatus.dismissed) return;
    if (!widget.animate || MediaQuery.of(context).disableAnimations) {
      // Jump to the face without the flip listener firing mid-build; announce
      // the reveal once the frame is done.
      _controller
        ..removeListener(_watchFlip)
        ..value = 1;
      WidgetsBinding.instance.addPostFrameCallback((_) => _reveal(haptic: widget.animate));
    } else {
      _controller.forward();
    }
  }

  void _watchFlip() {
    if (!_revealed && _controller.value >= _faceUp) _reveal();
  }

  void _reveal({bool haptic = true}) {
    if (_revealed || !mounted) return;
    _revealed = true;
    if (haptic) HapticFeedback.mediumImpact();
    widget.onRevealed?.call();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final rise = _rise.transform(t);
        final charge = _charge.transform(t);
        final flip = _flip.transform(t);
        // A burst of light that peaks as the face turns up.
        final flash = math.sin(_flash.transform(t) * math.pi);
        final done = t >= 1;
        final settle = _settle.transform(t);

        final faceUp = t >= _faceUp;
        final angle = flip * math.pi;
        final wobble = math.sin(charge * math.pi * 4) * _wobble * (1 - charge);
        // Lift while flipping, then land with a little spring.
        final scale = (0.6 + 0.4 * rise) * (1 + 0.08 * math.sin(flip * math.pi)) * (faceUp ? 0.96 + 0.04 * settle : 1);

        final face = faceUp
            ? Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..rotateY(math.pi),
                child: done ? LightSweep(borderRadius: AppRadius.lgAll, child: widget.front) : widget.front,
              )
            : const SacredCardBack();

        return Opacity(
          opacity: rise.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, 40 * (1 - rise)),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateZ(wobble)
                ..rotateY(angle)
                ..scaleByDouble(scale, scale, 1, 1),
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  face,
                  if (flash > 0)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: AppRadius.lgAll,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.9 * flash),
                                Colors.white.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
