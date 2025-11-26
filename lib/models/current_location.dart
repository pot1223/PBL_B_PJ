import 'package:hive/hive.dart';

part 'current_location.g.dart';

/// 현재 위치 모델
@HiveType(typeId: 2)
class CurrentLocation extends HiveObject {
  @HiveField(0)
  String address;

  @HiveField(1)
  double latitude;

  @HiveField(2)
  double longitude;

  @HiveField(3)
  DateTime lastUpdated;

  @HiveField(4)
  bool isAutoDetected;

  CurrentLocation({
    required this.address,
    required this.latitude,
    required this.longitude,
    DateTime? lastUpdated,
    this.isAutoDetected = true,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  /// 위치가 유효한지 확인
  bool get isValid {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180 &&
        address.isNotEmpty;
  }

  /// 마지막 업데이트로부터 경과 시간 (분)
  int get minutesSinceUpdate {
    return DateTime.now().difference(lastUpdated).inMinutes;
  }

  /// 복사 생성자
  CurrentLocation copyWith({
    String? address,
    double? latitude,
    double? longitude,
    DateTime? lastUpdated,
    bool? isAutoDetected,
  }) {
    return CurrentLocation(
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isAutoDetected: isAutoDetected ?? this.isAutoDetected,
    );
  }

  /// JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isAutoDetected': isAutoDetected,
    };
  }

  factory CurrentLocation.fromJson(Map<String, dynamic> json) {
    return CurrentLocation(
      address: json['address'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      isAutoDetected: json['isAutoDetected'] as bool? ?? true,
    );
  }

  @override
  String toString() {
    return 'CurrentLocation(address: $address, lat: $latitude, lng: $longitude)';
  }
}