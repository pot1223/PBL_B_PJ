import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_profile.dart';
import '../models/current_location.dart';
import '../models/interested_area.dart';

/// Hive 로컬 저장소 서비스
/// Repository 패턴으로 데이터 접근 추상화
class HiveService {
  static const String _profileBoxName = 'user_profile_box';
  static const String _profileKey = 'current_user_profile';

  Box<UserProfile>? _profileBox;

  /// Hive 초기화
  Future<void> initialize() async {
    await Hive.initFlutter();

    // TypeAdapter 등록
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserProfileAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(InterestedAreaAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(CurrentLocationAdapter());
    }

    // Box 열기
    _profileBox = await Hive.openBox<UserProfile>(_profileBoxName);
  }

  /// Box getter (null 체크)
  Box<UserProfile> get _box {
    if (_profileBox == null || !_profileBox!.isOpen) {
      throw Exception('Hive가 초기화되지 않았습니다. initialize()를 먼저 호출하세요.');
    }
    return _profileBox!;
  }

  // ==================== CRUD Operations ====================

  /// 프로필 저장
  Future<void> saveProfile(UserProfile profile) async {
    profile.updatedAt = DateTime.now();
    await _box.put(_profileKey, profile);
  }

  /// 프로필 불러오기
  UserProfile? getProfile() {
    return _box.get(_profileKey);
  }

  /// 프로필 존재 여부
  bool hasProfile() {
    return _box.containsKey(_profileKey);
  }

  /// 프로필 삭제
  Future<void> deleteProfile() async {
    await _box.delete(_profileKey);
  }

  /// 프로필 초기화 (새 프로필 생성)
  Future<UserProfile> createDefaultProfile(String userId) async {
    final profile = UserProfile(userId: userId);
    await saveProfile(profile);
    return profile;
  }

  /// 프로필 가져오기 또는 생성 (없으면 자동 생성)
  /// 앱 시작 시 이 메서드를 호출하면 프로필이 자동으로 준비됨
  Future<UserProfile> getOrCreateProfile(String userId) async {
    // 로컬에 프로필이 있는지 확인
    final existingProfile = getProfile();

    if (existingProfile != null) {
      // 프로필이 있으면 반환
      return existingProfile;
    }

    // 프로필이 없으면 기본값으로 생성
    final defaultProfile = UserProfile(
      userId: userId,
      currentLocation: null,
      interestedAreas: [],
      hasPets: false,
      livesWithFamily: false,
      housingTypeCode: 'apartment', // 기본값: 아파트
      hasVehicle: false,
    );

    await saveProfile(defaultProfile);
    return defaultProfile;
  }

  // ==================== Specific Field Updates ====================

  /// 현위치 업데이트
  Future<void> updateCurrentLocation(CurrentLocation location) async {
    final profile = getProfile();
    if (profile == null) return;

    profile.currentLocation = location;
    await saveProfile(profile);
  }

  /// 관심 지역 추가
  Future<void> addInterestedArea(InterestedArea area) async {
    final profile = getProfile();
    if (profile == null) return;

    profile.addInterestedArea(area);
    await saveProfile(profile);
  }

  /// 관심 지역 제거
  Future<void> removeInterestedArea(String areaId) async {
    final profile = getProfile();
    if (profile == null) return;

    profile.removeInterestedArea(areaId);
    await saveProfile(profile);
  }

  /// 관심 지역 순서 변경
  Future<void> reorderInterestedAreas(int oldIndex, int newIndex) async {
    final profile = getProfile();
    if (profile == null) return;

    profile.reorderInterestedAreas(oldIndex, newIndex);
    await saveProfile(profile);
  }

  /// 반려동물 동거 여부 업데이트
  Future<void> updateHasPets(bool hasPets) async {
    final profile = getProfile();
    if (profile == null) return;

    final updated = profile.copyWith(hasPets: hasPets);
    await saveProfile(updated);
  }

  /// 가족 동거 여부 업데이트
  Future<void> updateLivesWithFamily(bool livesWithFamily) async {
    final profile = getProfile();
    if (profile == null) return;

    final updated = profile.copyWith(livesWithFamily: livesWithFamily);
    await saveProfile(updated);
  }

  /// 주거 유형 업데이트
  Future<void> updateHousingType(String housingTypeCode) async {
    final profile = getProfile();
    if (profile == null) return;

    final updated = profile.copyWith(housingTypeCode: housingTypeCode);
    await saveProfile(updated);
  }

  /// 차량 소유 여부 업데이트
  Future<void> updateHasVehicle(bool hasVehicle) async {
    final profile = getProfile();
    if (profile == null) return;

    final updated = profile.copyWith(hasVehicle: hasVehicle);
    await saveProfile(updated);
  }

  // ==================== Utility Methods ====================

  /// 프로필 완성도 가져오기
  int? getProfileCompleteness() {
    final profile = getProfile();
    return profile?.completeness;
  }

  /// Box 닫기 (앱 종료 시)
  Future<void> close() async {
    await _box.close();
  }

  /// 모든 데이터 삭제 (개발/테스트용)
  Future<void> clearAll() async {
    await _box.clear();
  }

  // ==================== Stream for Real-time Updates ====================

  /// 프로필 변경 감지 스트림
  Stream<UserProfile?> watchProfile() {
    return _box.watch(key: _profileKey).map((_) => getProfile());
  }
}