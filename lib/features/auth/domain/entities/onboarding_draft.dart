import '../../../../core/location/captured_location.dart';
import '../../../../core/media/picked_photo.dart';

/// Everything the devotee supplies across the onboarding steps, in
/// backend-ready primitives. The presentation layer maps its UI enums
/// (`SetupInterest`, `SetupLanguage`, `SetupGender`) to wire values before
/// building this; the data layer serialises it onto the `/my/*` contracts.
class OnboardingDraft {
  const OnboardingDraft({
    this.name,
    this.mobile,
    this.dob,
    this.gender,
    this.city,
    this.profilePhoto,
    this.interests = const [],
    this.favoriteDeities = const [],
    this.visitFrequency,
    this.preferredRouteTypes = const [],
    this.preferredLanguage = 'EN',
    this.notificationPreferences = const {},
    this.location,
    this.pickedPhoto,
  });

  final String? name;

  /// E.164 mobile (e.g. `+919876543210`) — only set for a brand-new Google
  /// account that still needs to complete registration.
  final String? mobile;
  final DateTime? dob;

  /// Backend `Gender` value, or null if unspecified.
  final String? gender;
  final String? city;
  final String? profilePhoto;

  /// Backend `UserInterestType` values.
  final List<String> interests;

  /// Backend `DeityType` values.
  final List<String> favoriteDeities;

  /// Backend `VisitFrequency` value, or null if unspecified.
  final String? visitFrequency;

  /// Backend `RouteType` values (empty = "not sure yet").
  final List<String> preferredRouteTypes;

  /// Backend `Language` value.
  final String preferredLanguage;

  /// `NotificationPreference` boolean flags.
  final Map<String, bool> notificationPreferences;
  final CapturedLocation? location;

  /// A newly-picked avatar to upload during submit. When null, [profilePhoto]
  /// (the Google photo URL) is kept as-is.
  final PickedPhoto? pickedPhoto;

  /// Body for `PATCH /my/profile` — omits fields the user left blank so the
  /// partial update never clears server data.
  Map<String, dynamic> profilePatch() => {
        if (name != null && name!.isNotEmpty) 'name': name,
        if (dob != null) 'dob': dob!.toUtc().toIso8601String(),
        if (gender != null) 'gender': gender,
        if (city != null && city!.isNotEmpty) 'city': city,
        if (profilePhoto != null && profilePhoto!.isNotEmpty)
          'profilePhoto': profilePhoto,
        'preferredLanguage': preferredLanguage,
        'interests': interests,
        'favoriteDeities': favoriteDeities,
        if (visitFrequency != null) 'visitFrequency': visitFrequency,
        'preferredRouteTypes': preferredRouteTypes,
      };
}
