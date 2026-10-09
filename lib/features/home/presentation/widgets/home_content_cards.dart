import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/home_dashboard.dart';

/// Auto-advancing banner carousel (CMS banners) with page dots. Advancing
/// pauses when the platform asks to reduce motion.
class BannerCarousel extends StatefulWidget {
  const BannerCarousel({required this.banners, required this.onOpen, super.key});

  final List<HomeBanner> banners;
  final ValueChanged<HomeBanner> onOpen;

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  static const _interval = Duration(seconds: 5);
  final _controller = PageController();
  Timer? _timer;
  int _index = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _timer?.cancel();
    if (widget.banners.length > 1 && !MediaQuery.disableAnimationsOf(context)) {
      _timer = Timer.periodic(_interval, (_) {
        if (!_controller.hasClients) return;
        final next = (_index + 1) % widget.banners.length;
        _controller.animateToPage(next, duration: AppDurations.slow, curve: AppCurves.standard);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 168,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => Padding(
              padding: AppSpacing.screenH,
              child: _BannerCard(banner: widget.banners[i], onTap: () => widget.onOpen(widget.banners[i])),
            ),
          ),
        ),
        const Gap(AppSpacing.md),
        PageDots(count: widget.banners.length, index: _index),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.banner, required this.onTap});

  final HomeBanner banner;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: banner.title,
      child: DecoratedBox(
        decoration: const BoxDecoration(borderRadius: AppRadius.lgAll, boxShadow: AppShadows.md),
        child: ClipRRect(
          borderRadius: AppRadius.lgAll,
          child: Material(
            child: InkWell(
              onTap: onTap,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (banner.imageUrl != null)
                    AppNetworkImage(url: banner.imageUrl!, fallback: const BrandedImageFallback())
                  else
                    const BrandedImageFallback(),
                  const DecoratedBox(decoration: BoxDecoration(gradient: AppGradients.photoScrimLeft)),
                  Padding(
                    padding: AppSpacing.allLg,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FractionallySizedBox(
                          widthFactor: 0.7,
                          child: Text(
                            banner.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.displayText.titleLarge.copyWith(color: Colors.white),
                          ),
                        ),
                        if (banner.subtitle != null) ...[
                          const Gap(AppSpacing.xxs),
                          FractionallySizedBox(
                            widthFactor: 0.7,
                            child: Text(
                              banner.subtitle!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.bodySmall?.copyWith(color: Colors.white70),
                            ),
                          ),
                        ],
                        const Gap(AppSpacing.md),
                        _GradientPill(label: banner.ctaLabel ?? l10n.homeBannerCta),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A small saffron-gradient "Label →" pill used as a CTA over imagery.
class _GradientPill extends StatelessWidget {
  const _GradientPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
      decoration: const BoxDecoration(gradient: AppGradients.primary, borderRadius: AppRadius.fullAll),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: context.textTheme.labelMedium?.semiBold.withColor(context.scheme.onPrimary)),
          const Gap.h(AppSpacing.xs),
          Icon(AppIcons.arrowForward, size: 14, color: context.scheme.onPrimary),
        ],
      ),
    );
  }
}

/// Daily Inspiration — today's quote first, then recent ones, on parchment.
class InspirationCarousel extends StatefulWidget {
  const InspirationCarousel({required this.quotes, required this.onOpen, super.key});

  final List<DailyQuote> quotes;
  final VoidCallback onOpen;

  @override
  State<InspirationCarousel> createState() => _InspirationCarouselState();
}

class _InspirationCarouselState extends State<InspirationCarousel> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.6);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSpacing.screenH,
          child: SectionHeader(
            title: l10n.homeSectionDailyInspiration,
            onViewAll: widget.onOpen,
            viewAllLabel: l10n.commonViewAll,
          ),
        ),
        SizedBox(
          height: 236 * scale,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.quotes.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => Padding(
              padding: AppSpacing.screenH,
              child: _QuoteCard(quote: widget.quotes[i], onTap: widget.onOpen),
            ),
          ),
        ),
        const Gap(AppSpacing.md),
        Center(
          child: PageDots(count: widget.quotes.length, index: _index),
        ),
      ],
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.quote, required this.onTap});

  final DailyQuote quote;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final saffron = context.palette.accentSaffron;
    final mark = context.displayText.displaySmall.copyWith(color: saffron.withValues(alpha: 0.55), height: 1);
    final source = quote.reference ?? quote.source ?? quote.author;
    return AppCard(
      gradient: AppGradients.parchment,
      variant: AppCardVariant.filled,
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('“', style: mark),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (quote.textHi != null) ...[
                    Text(
                      quote.textHi!,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium?.semiBold.copyWith(
                        color: context.scheme.secondary,
                        height: 1.5,
                      ),
                    ),
                    const Gap(AppSpacing.sm),
                  ],
                  Text(
                    quote.text,
                    textAlign: TextAlign.center,
                    maxLines: quote.textHi != null ? 2 : 4,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: source == null
                    ? const SizedBox.shrink()
                    : Text(
                        '— $source',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.labelMedium?.semiBold.withColor(context.scheme.secondary),
                      ),
              ),
              Text('”', style: mark),
            ],
          ),
        ],
      ),
    );
  }
}

