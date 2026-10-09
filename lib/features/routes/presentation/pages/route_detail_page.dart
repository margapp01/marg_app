import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../features/auth/presentation/controllers/auth_controller.dart';
import '../../../../features/directions/domain/route_plan.dart';
import '../../../../shared/design_system.dart';
import '../../data/repository/routes_repository_impl.dart';
import '../../domain/entities/route_detail_bundle.dart';
import '../../domain/entities/yatra_route.dart';
import '../controllers/routes_controllers.dart';
import '../widgets/route_map_view.dart';
import '../widgets/route_reward_widgets.dart';
import '../widgets/route_widgets.dart';

/// Route Detail — a cover hero, the devotee's progress in the gilt night
/// panel, the next stop with directions, then (under a pinned tab strip) the
/// temple checklist, the journey rail, the route map and the rewards.
/// Completion, rewards and certificate all derive from backend progress;
/// nothing is unlocked locally.
class RouteDetailPage extends ConsumerWidget {
  const RouteDetailPage({required this.slug, super.key});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(routeDetailProvider(slug));
    return Scaffold(
      backgroundColor: context.scheme.surface,
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => Center(
          child: ErrorView(
            title: l10n.ryErrorTitle,
            message: l10n.ryErrorBody,
            onRetry: () => ref.invalidate(routeDetailProvider(slug)),
          ),
        ),
        data: (bundle) => _RouteDetailView(bundle: bundle),
      ),
    );
  }
}

String _date(BuildContext context, DateTime d) => DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(d);

void _openTemple(BuildContext context, String slug) =>
    context.pushNamed(RouteNames.templeDetail, pathParameters: {RoutePaths.templeIdParam: slug});

class _RouteDetailView extends StatefulWidget {
  const _RouteDetailView({required this.bundle});

  final RouteDetailBundle bundle;

  @override
  State<_RouteDetailView> createState() => _RouteDetailViewState();
}

class _RouteDetailViewState extends State<_RouteDetailView> {
  int _tab = 0;

  static const double _heroHeight = 280;
  static const int _rewardsTab = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bundle = widget.bundle;
    const content = EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.huge);
    return DefaultTabController(
      length: 4,
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: _heroHeight,
                pinned: true,
                stretch: true,
                // Navy when collapsed so the white title + back arrow stay legible.
                backgroundColor: context.scheme.secondary,
                foregroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                flexibleSpace: _Hero(bundle: bundle),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
                sliver: SliverToBoxAdapter(child: _Summary(bundle: bundle)),
              ),
              PinnedHeaderSliver(
                child: ColoredBox(
                  color: context.scheme.surface,
                  child: TabBar(
                    onTap: (i) => setState(() => _tab = i),
                    tabs: [
                      Tab(text: l10n.ryTabTemples),
                      Tab(text: l10n.ryTabTimeline),
                      Tab(text: l10n.ryTabMap),
                      Tab(text: l10n.ryTabRewards),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: content,
                sliver: switch (_tab) {
                  0 => _TemplesTab(bundle: bundle),
                  1 => _TimelineTab(bundle: bundle),
                  2 => SliverToBoxAdapter(child: RouteMapView(bundle: bundle, height: 380)),
                  _ => _RewardsTab(bundle: bundle),
                },
              ),
            ],
          ),
          if (_tab == _rewardsTab && bundle.isComplete)
            const Positioned.fill(child: IgnorePointer(child: ConfettiOverlay())),
        ],
      ),
    );
  }
}

// ─────────────────────────── Hero ───────────────────────────

/// Cover photo with the route's type, name and size; as the bar collapses the
/// block fades out and the name settles into the toolbar.
class _Hero extends StatelessWidget {
  const _Hero({required this.bundle});
  final RouteDetailBundle bundle;

