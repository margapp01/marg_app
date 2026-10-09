import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/router/route_paths.dart';
import '../../../../shared/design_system.dart';
import '../../domain/entities/achievement.dart';
import '../controllers/achievements_controllers.dart';
import '../widgets/achievement_widgets.dart';

/// Gallery arguments: an optional starting status filter, a category, and a
/// title override. Reused for "all", "locked", and per-category views.
class AchievementGalleryArgs {
  const AchievementGalleryArgs({this.status, this.category, this.title});
  final AchievementStatus? status;
  final String? category;
  final String? title;
}

/// Achievement Gallery — an adaptive grid with status filters, category chips,
/// and search. Filters the in-memory collection (bounded set, no pagination).
class AchievementGalleryPage extends ConsumerStatefulWidget {
  const AchievementGalleryPage({required this.args, super.key});

  final AchievementGalleryArgs args;

  @override
  ConsumerState<AchievementGalleryPage> createState() => _AchievementGalleryPageState();
}

class _AchievementGalleryPageState extends ConsumerState<AchievementGalleryPage> {
  late AchievementStatus? _status = widget.args.status;
  late final String? _category = widget.args.category;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(achievementCollectionProvider);

    return Scaffold(
      backgroundColor: context.scheme.surface,
      appBar: AppBar(title: Text(widget.args.title ?? l10n.acGallery)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          title: l10n.acErrorTitle,
          message: l10n.acErrorBody,
          onRetry: () => ref.invalidate(achievementCollectionProvider),
        ),
        data: (c) {
          var items = c.all;
          if (_status != null) items = items.where((a) => a.status == _status).toList();
          if (_category != null) items = items.where((a) => a.category == _category).toList();
          if (_query.isNotEmpty) {
            final q = _query.toLowerCase();
            items = items.where((a) => a.name.toLowerCase().contains(q)).toList();
          }
          return Column(
            children: [
              Padding(
                padding: AppSpacing.screenH,
                child: AppSearchBar(
                  controller: _searchCtrl,
                  hint: l10n.acSearchHint,
                  onChanged: (v) => setState(() => _query = v.trim()),
                ),
              ),
              const Gap(AppSpacing.sm),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: AppSpacing.screenH,
                  children: [
                    _statusChip(l10n.acAll, null),
                    const Gap(AppSpacing.sm),
                    _statusChip(l10n.acStatusCompleted, AchievementStatus.earned),
                    const Gap(AppSpacing.sm),
                    _statusChip(l10n.acInProgress, AchievementStatus.inProgress),
                    const Gap(AppSpacing.sm),
                    _statusChip(l10n.acLocked, AchievementStatus.locked),
                  ],
                ),
              ),
              const Gap(AppSpacing.sm),
              Expanded(
                child: items.isEmpty
                    ? EmptyView(art: StateArt.noResults, icon: AppIcons.achievement, title: l10n.acNoResults, message: l10n.acNoResultsBody)
                    : GridView.builder(
                        padding: AppSpacing.screenAll,
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 128,
                          mainAxisSpacing: AppSpacing.lg,
                          crossAxisSpacing: AppSpacing.md,
                          childAspectRatio: 0.66,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, i) => RepaintBoundary(
                          child: AchievementTile(
                            achievement: items[i],
                            onTap: () => context.pushNamed(
                              RouteNames.achievementDetail,
                              pathParameters: {RoutePaths.achievementIdParam: items[i].id},
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statusChip(String label, AchievementStatus? status) => AppFilterChip(
        label: label,
        selected: _status == status,
        onSelected: (_) => setState(() => _status = status),
      );
}
