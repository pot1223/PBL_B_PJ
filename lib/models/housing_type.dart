/// 주거 유형 열거형
enum HousingType {
  apartment('아파트', 'apartment'),
  semiBasement('반지하', 'semi_basement'),
  detachedHouse('단독주택', 'detached_house'),
  officetel('오피스텔', 'officetel'),
  dormitory('기숙사', 'dormitory');

  const HousingType(this.displayName, this.code);

  final String displayName;
  final String code;

  /// 코드로부터 HousingType 찾기
  static HousingType fromCode(String code) {
    return HousingType.values.firstWhere(
          (type) => type.code == code,
      orElse: () => HousingType.apartment,
    );
  }

  /// displayName으로부터 HousingType 찾기
  static HousingType fromDisplayName(String displayName) {
    return HousingType.values.firstWhere(
          (type) => type.displayName == displayName,
      orElse: () => HousingType.apartment,
    );
  }
}