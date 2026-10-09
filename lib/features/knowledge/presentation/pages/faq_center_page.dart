import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/knowledge_models.dart';
import '../controllers/knowledge_controllers.dart';

/// Screen 7 — FAQ Center. Search, category chips (derived from the data),
/// expandable questions, and a contact-support CTA (the CMS Contact page).
class FaqCenterPage extends ConsumerStatefulWidget {
  const FaqCenterPage({super.key});

  @override
  ConsumerState<FaqCenterPage> createState() => _FaqCenterPageState();
}

class _FaqCenterPageState extends ConsumerState<FaqCenterPage> {
  String _query = '';
  String? _category;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(knowledgeFaqsProvider);

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(l10n.kbFaqs)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(title: l10n.kbErrorTitle, message: l10n.kbErrorBody, onRetry: () => ref.invalidate(knowledgeFaqsProvider)),
        data: (faqs) {
          if (faqs.isEmpty) {
            return EmptyView(art: StateArt.noResults, icon: AppIcons.faq, title: l10n.kbNoFaqs, message: l10n.kbNoFaqsBody);
          }
          final categories = _categories(faqs);
          final q = _query.trim().toLowerCase();
          final filtered = faqs.where((f) {
            final matchesCat = _category == null || f.category == _category;
            final matchesQ = q.isEmpty || f.question.toLowerCase().contains(q) || f.answer.toLowerCase().contains(q);
            return matchesCat && matchesQ;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
                child: AppSearchBar(
                  hint: l10n.kbSearchFaqs,
                  onChanged: (v) => setState(() => _query = v),
                  onClear: () => setState(() => _query = ''),
                ),
              ),
              if (categories.isNotEmpty)
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: AppFilterChip(label: l10n.kbAll, selected: _category == null, onSelected: (_) => setState(() => _category = null)),
                      ),
                      for (final c in categories)
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: AppFilterChip(label: c, selected: _category == c, onSelected: (_) => setState(() => _category = c)),
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: filtered.isEmpty
                    ? EmptyView(art: StateArt.noResults, icon: AppIcons.search, title: l10n.kbNoResults, message: l10n.kbNoResultsBody)
                    : ListView(
                        padding: AppSpacing.screenAll,
                        children: [
                          for (final f in filtered) ...[
                            AppCard(
                              padding: EdgeInsets.zero,
                              child: ExpandableSection(
                                title: Text(f.question, style: context.textTheme.titleSmall?.semiBold),
                                child: Text(f.answer, style: context.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary, height: 1.5)),
                              ),
                            ),
                            const Gap(AppSpacing.sm),
                          ],
                          const Gap(AppSpacing.md),
                          _ContactCta(l10n: l10n),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<String> _categories(List<Faq> faqs) {
    final seen = <String>{};
    final out = <String>[];
    for (final f in faqs) {
      final c = f.category;
      if (c != null && c.isNotEmpty && seen.add(c)) out.add(c);
    }
    return out;
  }
}

class _ContactCta extends StatelessWidget {
  const _ContactCta({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Icon(AppIcons.help, color: context.scheme.primary, size: 32),
          const Gap(AppSpacing.sm),
          Text(l10n.kbStillNeedHelp, style: context.textTheme.titleSmall?.semiBold, textAlign: TextAlign.center),
          const Gap(AppSpacing.xs),
          Text(l10n.kbContactSupportBody, style: context.caption.copyWith(color: context.colors.textSecondary), textAlign: TextAlign.center),
          const Gap(AppSpacing.md),
          AppButton.outlined(
            label: l10n.kbContactSupport,
            icon: AppIcons.mail,
            onPressed: () => context.pushNamed(RouteNames.knowledgeStaticPage, pathParameters: {'kind': 'contact'}),
          ),
        ],
      ),
    );
  }
}
