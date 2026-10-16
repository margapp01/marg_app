import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/cms_content.dart';
import '../controllers/profile_controllers.dart';

/// A CMS static page (Privacy / Terms / About / Contact), laid out as a
/// readable document: header, contents and numbered sections.
class StaticPageScreen extends ConsumerWidget {
  const StaticPageScreen({required this.kind, super.key});
  final PageKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final async = ref.watch(staticPageProvider(kind)).whenData((p) => p.localized(lang));
    final title = async.valueOrNull?.title;
    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(title == null || title.isEmpty ? _fallbackTitle(l10n) : title)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(title: l10n.pfErrorTitle, message: l10n.pfErrorBody, onRetry: () => ref.invalidate(staticPageProvider(kind))),
        data: (page) {
          if (page.plainText.isEmpty) {
            return EmptyView(art: StateArt.empty, icon: AppIcons.article, title: _fallbackTitle(l10n), message: l10n.pfPageEmpty);
          }
          return CmsDocumentView(
            title: page.title.isEmpty ? _fallbackTitle(l10n) : page.title,
            html: page.contentHtml,
            icon: iconFor(kind),
            updatedAt: page.updatedAt,
          );
        },
      ),
    );
  }

  /// The header icon for each page.
  static IconData iconFor(PageKind kind) => switch (kind) {
        PageKind.privacy => AppIcons.shield,
        PageKind.terms => AppIcons.gavel,
        PageKind.about => AppIcons.info,
        PageKind.contact => AppIcons.support,
      };

  String _fallbackTitle(AppLocalizations l10n) => switch (kind) {
        PageKind.privacy => l10n.pfPrivacyPolicy,
        PageKind.terms => l10n.pfTerms,
        PageKind.about => l10n.pfAbout,
        PageKind.contact => l10n.pfContactSupport,
      };
}
