/// The authenticated user (backend SafeUser). Onboarding routing reads
/// [onboardingCompletedAt] / [isOnboarded].
class AuthUser {
  const AuthUser({
    required this.id,
    this.email,
    this.phone,
    this.name,
    this.profilePhoto,
    this.dob,
    this.gender,
    this.city,
    this.preferredLanguage = 'EN',
    this.interests = const [],
    this.isActive = false,
    this.isPhoneVerified = false,
    this.onboardingCompletedAt,
  });

  final String id;
  final String? email;
  final String? phone;
  final String? name;
  final String? profilePhoto;
  final DateTime? dob;
  final String? gender;
  final String? city;
  final String preferredLanguage;
  final List<String> interests;
  final bool isActive;
  final bool isPhoneVerified;
  final DateTime? onboardingCompletedAt;

  bool get isOnboarded => onboardingCompletedAt != null;

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String,
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        name: json['name'] as String?,
        profilePhoto: json['profilePhoto'] as String?,
        dob: json['dob'] == null ? null : DateTime.tryParse(json['dob'] as String),
        gender: json['gender'] as String?,
        city: json['city'] as String?,
        preferredLanguage: (json['preferredLanguage'] as String?) ?? 'EN',
        interests: ((json['interests'] as List?) ?? const [])
            .map((e) => e as String)
            .toList(),
        isActive: (json['isActive'] as bool?) ?? false,
        isPhoneVerified: (json['isPhoneVerified'] as bool?) ?? false,
        onboardingCompletedAt: json['onboardingCompletedAt'] == null
            ? null
            : DateTime.tryParse(json['onboardingCompletedAt'] as String),
      );
}
