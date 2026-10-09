import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/app/localization/app_localizations.dart';
import 'package:marg_app/app/theme/app_theme.dart';
import 'package:marg_app/core/models/spiritual_choices.dart';
import 'package:marg_app/features/auth/presentation/pages/setup_page.dart';
import 'package:marg_app/features/auth/presentation/widgets/setup/setup_models.dart';

Widget _app(Locale locale) => ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SetupPage(),
      ),
    );

void main() {
  testWidgets('onboarding renders in Hindi (no English leakage)', (tester) async {
    await tester.pumpWidget(_app(const Locale('hi')));
    await tester.pump();

    // Localized step-1 copy + primary action are Hindi.
    expect(find.text('मार्ग में आपका स्वागत है! 🙏'), findsOneWidget);
    expect(find.text('आगे बढ़ें'), findsOneWidget);
    // The English source strings must not appear.
    expect(find.text('Welcome to Marg! 🙏'), findsNothing);
    expect(find.text('Continue'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('onboarding renders in English', (tester) async {
    await tester.pumpWidget(_app(const Locale('en')));
    await tester.pump();
    expect(find.text('Welcome to Marg! 🙏'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('setup enums expose localized labels for both locales', (tester) async {
    late AppLocalizations hi;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('hi'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(builder: (context) {
        hi = AppLocalizations.of(context);
        return const SizedBox.shrink();
      }),
    ));
    await tester.pump();

    // Every enum value must resolve to a non-empty, non-English-source label.
    for (final i in SetupInterest.values) {
      expect(i.localizedLabel(hi), isNotEmpty);
    }
    for (final g in SetupGender.values) {
      expect(g.localizedLabel(hi), isNotEmpty);
    }
    for (final d in DeityChoice.values) {
      expect(d.localizedLabel(hi), isNotEmpty);
    }
    for (final f in VisitFrequency.values) {
      expect(f.localizedLabel(hi), isNotEmpty);
      expect(f.localizedSubtitle(hi), isNotEmpty);
    }
    for (final r in YatraType.values) {
      expect(r.localizedLabel(hi), isNotEmpty);
    }
    for (final i in SetupInterest.values) {
      expect(i.localizedSubtitle(hi), isNotEmpty);
    }
    for (final n in SetupNotification.values) {
      expect(n.localizedTitle(hi), isNotEmpty);
      expect(n.localizedSubtitle(hi), isNotEmpty);
    }
    expect(SetupInterest.templeVisits.localizedLabel(hi), 'मंदिर दर्शन');
    expect(SetupGender.female.localizedLabel(hi), 'महिला');
    expect(DeityChoice.shiva.localizedLabel(hi), 'शिव');
  });
}
