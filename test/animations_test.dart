import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/shared/animations/animations.dart';

Widget _host({required bool disableAnimations, required Widget child}) => MaterialApp(
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: disableAnimations),
          child: Scaffold(body: child),
        ),
      ),
    );

void main() {
  group('Reduce Animations', () {
    testWidgets('AppEntrance shows its child immediately when disabled', (tester) async {
      await tester.pumpWidget(_host(
        disableAnimations: true,
        child: const FadeIn(child: Text('hello')),
      ));
      // No pump-and-settle: the child must be present on the very first frame.
      expect(find.text('hello'), findsOneWidget);
      final opacity = tester.widgetList<Opacity>(find.byType(Opacity));
      expect(opacity, isEmpty, reason: 'entrance opacity animation should be skipped');
    });

    testWidgets('AppEntrance still animates when enabled', (tester) async {
      await tester.pumpWidget(_host(
        disableAnimations: false,
        child: const FadeIn(child: Text('hi')),
      ));
      // Mid-flight it is wrapped in an Opacity (fading in).
      await tester.pump(const Duration(milliseconds: 1));
      expect(find.byType(Opacity), findsWidgets);
      await tester.pumpAndSettle();
      expect(find.text('hi'), findsOneWidget);
    });

    testWidgets('ConfettiOverlay renders nothing when animations are disabled', (tester) async {
      await tester.pumpWidget(_host(
        disableAnimations: true,
        child: const ConfettiOverlay(),
      ));
      // The overlay itself paints nothing (its subtree has no CustomPaint).
      expect(
        find.descendant(of: find.byType(ConfettiOverlay), matching: find.byType(CustomPaint)),
        findsNothing,
      );
    });
  });
}
