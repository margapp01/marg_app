import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/key_value_store.dart';
import '../../../../core/storage/shared_prefs_store.dart';
import '../../domain/entities/app_preferences.dart';

/// Persists the device-local [AppPreferences] via the shared KeyValueStore.
class AppPreferencesStore {
  AppPreferencesStore(this._store);
  final KeyValueStore _store;

  static const _kUnits = 'prefs.units';
  static const _kReduceAnim = 'prefs.reduceAnimations';
  static const _kDataSaver = 'prefs.dataSaver';
  static const _kHighQuality = 'prefs.highQualityImages';

  Future<AppPreferences> load() async {
    final units = await _store.getString(_kUnits);
    return AppPreferences(
      units: units == 'miles' ? DistanceUnit.miles : DistanceUnit.kilometers,
      reduceAnimations: await _store.getBool(_kReduceAnim) ?? false,
      dataSaver: await _store.getBool(_kDataSaver) ?? false,
      highQualityImages: await _store.getBool(_kHighQuality) ?? true,
    );
  }

  Future<void> save(AppPreferences p) async {
    await _store.setString(_kUnits, p.units == DistanceUnit.miles ? 'miles' : 'kilometers');
    await _store.setBool(_kReduceAnim, value: p.reduceAnimations);
    await _store.setBool(_kDataSaver, value: p.dataSaver);
    await _store.setBool(_kHighQuality, value: p.highQualityImages);
  }
}

final appPreferencesStoreProvider = Provider<AppPreferencesStore>(
  (ref) => AppPreferencesStore(ref.watch(keyValueStoreProvider)),
);
