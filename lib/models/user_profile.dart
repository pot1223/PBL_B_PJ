import 'package:hive/hive.dart';
import 'current_location.dart';
import 'interested_area.dart';
import 'housing_type.dart';

part 'user_profile.g.dart';

/// 사용자 프로필 모델
@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  String userId;

  @HiveField(1)
  CurrentLocation? currentLocation;

  @HiveField(2)
  List<InterestedArea> interestedAreas;

  @HiveField(3)
  bool hasPets;

  @HiveField(4)
  bool livesWithFamily;

  @HiveField(5)
  String housingTypeCode;

  @HiveField(6)
  bool hasVehicle;

  @HiveField(7)
  DateTime updatedAt;

  @HiveField(8)
  DateTime createdAt;

  UserProfile({
    required this.userId,
    this.currentLocation,
    List<InterestedArea>? interestedAreas,
    this.hasPets = false,
    this.livesWithFamily = false,
    this.housingTypeCode = 'apartment',
    this.hasVehicle = false,
    DateTime? updatedAt,
    DateTime? createdAt,
  })  : interestedAreas = interestedAreas ?? [],
        updatedAt = updatedAt ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  /// 주거 유형 enum 가져오기
  HousingType get housingType => HousingType.fromCode(housingTypeCode);

  /// 주거 유형 설정
  set housingType(HousingType type) {
    housingTypeCode = type.code;
  }

  /// 프로필 완성도 계산 (0-100)
  int get completeness {
    int score = 0;
    int total = 6;

    // 현위치 (자동이지만 존재 여부 체크)
    if (currentLocation != null && currentLocation!.isValid) score++;

    // 관심 지역 (선택사항이지만 있으면 가산점)
    if (interestedAreas.isNotEmpty) score++;

    // 주거 유형 (필수)
    if (housingTypeCode.isNotEmpty) score++;

    // 나머지는 기본값이 있어서 항상 카운트
    score += 3; // hasPets, livesWithFamily, hasVehicle

    return ((score / total) * 100).round();
  }

  /// 관심 지역 추가
  void addInterestedArea(InterestedArea area) {
    if (interestedAreas.length >= 5) {
      throw Exception('최대 5개의 관심 지역만 추가할 수 있습니다.');
    }
    interestedAreas.add(area);
    updatedAt = DateTime.now();
  }

  /// 관심 지역 제거
  void removeInterestedArea(String areaId) {
    interestedAreas.removeWhere((area) => area.id == areaId);
    _reorderInterestedAreas();
    updatedAt = DateTime.now();
  }

  /// 관심 지역 순서 재정렬
  void _reorderInterestedAreas() {
    for (int i = 0; i < interestedAreas.length; i++) {
      interestedAreas[i].order = i + 1;
    }
  }

  /// 관심 지역 순서 변경
  void reorderInterestedAreas(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final area = interestedAreas.removeAt(oldIndex);
    interestedAreas.insert(newIndex, area);
    _reorderInterestedAreas();
    updatedAt = DateTime.now();
  }

  /// 복사 생성자
  UserProfile copyWith({
    String? userId,
    CurrentLocation? currentLocation,
    List<InterestedArea>? interestedAreas,
    bool? hasPets,
    bool? livesWithFamily,
    String? housingTypeCode,
    bool? hasVehicle,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      currentLocation: currentLocation ?? this.currentLocation,
      interestedAreas: interestedAreas ?? List.from(this.interestedAreas),
      hasPets: hasPets ?? this.hasPets,
      livesWithFamily: livesWithFamily ?? this.livesWithFamily,
      housingTypeCode: housingTypeCode ?? this.housingTypeCode,
      hasVehicle: hasVehicle ?? this.hasVehicle,
      updatedAt: updatedAt ?? DateTime.now(),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'currentLocation': currentLocation?.toJson(),
      'interestedAreas': interestedAreas.map((a) => a.toJson()).toList(),
      'hasPets': hasPets,
      'livesWithFamily': livesWithFamily,
      'housingTypeCode': housingTypeCode,
      'hasVehicle': hasVehicle,
      'updatedAt': updatedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'completeness': completeness,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String,
      currentLocation: json['currentLocation'] != null
          ? CurrentLocation.fromJson(json['currentLocation'] as Map<String, dynamic>)
          : null,
      interestedAreas: (json['interestedAreas'] as List?)
          ?.map((a) => InterestedArea.fromJson(a as Map<String, dynamic>))
          .toList() ??
          [],
      hasPets: json['hasPets'] as bool? ?? false,
      livesWithFamily: json['livesWithFamily'] as bool? ?? false,
      housingTypeCode: json['housingTypeCode'] as String? ?? 'apartment',
      hasVehicle: json['hasVehicle'] as bool? ?? false,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'UserProfile(userId: $userId, completeness: $completeness%)';
  }
}