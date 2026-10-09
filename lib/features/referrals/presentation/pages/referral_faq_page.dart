import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/design_system.dart';
import '../controllers/referral_controllers.dart';

/// Screen 10 — Referral FAQ. Reuses the CMS FAQs, with a category filter + search.
class ReferralFaqPage extends ConsumerStatefulWidget {
  const ReferralFaqPage({super.key});

  @override
  ConsumerState<ReferralFaqPage> createState() => _ReferralFaqPageState();
}

class _ReferralFaqPageState extends ConsumerState<ReferralFaqPage> {
  String? _category;
  String _query = '';
  bool _searching = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(referralFaqsProvider);

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(
        title: _searching
            ? AppSearchBar(hint: l10n.rfSearchFaq, autofocus: true, onChanged: (v) => setState(() => _query = v))
            : Text(l10n.rfFaq),
        actions: [
          IconButton(
            icon: Icon(_searching ? AppIcons.close : AppIcons.search),
            onPressed: () => setState(() {
              _searching = !_searching;
              if (!_searching) _query = '';
            }),
          ),
        ],
      ),
      body: async.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(title: l10n.rfErrorTitle, message: l10n.rfErrorBody, onRetry: () => ref.invalidate(referralFaqsProvider)),
        data: (all) {
          // Category chips are only the ones the CMS actually returns.
          final categories = <String>{for (final f in all) if (f.category.isNotEmpty) f.category}.toList()..sort();
          final q = _query.trim().toLowerCase();
          final filtered = all.where((f) {
            final catOk = _category == null || f.category == _category;
            final qOk = q.isEmpty || f.question.toLowerCase().contains(q) || f.answer.toLowerCase().contains(q);
            return catOk && qOk;
          }).toList();

          return Column(
            children: [
              if (categories.isNotEmpty)
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: AppSpacing.screenH,
                    children: [
                      Center(child: AppFilterChip(label: l10n.rfAll, selected: _category == null, onSelected: (_) => setState(() => _category = null))),
                      for (final c in categories) ...[
                        const Gap(AppSpacing.sm),
                        Center(child: AppFilterChip(label: c, selected: _category == c, onSelected: (_) => setState(() => _category = c))),
                      ],
                    ],
                  ),
                ),
              Expanded(
                child: filtered.isEmpty
                    ? EmptyView(art: StateArt.noResults, icon: AppIcons.help, title: l10n.rfNoFaqs, message: l10n.rfNoFaqsBody)
                    : ListView.separated(
                        padding: AppSpacing.screenAll,
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const AppDivider(),
                        itemBuilder: (context, i) => _FaqTile(question: filtered[i].question, answer: filtered[i].answer),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.question, required this.answer});
  final String question;
  final String answer;
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: AppSpacing.sm),
        title: Text(question, style: context.textTheme.bodyMedium?.semiBold),
        children: [Align(alignment: Alignment.centerLeft, child: Text(answer, style: context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary, height: 1.5)))],
      ),
    );
  }
}
