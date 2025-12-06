// lib/utils/archive_builder.dart

import 'package:pbl_b_app/models/archive.dart';
import 'package:pbl_b_app/models/user_profile.dart';
import 'package:pbl_b_app/models/interested_area.dart';
import 'package:pbl_b_app/models/archive_list.dart';

String shortRegion(String full) {
  final removePrefixes = [
    '서울특별시 ',
    '부산광역시 ',
    '인천광역시 ',
    '대구광역시 ',
    '광주광역시 ',
    '대전광역시 ',
    '울산광역시 ',
  ];

  for (final prefix in removePrefixes) {
    if (full.startsWith(prefix)) {
      return full.substring(prefix.length);
    }
  }
  return full;
}

/// 해당 region이 UserProfile에서 어떤 의미인지 추론
/// - 집 / 직장 / 부모님 댁 / 자주 가는 곳 / 관심 지역 ...
String inferAreaLabelForRegion(String region, UserProfile? profile) {
  if (profile == null) return '관심 지역';

  final candidates = profile.interestedAreas.where(
    (area) => area.address.contains(region) || region.contains(area.address),
  );

  if (candidates.isEmpty) return '관심 지역';

  final InterestedArea area = candidates.first;

  final reasons = area.reasons;
  final custom = area.customReason;

  if (reasons.contains('집')) {
    if (custom != null && custom.isNotEmpty) return custom; // "부모님 댁" 등
    return '집';
  }
  if (reasons.contains('직장')) {
    return '직장 근처';
  }

  if (custom != null && custom.isNotEmpty) {
    return '$custom 주변';
  }

  // 그 외엔 대충 "자주 가는 곳" 정도로
  return '자주 가는 곳';
}

/// Archive.title 생성
/// 예: [침수 위험] 영등포구 집 상황 기록
String buildArchiveTitle({
  required String disasterName,
  required String region,
  required UserProfile? profile,
}) {
  final regionShort = shortRegion(region);
  final label = inferAreaLabelForRegion(region, profile);

  return '[$disasterName] $regionShort $label 상황 기록';
}

/// Archive.description 생성 (강수량 없이 프로필 정보만 반영)
String buildArchiveDescription({
  required String disasterName,
  required String region,
  required DateTime created,
  required UserProfile? profile,
}) {
  final regionShort = shortRegion(region);
  final label = inferAreaLabelForRegion(region, profile);

  final ts =
      '${created.year}.${created.month.toString().padLeft(2, '0')}.${created.day.toString().padLeft(2, '0')} '
      '${created.hour.toString().padLeft(2, '0')}:${created.minute.toString().padLeft(2, '0')}';

  final buf = StringBuffer();
  buf.write('$ts 기준, $regionShort $label에 ');
  buf.write('$disasterName 알림이 감지되었습니다. ');

  // 프로필 기반 맞춤 한 줄들
  if (profile != null) {
    if (profile.housingTypeCode == 'semi_basement') {
      buf.write(
          '반지하/저층 주택 거주 중이라면 즉시 위쪽 안전한 장소로 이동하세요. ');
    }

    if (profile.hasPets) {
      buf.write(
          '반려동물이 있다면 케이지, 목줄 등을 준비해 함께 대피할 수 있도록 하세요. ');
    }

    if (profile.hasVehicle) {
      buf.write(
          '침수 상황에서 차량 이동은 매우 위험하니, 차량보다는 도보로 고지대로 이동하는 것을 우선 고려하세요. ');
    }

    if (profile.livesWithFamily) {
      buf.write(
          '가족과 함께 거주 중이라면 전원이 함께 이동할 수 있는 동선을 미리 상의하세요. ');
    }
  }

  return buf.toString().trim();
}

/// ✅ 예측 서버 결과(Positive/Negative) + region + UserProfile로
/// Archive 하나를 만들어 archiveList에 추가하는 함수
void createArchiveFromPrediction({
  required String region,
  required UserProfile? profile,
  required bool isFloodPositive, // 예측 서버가 Positive(침수 위험)인지 여부
}) {
  // Negative면 히스토리 남기지 않음 (원하면 바꿔도 됨)
  if (!isFloodPositive) return;

  final now = DateTime.now();
  const disasterName = '침수 위험';

  final archive = Archive(
    disasterName: disasterName,
    location: region,
    created: now,
    title: buildArchiveTitle(
      disasterName: disasterName,
      region: region,
      profile: profile,
    ),
    description: buildArchiveDescription(
      disasterName: disasterName,
      region: region,
      created: now,
      profile: profile,
    ),
  );

  // 최신 것이 맨 위에 오도록
  archiveList.insert(0, archive);
}
