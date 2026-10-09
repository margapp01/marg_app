import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../controllers/knowledge_controllers.dart';
import '../widgets/knowledge_share.dart';
import '../widgets/knowledge_widgets.dart';

/// Festival detail — hero, name, date, countdown, deity, and significance
/// (`description`). The backend models festivals with a single description
/// (no structured rituals/history) and no temple association, so those
/// sections are not shown.
class FestivalDetailPage extends ConsumerWidget {
  const FestivalDetailPage({required this.slug, super.key});
  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(festivalDetailProvider(slug));

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(
        title: Text(l10n.kbFestival),
        actions: [
          async.maybeWhen(
            data: (f) => IconButton(
              icon: Icon(AppIcons.share),
              tooltip: l10n.kbShare,
              onPressed: () => showKnowledgeShare(
                context,
                ShareContent(
                  title: f.name,
                  subtitle: f.deity,
                  heroImageUrl: f.imageUrl,
                  shareText: '${f.name}${f.startDate != null ? ' · ${festivalDate(f.startDate)}' : ''}',
                ),
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: async.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(title: l10n.kbErrorTitle, message: l10n.kbErrorBody, onRetry: () => ref.invalidate(festivalDetailProvider(slug))),
        data: (f) => ListView(
          padding: EdgeInsets.zero,
          children: [
            if (f.imageUrl != null)
              AppNetworkImage(url: f.imageUrl!, height: 220, width: double.infinity, fit: BoxFit.cover),
            Padding(
              padding: AppSpacing.screenAll,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(f.name, style: context.textTheme.headlineSmall?.bold),
                  const Gap(AppSpacing.sm),
                  Row(
                    children: [
                      Icon(AppIcons.calendar, size: 16, color: context.scheme.primary),
                      const Gap(AppSpacing.xs),
                      Text(festivalDate(f.startDate), style: context.textTheme.bodyMedium?.semiBold),
                      const Spacer(),
                      _CountdownChip(daysUntil: f.daysUntil, isToday: f.isToday),
                    ],
                  ),
                  if (f.deity != null) ...[
                    const Gap(AppSpacing.md),
                    Row(
                      children: [
                        Icon(AppIcons.temple, size: 16, color: context.colors.textSecondary),
                        const Gap(AppSpacing.xs),
                        Text(f.deity!, style: context.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary)),
                      ],
                    ),
                  ],
                  if (f.description != null && f.description!.isNotEmpty) ...[
                    const Gap(AppSpacing.lg),
                    Text(l10n.kbSignificance, style: context.textTheme.titleSmall?.semiBold),
                    const Gap(AppSpacing.sm),
                    HtmlContentView(html: f.description!),
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

class _CountdownChip extends StatelessWidget {
  const _CountdownChip({required this.daysUntil, required this.isToday});
  final int? daysUntil;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final String? text;
    if (isToday) {
      text = l10n.kbHappeningNow;
    } else if (daysUntil == null || daysUntil! < 0) {
      text = null;
    } else if (daysUntil == 1) {
      text = l10n.kbTomorrow;
    } else {
      text = '$daysUntil ${l10n.kbDaysToGo}';
    }
    if (text == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(color: context.scheme.primary.withValues(alpha: 0.1), borderRadius: AppRadius.fullAll),
      child: Text(text, style: context.caption.copyWith(color: context.scheme.primary, fontWeight: FontWeight.w700)),
    );
  }
}
