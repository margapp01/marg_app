// A registered device (`GET /my/devices`).

String? _s(Object? v) => v is String && v.isNotEmpty ? v : null;
bool _b(Object? v) => v == true;
DateTime? _dt(Object? v) => v is String ? DateTime.tryParse(v) : null;

class UserDevice {
  const UserDevice({
    required this.id,
    required this.platform,
    this.fcmToken,
    this.appVersion,
    this.deviceModel,
    this.lastSeenAt,
    this.isActive = true,
  });

  final String id;
  final String platform; // ANDROID | IOS | WEB
  final String? fcmToken;
  final String? appVersion;
  final String? deviceModel;
  final DateTime? lastSeenAt;
  final bool isActive;

  factory UserDevice.fromJson(Map<String, dynamic> j) => UserDevice(
        id: _s(j['id']) ?? '',
        platform: _s(j['platform']) ?? 'ANDROID',
        fcmToken: _s(j['fcmToken']),
        appVersion: _s(j['appVersion']),
        deviceModel: _s(j['deviceModel']),
        lastSeenAt: _dt(j['lastSeenAt']),
        isActive: _b(j['isActive']),
      );
}
