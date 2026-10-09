import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:marg_app/app/localization/app_localizations.dart';
import 'package:marg_app/app/router/app_shell.dart';
import 'package:marg_app/core/location/location_access.dart';
import 'package:marg_app/shared/design_system.dart';

const _paths = ['/home', '/explore', '/yatra', '/passport', '/profile'];

GoRouter _router(String initial) => GoRouter(
      initialLocation: initial,
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => AppShell(navigationShell: shell),
          branches: [
            for (final path in _paths)
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: path,
                    builder: (_, _) => Text('page $path'),
                    routes: [GoRoute(path: 'child', builder: (_, _) => Text('child $path'))],
                  ),
                ],
              ),
          ],
        ),
      ],
    );

Future<void> _pump(WidgetTester tester, GoRouter router) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [locationAccessReaderProvider.overrideWithValue(() async => LocationAccess.granted)],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _systemBack(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Back at the root of another tab returns to Home', (tester) async {
    final router = _router('/passport');
    await _pump(tester, router);
    expect(find.text('page /passport'), findsOneWidget);

    await _systemBack(tester);

    expect(find.text('page /home'), findsOneWidget);
    expect(router.routeInformationProvider.value.uri.path, '/home');
  });

  testWidgets('Back pops inside a tab before returning to Home', (tester) async {
    final router = _router('/explore');
    await _pump(tester, router);
    router.go('/explore/child');
    await tester.pumpAndSettle();
    expect(find.text('child /explore'), findsOneWidget);

    await _systemBack(tester);
    expect(find.text('page /explore'), findsOneWidget);

    await _systemBack(tester);
    expect(find.text('page /home'), findsOneWidget);
  });

  testWidgets('Back at Home asks before exiting; Back again exits', (tester) async {
    final calls = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      calls.add(call.method);
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    final router = _router('/home');
    await _pump(tester, router);

    await _systemBack(tester);
    expect(find.text('Leaving so soon?'), findsOneWidget);
    expect(calls, isNot(contains('SystemNavigator.pop')));

    await tester.tap(find.text('Stay'));
    await tester.pumpAndSettle();
    expect(find.text('Leaving so soon?'), findsNothing);
    expect(find.text('page /home'), findsOneWidget);

    await _systemBack(tester);
    await _systemBack(tester);
    expect(calls, contains('SystemNavigator.pop'));
  });
}
