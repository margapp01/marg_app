import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../controllers/knowledge_controllers.dart';
import '../widgets/knowledge_share.dart';
import '../widgets/knowledge_widgets.dart';

/// Screen 6 — Announcements. Temple updates, pilgrimage alerts, app updates and
/// emergency notices in the backend's own priority order (pinned first, then
/// newest). Kind is shown via a colour-coded badge — never colour alone.
class AnnouncementsPage extends ConsumerWidget {
  const AnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(announcementsProvider);

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.kbAnnouncements)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(title: l10n.kbErrorTitle, message: l10n.kbErrorBody, onRetry: () => ref.invalidate(announcementsProvider)),
        data: (items) {
          if (items.isEmpty) {
            return EmptyView(art: StateArt.knowledge, icon: AppIcons.announcement, title: l10n.kbNoAnnouncements, message: l10n.kbNoAnnouncementsBody);
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(announcementsProvider),
            child: ListView.separated(
              padding: AppSpacing.screenAll,
              itemCount: items.length,
              separatorBuilder: (_, _) => const Gap(AppSpacing.md),
              itemBuilder: (context, i) {
                final a = items[i];
                return AnnouncementCard(
                  announcement: a,
                  onShare: () => showKnowledgeShare(context, ShareContent(title: a.title, subtitle: a.body, shareText: '${a.title}\n\n${a.body}')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
