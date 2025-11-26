import 'package:flutter/material.dart';
import 'package:pbl_b_app/screens/main_screen.dart';
import '../services/hive_service.dart';
import '../models/user_profile.dart';

/// 온보딩 화면 (권한 설정만 포함)
class OnboardingScreen extends StatefulWidget {
  final HiveService hiveService;

  const OnboardingScreen({Key? key, required this.hiveService})
      : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String? _selectedPermission;
  bool _isLoading = true;
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  /// 프로필 초기화
  /// - 로컬에 프로필이 있으면: 기존 프로필 사용
  /// - 로컬에 프로필이 없으면: 기본값으로 새로 생성
  Future<void> _initializeProfile() async {
    try {
      // 프로필 확인 및 생성
      final profile = await widget.hiveService.getOrCreateProfile('user_001');

      setState(() {
        _profile = profile;
        _isLoading = false;
      });

      // 프로필 정보 출력
      _printProfileInfo(profile);
    } catch (e) {
      print('❌ 프로필 초기화 실패: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 프로필 정보 출력 (디버그용)
  void _printProfileInfo(UserProfile profile) {
    final exists = widget.hiveService.hasProfile();
    print('═══════════════════════════════════════');
    print(exists ? '✅ 기존 프로필 로드됨' : '🆕 새 프로필 생성됨');
    print('═══════════════════════════════════════');
    print('User ID: ${profile.userId}');
    print('프로필 완성도: ${profile.completeness}%');
    print('반려동물: ${profile.hasPets}');
    print('가족 동거: ${profile.livesWithFamily}');
    print('주거 유형: ${profile.housingType.displayName}');
    print('차량 소유: ${profile.hasVehicle}');
    print('═══════════════════════════════════════');
  }

  void _finishOnboarding() {
    if (_profile == null) {
      print('❌ 프로필이 없습니다!');
      return;
    }

    print('🎉 온보딩 완료 - 메인 화면으로 이동');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(
          profile: _profile!,
          hiveService: widget.hiveService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBgColor = Color.fromRGBO(248, 205, 219, 1);
    const Color darkButtonColor = Color.fromRGBO(248, 205, 219, 1);
    const Color highlightColor = Color(0xFF30D158);

    // 로딩 중일 때
    if (_isLoading) {
      return Scaffold(
        backgroundColor: darkBgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(color: highlightColor),
              SizedBox(height: 16),
              Text(
                '프로필 확인 중...',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    // 프로필 초기화 실패 시
    if (_profile == null) {
      return Scaffold(
        backgroundColor: darkBgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                '프로필을 불러올 수 없습니다',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _initializeProfile,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    // 온보딩 화면
    return Scaffold(
      backgroundColor: darkBgColor,
      appBar: AppBar(
        backgroundColor: darkBgColor,
        elevation: 0,
        title: const Text(
          '권한 설정',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            // 진행도 표시 바
            Container(
              height: 4.0,
              decoration: BoxDecoration(
                color: highlightColor,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
            const SizedBox(height: 32),

            // 컨텐츠
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '위치 정보와 알림 권한이 필요합니다',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '안전한 대피를 위해 권한을 설정해주세요',
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  // 위치 권한 버튼
                  _buildOptionButton(
                    title: '위치권한',
                    subtitle: '실시간 위험도 확인',
                    isSelected: _selectedPermission == '위치권한',
                    onTap: () {
                      setState(() => _selectedPermission = '위치권한');
                      // TODO: 실제 위치 권한 요청
                      print('📍 위치 권한 요청');
                    },
                  ),

                  // 알림 권한 버튼
                  _buildOptionButton(
                    title: '알림권한',
                    subtitle: '긴급 상황 알림',
                    isSelected: _selectedPermission == '알림권한',
                    onTap: () {
                      setState(() => _selectedPermission = '알림권한');
                      // TODO: 실제 알림 권한 요청
                      print('🔔 알림 권한 요청');
                    },
                  ),

                  const Spacer(),

                  // 다음 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _finishOnboarding,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: highlightColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '시작하기',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 건너뛰기 버튼
                  Center(
                    child: TextButton(
                      onPressed: _finishOnboarding,
                      child: const Text(
                        '건너뛰기',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 옵션 버튼 위젯
  Widget _buildOptionButton({
    required String title,
    String? subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final Color bgColor =
    isSelected ? const Color(0xFF30D158) : const Color.fromARGB(255, 170, 4, 76);
    final Color titleColor = isSelected ? Colors.black : Colors.white;
    final Color subtitleColor = isSelected ? Colors.black87 : Colors.grey[400]!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}