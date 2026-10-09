import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../shared/design_system.dart';
import '../controllers/achievements_controllers.dart';
import '../widgets/achievement_widgets.dart';

/// Recently Unlocked — earned achievements, newest first.
class AchievementRecentPage extends ConsumerWidget {
  const AchievementRecentPage({super.key});

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(achievementCollectionProvider);
    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.acRecent)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          title: l10n.acErrorTitle,
          message: l10n.acErrorBody,
          onRetry: () => ref.invalidate(achievementCollectionProvider),
        ),
        data: (c) {
          final recent = c.recent;
          if (recent.isEmpty) {
            return EmptyView(art: StateArt.achievements, icon: AppIcons.achievement, title: l10n.acNoRecent, message: l10n.acNoRecentBody);
          }
          return ListView.separated(
            padding: AppSpacing.screenAll,
            itemCount: recent.length,
            separatorBuilder: (_, _) => const Gap(AppSpacing.sm),
            itemBuilder: (context, i) {
              final a = recent[i];
              final d = a.earnedAt!;
              return AchievementRow(
                achievement: a,
                trailingDate: '${d.day} ${_months[d.month - 1]} ${d.year}',
                onTap: () => context.pushNamed(
                  RouteNames.achievementDetail,
                  pathParameters: {RoutePaths.achievementIdParam: a.id},
                ),
              );
            },
          );
        },
      ),
    );
  }
}