  static const double _toolbarInset = kToolbarHeight + AppSpacing.md;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final route = bundle.route;
    final meta = routeTypeMeta(l10n, route.type);
    final settings = context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    final t = settings == null
        ? 1.0
        : ((settings.currentExtent - settings.minExtent) / (settings.maxExtent - settings.minExtent)).clamp(0.0, 1.0);
    final km = route.totalDistanceKm.round();
    const white = Colors.white;
    return Stack(
      fit: StackFit.expand,
      children: [
        FlexibleSpaceBar(
          stretchModes: const [StretchMode.zoomBackground],
          background: Stack(
            fit: StackFit.expand,
            children: [
              if (route.coverImage == null)
                const BrandedImageFallback(iconSize: 120)
              else
                AppNetworkImage(url: route.coverImage!, fit: BoxFit.cover, fallback: const BrandedImageFallback(iconSize: 120)),
              const DecoratedBox(decoration: BoxDecoration(gradient: AppGradients.photoScrim)),
            ],
          ),
        ),
        Positioned(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          bottom: AppSpacing.lg,
          child: Opacity(
            opacity: ((t - 0.35) / 0.65).clamp(0.0, 1.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    PhotoPill(label: meta.label, icon: meta.icon, color: context.palette.accentSaffron),
                    PhotoPill(label: l10n.ppTemplesCount(route.temples.length), icon: AppIcons.temple, color: context.colors.gold),
                  ],
                ),
                const Gap(AppSpacing.sm),
                Text(
                  route.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.displayText.headlineSmall.copyWith(color: white),
                ),
                if (km > 0)
                  Text(
                    l10n.ryKmRoute(NumberFormat.decimalPattern(Localizations.localeOf(context).toLanguageTag()).format(km)),
                    style: context.textTheme.bodySmall?.copyWith(color: white.withValues(alpha: 0.8)),
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          left: _toolbarInset,
          right: AppSpacing.lg,
          bottom: 0,
          height: kToolbarHeight,
          child: Opacity(
            opacity: ((0.3 - t) / 0.3).clamp(0.0, 1.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                route.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleMedium?.bold.copyWith(color: white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────── Summary ───────────────────────────

class _Summary extends StatelessWidget {
  const _Summary({required this.bundle});
  final RouteDetailBundle bundle;

  @override
  Widget build(BuildContext context) {
    final route = bundle.route;
    final next = bundle.isComplete ? null : bundle.nextEntry;
    final description = route.description;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProgressPanel(bundle: bundle).fadeIn(),
        if (description != null && description.isNotEmpty) ...[
          const Gap(AppSpacing.md),
          _Description(text: description),
        ],
        if (next != null) ...[
          const Gap(AppSpacing.lg),
          _NextStopCard(entry: next).fadeIn(delay: 80.ms),
        ],
        if (!bundle.isComplete) _SaveRouteButton(routeId: route.id),
      ],
    );
  }
}

/// The devotee's progress on a night sky in the gilt frame: ring, headline,
/// temples to go, route length and days on the road.
class _ProgressPanel extends StatelessWidget {
  const _ProgressPanel({required this.bundle});
  final RouteDetailBundle bundle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gold = context.colors.gold;
    final light = context.colors.card;
    final dim = light.withValues(alpha: 0.75);
    final remaining = bundle.totalCount - bundle.completedCount;
    final km = bundle.route.totalDistanceKm.round();
    final days = bundle.journeyDurationDays;
    final headline = bundle.isComplete
        ? l10n.ryYatraComplete
        : bundle.completedCount == 0
            ? l10n.ryNotStarted
            : l10n.ryVisitedOf(bundle.completedCount, bundle.totalCount);
    return GiltFrame(
      accent: gold,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.night),
        child: Padding(
          padding: AppSpacing.allLg,
          child: Row(
            children: [
              AppCircularProgress(
                value: (bundle.percent / 100).clamp(0, 1),
                size: 88,
                strokeWidth: 8,
                color: gold,
                backgroundColor: light.withValues(alpha: 0.12),
                center: Text('${bundle.percent}%', style: context.textTheme.titleLarge?.bold.withColor(light)),
              ),
              const Gap.h(AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.ryYourProgress.toUpperCase(), style: context.overline.copyWith(color: gold, letterSpacing: 1.4)),
                    const Gap(AppSpacing.xxs),
                    Text(headline, style: context.displayText.titleLarge.withColor(light)),
                    const Gap(AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.xxs,
                      children: [
                        if (!bundle.isComplete) _Fact(icon: AppIcons.temple, text: l10n.ryToGo(remaining), color: dim),
                        if (km > 0)
                          _Fact(
                            icon: AppIcons.route,
                            text: l10n.ryKmRoute(NumberFormat.decimalPattern(Localizations.localeOf(context).toLanguageTag()).format(km)),
                            color: dim,
                          ),
                        if (days != null) _Fact(icon: AppIcons.timer, text: '$days ${l10n.ryDays}', color: dim),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.text, required this.color});
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: context.colors.gold),
        const Gap.h(AppSpacing.xxs),
        Text(text, style: context.caption.copyWith(color: color)),
      ],
    );
  }
}

/// The route's story — three lines, the rest a tap away.
class _Description extends StatefulWidget {
  const _Description({required this.text});
  final String text;

  @override
  State<_Description> createState() => _DescriptionState();
}

class _DescriptionState extends State<_Description> {
  bool _open = false;

  static const int _lines = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return InkWell(
      borderRadius: AppRadius.mdAll,
      onTap: () => setState(() => _open = !_open),
      child: AnimatedSize(
        duration: AppDurations.normal,
        curve: AppCurves.standard,
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              maxLines: _open ? null : _lines,
              overflow: _open ? TextOverflow.visible : TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary),
            ),
            if (!_open)
              Text(l10n.tdReadMore, style: context.textTheme.labelMedium?.bold.withColor(context.scheme.primary)),
          ],
        ),
      ),
    );
  }
}

