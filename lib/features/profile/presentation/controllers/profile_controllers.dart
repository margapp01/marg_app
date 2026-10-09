import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/app_preferences_store.dart';
import '../../data/repository/profile_repository.dart';
import '../../domain/entities/app_preferences.dart';
import '../../domain/entities/cms_content.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/user_device.dart';

/// The self profile (`GET /my/profile`).
final profileProvider = FutureProvider.autoDispose<Profile>(
  (ref) => ref.watch(profileRepositoryProvider).getProfile(),
);

/// Registered devices (`GET /my/devices`).
final devicesProvider = FutureProvider.autoDispose<List<UserDevice>>(
  (ref) => ref.watch(profileRepositoryProvider).devices(),
);

/// Help & Support FAQs.
final faqsProvider = FutureProvider.autoDispose<List<Faq>>(
  (ref) => ref.watch(profileRepositoryProvider).faqs(),
);

/// A CMS static page (privacy / terms / about / contact).
final staticPageProvider = FutureProvider.autoDispose.family<StaticPage, PageKind>(
  (ref, kind) => ref.watch(profileRepositoryProvider).page(kind),
);

/// Device-local app preferences — kept alive app-wide so the root MaterialApp
/// can honor `reduceAnimations`.
class AppPreferencesController extends AsyncNotifier<AppPreferences> {
  @override
  Future<AppPreferences> build() => ref.watch(appPreferencesStoreProvider).load();

  Future<void> _update(AppPreferences next) async {
    state = AsyncData(next);
    await ref.read(appPreferencesStoreProvider).save(next);
  }

  Future<void> setUnits(DistanceUnit v) async => _update((state.valueOrNull ?? AppPreferences.defaults).copyWith(units: v));
  Future<void> setReduceAnimations(bool v) async => _update((state.valueOrNull ?? AppPreferences.defaults).copyWith(reduceAnimations: v));
  Future<void> setDataSaver(bool v) async => _update((state.valueOrNull ?? AppPreferences.defaults).copyWith(dataSaver: v));
  Future<void> setHighQualityImages(bool v) async => _update((state.valueOrNull ?? AppPreferences.defaults).copyWith(highQualityImages: v));
}

final appPreferencesProvider =
    AsyncNotifierProvider<AppPreferencesController, AppPreferences>(AppPreferencesController.new);
