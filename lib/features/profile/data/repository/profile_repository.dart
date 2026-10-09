import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/cms_content.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/user_device.dart';
import '../datasource/profile_remote_datasource.dart';

/// Thin orchestration over the profile / devices / account / CMS datasource.
class ProfileRepository {
  ProfileRepository(this._remote);
  final ProfileRemoteDataSource _remote;

  Future<Profile> getProfile() => _remote.getProfile();

  Future<Profile> updateProfile({
    String? name,
    DateTime? dob,
    String? gender,
    String? city,
    String? preferredLanguage,
    List<String>? interests,
    List<String>? favoriteDeities,
    String? visitFrequency,
    List<String>? preferredRouteTypes,
    List<String>? festivalInterests,
    int? nearbyRadiusKm,
  }) =>
      _remote.updateProfile(
        name: name,
        dob: dob,
        gender: gender,
        city: city,
        preferredLanguage: preferredLanguage,
        interests: interests,
        favoriteDeities: favoriteDeities,
        visitFrequency: visitFrequency,
        preferredRouteTypes: preferredRouteTypes,
        festivalInterests: festivalInterests,
        nearbyRadiusKm: nearbyRadiusKm,
      );

  Future<Profile> uploadAvatar({required List<int> bytes, required String fileName, required String mimeType}) =>
      _remote.uploadAvatar(bytes: bytes, fileName: fileName, mimeType: mimeType);

  Future<List<UserDevice>> devices() => _remote.devices();
  Future<void> removeDevice(String id) => _remote.removeDevice(id);
  Future<void> deleteAccount() => _remote.deleteAccount();

  Future<List<Faq>> faqs() => _remote.faqs();
  Future<StaticPage> page(PageKind kind) => _remote.page(kind);
}

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(profileRemoteDataSourceProvider)),
);
