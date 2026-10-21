import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/app/theme/app_theme.dart';
import 'package:marg_app/shared/components/scratch_card.dart';

Widget _host(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: Center(child: SizedBox(width: 300, child: child))),
    );

ScratchCard _card({bool enabled = true, VoidCallback? onRevealed}) => ScratchCard(
      enabled: enabled,
      semanticLabel: 'Scratch card',
      onRevealed: onRevealed,
      cover: const ColoredBox(color: Colors.amber, child: Center(child: Text('Scratch me'))),
      child: const SizedBox(height: 200, child: Center(child: Text('Prize'))),
    );

Future<void> _scrub(WidgetTester tester) async {
  final box = tester.getRect(find.byType(ScratchCard));
  for (var row = 0; row < 8; row++) {
    final y = box.top + 12 + row * (box.height - 24) / 7;
    final gesture = await tester.startGesture(Offset(box.left + 8, y));
    for (var x = box.left + 8; x < box.right - 8; x += 12) {
      await gesture.moveTo(Offset(x, y));
    }
    await gesture.up();
  }
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('scratching most of the card reveals the prize once', (tester) async {
    var revealed = 0;
    await tester.pumpWidget(_host(_card(onRevealed: () => revealed++)));
    await _scrub(tester);
    await _scrub(tester);
    expect(revealed, 1);
    expect(find.text('Prize'), findsOneWidget);
    final cover = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
    expect(cover.opacity, 0);
  });

  testWidgets('a locked card cannot be scratched', (tester) async {
    var revealed = 0;
    await tester.pumpWidget(_host(_card(enabled: false, onRevealed: () => revealed++)));
    await _scrub(tester);
    expect(revealed, 0);
    expect(tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity, 1);
  });

  testWidgets('screen readers reveal it in one action', (tester) async {
    final semantics = tester.ensureSemantics();
    var revealed = 0;
    await tester.pumpWidget(_host(_card(onRevealed: () => revealed++)));
    expect(find.semantics.byLabel('Prize'), findsNothing);
    tester.semantics.tap(find.semantics.byLabel('Scratch card'));
    await tester.pumpAndSettle();
    expect(revealed, 1);
    expect(find.semantics.byLabel('Prize'), findsOne);
    semantics.dispose();
  });

  testWidgets('an already scratched card shows the prize without a cover', (tester) async {
    await tester.pumpWidget(_host(const ScratchCard(
      revealed: true,
      semanticLabel: 'Scratch card',
      cover: Text('Scratch me'),
      child: Text('Prize'),
    )));
    expect(find.text('Prize'), findsOneWidget);
    expect(find.text('Scratch me'), findsNothing);
  });
}
