import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/app/localization/app_localizations.dart';
import 'package:marg_app/app/theme/app_theme.dart';
import 'package:marg_app/features/auth/presentation/widgets/setup/setup_complete_view.dart';

Widget _app(Locale locale, VoidCallback onStart) => MaterialApp(
      theme: AppTheme.light,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SetupCompleteView(onStart: onStart)),
    );

void main() {
  testWidgets('"You\'re all set" names the brand and starts the journey', (tester) async {
    var started = 0;
    await tester.pumpWidget(_app(const Locale('en'), () => started++));
    await tester.pumpAndSettle();

    expect(find.text("You're all set! 🎉"), findsOneWidget);
    expect(find.textContaining('MARG', findRichText: true), findsOneWidget);
    expect(find.text("What's next?"), findsOneWidget);

    await tester.tap(find.text('Start My Journey'));
    expect(started, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('"You\'re all set" renders in Hindi', (tester) async {
    await tester.pumpWidget(_app(const Locale('hi'), () {}));
    await tester.pumpAndSettle();

    expect(find.text('मेरी यात्रा आरंभ करें'), findsOneWidget);
    expect(find.textContaining('MARG के साथ', findRichText: true), findsOneWidget);
    expect(find.text('Start My Journey'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
