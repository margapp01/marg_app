import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../controllers/referral_controllers.dart';

/// Screen 9 — Referral Analytics, derived client-side from the real referral
/// summary + invite history (invites, joined, conversion, monthly, top source).
class ReferralAnalyticsPage extends ConsumerWidget {
  const ReferralAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(referralAnalyticsProvider);

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.rfAnalytics)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(title: l10n.rfErrorTitle, message: l10n.rfErrorBody, onRetry: () => ref.invalidate(referralAnalyticsProvider)),
        data: (a) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(referralAnalyticsProvider),
          child: ListView(
            padding: AppSpacing.screenAll,
            children: [
              Row(
                children: [
                  _stat(context, '${a.invitesSent}', l10n.rfInvitesSent, context.scheme.primary),
                  const Gap(AppSpacing.sm),
                  _stat(context, '${a.joined}', l10n.rfJoined, context.colors.success),
                  const Gap(AppSpacing.sm),
                  _stat(context, '${a.conversionPercent.toStringAsFixed(1)}%', l10n.rfConversion, context.colors.gold),
                ],
              ),
              const Gap(AppSpacing.lg),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.rfInvitesOverview, style: context.textTheme.titleSmall?.semiBold),
                    const Gap(AppSpacing.md),
                    _Bars(counts: a.monthly, emptyLabel: l10n.rfNoActivity),
                  ],
                ),
              ),
              if (a.topSource != null) ...[
                const Gap(AppSpacing.lg),
                SectionHeader(title: l10n.rfTopSource),
                const Gap(AppSpacing.sm),
                AppCard(
                  child: Row(
                    children: [
                      Icon(AppIcons.share, color: context.scheme.primary),
                      const Gap(AppSpacing.md),
                      Expanded(child: Text(a.topSource!, style: context.textTheme.bodyMedium?.semiBold)),
                      if (a.topSourcePercent != null)
                        Text('${a.topSourcePercent}%', style: context.textTheme.bodyMedium?.bold.copyWith(color: context.scheme.primary)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(BuildContext context, String value, String label, Color color) => Expanded(
        child: AppCard(
          padding: AppSpacing.allMd,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: context.textTheme.titleLarge?.bold.copyWith(color: color)),
            Text(label, style: context.caption.copyWith(color: context.colors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
      );
}

class _Bars extends StatelessWidget {
  const _Bars({required this.counts, required this.emptyLabel});
  final List<(String, int)> counts;
  final String emptyLabel;
  @override
  Widget build(BuildContext context) {
    if (counts.every((c) => c.$2 == 0)) {
      return SizedBox(height: 120, child: Center(child: Text(emptyLabel, style: context.caption.copyWith(color: context.colors.textSecondary))));
    }
    final max = counts.fold<int>(1, (m, c) => c.$2 > m ? c.$2 : m);
    return SizedBox(
      height: 130,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final (label, count) in counts)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('$count', style: context.overline.copyWith(color: context.colors.textSecondary)),
                    const Gap(AppSpacing.xxs),
                    Container(
                      height: (90 * count / max).clamp(4, 90).toDouble(),
                      decoration: BoxDecoration(color: context.scheme.primary.withValues(alpha: count == 0 ? 0.15 : 0.85), borderRadius: AppRadius.smAll),
                    ),
                    const Gap(AppSpacing.xxs),
                    Text(label, style: context.overline.copyWith(color: context.colors.textSecondary)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
