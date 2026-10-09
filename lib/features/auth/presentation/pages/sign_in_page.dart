import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../shared/design_system.dart';
import '../controllers/auth_controller.dart';
import '../states/auth_state.dart';

const String _googleLogo = 'assets/icons/google.svg';

/// Login screen: MARG wordmark and tagline over the devotional backdrop with a
/// "Welcome Back" card that starts real Google sign-in.
///
/// On success the auth state drives navigation: a returning, onboarded user
/// goes Home; everyone else continues into onboarding (setup).
class SignInPage extends ConsumerWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.sizeOf(context);
    final logoWidth = (size.width * 0.52).clamp(180.0, 300.0);
    final overlayHeight = size.height * 0.34;

    ref.listen(authControllerProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        AppSnackbar.error(context, next.error!);
      }
      if (next.status == AuthStatus.needsMobile) {
        context.goNamed(RouteNames.setup);
      } else if (next.status == AuthStatus.authenticated) {
        context.goNamed(
          next.user?.isOnboarded == true ? RouteNames.home : RouteNames.setup,
        );
      }
    });
    final busy = ref.watch(authControllerProvider).status == AuthStatus.authenticating;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.colors.splashCanvas,
              context.scheme.primaryContainer,
            ],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Bottom: temple-skyline + lotus-border band, its top edge faded so
            // it blends into the warm background above.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: overlayHeight,
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.white],
                  stops: [0.0, 0.5],
                ).createShader(rect),
                child: Image.asset(
                  BrandAssets.loginOverlay,
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: AppSpacing.screenH,
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    ScaleIn(
                      from: 0.9,
                      duration: AppDurations.slow,
                      child: BrandWordmark(width: logoWidth.toDouble()),
                    ),
                    FadeIn(
                      delay: const Duration(milliseconds: 200),
                      child: Text(
                        l10n.siSacredPath,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cinzel(
                          color: context.scheme.secondary,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const Spacer(flex: 1),
                    const Gap(AppSpacing.xxxl),
                    FadeIn(
                      delay: const Duration(milliseconds: 300),
                      child: _WelcomeCard(
                        busy: busy,
                        onGoogle: () => ref.read(authControllerProvider.notifier).signInWithGoogle(),
                      ),
                    ),
                    const Spacer(flex: 6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The sign-in card in the app's devotional theme: a soft gold-edged surface
/// with the lotus ornament, serif greeting and the Google button.
class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.onGoogle, this.busy = false});

  final VoidCallback onGoogle;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gold = context.colors.gold;
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.xxl),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: AppRadius.xlAll,
        border: Border.all(color: gold.withValues(alpha: 0.35)),
        boxShadow: [
          ...AppShadows.lg,
          BoxShadow(color: gold.withValues(alpha: 0.18), blurRadius: 32, spreadRadius: 1),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The divider art sits in the middle band of a tall transparent
          // canvas; a short `cover` box crops it to just the ornament.
          ExcludeSemantics(
            child: Image.asset(BrandAssets.splashLotusDivider, width: 200, height: 36, fit: BoxFit.cover),
          ),
          const Gap(AppSpacing.md),
          Text(l10n.siWelcome, textAlign: TextAlign.center, style: context.displayText.headlineLarge),
          const Gap(AppSpacing.xs),
          Text(
            l10n.siSubtitle,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary),
          ),
          const Gap(AppSpacing.xxl),
          _GoogleButton(label: l10n.siGoogle, onPressed: onGoogle, busy: busy),
          const Gap(AppSpacing.xl),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(AppIcons.shield, size: 16, color: context.palette.accentSaffron, fill: 1),
              const Gap.h(AppSpacing.xs),
              Flexible(
                child: Text(
                  l10n.siSecure,
                  style: context.textTheme.labelMedium?.copyWith(color: context.colors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// White "Continue with Google" button carrying the official Google mark.
class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.label, required this.onPressed, this.busy = false});

  final String label;
  final VoidCallback onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: context.colors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.lgAll,
        child: InkWell(
          borderRadius: AppRadius.lgAll,
          onTap: busy ? null : onPressed,
          child: SizedBox(
            height: 56,
            child: busy
                ? const Center(
                    child: SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(_googleLogo, width: 22, height: 22),
                      const Gap.h(AppSpacing.md),
                      Flexible(
                        child: Text(
                          label,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.titleMedium?.semiBold.withColor(context.scheme.secondary),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
