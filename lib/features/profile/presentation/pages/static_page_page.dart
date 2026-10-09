import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/cms_content.dart';
import '../controllers/profile_controllers.dart';

/// A CMS static page (Privacy / Terms / About / Contact) rendered as plain text.
class StaticPageScreen extends ConsumerWidget {
  const StaticPageScreen({required this.kind, super.key});
  final PageKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(staticPageProvider(kind));
    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(async.valueOrNull?.title ?? _fallbackTitle(l10n))),
      body: async.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(title: l10n.pfErrorTitle, message: l10n.pfErrorBody, onRetry: () => ref.invalidate(staticPageProvider(kind))),
        data: (page) {
          final text = page.plainText;
          if (text.isEmpty) {
            return EmptyView(art: StateArt.empty, icon: AppIcons.article, title: _fallbackTitle(l10n), message: l10n.pfPageEmpty);
          }
          return SingleChildScrollView(
            padding: AppSpacing.screenAll,
            child: Text(text, style: context.textTheme.bodyMedium?.copyWith(height: 1.6)),
          );
        },
      ),
    );
  }

  String _fallbackTitle(AppLocalizations l10n) => switch (kind) {
        PageKind.privacy => l10n.pfPrivacyPolicy,
        PageKind.terms => l10n.pfTerms,
        PageKind.about => l10n.pfAbout,
        PageKind.contact => l10n.pfContactSupport,
      };
}
