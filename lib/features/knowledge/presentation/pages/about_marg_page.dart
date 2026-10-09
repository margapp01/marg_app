import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/knowledge_models.dart';
import '../controllers/knowledge_controllers.dart';

/// About MARG — the official brand mark over the CMS "About" page. This is a
/// branding surface, so the Cinzel brand type + logo are used here (unlike the
/// content screens, which stay content-first).
class AboutMargPage extends ConsumerWidget {
  const AboutMargPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(staticPageProvider(PageKind.about));

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.kbAboutMarg)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(title: l10n.kbErrorTitle, message: l10n.kbErrorBody, onRetry: () => ref.invalidate(staticPageProvider(PageKind.about))),
        data: (page) => ListView(
          padding: AppSpacing.screenAll,
          children: [
            const Gap(AppSpacing.md),
            const Center(child: BrandLogo(size: 48)),
            const Gap(AppSpacing.sm),
            Text(l10n.kbSpiritualCompanion, textAlign: TextAlign.center, style: context.brandText.headlineSmall.copyWith(color: context.scheme.primary)),
            const Gap(AppSpacing.xl),
            if (page.contentHtml.isNotEmpty)
              HtmlContentView(html: page.contentHtml)
            else
              Text(l10n.kbAboutFallback, textAlign: TextAlign.center, style: context.textTheme.bodyLarge?.copyWith(height: 1.6, color: context.colors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
