// Material Design 라이브러리를 가져와야 화면 구성을 위한 UI 요소를 활용할 수 있음 
import 'package:flutter/material.dart'; 
// 어플리케이션 언어를 설정하는데 필요한 localization 기능을 가져옴
import 'package:flutter_localizations/flutter_localizations.dart';
// 사용자에게 보여줄 첫 홈 화면을 가져옴 
import 'package:pbl_b_app/screens/randing_page.dart';
import 'package:pbl_b_app/screens/ai_chatbot_archive.dart';
import 'package:pbl_b_app/screens/onboarding_screen.dart';
import 'package:pbl_b_app/screens/mypage.dart'; 

void main() {
  runApp(const MyApp()); // runApp을 통해 MyApp 클래스를 가장 먼저 실행
}

class MyApp extends StatelessWidget { //StatelessWidget은 앱 실행 시, 해당 클래스의 데이터가 변경되지 않음을 의미함(정적 로고, 앱 제목 등)
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) { // build 메소드를 통해 화면UI를 알려줘야함
    // MaterialApp을 통해 어플의 전반적인 테마, 언어, 홈 화면을 정의함 
    return MaterialApp(
      title: 'Flutter Demo', // 앱의 제목 
      locale: const Locale('ko'), // 앱의 기본 언어를 한국어로 설정 
      supportedLocales: const [Locale('ko'), Locale('en')], //앱이 지원하는 언어를 지정함 
      localizationsDelegates: GlobalMaterialLocalizations.delegates, // 설정한 언어를 실제 앱에 적용시키기 위한 코드 
      // ThemeData를 통해 앱의 디자인 테마(색상, 글꼴) 정의
      theme: ThemeData( 
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // home을 통해 앱이 처음 실행될 때 사용자에게 보여줄 홈 화면을 지정함 
      home: const OnboardingScreen(),
    );
  }
}


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}


class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // 현재 선택된 탭의 인덱스

  // 보여줄 페이지 리스트를 정의
  static final List<Widget> _widgetOptions = <Widget>[
    const RandingPage(), // 홈 페이지
    const AiChatbotArchivePage(), // AI 챗봇 아카이브
    const MyPage() // 내정보
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex), 

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