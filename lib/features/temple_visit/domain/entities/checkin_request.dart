/// The exact payload for `POST /temples/:id/checkin`. Only fields the backend
/// validator accepts are included; unknown/unavailable signals (heading, speed,
/// battery, wifi BSSID, cell tower) are omitted rather than fabricated.
class CheckinRequest {
  const CheckinRequest({
    required this.latitude,
    required this.longitude,
    this.isMockLocation = false,
    this.isRooted = false,
    this.deviceId,
    this.appVersion,
    this.platform,
    this.deviceModel,
    this.altitude,
  });

  final double latitude;
  final double longitude;
  final bool isMockLocation;
  final bool isRooted;
  final String? deviceId;
  final String? appVersion;
  final String? platform;
  final String? deviceModel;
  final double? altitude;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'latitude': latitude,
        'longitude': longitude,
        'isMockLocation': isMockLocation,
        'isRooted': isRooted,
        if (deviceId != null && deviceId!.isNotEmpty) 'deviceId': deviceId,
        if (appVersion != null && appVersion!.isNotEmpty) 'appVersion': appVersion,
        if (platform != null) 'platform': platform,
        if (deviceModel != null && deviceModel!.isNotEmpty) 'deviceModel': deviceModel,
        if (altitude != null) 'altitude': altitude,
      };
}