/// Invite & Earn promo (peach) with the gift illustration.
class InviteEarnCard extends StatelessWidget {
  const InviteEarnCard({required this.onInvite, super.key});

  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _PromoCard(
      title: l10n.homeReferralTitle,
      subtitle: l10n.homeReferralSubtitle,
      action: AppButton(
        label: l10n.homeInviteNow,
        onPressed: onInvite,
        size: AppButtonSize.small,
        trailingIcon: AppIcons.arrowForward,
        expand: false,
      ),
      art: IllustratedIcon(
        asset: BrandAssets.illustrationInviteGift,
        fallbackIcon: AppIcons.referral,
        color: context.palette.accentSaffron,
        background: context.colors.card.withValues(alpha: 0.7),
        size: 96,
      ),
      onTap: onInvite,
    );
  }
}

/// Need Help? — support promo with the headset illustration.
class NeedHelpCard extends StatelessWidget {
  const NeedHelpCard({required this.onContact, super.key});

  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _PromoCard(
      title: l10n.homeHelpTitle,
      subtitle: l10n.homeHelpSubtitle,
      action: AppButton(
        label: l10n.homeContactSupport,
        onPressed: onContact,
        variant: AppButtonVariant.outlined,
        size: AppButtonSize.small,
        trailingIcon: AppIcons.arrowForward,
        expand: false,
      ),
      art: IllustratedIcon(
        asset: BrandAssets.illustrationSupport,
        fallbackIcon: AppIcons.support,
        color: context.palette.accentAmber,
        background: context.colors.card.withValues(alpha: 0.7),
        size: 88,
      ),
      onTap: onContact,
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({
    required this.title,
    required this.subtitle,
    required this.action,
    required this.art,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Widget action;
  final Widget art;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: AppGradients.peach,
      variant: AppCardVariant.filled,
      onTap: onTap,
      padding: AppSpacing.allXl,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.displayText.titleLarge),
                const Gap(AppSpacing.xs),
                Text(
                  subtitle,
                  style: context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary, height: 1.4),
                ),
                const Gap(AppSpacing.lg),
                action,
              ],
            ),
          ),
          const Gap.h(AppSpacing.md),
          art,
        ],
      ),
    );
  }
}

/// Explore More — wide image cards for CMS promotions + blogs.
class ExploreSection extends StatelessWidget {
  const ExploreSection({required this.promotions, required this.blogs, required this.onOpen, super.key});

  final List<HomePromotion> promotions;
  final List<HomeBlog> blogs;
  final ValueChanged<String?> onOpen;

  @override
  Widget build(BuildContext context) {
    final items = <(String, String?, String?, String?)>[
      for (final p in promotions) (p.title, p.description, p.imageUrl, p.ctaUrl),
      for (final b in blogs) (b.title, b.excerpt, b.coverImageUrl, '/cms/blogs/${b.slug}'),
    ].take(3).toList();
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: AppLocalizations.of(context).homeSectionExplore),
        for (final (title, subtitle, image, href) in items) ...[
          _ExploreCard(title: title, subtitle: subtitle, imageUrl: image, onTap: () => onOpen(href)),
          const Gap(AppSpacing.md),
        ],
      ],
    );
  }
}

class _ExploreCard extends StatelessWidget {
  const _ExploreCard({required this.title, required this.subtitle, required this.imageUrl, required this.onTap});

  final String title;
  final String? subtitle;
  final String? imageUrl;
  final VoidCallback onTap;

  /// Small and faint, left of the arrow, so it never fights the title.
  static const _fallback = BrandedImageFallback(iconSize: 64, alignment: Alignment(0.62, 0), opacity: 0.2);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      child: ClipRRect(
        borderRadius: AppRadius.lgAll,
        child: SizedBox(
          height: 104,
          child: Material(
            child: InkWell(
              onTap: onTap,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl != null) AppNetworkImage(url: imageUrl!, fallback: _fallback) else _fallback,
                  const DecoratedBox(decoration: BoxDecoration(gradient: AppGradients.photoScrimLeft)),
                  Padding(
                    padding: AppSpacing.allLg,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.displayText.titleLarge.copyWith(color: Colors.white),
                              ),
                              if (subtitle != null)
                                Text(
                                  subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.textTheme.bodySmall?.copyWith(color: Colors.white70),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white70, width: 1.5),
                          ),
                          child: const Icon(AppIcons.arrowForward, color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
