// lib/models/archive.dart

class Archive {
  /// 예: "침수 위험"
  final String disasterName;

  /// 예: "서울특별시 영등포구"
  final String location;

  /// 알림/상담 생성 시각
  final DateTime created;

  /// 카드에서 크게 보이는 제목
  final String title;

  /// 카드에서 2줄 정도로 보이는 설명
  final String description;


  Archive({
    required this.disasterName,
    required this.location,
    required this.created,
    required this.title,
    required this.description,
  });
}

