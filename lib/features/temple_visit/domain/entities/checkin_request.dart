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
    this.offline = false,
    this.capturedAt,
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

  /// Captured at the shrine without network and submitted later.
  final bool offline;

  /// When the GPS fix was taken (sent for offline check-ins).
  final DateTime? capturedAt;

  /// The same check-in, kept to be submitted once the network returns.
  CheckinRequest forOffline(DateTime capturedAt) => CheckinRequest(
        latitude: latitude,
        longitude: longitude,
        isMockLocation: isMockLocation,
        isRooted: isRooted,
        deviceId: deviceId,
        appVersion: appVersion,
        platform: platform,
        deviceModel: deviceModel,
        altitude: altitude,
        offline: true,
        capturedAt: capturedAt,
      );

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
        if (offline) 'offline': true,
        if (offline && capturedAt != null) 'capturedAt': capturedAt!.toUtc().toIso8601String(),
      };

  /// Reads back a request saved with [toJson].
  factory CheckinRequest.fromJson(Map<String, dynamic> j) => CheckinRequest(
        latitude: (j['latitude'] as num).toDouble(),
        longitude: (j['longitude'] as num).toDouble(),
        isMockLocation: j['isMockLocation'] == true,
        isRooted: j['isRooted'] == true,
        deviceId: j['deviceId'] as String?,
        appVersion: j['appVersion'] as String?,
        platform: j['platform'] as String?,
        deviceModel: j['deviceModel'] as String?,
        altitude: (j['altitude'] as num?)?.toDouble(),
        offline: j['offline'] == true,
        capturedAt: DateTime.tryParse((j['capturedAt'] as String?) ?? ''),
      );
}
