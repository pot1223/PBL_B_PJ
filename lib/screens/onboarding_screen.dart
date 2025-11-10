import 'package:flutter/material.dart';
import 'package:pbl_b_app/main.dart'; 


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // PageView를 제어하기 위한 컨트롤러
  final PageController _pageController = PageController();
  // 현재 페이지 인덱스 (0, 1, 2)
  int _currentPage = 0;

  // 각 단계에서 선택된 값을 저장할 변수
  String? _selectedLevel;
  String? _selectedPlace;

  // 온보딩을 완료하고 메인 화면으로 이동
  void _finishOnboarding() {

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  // 페이지가 변경될 때 호출
  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  // 다음 페이지로 이동
  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // 이전 페이지로 이동
  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }


  @override
  Widget build(BuildContext context) {
    
    const Color darkBgColor = Color.fromRGBO(248, 205, 219, 1);
    
    const Color darkButtonColor =  Color.fromRGBO(248, 205, 219, 1);
    
    const Color highlightColor = Color(0xFF30D158); // 이미지의 녹색과 유사하게

    return Scaffold(
      backgroundColor: darkBgColor,
      appBar: AppBar(
        backgroundColor: darkBgColor,
        elevation: 0,
        // 1. 뒤로 가기 버튼 (첫 페이지가 아닐 때만 보임)
        leading: _currentPage == 0
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: _previousPage,
              ),
        // 2. 제목 (페이지마다 다르게 표시)
        title: Text(
          _currentPage == 0
              ? '권한 설정'
              : _currentPage == 1
                  ? '맞춤 정보'
                  : '관심 지역',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        // 3. 건너뛰기 버튼 (마지막 페이지일 때만 보임)
        actions: [
          if (_currentPage == 2)
            TextButton(
              onPressed: _finishOnboarding, // 건너뛰기
              child: const Text(
                '건너뛰기',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            // --- 1. 진행도 표시 바 (Progress Bar) ---
            Row(
              children: List.generate(3, (index) {
                return Expanded(
                  child: Container(
                    height: 4.0,
                    margin: const EdgeInsets.symmetric(horizontal: 2.0),
                    decoration: BoxDecoration(
                      color:
                          index <= _currentPage ? highlightColor : darkButtonColor,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),

            // --- 2. 페이지 뷰 (화면 전환 영역) ---
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics:
                    const NeverScrollableScrollPhysics(), 
                children: [
                  
                  _buildStep1Page(),
                 
                  _buildStep2Page(),
                 
                  _buildStep3Page(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

 
  Widget _buildStep1Page() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '위치 정보와 알림 권한이 필요합니다',
          style: TextStyle(
              color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '안전한 대피를 위해 권한을 설정해주세요',
          style: TextStyle(color: Colors.black, fontSize: 14),
        ),
        const SizedBox(height: 32),
        _buildOptionButton(
          title: '위치권한',
          subtitle: '실시간 위험도 확인',
          isSelected: _selectedLevel == '위치권한',
          onTap: () {
            setState(() => _selectedLevel = '위치권한');
            Future.delayed(const Duration(milliseconds: 200), _nextPage);
          },
        ),
        _buildOptionButton(
          title: '알림권한',
          subtitle: '긴급 상황 알림',
          isSelected: _selectedLevel == '알림권한',
          onTap: () {
            setState(() => _selectedLevel = '알림권한');
            Future.delayed(const Duration(milliseconds: 200), _nextPage);
          },
        ),
      ],
    );
  }

 
  Widget _buildStep2Page() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '사용자 맞춤 정보를 알려주세요',
          style: TextStyle(
              color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '더 안전한 대피를 위한 정보입니다',
          style: TextStyle(color: Colors.black, fontSize: 14),
        ),
        const SizedBox(height: 32),
        _buildOptionButton(
          title: '이동에 도움이 필요해요(휠체어 등)',
          isSelected: _selectedPlace == '이동불편',
          onTap: () {
            setState(() => _selectedPlace = '이동불편');
            
            Future.delayed(const Duration(milliseconds: 200), _nextPage);
          },
        ),
        _buildOptionButton(
          title: '반려동물이 있어요',
          isSelected: _selectedPlace == '반려동물',
          onTap: () {
            setState(() => _selectedPlace = '반려동물');
            
            Future.delayed(const Duration(milliseconds: 200), _nextPage);
          },
        ),
      ],
    );
  }


  Widget _buildStep3Page() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '관심 지역을 알려주세요',
          style: TextStyle(
              color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '자주 다니는 지역, 거주지 등 관심 지역을 설정해주세요',
          style: TextStyle(color: Colors.black, fontSize: 14),
        ),
        const SizedBox(height: 32),
        
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 207, 31, 107),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                '주소 검색하면 더 빠르게 찾을 수 있어요!',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
          _buildOptionButton(
          title: '저장하기',
          isSelected: _selectedPlace == '저장하기',
          onTap: () {
            setState(() => _selectedPlace = '저장하기');
            
            Future.delayed(const Duration(milliseconds: 200), _finishOnboarding );
          },
        ),
      ],
    );
  }


  Widget _buildOptionButton({
    required String title,
    String? subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    
    final Color bgColor =
        isSelected ? const Color(0xFF30D158) :  Color.fromARGB(255, 170, 4, 76);
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