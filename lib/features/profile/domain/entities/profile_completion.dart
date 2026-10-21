import 'profile.dart';

/// A profile detail that counts towards "X% complete". Onboarding can be
/// skipped after the first step, so these are what's left to fill in later.
enum ProfileItem {
  photo(_Where.edit),
  mobile(_Where.edit),
  birthday(_Where.edit),
  gender(_Where.edit),
  city(_Where.edit),
  interests(_Where.preferences),
  deities(_Where.preferences),
  visitFrequency(_Where.preferences),
  yatras(_Where.preferences);

  const ProfileItem(this._where);
  final _Where _where;

  /// Filled in on Spiritual Preferences (else on Edit Profile).
  bool get onPreferences => _where == _Where.preferences;
}

enum _Where { edit, preferences }

/// How complete the devotee's profile is and which [ProfileItem]s are missing.
class ProfileCompletion {
  const ProfileCompletion._(this.missing);

  factory ProfileCompletion.of(Profile p) {
    bool blank(String? v) => v == null || v.trim().isEmpty;
    return ProfileCompletion._([
      if (blank(p.profilePhoto)) ProfileItem.photo,
      if (blank(p.phone)) ProfileItem.mobile,
      if (p.dob == null) ProfileItem.birthday,
      if (blank(p.gender)) ProfileItem.gender,
      if (blank(p.city)) ProfileItem.city,
      if (p.interests.isEmpty) ProfileItem.interests,
      if (p.favoriteDeities.isEmpty) ProfileItem.deities,
      if (blank(p.visitFrequency)) ProfileItem.visitFrequency,
      if (p.preferredRouteTypes.isEmpty) ProfileItem.yatras,
    ]);
  }

  /// Missing items, in the order they're asked for.
  final List<ProfileItem> missing;

  int get total => ProfileItem.values.length;
  int get filled => total - missing.length;
  int get percent => (filled * 100 / total).round();
  bool get isComplete => missing.isEmpty;

  /// The first missing item — where "Complete now" takes the devotee.
  ProfileItem? get next => missing.firstOrNull;
}
