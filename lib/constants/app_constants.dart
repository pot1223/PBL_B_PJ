/// 앱 전역 상수
class AppConstants {
  AppConstants._();

  /// 관심 지역 설정 이유 옵션
  static const List<String> interestedAreaReasons = [
    '집',
    '직장',
    '자주 가는 곳',
    '부모님 댁',
    '친척 댁',
    '친구 집',
    '자주 가는 길',
  ];

  /// 관심 지역 최대 개수
  static const int maxInterestedAreas = 5;

  /// 위치 업데이트 만료 시간 (분)
  static const int locationExpiryMinutes = 30;
}