import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../shared/design_system.dart';
import '../../../../shared/offline/offline_banner.dart';
import '../../../directions/domain/route_plan.dart';
import '../../domain/entities/temple_detail.dart';
import '../controllers/temple_detail_controller.dart';
import '../widgets/temple_detail_skeleton.dart';
import '../widgets/temple_engagement.dart';
import '../widgets/temple_gallery_viewer.dart';
import '../widgets/temple_sections.dart';

/// The flagship Temple Detail screen: immersive collapsing hero, live
/// intelligence, route integration, spiritual passport progress, gallery, and
/// an adaptive sticky CTA. One controller loads everything (fail-soft).
class TempleDetailPage extends ConsumerWidget {
  const TempleDetailPage({required this.slug, super.key});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(templeDetailControllerProvider(slug));

    return Scaffold(
      // When online the banner is zero-height, so the hero is unchanged; when
      // offline a slim strip sits above it and cached content still renders.
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: async.when(
              loading: () => const TempleDetailSkeleton(),
              error: (_, _) => _ErrorState(
                onRetry: () => ref.invalidate(templeDetailControllerProvider(slug)),
              ),
              data: (bundle) => _Content(bundle: bundle),
            ),
          ),
        ],
      ),
      bottomNavigationBar: async.maybeWhen(
        data: (bundle) => _StickyCta(bundle: bundle),
        orElse: () => null,
      ),
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.bundle});

  final TempleDetailBundle bundle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final temple = bundle.temple;
    final status = bundle.myStatus;
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(templeDetailControllerProvider(temple.slug)),
      child: CustomScrollView(
        slivers: [
          _HeroAppBar(temple: temple, saved: status?.saved ?? false, onShare: () => _share(temple)),
          SliverToBoxAdapter(
            child: FadeIn(
              child: Padding(
                padding: AppSpacing.screenAll,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Glance(bundle: bundle),
                    const Gap(AppSpacing.lg),
                    if (bundle.crowd != null)
                      RepaintBoundary(
                        child: IntelligenceCard(
                          crowd: bundle.crowd!,
                          bestTimeWindow: bundle.bestTimeWindow,
                          peakWindow: bundle.peakWindow,
                        ),
                      ),
                    if (temple.card != null) ...[
                      const Gap(AppSpacing.lg),
                      SacredCardShowcase(
                        card: temple.card!,
                        collected: status?.cardCollected ?? false,
                        onCollect: () => context.pushNamed(
                          RouteNames.templeVisit,
                          pathParameters: {RoutePaths.templeIdParam: temple.slug},
                        ),
                        onView: () => context.pushNamed(
                          RouteNames.cardDetail,
                          pathParameters: {RoutePaths.cardIdParam: temple.card!.id},
                        ),
                      ).fadeIn(delay: 60.ms),
                    ],
                    if (temple.description != null) ...[
                      const Gap(AppSpacing.lg),
                      AboutSection(name: temple.name, description: temple.description!),
                    ],
                    if (status != null) ...[
                      const Gap(AppSpacing.xl),
                      MyProgressSection(status: status),
                    ],
                    if (temple.routes.isNotEmpty) ...[
                      const Gap(AppSpacing.xl),
                      RepaintBoundary(
                        child: RouteIntegrationSection(
                          routes: temple.routes,
                          progress: status?.routes ?? const [],
                          onOpen: (r) => context.pushNamed(
                            RouteNames.routeDetail,
                            pathParameters: {RoutePaths.routeSlugParam: r},
                          ),
                        ),
                      ),
                    ],
                    const Gap(AppSpacing.xl),
                    InfoSection(temple: temple),
                    if (!temple.visitorInfo.isEmpty) ...[
                      const Gap(AppSpacing.xl),
                      VisitorInfoSection(info: temple.visitorInfo),
                    ],
                    const Gap(AppSpacing.xl),
                    FacilitiesSection(facilities: temple.facilities),
                    if (temple.images.isNotEmpty) ...[
                      const Gap(AppSpacing.xl),
                      GallerySection(
                        images: temple.images,
                        onOpen: (i) => TempleGalleryViewer.open(context, temple.images, i),
                      ),
                    ],
                    const Gap(AppSpacing.xl),
                    ReviewsSection(
                      summary: bundle.reviewSummary ??
                          ReviewSummary(average: temple.ratingAverage, count: temple.ratingCount),
                      reviews: bundle.reviews,
                      myReview: bundle.myReview,
                      canReview: status?.verified ?? false,
                      onWrite: () => showReviewSheet(context, temple: temple, existing: bundle.myReview),
                    ),
                    if (bundle.nearby.isNotEmpty) ...[
                      const Gap(AppSpacing.xl),
                      NearbyTemplesSection(
                        nearby: bundle.nearby,
                        onOpen: (s) => context.pushNamed(
                          RouteNames.templeDetail,
                          pathParameters: {'templeId': s},
                        ),
                      ),
                    ],
                    const Gap(AppSpacing.huge2),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _share(TempleDetail t) =>
      SharePlus.instance.share(ShareParams(text: '${t.name} · MARG\nhttps://margapp.in/temples/${t.slug}'));
}

class _HeroAppBar extends StatelessWidget {
  const _HeroAppBar({required this.temple, required this.saved, required this.onShare});

  final TempleDetail temple;
  final bool saved;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      stretch: true,
      backgroundColor: context.scheme.secondary,
      foregroundColor: Colors.white,
      leading: _CircleButton(icon: AppIcons.back, onTap: () => context.canPop() ? context.pop() : context.goNamed(RouteNames.home)),
      actions: [
        _CircleButton(icon: AppIcons.share, onTap: onShare),
        SaveTempleButton(templeId: temple.id, initiallySaved: saved),
        const Gap.h(AppSpacing.sm),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (temple.coverImage != null)
              AppNetworkImage(url: temple.coverImage!, placeholderIcon: AppIcons.temple)
            else
              ColoredBox(color: context.scheme.primaryContainer),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                  stops: [0.4, 1.0],
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.lg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      if (temple.isVerified)
                        PhotoPill(label: l10n.tdVerified, icon: AppIcons.verified, color: context.colors.success),
                      if (temple.deity != null)
                        PhotoPill(
                          label: InfoSection.titleCase(temple.deity!),
                          icon: AppIcons.temple,
                          color: deityColor(context, temple.deity),
                        ),
                    ],
                  ),
                  const Gap(AppSpacing.sm),
                  Text(
                    temple.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.displayText.headlineLarge.copyWith(color: Colors.white),
                  ),
                  if (temple.ratingCount > 0) ...[
                    const Gap(AppSpacing.xxs),
                    RatingBadge(rating: temple.ratingAverage, count: temple.ratingCount, onDark: true),
                  ],
                  if (temple.location.isNotEmpty) ...[
                    const Gap(AppSpacing.xxs),
                    Row(
                      children: [
                        const Icon(AppIcons.location, size: 16, color: Colors.white70),
                        const Gap.h(AppSpacing.xxs),
                        Flexible(
                          child: Text(
                            temple.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: Material(
        color: Colors.black.withValues(alpha: 0.35),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: AppSpacing.allSm,
            child: Icon(icon, size: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// Open / closed today, crowd, wait and rating as one parchment strip.
class _Glance extends StatelessWidget {
  const _Glance({required this.bundle});

  final TempleDetailBundle bundle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final temple = bundle.temple;
    final crowd = bundle.crowd;
    final open = _isOpenNow(temple.timings);
    final crowdLook = crowd == null ? null : crowdMeta(context, l10n, crowd.crowdLevel);
    return TempleGlance(
      cells: [
        if (open != null)
          GlanceCell(
            icon: AppIcons.timer,
            value: open ? l10n.tdOpen : l10n.tdClosed,
            label: _todayHours(temple.timings),
            color: open ? context.colors.success : context.scheme.error,
          ),
        if (crowdLook != null)
          GlanceCell(icon: AppIcons.crowd, value: crowdLook.label, label: l10n.tdCrowd, color: crowdLook.color),
        if (crowd?.waitMinutes != null)
          GlanceCell(
            icon: AppIcons.timer,
            value: '${crowd!.waitMinutes} ${l10n.tdMinutesShort}',
            label: l10n.tdWaitTime,
            color: context.scheme.primary,
          ),
        if (temple.ratingCount > 0)
          GlanceCell(
            icon: AppIcons.star,
            value: temple.ratingAverage.toStringAsFixed(1),
            label: l10n.tdReviewCount(temple.ratingCount),
            color: context.colors.gold,
          ),
      ],
    );
  }

  bool? _isOpenNow(List<TempleTiming> timings) {
    if (timings.isEmpty) return null;
    final now = DateTime.now();
    final today = now.weekday % 7;
    final match = timings.where((t) => t.dayOfWeek == today);
    final t = match.isNotEmpty ? match.first : timings.first;
    final open = _minutes(t.openTime);
    final close = _minutes(t.closeTime);
    if (open == null || close == null) return null;
    final cur = now.hour * 60 + now.minute;
    return close < open ? (cur >= open || cur <= close) : (cur >= open && cur <= close);
  }

  String _todayHours(List<TempleTiming> timings) {
    if (timings.isEmpty) return '';
    final today = DateTime.now().weekday % 7;
    final match = timings.where((t) => t.dayOfWeek == today);
    final t = match.isNotEmpty ? match.first : timings.first;
    return '${t.openTime} – ${t.closeTime}';
  }

  int? _minutes(String s) {
    final m = RegExp(r'^\s*(\d{1,2}):(\d{2})\s*([AaPp][Mm])?').firstMatch(s);
    if (m == null) return null;
    var h = int.parse(m.group(1)!);
    final min = int.parse(m.group(2)!);
    final ap = m.group(3)?.toUpperCase();
    if (ap == 'PM' && h != 12) h += 12;
    if (ap == 'AM' && h == 12) h = 0;
    return h * 60 + min;
  }
}

class _StickyCta extends StatelessWidget {
  const _StickyCta({required this.bundle});

  final TempleDetailBundle bundle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = bundle.myStatus;
    final visited = status?.visited ?? false;
    final canCheckIn = status?.canCheckIn ?? true;
    final temple = bundle.temple;
    void openVisit() => context.pushNamed(
          RouteNames.templeVisit,
          pathParameters: {RoutePaths.templeIdParam: temple.slug},
        );
    void openDirections() => context.pushNamed(
          RouteNames.directions,
          extra: DirectionsArgs(
            name: temple.name,
            latitude: temple.latitude,
            longitude: temple.longitude,
            place: temple.location,
            imageUrl: temple.coverImage,
            templeSlug: temple.slug,
          ),
        );

    return Container(
      decoration: BoxDecoration(
        color: context.colors.card,
        boxShadow: AppShadows.md,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: AppSpacing.screenAll,
          // Not visited → one clear primary action: go visit the temple.
          // Visited  → directions stay available; the primary action is the
          // next check-in, or a done state once today's is recorded (the
          // backend allows one verified check-in per temple per day).
          child: visited
              ? Row(
                  children: [
                    Expanded(
                      child: AppButton.outlined(
                        label: l10n.tdNavigate,
                        icon: AppIcons.nearby,
                        onPressed: openDirections,
                      ),
                    ),
                    const Gap.h(AppSpacing.md),
                    Expanded(
                      child: canCheckIn
                          ? AppButton.primary(
                              label: l10n.tdCheckInAgain,
                              icon: AppIcons.verified,
                              onPressed: openVisit,
                            )
                          : AppButton.primary(
                              label: l10n.tdCheckedInToday,
                              success: true,
                              onPressed: null,
                            ),
                    ),
                  ],
                )
              : AppButton.primary(
                  label: l10n.tdNavigate,
                  icon: AppIcons.nearby,
                  onPressed: openVisit,
                ),
        ),
      ),
    );
  }

}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: ErrorView(
        icon: AppIcons.error,
        title: l10n.tdErrorTitle,
        message: l10n.homeErrorMessage,
        retryLabel: l10n.commonRetry,
        onRetry: onRetry,
      ),
    );
  }
}
