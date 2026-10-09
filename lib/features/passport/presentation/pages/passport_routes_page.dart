import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/passport_lists.dart';
import '../controllers/passport_controllers.dart';

/// Routes Summary — the routes walked in numbers, then each route as a cover
/// card: in progress (with the next temple) first, then completed (with the
/// date and a path to its certificate).
class PassportRoutesPage extends ConsumerWidget {
  const PassportRoutesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(passportRoutesProvider);
    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.ppRoutes)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          title: l10n.ppErrorTitle,
          message: l10n.ppErrorBody,
          onRetry: () => ref.invalidate(passportRoutesProvider),
        ),
        data: (routes) {
          if (routes.isEmpty) {
            return EmptyView(
              art: StateArt.journey,
              icon: AppIcons.route,
              title: l10n.ppNoRoutes,
              message: l10n.ppNoRoutesBody,
              action: AppButton.primary(
                label: l10n.ppExploreRoutes,
                icon: AppIcons.explore,
                expand: false,
                onPressed: () => context.goNamed(RouteNames.routes),
              ),
            );
          }
          final completed = routes.where((r) => r.completed).toList();
          final inProgress = routes.where((r) => !r.completed).toList();
          final templesWalked = routes.fold<int>(0, (sum, r) => sum + r.completedTemples);
          final p = context.palette;
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(passportRoutesProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.huge),
              children: [
                StatLedger(
                  stats: [
                    LedgerStat(icon: AppIcons.verified, color: context.colors.success, value: completed.length, label: l10n.ppCompleted),
                    LedgerStat(icon: AppIcons.route, color: p.accentSaffron, value: inProgress.length, label: l10n.ppInProgress),
                    LedgerStat(icon: AppIcons.temple, color: p.accentBlue, value: templesWalked, label: l10n.ppTemplesWalked),
                  ],
                  footer: completed.isEmpty ? null : _CertificatesLink(count: completed.length),
                ).fadeIn(),
                if (inProgress.isNotEmpty) ...[
                  const Gap(AppSpacing.lg),
                  GoldRuleHeader(label: l10n.ppInProgress, count: inProgress.length),
                  const Gap(AppSpacing.md),
                  for (final (i, r) in inProgress.indexed) _RouteEntry(route: r).fadeIn(delay: (60 * i).ms),
                ],
                if (completed.isNotEmpty) ...[
                  const Gap(AppSpacing.lg),
                  GoldRuleHeader(label: l10n.ppCompleted, count: completed.length),
                  const Gap(AppSpacing.md),
                  for (final r in completed) _RouteEntry(route: r),
                ],
                const Gap(AppSpacing.sm),
                AppButton.outlined(
                  label: l10n.ppExploreRoutes,
                  icon: AppIcons.route,
                  onPressed: () => context.goNamed(RouteNames.routes),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RouteEntry extends StatelessWidget {
  const _RouteEntry({required this.route});
  final RouteHistoryItem route;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final done = route.completedAt;
    final next = route.nextTempleName;
    final (footnote, icon) = route.completed && done != null
        ? (l10n.ppCompletedOn(DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(done)), AppIcons.calendar)
        : next != null
            ? (l10n.ppNextTempleName(next), AppIcons.nearby)
            : (null, null);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: RouteCard(
        name: route.name,
        type: route.type,
        templeCount: route.totalTemples,
        coverImage: route.coverImage,
        percent: route.percent,
        completedTemples: route.completedTemples,
        pill: route.completed
            ? PhotoPill(label: l10n.ppCompleted, icon: AppIcons.verified, color: context.colors.success)
            : null,
        footnote: footnote,
        footnoteIcon: icon,
        onTap: () => context.pushNamed(RouteNames.routeDetail, pathParameters: {RoutePaths.routeSlugParam: route.slug}),
      ),
    );
  }
}

/// "🏅 1 certificate earned · View All" under the ledger.
class _CertificatesLink extends StatelessWidget {
  const _CertificatesLink({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return InkWell(
      borderRadius: AppRadius.mdAll,
      onTap: () => context.pushNamed(RouteNames.passportCertificates),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
        child: Row(
          children: [
            Icon(AppIcons.description, size: 18, color: context.colors.gold, fill: 1),
            const Gap.h(AppSpacing.xs),
            Expanded(
              child: Text(
                l10n.ppCertificatesEarned(count),
                style: context.textTheme.bodySmall?.semiBold.withColor(context.scheme.secondary),
              ),
            ),
            Text(l10n.commonViewAll, style: context.textTheme.labelMedium?.bold.withColor(context.scheme.primary)),
            Icon(AppIcons.chevronRight, size: 18, color: context.scheme.primary),
          ],
        ),
      ),
    );
  }
}
