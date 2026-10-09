import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../shared/design_system.dart';
import '../../data/repository/passport_repository_impl.dart';
import '../../domain/entities/passport_lists.dart';
import '../controllers/passport_controllers.dart';

/// Certificates — one gilt-framed certificate per completed route,
/// downloadable as PDF (`/my/routes/:id/certificate`), then the routes still
/// in progress as certificates to earn.
class PassportCertificatesPage extends ConsumerWidget {
  const PassportCertificatesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(passportRoutesProvider);
    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.ppCertificates)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          title: l10n.ppErrorTitle,
          message: l10n.ppErrorBody,
          onRetry: () => ref.invalidate(passportRoutesProvider),
        ),
        data: (routes) {
          final earned = routes.where((r) => r.completed).toList();
          final toEarn = routes.where((r) => !r.completed).toList();
          if (routes.isEmpty) {
            return EmptyView(
              art: StateArt.certificates,
              icon: AppIcons.description,
              title: l10n.ppNoCertificates,
              message: l10n.ppNoCertificatesBody,
              action: AppButton.primary(
                label: l10n.ppExploreRoutes,
                icon: AppIcons.route,
                expand: false,
                onPressed: () => context.goNamed(RouteNames.routes),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(passportRoutesProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.huge),
              children: [
                IntroBanner(
                  icon: AppIcons.description,
                  color: context.colors.gold,
                  title: l10n.ppCertificates,
                  message: earned.isEmpty ? l10n.ppFirstCertHint : l10n.ppCertIntro,
                  status: l10n.ppEarnedCount(earned.length),
                ).fadeIn(),
                if (earned.isNotEmpty) ...[
                  const Gap(AppSpacing.lg),
                  GoldRuleHeader(label: l10n.ppEarned, count: earned.length),
                  const Gap(AppSpacing.md),
                  for (final (i, r) in earned.indexed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: _Certificate(route: r).fadeIn(delay: (80 * i).ms),
                    ),
                ],
                if (toEarn.isNotEmpty) ...[
                  const Gap(AppSpacing.md),
                  GoldRuleHeader(label: l10n.ppToEarn, count: toEarn.length),
                  const Gap(AppSpacing.md),
                  for (final r in toEarn)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _LockedCertificate(route: r),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

void _openRoute(BuildContext context, RouteHistoryItem route) =>
    context.pushNamed(RouteNames.routeDetail, pathParameters: {RoutePaths.routeSlugParam: route.slug});

/// An earned certificate: parchment in a gilt frame, gold seal, the route's
/// name in the display face, completion date + temples, Download / View Route.
class _Certificate extends ConsumerStatefulWidget {
  const _Certificate({required this.route});
  final RouteHistoryItem route;

  @override
  ConsumerState<_Certificate> createState() => _CertificateState();
}

class _CertificateState extends ConsumerState<_Certificate> {
  bool _busy = false;

  Future<void> _download() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final bytes = await ref.read(passportRepositoryProvider).certificate(widget.route.routeId);
      if (bytes.isEmpty) {
        if (mounted) AppSnackbar.error(context, l10n.ppCertUnavailable);
        return;
      }
      final file = XFile.fromData(Uint8List.fromList(bytes), name: 'marg-certificate.pdf', mimeType: 'application/pdf');
      await SharePlus.instance.share(ShareParams(files: [file]));
    } catch (_) {
      if (mounted) AppSnackbar.error(context, l10n.ppCertUnavailable);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final route = widget.route;
    final gold = context.colors.gold;
    final done = route.completedAt;
    final meta = routeTypeMeta(l10n, route.type);
    return GiltFrame(
      accent: gold,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.parchment),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.lg),
          child: Column(
            children: [
              Text(
                l10n.ppCertOfCompletion.toUpperCase(),
                textAlign: TextAlign.center,
                style: context.overline.copyWith(color: gold, letterSpacing: 1.6),
              ),
              const Gap(AppSpacing.md),
              const GoldSeal(size: 60),
              const Gap(AppSpacing.md),
              Text(
                route.name,
                textAlign: TextAlign.center,
                style: context.displayText.titleLarge.withColor(context.scheme.secondary),
              ),
              const Gap(AppSpacing.xxs),
              Text(meta.label, style: context.caption.copyWith(color: context.colors.textSecondary)),
              const Gap(AppSpacing.md),
              const GoldRule(),
              const Gap(AppSpacing.sm),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.xs,
                children: [
                  if (done != null)
                    _Fact(
                      icon: AppIcons.calendar,
                      text: l10n.ppCompletedOn(DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(done)),
                    ),
                  _Fact(icon: AppIcons.temple, text: l10n.ppTemplesCount(route.totalTemples)),
                ],
              ),
              const Gap(AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: AppButton.outlined(
                      label: l10n.ppViewRoute,
                      icon: AppIcons.route,
                      size: AppButtonSize.small,
                      onPressed: () => _openRoute(context, route),
                    ),
                  ),
                  const Gap.h(AppSpacing.sm),
                  Expanded(
                    child: AppButton.primary(
                      label: l10n.ppDownload,
                      icon: AppIcons.description,
                      size: AppButtonSize.small,
                      busy: _busy,
                      onPressed: _download,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: context.colors.gold),
        const Gap.h(AppSpacing.xxs),
        Text(text, style: context.caption.copyWith(color: context.colors.textSecondary)),
      ],
    );
  }
}

/// A certificate still to earn: a stone frame with the route's cover, its
/// progress and how many temples remain.
class _LockedCertificate extends StatelessWidget {
  const _LockedCertificate({required this.route});
  final RouteHistoryItem route;

  static const double _thumb = 64;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final left = (route.totalTemples - route.completedTemples).clamp(0, route.totalTemples);
    return GiltFrame(
      accent: context.colors.templeStone,
      locked: true,
      child: Material(
        color: context.colors.card,
        child: InkWell(
          onTap: () => _openRoute(context, route),
          child: Padding(
            padding: AppSpacing.allMd,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: AppRadius.mdAll,
                  child: SizedBox.square(
                    dimension: _thumb,
                    child: route.coverImage == null
                        ? const BrandedImageFallback(iconSize: 28)
                        : AppNetworkImage(url: route.coverImage!, fallback: const BrandedImageFallback(iconSize: 28)),
                  ),
                ),
                const Gap.h(AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(AppIcons.lock, size: 14, color: context.colors.textDisabled),
                          const Gap.h(AppSpacing.xxs),
                          Expanded(
                            child: Text(
                              route.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.titleSmall?.semiBold.withColor(context.scheme.secondary),
                            ),
                          ),
                        ],
                      ),
                      const Gap(AppSpacing.xs),
                      AppLinearProgress(value: (route.percent / 100).clamp(0, 1), height: 6, color: context.colors.gold),
                      const Gap(AppSpacing.xs),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.ppTemplesToGo(left),
                              style: context.caption.copyWith(color: context.colors.textSecondary),
                            ),
                          ),
                          Text('${route.percent}%', style: context.textTheme.labelMedium?.bold.withColor(context.colors.gold)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap.h(AppSpacing.xs),
                Icon(AppIcons.chevronRight, color: context.colors.textDisabled),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
