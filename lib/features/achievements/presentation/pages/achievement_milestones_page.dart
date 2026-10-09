import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../controllers/achievements_controllers.dart';
import '../widgets/achievement_widgets.dart';

/// Milestones — the journey timeline (First Temple → 100 Temples, First Route,
/// First Jyotirlinga), from the passport overview.
class AchievementMilestonesPage extends ConsumerWidget {
  const AchievementMilestonesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(achievementSummaryProvider);
    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.acMilestones)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          title: l10n.acErrorTitle,
          message: l10n.acErrorBody,
          onRetry: () => ref.invalidate(achievementSummaryProvider),
        ),
        data: (summary) {
          if (summary.milestones.isEmpty) {
            return EmptyView(art: StateArt.achievements, icon: AppIcons.route, title: l10n.acNoMilestones, message: l10n.acNoMilestonesBody);
          }
          return ListView(
            padding: AppSpacing.screenAll,
            children: [
              Container(
                width: double.infinity,
                padding: AppSpacing.allLg,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [context.colors.gold.withValues(alpha: 0.16), context.scheme.primary.withValues(alpha: 0.08)]),
                  borderRadius: AppRadius.lgAll,
                ),
                child: Column(
                  children: [
                    Text(l10n.acMilestonesBanner, style: context.textTheme.titleSmall?.semiBold, textAlign: TextAlign.center),
                    const Gap(AppSpacing.xxs),
                    Text(l10n.acMilestonesBannerSub,
                        style: context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
              const Gap(AppSpacing.lg),
              for (var i = 0; i < summary.milestones.length; i++)
                MilestoneTile(milestone: summary.milestones[i], isLast: i == summary.milestones.length - 1),
            ],
          );
        },
      ),
    );
  }
}
