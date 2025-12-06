import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/interested_area.dart';

class RandingPage extends StatefulWidget {
  final UserProfile profile;

  const RandingPage({
    Key? key,
    required this.profile,
  }) : super(key: key);

  @override
  State<RandingPage> createState() => _RandingPageState();
}

class _RandingPageState extends State<RandingPage> {
  @override
  Widget build(BuildContext context) {
    // ✅ 현재 위치 / 관심 지역 상태 계산
    final currentLocation = widget.profile.currentLocation;
    final bool hasCurrentLocation =
        currentLocation != null && currentLocation.isValid;

    final bool hasInterestedAreas =
        widget.profile.interestedAreas.isNotEmpty;

    // ✅ 상단 카드 제목
    final String headerTitle = () {
      if (hasCurrentLocation) return '현재 위치 모니터링';
      if (hasInterestedAreas) return '관심 지역 모니터링';
      return '관심 지역 미설정';
    }();

    // ✅ 메인 텍스트 (주소)
    final String mainAreaText = () {
      if (hasCurrentLocation) {
        return currentLocation!.address;
      } else if (hasInterestedAreas) {
        // 첫 번째 관심 지역
        final InterestedArea area = widget.profile.interestedAreas.first;
        return area.address;
      } else {
        return '하단의 "내 정보"에서 관심 지역을 등록하면\n해당 지역의 침수 위험을 자동으로 알려드려요.';
      }
    }();

    // ✅ 서브 텍스트 (이유/설명)
    final String subAreaText = () {
      if (hasCurrentLocation) {
        return '현재 GPS 기준으로 침수 위험을 모니터링 중입니다.';
      } else if (hasInterestedAreas) {
        final InterestedArea area = widget.profile.interestedAreas.first;
        // "#집 #직장 ..." 이런 식의 해시태그 문자열
        final reasons = area.hashtagReasons;
        return reasons.isNotEmpty
            ? '등록 이유: $reasons'
            : '사용자가 미리 등록한 관심 지역입니다.';
      } else {
        return '';
      }
    }();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔴 상단 경고/모니터링 카드
            Container(
              margin: const EdgeInsets.only(
                bottom: 20.0,
                top: 60.0,
                left: 20.0,
                right: 20.0,
              ),
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade600, Colors.red.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        headerTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mainAreaText,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                        if (subAreaText.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            subAreaText,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 🌎 지도/시각화 영역 (기존 코드 그대로)
            Container(
              height: 400,
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.shade100.withOpacity(0.5),
                          Colors.blue.shade100.withOpacity(0.5),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  Positioned(
                    left: 100,
                    top: 150,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 150,
                    top: 80,
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.red.shade700,
                      size: 40,
                    ),
                  ),
                  Positioned(
                    left: 60,
                    top: 180,
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.red.shade700,
                      size: 40,
                    ),
                  ),
                  Positioned(
                    right: 60,
                    bottom: 150,
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.red.shade700,
                      size: 40,
                    ),
                  ),
                  // 범례
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildLegendItem(Colors.blue, '내 위치'),
                          _buildLegendItem(Colors.red.shade700, '대피소'),
                          _buildLegendItem(Colors.pink.shade200, '침수 지역'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 안내 문구
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 5),
                  const Expanded(
                    child: Text(
                      '침수·재난 상황 발생 시 AI 비서와 함께\n가까운 대피소와 안전한 행동 요령을 확인하세요.',
                      style: TextStyle(fontSize: 14),
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
