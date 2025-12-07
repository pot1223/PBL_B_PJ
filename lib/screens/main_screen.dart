import 'package:flutter/material.dart';
import 'package:pbl_b_app/screens/randing_page.dart';
import 'package:pbl_b_app/screens/ai_chatbot_archive.dart';
import 'package:pbl_b_app/screens/mypage.dart';
import '../models/user_profile.dart';
import '../services/hive_service.dart';

class MainScreen extends StatefulWidget {
  final UserProfile profile;
  final HiveService hiveService;

  const MainScreen({
    Key? key,
    required this.profile,
    required this.hiveService,
  }) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late UserProfile _currentProfile;

  @override
  void initState() {
    super.initState();
    _currentProfile = widget.profile;
    _printProfileInfo();
  }

  void _printProfileInfo() {
    print('═══════════════════════════════════════');
    print('🎉 MainScreen - 프로필 정보');
    print('═══════════════════════════════════════');
    print('User ID: ${_currentProfile.userId}');
    print('프로필 완성도: ${_currentProfile.completeness}%');
    print('반려동물: ${_currentProfile.hasPets}');
    print('가족 동거: ${_currentProfile.livesWithFamily}');
    print('주거 유형: ${_currentProfile.housingType.displayName}');
    print('차량 소유: ${_currentProfile.hasVehicle}');
    print('관심 지역: ${_currentProfile.interestedAreas.length}개');
    print('═══════════════════════════════════════');
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      // 마이페이지 탭 들어갈 때 최신 프로필 다시 로드
      if (index == 2) {
        final latestProfile = widget.hiveService.getProfile();
        if (latestProfile != null) {
          _currentProfile = latestProfile;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      RandingPage(
        profile: _currentProfile,
      ),
      // 🚨 여기서 프로필 넘겨주기
      AiChatbotArchivePage(
        profile: _currentProfile,
        hiveService: widget.hiveService,
      ),
      MyPage(
        profile: _currentProfile,
        hiveService: widget.hiveService,
      ),
    ];

    return Scaffold(
      body: Center(
        child: widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pink.shade400,
        unselectedItemColor: Colors.grey.shade600,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 10,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'AI 챗봇',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: '내 정보',
          ),
        ],
      ),
    );
  }
}
