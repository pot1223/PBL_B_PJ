import '../services/hive_service.dart';
import '../models/user_profile.dart';

/// 프로필 초기화 유틸리티 클래스
/// 앱 시작 시 프로필 준비를 담당
class ProfileInitializer {
  final HiveService _hiveService;

  ProfileInitializer(this._hiveService);

  /// 앱 초기화 시 호출
  /// 프로필이 없으면 자동으로 생성하고, 있으면 기존 프로필 반환
  Future<UserProfile> initialize({String? userId}) async {
    // userId가 없으면 기본값 사용
    final uid = userId ?? _generateDefaultUserId();

    // 프로필 가져오기 또는 생성
    final profile = await _hiveService.getOrCreateProfile(uid);

    return profile;
  }

  /// 기본 사용자 ID 생성
  /// 실제 앱에서는 Firebase Auth, Device ID 등을 사용할 수 있음
  String _generateDefaultUserId() {
    // 현재 시간 기반 ID (예시)
    return 'user_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 프로필 존재 여부 확인
  bool hasProfile() {
    return _hiveService.hasProfile();
  }

  /// 현재 프로필 가져오기
  UserProfile? getCurrentProfile() {
    return _hiveService.getProfile();
  }

  /// 프로필 리셋 (개발/테스트용)
  Future<void> resetProfile() async {
    await _hiveService.deleteProfile();
  }
}