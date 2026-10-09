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

enum _TempleFilter { all, verified, pending }

/// Temple Summary — every temple visit in numbers, filterable by
/// verification, as a grid of photo stamps.
class PassportTemplesPage extends ConsumerStatefulWidget {
  const PassportTemplesPage({super.key});

  @override
  ConsumerState<PassportTemplesPage> createState() => _PassportTemplesPageState();
}

class _PassportTemplesPageState extends ConsumerState<PassportTemplesPage> {
  _TempleFilter _filter = _TempleFilter.all;

  static const double _tileExtent = 228;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(passportTemplesProvider);
    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.ppTemples)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          title: l10n.ppErrorTitle,
          message: l10n.ppErrorBody,
          onRetry: () => ref.invalidate(passportTemplesProvider),
        ),
        data: (temples) {
          if (temples.isEmpty) {
            return EmptyView(art: StateArt.noVisits, icon: AppIcons.temple, title: l10n.ppNoTemples, message: l10n.ppNoTemplesBody);
          }
          final p = context.palette;
          final verified = temples.where((t) => t.verified).length;
          final pending = temples.where((t) => t.pending).length;
          final states = temples.map((t) => t.state).whereType<String>().toSet().length;
          final filtered = switch (_filter) {
            _TempleFilter.all => temples,
            _TempleFilter.verified => temples.where((t) => t.verified).toList(),
            _TempleFilter.pending => temples.where((t) => t.pending).toList(),
          };
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(passportTemplesProvider),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
                  sliver: SliverList.list(
                    children: [
                      StatLedger(
                        stats: [
                          LedgerStat(icon: AppIcons.temple, color: p.accentSaffron, value: temples.length, label: l10n.ppTotal),
                          LedgerStat(icon: AppIcons.verified, color: context.colors.success, value: verified, label: l10n.ppVerified),
                          LedgerStat(icon: AppIcons.timer, color: p.accentAmber, value: pending, label: l10n.ppPending),
                          LedgerStat(icon: AppIcons.map, color: p.accentBlue, value: states, label: l10n.ppStates),
                        ],
                      ).fadeIn(),
                      const Gap(AppSpacing.lg),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final (label, icon, f) in [
                              (l10n.ppAll, AppIcons.temple, _TempleFilter.all),
                              (l10n.ppVerified, AppIcons.verified, _TempleFilter.verified),
                              (l10n.ppPending, AppIcons.timer, _TempleFilter.pending),
                            ]) ...[
                              AppFilterChip(
                                label: label,
                                icon: icon,
                                selected: _filter == f,
                                onSelected: (_) => setState(() => _filter = f),
                              ),
                              const Gap.h(AppSpacing.sm),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyView(icon: AppIcons.filter, title: l10n.ppNoFilterMatch, message: l10n.ppNoFilterMatchBody),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.huge),
                    sliver: SliverGrid.builder(
                      itemCount: filtered.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: context.responsive(compact: 2, medium: 3, expanded: 4),
                        mainAxisSpacing: AppSpacing.md,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisExtent: _tileExtent,
                      ),
                      itemBuilder: (context, i) => _TempleStamp(item: filtered[i]),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// One visited temple: photo with its verification pill, name, place, date.
class _TempleStamp extends StatelessWidget {
  const _TempleStamp({required this.item});
  final TempleHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final date = item.visitedAt;
    final (label, icon, color) = item.verified
        ? (l10n.ppVerified, AppIcons.verified, context.colors.success)
        : item.pending
            ? (l10n.ppPending, AppIcons.timer, context.palette.accentAmber)
            : (l10n.ppUnderReview, AppIcons.info, context.colors.warning);
    return TempleCardBase(
      dense: true,
      imageHeight: 120,
      name: item.name,
      location: item.place ?? '',
      imageUrl: item.imageUrl,
      chip: PhotoPill(label: label, icon: icon, color: color),
      footer: date == null
          ? null
          : Row(
              children: [
                Icon(AppIcons.calendar, size: 13, color: context.colors.textDisabled),
                const Gap.h(AppSpacing.xxs),
                Text(
                  DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(date),
                  style: context.caption.copyWith(color: context.colors.textDisabled),
                ),
              ],
            ),
      onTap: () => context.pushNamed(RouteNames.templeDetail, pathParameters: {RoutePaths.templeIdParam: item.slug}),
    );
  }
}
