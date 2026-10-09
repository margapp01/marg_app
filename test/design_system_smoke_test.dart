import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/shared/design_system.dart';

/// A screen that instantiates a representative slice of the design system, so
/// the test proves the tokens + widgets build and lay out under the real theme.
class _Gallery extends StatelessWidget {
  const _Gallery();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Gallery',
      body: SingleChildScrollView(
        padding: AppSpacing.screenAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Text('MARG', style: context.brandText.displayLarge),
          Text('मंदिर दर्शन', style: context.textTheme.titleMedium),
          Text('Caption', style: context.caption),
          AppButton.primary(label: 'Primary', onPressed: () {}),
          const Gap(AppSpacing.sm),
          AppButton.danger(label: 'Delete', onPressed: () {}, icon: AppIcons.delete),
          const Gap(AppSpacing.sm),
          const AppTextField(label: 'Name'),
          const Gap(AppSpacing.sm),
          const PasswordField(),
          const Gap(AppSpacing.sm),
          const StatCard(label: 'Points', value: 1200, icon: AppIcons.points, animate: false),
          const Gap(AppSpacing.sm),
          const InfoCard(icon: AppIcons.temple, title: 'Temple', subtitle: 'Varanasi'),
          const Gap(AppSpacing.sm),
          Row(
            children: const [
              AppBadge(label: 'Active', tone: AppBadgeTone.success),
              Gap.h(AppSpacing.sm),
              TrustBadge(score: 82),
              Gap.h(AppSpacing.sm),
              PointsBadge(points: 340),
            ],
          ),
          const Gap(AppSpacing.sm),
          AppFilterChip(label: 'Nearby', selected: true, onSelected: (_) {}),
          const Gap(AppSpacing.sm),
          const SettingsTile.value(icon: AppIcons.language, title: 'Language', value: 'English'),
          const AppDivider(),
          const InfoTile(label: 'Visits', value: '12'),
          const Gap(AppSpacing.sm),
          const AppLinearProgress(value: 0.6),
          const Gap(AppSpacing.sm),
          const VisitsEmpty(),
          OfflineError(onRetry: () {}),
        ],
        ),
      ),
    );
  }
}

void main() {
  testWidgets('design system renders under AppTheme without errors',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const _Gallery()),
    );
    // Let finite entrance animations complete.
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Primary'), findsOneWidget);
    expect(find.text('Temple'), findsOneWidget);
    expect(find.text('No visits yet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
