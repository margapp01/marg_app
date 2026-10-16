import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../../../profile/presentation/pages/static_page_page.dart';
import '../../domain/entities/knowledge_models.dart';
import '../controllers/knowledge_controllers.dart';

/// Screen 10 — a CMS static page (Privacy / Terms / Contact / About) laid out
/// as a readable document. Community Guidelines is not offered — there is no such
/// `PageKind` in the backend.
class KnowledgeStaticPagePage extends ConsumerWidget {
  const KnowledgeStaticPagePage({required this.kindWire, super.key});

  /// Route path value: `about` | `contact` | `privacy` | `terms`.
  final String kindWire;

  PageKind get _kind => switch (kindWire.toLowerCase()) {
        'contact' => PageKind.contact,
        'privacy' => PageKind.privacy,
        'terms' => PageKind.terms,
        _ => PageKind.about,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final async = ref.watch(staticPageProvider(_kind)).whenData((p) => p.localized(lang));

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(
        title: Text(async.maybeWhen(data: (p) => p.title, orElse: () => l10n.kbAbout)),
      ),
      body: async.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(title: l10n.kbErrorTitle, message: l10n.kbErrorBody, onRetry: () => ref.invalidate(staticPageProvider(_kind))),
        data: (page) {
          if (page.contentHtml.isEmpty) {
            return EmptyView(art: StateArt.empty, icon: AppIcons.description, title: page.title.isEmpty ? l10n.kbAbout : page.title, message: l10n.kbNoContentBody);
          }
          return CmsDocumentView(
            title: page.title.isEmpty ? l10n.kbAbout : page.title,
            html: page.contentHtml,
            icon: StaticPageScreen.iconFor(_kind),
            updatedAt: page.updatedAt,
          );
        },
      ),
    );
  }
}
