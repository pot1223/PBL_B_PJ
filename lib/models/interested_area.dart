import 'package:hive/hive.dart';
part 'interested_area.g.dart';

/// 관심 지역 모델
@HiveType(typeId: 1)
class InterestedArea extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String address;

  @HiveField(2)
  List<String> reasons;

  @HiveField(3)
  String? customReason;

  @HiveField(4)
  int order;

  @HiveField(5)
  DateTime createdAt;

  InterestedArea({
    required this.id,
    required this.address,
    required this.reasons,
    this.customReason,
    required this.order,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// 해시태그 형태로 변환 (ex: #직장 #자주가는곳)
  String get hashtagReasons {
    final tags = reasons.map((r) => '#$r').toList();
    if (customReason != null && customReason!.isNotEmpty) {
      tags.add('#$customReason');
    }
    return tags.join(' ');
  }

  /// 복사 생성자
  InterestedArea copyWith({
    String? id,
    String? address,
    List<String>? reasons,
    String? customReason,
    int? order,
    DateTime? createdAt,
  }) {
    return InterestedArea(
      id: id ?? this.id,
      address: address ?? this.address,
      reasons: reasons ?? List.from(this.reasons),
      customReason: customReason ?? this.customReason,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'reasons': reasons,
      'customReason': customReason,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory InterestedArea.fromJson(Map<String, dynamic> json) {
    return InterestedArea(
      id: json['id'] as String,
      address: json['address'] as String,
      reasons: List<String>.from(json['reasons'] as List),
      customReason: json['customReason'] as String?,
      order: json['order'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'InterestedArea(id: $id, address: $address, reasons: $reasons)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InterestedArea && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}