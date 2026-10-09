import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/shared/design_system.dart';

const _items = [
  AppNavItem(icon: AppIcons.home, label: 'Home'),
  AppNavItem(icon: AppIcons.explore, label: 'Explore'),
  AppNavItem(icon: AppIcons.temple, label: 'Yatra'),
  AppNavItem(icon: AppIcons.passport, label: 'Passport'),
  AppNavItem(icon: AppIcons.profile, label: 'Profile'),
];

Widget _nav({required int current, required ValueChanged<int> onSelect}) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        bottomNavigationBar: AppBottomNav(items: _items, currentIndex: current, onDestinationSelected: onSelect),
      ),
    );

void main() {
  testWidgets('renders every destination with the active one selected', (tester) async {
    await tester.pumpWidget(_nav(current: 0, onSelect: (_) {}));
    for (final item in _items) {
      expect(find.text(item.label), findsOneWidget);
    }
    expect(tester.getSemantics(find.bySemanticsLabel('Home')), matchesSemantics(isButton: true, isSelected: true, hasSelectedState: true, label: 'Home', hasTapAction: true));
    expect(tester.takeException(), isNull);
  });

  testWidgets('every tab, including the centre one, reports its index', (tester) async {
    final taps = <int>[];
    await tester.pumpWidget(_nav(current: 0, onSelect: taps.add));

    await tester.tap(find.text('Passport'));
    await tester.tap(find.byIcon(AppIcons.temple));
    await tester.pump();

    expect(taps, [3, 2]);
  });
}
