import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/achievement.dart';
import '../widgets/achievement_widgets.dart';

/// Achievement Celebration — a full-screen medal reveal with confetti and the
/// points earned. Reached from the recent list (replay) or after an unlock.
class AchievementCelebrationPage extends ConsumerWidget {
  const AchievementCelebrationPage({required this.achievement, super.key});

  final Achievement achievement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final accent = rarityColor(context, achievement.rarity);
    return Scaffold(
      backgroundColor: context.scheme.surface,
      body: Stack(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [accent.withValues(alpha: 0.2), context.scheme.surface],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: AppSpacing.screenAll,
                        child: Column(
                          children: [
                            Text(l10n.acUnlockedTitle,
                                style: context.textTheme.titleMedium?.semiBold, textAlign: TextAlign.center),
                            const Gap(AppSpacing.xl),
                            ScaleIn(child: AchievementMedal(achievement: achievement, size: 160, hero: true)),
                            const Gap(AppSpacing.lg),
                            Text(achievement.name, style: context.brandText.headlineMedium, textAlign: TextAlign.center),
                            if (achievement.description != null) ...[
                              const Gap(AppSpacing.xs),
                              Text(achievement.description!,
                                  style: context.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary),
                                  textAlign: TextAlign.center),
                            ],
                            const Gap(AppSpacing.lg),
                            if (achievement.points > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                                decoration: BoxDecoration(color: context.colors.gold.withValues(alpha: 0.14), borderRadius: AppRadius.fullAll),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(AppIcons.points, color: context.colors.gold),
                                    const Gap(AppSpacing.sm),
                                    Text('+${achievement.points} ${l10n.acPoints}',
                                        style: context.textTheme.titleSmall?.bold),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: AppSpacing.screenAll,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppButton.primary(
                          label: l10n.acViewAchievement,
                          icon: AppIcons.achievement,
                          onPressed: () => context.pushReplacementNamed(
                            RouteNames.achievementDetail,
                            pathParameters: {RoutePaths.achievementIdParam: achievement.id},
                          ),
                        ),
                        const Gap(AppSpacing.sm),
                        AppButton.ghost(
                          label: l10n.acContinue,
                          onPressed: () => context.canPop() ? context.pop() : context.goNamed(RouteNames.achievements),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned.fill(child: IgnorePointer(child: ConfettiOverlay())),
        ],
      ),
    );
  }
}
