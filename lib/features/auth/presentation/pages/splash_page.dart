import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../shared/design_system.dart';
import '../controllers/auth_controller.dart';
import '../states/auth_state.dart';

/// Minimal launch splash: the MARG wordmark rising out of a softly breathing
/// saffron glow on the brand cream (the same colour as the native launch
/// screen, so there is no jump), with the golden lotus ornament and tagline
/// following in, a slim loader and the "product by" credit. While it plays,
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
    Future.microtask(() => ref.read(authControllerProvider.notifier).restore());
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
      case AuthStatus.needsRegistration:
        _go(RouteNames.setup);
      case AuthStatus.authenticated:
        _go(auth.user?.isOnboarded == true ? RouteNames.home : RouteNames.setup);
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

    return Scaffold(
      backgroundColor: context.colors.splashCanvas,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              const Spacer(flex: 5),
              const _BrandBlock(),
              const Spacer(flex: 6),
              const _Loader().fadeIn(delay: AppDurations.counter),
              const Gap(AppSpacing.lg),
              const _Credit().fadeIn(delay: AppDurations.counter),
              const Gap(AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

/// Wordmark, golden lotus ornament and tagline over a breathing sun-glow.
class _BrandBlock extends StatelessWidget {
  const _BrandBlock();

  static const String _tagline = 'YOUR SACRED PATH.';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final wordmarkWidth = (width * 0.7).clamp(240.0, 360.0);
    final ornamentWidth = (width * 0.46).clamp(170.0, 260.0);
    return Stack(
      alignment: Alignment.center,
      children: [
        const Positioned.fill(child: _BreathingGlow()),
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
              Image.asset(
                BrandAssets.splashOrnament,
                width: ornamentWidth.toDouble(),
                excludeFromSemantics: true,
              ).fadeIn(delay: AppDurations.slow),
              const Gap(AppSpacing.md),
              Text(
                _tagline,
                textAlign: TextAlign.center,
                style: context.brandText.titleMedium.copyWith(color: context.scheme.secondary, letterSpacing: 4),
              ).slideIn(delay: AppDurations.slow + AppDurations.normal, from: const Offset(0, 12)),
            ],
          ),
        ),
      ],
    );
  }
}

/// A soft saffron halo behind the wordmark that slowly swells and settles;
/// held still when the user asks for reduced motion.
class _BreathingGlow extends StatefulWidget {
  const _BreathingGlow();

  @override
  State<_BreathingGlow> createState() => _BreathingGlowState();
}

class _BreathingGlowState extends State<_BreathingGlow> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: AppDurations.splash);

  static const double _minAlpha = 0.08;
  static const double _maxAlpha = 0.22;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final saffron = context.scheme.primary;
    return AnimatedBuilder(
      animation: CurvedAnimation(parent: _controller, curve: AppCurves.standard),
      builder: (_, _) {
        final alpha =
            _minAlpha + (_maxAlpha - _minAlpha) * CurvedAnimation(parent: _controller, curve: AppCurves.standard).value;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: 0.5,
              colors: [
                saffron.withValues(alpha: alpha),
                saffron.withValues(alpha: 0),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A dashed saffron "path" with a bright stretch travelling along it, looping
/// until the splash hands off — the road being walked. Held still when the
/// user asks for reduced motion.
class _Loader extends StatefulWidget {
  const _Loader();

  @override
  State<_Loader> createState() => _LoaderState();
}

class _LoaderState extends State<_Loader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: AppDurations.splash);

  static const int _dashes = 9;
  static const double _dashWidth = 14;
  static const double _dashHeight = 3;
  static const double _gap = 7;

  /// Dashes either side of the head that stay lit, and the resting opacity.
  static const double _tail = 3.5;
  static const double _restAlpha = 0.16;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final saffron = context.scheme.primary;
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          final head = _controller.value * (_dashes + _tail) - _tail / 2;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < _dashes; i++) ...[
                if (i > 0) const SizedBox(width: _gap),
                Container(
                  width: _dashWidth,
                  height: _dashHeight,
                  decoration: BoxDecoration(
                    color: saffron.withValues(alpha: _alphaFor(i - head)),
                    borderRadius: AppRadius.fullAll,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  /// Brightest at the head, fading over [_tail] dashes behind it.
  double _alphaFor(double behind) {
    if (behind > 0.5 || behind < -_tail) return _restAlpha;
    final t = (behind > 0 ? 0.0 : -behind) / _tail;
    return _restAlpha + (1 - _restAlpha) * (1 - t);
  }
}

/// "A product by TechLuminix".
class _Credit extends StatelessWidget {
  const _Credit();

  @override
  Widget build(BuildContext context) {
    final navy = context.scheme.secondary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('A PRODUCT BY', style: context.overline.copyWith(color: navy.withValues(alpha: 0.7))),
        const Gap(AppSpacing.xxs),
        Text('TechLuminix', style: context.brandText.titleMedium.copyWith(color: navy)),
      ],
    );
  }
}
