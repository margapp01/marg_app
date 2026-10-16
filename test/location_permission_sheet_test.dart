import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/app/localization/app_localizations.dart';
import 'package:marg_app/core/location/location_access.dart';
import 'package:marg_app/shared/design_system.dart';

void main() {
  testWidgets('a repeated "granted" closes the sheet once and keeps the page under it', (tester) async {
    var access = LocationAccess.denied;
    bool? result;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [locationAccessReaderProvider.overrideWithValue(() async => access)],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async => result = await LocationPermissionSheet.show(context),
                child: const Text('home page'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('home page'));
    await tester.pumpAndSettle();
    expect(find.byType(LocationPermissionSheet), findsOneWidget);

    // The system dialog's answer and the resume after it both re-read access.
    access = LocationAccess.granted;
    final container = ProviderScope.containerOf(tester.element(find.byType(LocationPermissionSheet)));
    await container.read(locationAccessProvider.notifier).refresh();
    await container.read(locationAccessProvider.notifier).refresh();
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(find.byType(LocationPermissionSheet), findsNothing);
    expect(find.text('home page'), findsOneWidget);
  });
}
