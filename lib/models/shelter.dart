import 'package:hive/hive.dart';
import 'dart:math';

part 'shelter.g.dart';

/// 대피소 모델
@HiveType(typeId: 3)
class Shelter extends HiveObject {
  @HiveField(0)
  String name; // EQUP_NM (대피소명)

  @HiveField(1)
  String address; // LOC_SFPR_A (주소)

  @HiveField(2)
  double longitude; // XCORD (경도)

  @HiveField(3)
  double latitude; // YCORD (위도)

  @HiveField(4)
  String? phoneNumber; // 전화번호 (선택사항)

  @HiveField(5)
  int? capacity; // 수용 인원 (선택사항)

  @HiveField(6)
  String? facilityType; // 시설 유형 (선택사항)

  Shelter({
    required this.name,
    required this.address,
    required this.longitude,
    required this.latitude,
    this.phoneNumber,
    this.capacity,
    this.facilityType,
  });

  /// 위치가 유효한지 확인
  bool get isValid {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180 &&
        name.isNotEmpty;
  }

  /// 특정 위치로부터의 거리 계산 (km 단위)
  double distanceFrom(double targetLat, double targetLng) {
    const double earthRadiusKm = 6371.0;

    final lat1Rad = latitude * pi / 180.0;
    final lat2Rad = targetLat * pi / 180.0;
    final deltaLatRad = (targetLat - latitude) * pi / 180.0;
    final deltaLngRad = (targetLng - longitude) * pi / 180.0;

    final a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
            sin(deltaLngRad / 2) * sin(deltaLngRad / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  /// 복사 생성자
  Shelter copyWith({
    String? name,
    String? address,
    double? longitude,
    double? latitude,
    String? phoneNumber,
    int? capacity,
    String? facilityType,
  }) {
    return Shelter(
      name: name ?? this.name,
      address: address ?? this.address,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      capacity: capacity ?? this.capacity,
      facilityType: facilityType ?? this.facilityType,
    );
  }

  /// JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'longitude': longitude,
      'latitude': latitude,
      'phoneNumber': phoneNumber,
      'capacity': capacity,
      'facilityType': facilityType,
    };
  }

  factory Shelter.fromJson(Map<String, dynamic> json) {
    return Shelter(
      name: json['name'] as String,
      address: json['address'] as String,
      longitude: (json['longitude'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      phoneNumber: json['phoneNumber'] as String?,
      capacity: json['capacity'] as int?,
      facilityType: json['facilityType'] as String?,
    );
  }

  /// 엑셀/CSV 행에서 생성
  factory Shelter.fromExcelRow(List<dynamic> row) {
    return Shelter(
      name: row[0]?.toString() ?? '',
      address: row[1]?.toString() ?? '',
      longitude: double.tryParse(row[2]?.toString() ?? '0') ?? 0.0,
      latitude: double.tryParse(row[3]?.toString() ?? '0') ?? 0.0,
    );
  }

  @override
  String toString() {
    return 'Shelter(name: $name, address: $address, lat: $latitude, lng: $longitude)';
  }
}