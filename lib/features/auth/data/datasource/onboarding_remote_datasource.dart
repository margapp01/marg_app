import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';

/// Self-service onboarding endpoints under `/my/*`. Uses the authenticated
/// [dioProvider] so the Bearer access token is attached (and refreshed on 401)
/// by the interceptor.
class OnboardingRemoteDataSource {
  OnboardingRemoteDataSource(this._dio);

  final Dio _dio;

  /// `PATCH /my/profile` — partial update of the devotee's profile.
  Future<void> updateProfile(Map<String, dynamic> body) async {
    await _dio.patch<dynamic>('/my/profile', data: body);
  }

  /// `PUT /my/location` — upsert the current location.
  Future<void> updateLocation(Map<String, dynamic> body) async {
    await _dio.put<dynamic>('/my/location', data: body);
  }

  /// `PATCH /my/notification-preferences` — toggle notification categories.
  Future<void> updatePreferences(Map<String, dynamic> body) async {
    await _dio.patch<dynamic>('/my/notification-preferences', data: body);
  }

  /// `POST /my/profile/complete-onboarding` — idempotent completion stamp.
  Future<void> completeOnboarding() async {
    await _dio.post<dynamic>('/my/profile/complete-onboarding');
  }
}

final onboardingRemoteDataSourceProvider =
    Provider<OnboardingRemoteDataSource>(
  (ref) => OnboardingRemoteDataSource(ref.watch(dioProvider)),
);
