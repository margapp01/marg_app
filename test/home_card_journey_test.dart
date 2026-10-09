import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/app/localization/app_localizations.dart';
import 'package:marg_app/app/theme/app_theme.dart';
import 'package:marg_app/features/home/domain/entities/home_dashboard.dart';
import 'package:marg_app/features/home/presentation/widgets/home_card_journey.dart';

Widget _host(Widget child) => MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: child)),
    );

void main() {
  test('next card milestone steps 1 → 5 → 10 … and ends after 100', () {
    expect(nextCardMilestone(0), 1);
    expect(nextCardMilestone(1), 5);
    expect(nextCardMilestone(17), 25);
    expect(nextCardMilestone(100), isNull);
  });

  testWidgets('a fresh devotee is invited to collect their first card', (tester) async {
    var found = false;
    await tester.pumpWidget(_host(CardJourneyCard(
      collected: 0,
      recent: const [],
      onFindTemple: () => found = true,
      onOpenCollection: () {},
      onOpenTemple: (_) {},
    )));
    await tester.pumpAndSettle();

    expect(find.text('Collect your first card'), findsOneWidget);
    expect(find.text('Visit a temple'), findsOneWidget);
    expect(find.text('Card unlocked'), findsOneWidget);
    await tester.tap(find.text('Find a temple near you'));
    expect(found, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a collector sees progress to the next milestone and the next temple', (tester) async {
    NearbyTemple? opened;
    final next = NearbyTemple.fromJson(const {'id': 't9', 'name': 'Somnath Temple', 'slug': 'somnath', 'city': 'Veraval'});
    await tester.pumpWidget(_host(CardJourneyCard(
      collected: 17,
      recent: const [HomeCard(id: 'c1', title: 'Kashi', rarity: 'EPIC')],
      nextTemple: next,
      onFindTemple: () {},
      onOpenCollection: () {},
      onOpenTemple: (t) => opened = t,
    )));
    await tester.pumpAndSettle();

    expect(find.text('17 Sacred Cards collected'), findsOneWidget);
    expect(find.text('8 more to reach 25 cards'), findsOneWidget);
    expect(find.text('Collect more'), findsOneWidget);
    await tester.tap(find.text('Somnath Temple'));
    expect(opened?.slug, 'somnath');
    expect(tester.takeException(), isNull);
  });
}