/// The next temple on the route, with directions and its page.
class _NextStopCard extends StatelessWidget {
  const _NextStopCard({required this.entry});
  final RouteTempleEntry entry;

  static const double _thumb = 64;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = entry.temple;
    final located = !(t.latitude == 0 && t.longitude == 0);
    return AppCard(
      selected: true,
      padding: AppSpacing.allMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.navigation, size: 16, color: context.scheme.primary, fill: 1),
              const Gap.h(AppSpacing.xs),
              Text(l10n.ryNextStop.toUpperCase(), style: context.overline.copyWith(color: context.scheme.primary, letterSpacing: 1.2)),
            ],
          ),
          const Gap(AppSpacing.sm),
          Row(
            children: [
              ClipRRect(
                borderRadius: AppRadius.mdAll,
                child: SizedBox.square(
                  dimension: _thumb,
                  child: t.imageUrl == null
                      ? const BrandedImageFallback(iconSize: 28)
                      : AppNetworkImage(url: t.imageUrl!, fallback: const BrandedImageFallback(iconSize: 28)),
                ),
              ),
              const Gap.h(AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium?.semiBold.withColor(context.scheme.secondary),
                    ),
                    if (t.location != null)
                      Text(t.location!, style: context.caption.copyWith(color: context.colors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.md),
          Row(
            children: [
              if (located) ...[
                Expanded(
                  child: AppButton.outlined(
                    label: l10n.exNavigate,
                    icon: AppIcons.directions,
                    size: AppButtonSize.small,
                    onPressed: () => context.pushNamed(
                      RouteNames.directions,
                      extra: DirectionsArgs(
                        name: t.name,
                        latitude: t.latitude,
                        longitude: t.longitude,
                        place: t.location,
                        imageUrl: t.imageUrl,
                        templeSlug: t.slug,
                      ),
                    ),
                  ),
                ),
                const Gap.h(AppSpacing.sm),
              ],
              Expanded(
                child: AppButton.primary(
                  label: l10n.exViewDetails,
                  icon: AppIcons.temple,
                  size: AppButtonSize.small,
                  onPressed: () => _openTemple(context, t.slug),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Saves the route to the user's journeys (idempotent enroll); gone once saved.
class _SaveRouteButton extends ConsumerStatefulWidget {
  const _SaveRouteButton({required this.routeId});
  final String routeId;
  @override
  ConsumerState<_SaveRouteButton> createState() => _SaveRouteButtonState();
}

class _SaveRouteButtonState extends ConsumerState<_SaveRouteButton> {
  bool _busy = false;

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(routesRepositoryProvider).enroll(widget.routeId);
      ref.invalidate(myRoutesProvider);
      if (mounted) AppSnackbar.info(context, l10n.rySavedToPlanned);
    } catch (_) {
      if (mounted) AppSnackbar.error(context, l10n.ryErrorBody);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Already in the devotee's yatras (saved earlier or in progress)?
    final enrolled = ref.watch(
      myRoutesProvider.select((r) => r.valueOrNull?.any((m) => m.routeId == widget.routeId) ?? false),
    );
    if (enrolled) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: AppButton.outlined(label: l10n.rySaveRoute, icon: AppIcons.favorite, busy: _busy, onPressed: _save),
    );
  }
}

// ─────────────────────────── Temples (checklist) ───────────────────────────

class _TemplesTab extends StatelessWidget {
  const _TemplesTab({required this.bundle});
  final RouteDetailBundle bundle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final temples = bundle.route.temples;
    return SliverList.builder(
      itemCount: temples.length,
      itemBuilder: (context, i) {
        final entry = temples[i];
        final date = bundle.visitDateByTempleId[entry.temple.id];
        return TempleChecklistItem(
          index: i + 1,
          entry: entry,
          status: bundle.statusOf(entry),
          visitedOn: date == null ? null : l10n.ryVisitedOn(_date(context, date)),
          onTap: () => _openTemple(context, entry.temple.slug),
        );
      },
    );
  }
}

// ─────────────────────────── Timeline ───────────────────────────

/// The journey as it happened — visits in date order — then the stops still
/// ahead in route order, the next one outlined.
class _TimelineTab extends StatelessWidget {
  const _TimelineTab({required this.bundle});
  final RouteDetailBundle bundle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final temples = bundle.route.temples;
    final stopOf = {for (final (i, e) in temples.indexed) e.temple.id: i + 1};
    final dates = bundle.visitDateByTempleId;
    final done = temples.where(bundle.isCompleted).toList()
      ..sort((a, b) {
        final da = dates[a.temple.id];
        final db = dates[b.temple.id];
        if (da == null || db == null) return da == null ? 1 : -1;
        return da.compareTo(db);
      });
    final ahead = temples.where((e) => !bundle.isCompleted(e)).toList();
    final success = context.colors.success;
    return SliverList.list(
      children: [
        GoldRuleHeader(label: l10n.ryJourneySoFar, count: done.length),
        const Gap(AppSpacing.md),
        if (done.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Text(l10n.ryNoVisitsOnRoute, style: context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary)),
          ),
        for (final (i, e) in done.indexed)
          JourneyRailTile(
            icon: AppIcons.check,
            color: success,
            title: e.temple.name,
            subtitle: e.temple.location,
            caption: dates[e.temple.id] == null ? null : _date(context, dates[e.temple.id]!),
            captionIcon: AppIcons.calendar,
            imageUrl: e.temple.imageUrl,
            isLast: i == done.length - 1,
            onTap: () => _openTemple(context, e.temple.slug),
          ),
        if (ahead.isNotEmpty) ...[
          const Gap(AppSpacing.sm),
          GoldRuleHeader(label: l10n.ryStillAhead, count: ahead.length),
          const Gap(AppSpacing.md),
          for (final (i, e) in ahead.indexed)
            _aheadTile(context, e, stop: stopOf[e.temple.id] ?? i + 1, isLast: i == ahead.length - 1),
        ],
      ],
    );
  }

  Widget _aheadTile(BuildContext context, RouteTempleEntry e, {required int stop, required bool isLast}) {
    final l10n = AppLocalizations.of(context);
    final next = bundle.statusOf(e) == TempleJourneyStatus.current;
    return JourneyRailTile(
      icon: AppIcons.temple,
      nodeLabel: '$stop',
      color: next ? context.scheme.primary : context.colors.textSecondary,
      title: e.temple.name,
      subtitle: e.temple.location,
      caption: next ? l10n.ryNextStop : l10n.ryStatusUpcoming,
      captionIcon: next ? AppIcons.navigation : null,
      captionColor: next ? context.scheme.primary : null,
      imageUrl: e.temple.imageUrl,
      highlighted: next,
      muted: !next,
      isLast: isLast,
      onTap: () => _openTemple(context, e.temple.slug),
    );
  }
}

// ─────────────────────────── Rewards / Completion ───────────────────────────

class _RewardsTab extends ConsumerWidget {
  const _RewardsTab({required this.bundle});
  final RouteDetailBundle bundle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final route = bundle.route;
    final card = route.rewardCard;
    final duration = bundle.journeyDurationDays;
    final p = context.palette;

    return SliverList.list(
      children: [
        if (bundle.isComplete) ...[
          const Gap(AppSpacing.sm),
          Center(child: ScaleIn(child: const CompletionMedal())),
          const Gap(AppSpacing.md),
          Text(l10n.ryCongratulations, style: context.displayText.headlineSmall.withColor(context.scheme.secondary), textAlign: TextAlign.center),
          const Gap(AppSpacing.xxs),
          Text(
            '${l10n.ryCompletedRoutePrefix} ${route.name}',
            style: context.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const Gap(AppSpacing.lg),
        ],
        StatLedger(
          stats: [
            if (duration != null) LedgerStat(icon: AppIcons.timer, color: p.accentSaffron, value: duration, label: l10n.ryDays),
            LedgerStat(icon: AppIcons.route, color: p.accentBlue, value: bundle.distanceCoveredKm.round(), label: l10n.ryKmCovered),
            LedgerStat(icon: AppIcons.temple, color: context.colors.success, value: bundle.completedCount, label: l10n.ryTemplesVisited),
          ],
        ),
        if (card != null) ...[
          const Gap(AppSpacing.lg),
          GoldRuleHeader(label: l10n.ryRouteReward),
          const Gap(AppSpacing.lg),
          Center(child: RewardCardArt(card: card)),
        ],
        if (bundle.isComplete) ...[
          const Gap(AppSpacing.xl),
          GoldRuleHeader(label: l10n.ryCertificate),
          const Gap(AppSpacing.md),
          CertificateCard(
            routeName: route.name,
            userName: ref.watch(authControllerProvider).user?.name ?? l10n.ryPilgrim,
            completedOn: bundle.completedOn,
          ),
          const Gap(AppSpacing.lg),
          AppButton.primary(
            label: l10n.ryDownloadCertificate,
            icon: AppIcons.description,
            onPressed: () => _downloadCertificate(context, ref, route.id),
          ),
          const Gap(AppSpacing.sm),
          AppButton.outlined(
            label: l10n.ryShareAchievement,
            icon: AppIcons.share,
            onPressed: () => _share(context, route.name),
          ),
          const Gap(AppSpacing.sm),
          AppButton.ghost(
            label: l10n.ryViewPassport,
            icon: AppIcons.passport,
            onPressed: () => context.goNamed(RouteNames.passport),
          ),
        ] else ...[
          const Gap(AppSpacing.lg),
          Text(
            l10n.ryRewardsLockedHint,
            style: context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  void _share(BuildContext context, String routeName) {
    final l10n = AppLocalizations.of(context);
    SharePlus.instance.share(ShareParams(text: '${l10n.ryShareBody} $routeName · MARG'));
  }

  Future<void> _downloadCertificate(BuildContext context, WidgetRef ref, String routeId) async {
    final l10n = AppLocalizations.of(context);
    try {
      final bytes = await ref.read(routesRepositoryProvider).certificate(routeId);
      if (bytes.isEmpty) {
        if (context.mounted) AppSnackbar.error(context, l10n.ryCertUnavailable);
        return;
      }
      final file = XFile.fromData(
        Uint8List.fromList(bytes),
        name: 'marg-certificate.pdf',
        mimeType: 'application/pdf',
      );
      await SharePlus.instance.share(ShareParams(files: [file]));
    } catch (_) {
      if (context.mounted) AppSnackbar.error(context, l10n.ryCertUnavailable);
    }
  }
}
