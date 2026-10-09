import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../shared/design_system.dart';
import '../controllers/auth_controller.dart';
import '../states/auth_state.dart';

/// Branded launch splash: the MARG wordmark, golden lotus ornament and tagline
/// glowing over the devotional sunrise backdrop (which settles in with a slow
/// zoom), a slim saffron loader and the "product by" credit. While it plays,
/// the session is restored; once both the brand moment has elapsed and the
/// session has resolved, it routes returning users straight to Home (or
/// onboarding), and everyone else to sign-in.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  Timer? _minTimer;
  bool _minElapsed = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // Restore any stored session; the guard/splash route once it resolves.
    Future.microtask(
      () => ref.read(authControllerProvider.notifier).restore(),
    );
    _minTimer = Timer(AppDurations.splash, () {
      _minElapsed = true;
      _maybeAdvance();
    });
  }

  @override
  void dispose() {
    _minTimer?.cancel();
    super.dispose();
  }

  /// Navigate once the brand moment has elapsed *and* the session is resolved.
  void _maybeAdvance() {
    if (!mounted || _navigated || !_minElapsed) return;
    final auth = ref.read(authControllerProvider);
    switch (auth.status) {
      case AuthStatus.unknown:
      case AuthStatus.authenticating:
        return; // still resolving — a later trigger will advance
      case AuthStatus.unauthenticated:
        _go(RouteNames.auth);
      case AuthStatus.needsMobile:
        _go(RouteNames.setup);
      case AuthStatus.authenticated:
        _go(auth.user?.isOnboarded == true
            ? RouteNames.home
            : RouteNames.setup);
    }
  }

  void _go(String name) {
    _navigated = true;
    context.goNamed(name);
  }

  @override
  Widget build(BuildContext context) {
    // When the session resolves after the brand timer, advance immediately.
    ref.listen(authControllerProvider, (_, _) => _maybeAdvance());

    final size = MediaQuery.sizeOf(context);
    final canvas = context.colors.splashCanvas;
    // Sit the credit low, just above the skyline border.
    final bottomGap = context.viewPadding.bottom + AppSpacing.huge;

    return Scaffold(
      backgroundColor: canvas,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Devotional sunrise backdrop, settling in with a slow zoom.
          _SettleIn(
            child: Image.asset(
              BrandAssets.splashBackground,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          // A cream wash over the upper sky so the brand block reads crisply,
          // fading out before the temple and the path.
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: size.height * _washFraction,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [canvas, canvas.withValues(alpha: 0.9), canvas.withValues(alpha: 0)],
                  stops: const [0, 0.55, 1],
                ),
              ),
            ),
          ),
          // Temple-skyline + lotus-border band along the bottom; its top half
          // is an alpha fade so it melts into the backdrop.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: size.height * _skylineFraction,
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (rect) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.white],
                stops: [0.0, 0.55],
              ).createShader(rect),
              child: Image.asset(
                BrandAssets.splashSkyline,
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                const _BrandBlock(),
                const Spacer(flex: 7),
                const _Loader().fadeIn(delay: AppDurations.counter),
                const Gap(AppSpacing.lg),
                const _Credit().fadeIn(delay: AppDurations.counter),
                SizedBox(height: bottomGap),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Share of the screen height covered by the cream wash / skyline band.
  static const double _washFraction = 0.46;
  static const double _skylineFraction = 0.22;
}

/// Wordmark, golden lotus ornament and tagline, on a soft saffron sun-glow.
class _BrandBlock extends StatelessWidget {
  const _BrandBlock();

  static const String _tagline = 'YOUR SACRED PATH.';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final wordmarkWidth = (width * 0.74).clamp(240.0, 380.0);
    final ornamentWidth = (width * 0.5).clamp(180.0, 280.0);
    final saffron = context.scheme.primary;
    return Stack(
      alignment: Alignment.center,
      children: [
        // Sun-glow: a blurred saffron halo behind the mark.
        Positioned.fill(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 0.6,
                  colors: [saffron.withValues(alpha: 0.16), saffron.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleIn(
                from: 0.88,
                duration: AppDurations.counter,
                child: BrandWordmark(width: wordmarkWidth.toDouble()),
              ),
              const Gap(AppSpacing.lg),
              Image.asset(BrandAssets.splashOrnament, width: ornamentWidth.toDouble(), excludeFromSemantics: true)
                  .fadeIn(delay: AppDurations.slow),
              const Gap(AppSpacing.md),
              Text(
                _tagline,
                textAlign: TextAlign.center,
                style: context.brandText.titleMedium.copyWith(
                  color: context.scheme.secondary,
                  letterSpacing: 4,
                ),
              ).slideIn(delay: AppDurations.slow + AppDurations.normal, from: const Offset(0, 12)),
            ],
          ),
        ),
      ],
    );
  }
}

/// A slim saffron progress line on a faint navy track — "the path is loading".
class _Loader extends StatelessWidget {
  const _Loader();

  static const double _width = 120;
  static const double _height = 3;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      child: ClipRRect(
        borderRadius: AppRadius.fullAll,
        child: LinearProgressIndicator(
          minHeight: _height,
          color: context.scheme.primary,
          backgroundColor: context.scheme.secondary.withValues(alpha: 0.12),
        ),
      ),
    );
  }
}

/// "A product by TechLuminix" on a soft, edgeless white cloud so it stays
/// legible over the skyline band.
class _Credit extends StatelessWidget {
  const _Credit();

  @override
  Widget build(BuildContext context) {
    final navy = context.scheme.secondary;
    final cloud = context.colors.card;
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 14),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 0.75,
                  colors: [cloud.withValues(alpha: 0.95), cloud.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.huge3, vertical: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('A PRODUCT BY', style: context.overline.copyWith(color: navy.withValues(alpha: 0.7))),
              const Gap(AppSpacing.xxs),
              Text('TechLuminix', style: context.brandText.titleMedium.copyWith(color: navy)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Plays a slow zoom-out (1.08 → 1) over the splash's brand moment; static
/// when the user asks for reduced motion.
class _SettleIn extends StatelessWidget {
  const _SettleIn({required this.child});

  final Widget child;

  static const double _startScale = 1.08;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: _startScale, end: 1),
      duration: AppDurations.splash,
      curve: AppCurves.standard,
      builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
      child: child,
    );
  }
}
