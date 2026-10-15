import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/app/localization/app_localizations.dart';
import 'package:marg_app/app/theme/app_icons.dart';
import 'package:marg_app/app/theme/app_theme.dart';
import 'package:marg_app/core/services/app_update_service.dart';
import 'package:marg_app/core/storage/key_value_store.dart';
import 'package:marg_app/shared/feedback/app_update_gate.dart';

class _Store implements KeyValueStore {
  final values = <String, Object>{};
  @override
  Future<String?> getString(String key) async => values[key] as String?;
  @override
  Future<void> setString(String key, String value) async => values[key] = value;
  @override
  Future<bool?> getBool(String key) async => values[key] as bool?;
  @override
  Future<void> setBool(String key, {required bool value}) async => values[key] = value;
  @override
  Future<void> remove(String key) async => values.remove(key);
}

class _Service extends AppUpdateService {
  _Service(this.result, this.store) : super(dio: Dio(), store: store);
  final AppUpdateCheck result;
  final _Store store;
  @override
  Future<AppUpdateCheck?> check() async => result;
}

Future<_Store> _pump(WidgetTester tester, UpdateLevel level) async {
  final store = _Store();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appUpdateServiceProvider.overrideWithValue(
          _Service(AppUpdateCheck(level: level, version: '2.1.0', notes: 'Faster temple search.'), store),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => AppUpdateGate(child: child!),
        home: const Scaffold(body: Text('home')),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return store;
}

void main() {
  testWidgets('a major update covers the app with no way to dismiss it', (tester) async {
    await _pump(tester, UpdateLevel.major);
    expect(find.text('Time to update MARG'), findsOneWidget);
    expect(find.text('Update now'), findsOneWidget);
    expect(find.text('Later'), findsNothing);
    expect(find.text('Faster temple search.'), findsOneWidget);
  });

  testWidgets('a minor update asks, and "Later" snoozes it', (tester) async {
    final store = await _pump(tester, UpdateLevel.minor);
    expect(find.text('A new MARG is here'), findsOneWidget);
    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();
    expect(find.text('A new MARG is here'), findsNothing);
    expect(store.values['appUpdate.snoozed'], startsWith('2.1.0|'));
  });

  testWidgets('a patch update is a dismissible hint over the app', (tester) async {
    await _pump(tester, UpdateLevel.patch);
    expect(find.text('home'), findsOneWidget);
    expect(find.textContaining('v2.1.0'), findsOneWidget);
    await tester.tap(find.byIcon(AppIcons.close));
    await tester.pumpAndSettle();
    expect(find.textContaining('v2.1.0'), findsNothing);
  });
}
