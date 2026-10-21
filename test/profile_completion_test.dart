import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/features/profile/domain/entities/profile.dart';
import 'package:marg_app/features/profile/domain/entities/profile_completion.dart';

void main() {
  test('a skipped onboarding leaves most of the profile to complete', () {
    final c = ProfileCompletion.of(Profile.fromJson(const {'id': 'u1', 'name': 'Asha'}));
    expect(c.isComplete, isFalse);
    expect(c.percent, 0);
    expect(c.next, ProfileItem.photo);
    expect(c.missing, contains(ProfileItem.mobile));
  });

  test('percent counts the filled items; preferences items route to Spiritual Preferences', () {
    final c = ProfileCompletion.of(Profile.fromJson(const {
      'id': 'u1',
      'profilePhoto': 'https://x/p.jpg',
      'phone': '+919876543210',
      'dob': '1990-01-01T00:00:00.000Z',
      'gender': 'FEMALE',
      'city': 'Pune',
      'interests': ['TEMPLE_VISITS'],
    }));
    expect(c.percent, 67);
    expect(c.next, ProfileItem.deities);
    expect(c.next!.onPreferences, isTrue);
  });
}
