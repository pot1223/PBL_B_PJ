// Material Design 라이브러리를 가져와야 화면 구성을 위한 UI 요소를 활용할 수 있음 
import 'package:flutter/material.dart'; 
// 어플리케이션 언어를 설정하는데 필요한 localization 기능을 가져옴
import 'package:flutter_localizations/flutter_localizations.dart';
// 사용자에게 보여줄 첫 홈 화면을 가져옴 
import 'package:pbl_b_app/screens/randing_page.dart';
import 'package:pbl_b_app/screens/ai_chatbot_archive.dart';
import 'package:pbl_b_app/screens/onboarding_screen.dart';
import 'package:pbl_b_app/screens/mypage.dart'; 

<<<<<<< Updated upstream
void main() {
  runApp(const MyApp()); // runApp을 통해 MyApp 클래스를 가장 먼저 실행
=======
// 로컬 DB인 Hive 사용
import 'services/hive_service.dart';

import 'package:kakao_map_plugin/kakao_map_plugin.dart';

// ================== 전역 상수/키 ==================
const String apiBaseUrl = 'http://10.0.2.2:8000';
const String locationTaskName = 'updateLocationTask';

// 전역 네비게이터 (푸시 알림 클릭 시 화면 전환용)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// ================== main() ==================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AuthRepository.initialize(appKey: 'bae9dc4a7712033a1610e03f650b078c');

  await Firebase.initializeApp();

  final hiveService = HiveService();
  await hiveService.initialize();

  runApp(MyApp(hiveService: hiveService));
>>>>>>> Stashed changes
}

class MyApp extends StatelessWidget { //StatelessWidget은 앱 실행 시, 해당 클래스의 데이터가 변경되지 않음을 의미함(정적 로고, 앱 제목 등)
  const MyApp({super.key});

  
  @override
<<<<<<< Updated upstream
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
=======
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _onboardingFinished = false;
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();

    // ✅ 앱 재실행 시, 이미 저장된 프로필이 있으면 온보딩 스킵
    final existingProfile = widget.hiveService.getProfile();
    if (existingProfile != null) {
      _profile = existingProfile;
      _onboardingFinished = true;

      // 앱이 켜질 때 FCM/위치까지 바로 하고 싶으면 여기에 추가로 설정 가능
      _safeSetupFCMAndLocation(existingProfile);
    }
  }

  // ---------- 행정구 영어 → 한글 매핑 ----------
  String _toKoreanAdminName(String name) {
    if (name.isEmpty) return name;

    const mapping = {
      // 서울시 예시들
      'Yeongdeungpo District': '영등포구',
      'Yeongdeungpo-gu': '영등포구',
      'Mapo District': '마포구',
      'Mapo-gu': '마포구',
      'Gangnam-gu': '강남구',
      'Gangdong-gu': '강동구',
      'Gangbuk-gu': '강북구',
      'Gangseo-gu': '강서구',
      'Jongno-gu': '종로구',
      'Jung-gu': '중구',
      'Yongsan-gu': '용산구',
      // 필요하면 계속 추가
    };

    // 1) 완전 일치
    if (mapping.containsKey(name)) return mapping[name]!;

    // 2) 'Yeongdeungpo-gu, Seoul' 같은 복합 문자열
    for (final entry in mapping.entries) {
      if (name.contains(entry.key)) {
        return entry.value;
      }
    }

    // 3) 'Yeongdeungpo District' 패턴 간단 처리
    if (name.endsWith(' District')) {
      final base = name.replaceAll(' District', '').trim();
      if (base == 'Yeongdeungpo') return '영등포구';
    }

    return name; // 모르는 건 그대로 반환
  }

  // ---------- 위치/권한 유틸 ----------

  // 위치 서비스 & 권한 확인 + 좌표 얻기
  Future<Position> _determinePosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('위치 서비스가 꺼져 있습니다.');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      throw Exception('위치 권한이 없습니다. 온보딩에서 권한을 허용해주세요.');
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );
  }

  // 위치 권한이 있는지 확인
  Future<bool> _hasLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  // 알림 권한이 있는지 확인
  Future<bool> _hasNotificationPermission() async {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.getNotificationSettings();

    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }
  /// 위치 권한을 실제로 요청해 보고, 최종 결과를 true/false로 리턴
  Future<bool> _ensureLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // 👉 여기서 실제 안드로이드 권한 팝업이 뜬다
      permission = await Geolocator.requestPermission();
    }

    // 사용자가 "다시는 묻지 않음" 또는 완전 차단한 상태
    if (permission == LocationPermission.deniedForever) {
      debugPrint('위치 권한이 영구적으로 거부됨. 설정에서 직접 허용 필요');
      return false;
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }




    Future<CurrentLocation> _buildCurrentLocationFromPosition(
      Position position) async {
    String address = '알 수 없는 위치';

    try {
      await setLocaleIdentifier('ko_KR');

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        // 디버깅용으로 한 번 전체 필드 찍어보기
        debugPrint(
            'GEOCODING place: admin=${place.administrativeArea}, '
            'subAdmin=${place.subAdministrativeArea}, '
            'locality=${place.locality}, '
            'subLocality=${place.subLocality}, '
            'thoroughfare=${place.thoroughfare}, '
            'subThoroughfare=${place.subThoroughfare}');

        // 여러 후보를 모아서, 비어있지 않은 것들만 순서대로 사용
        final parts = <String>[];

        String admin = place.administrativeArea ?? '';        // 서울특별시
        String subAdmin = place.subAdministrativeArea ?? '';  // 영등포구, 성남시 등
        String city = place.locality ?? '';                   // 어떤 기기에서는 여기 구/시가 오기도 함
        String district = place.subLocality ?? '';            // 동 단위가 올 수도 있고, 아예 비어있기도 함

        // 영어 -> 한글 매핑 한 번씩 걸어주기
        admin = _toKoreanAdminName(admin);
        subAdmin = _toKoreanAdminName(subAdmin);
        city = _toKoreanAdminName(city);
        district = _toKoreanAdminName(district);

        // 순서는 상황에 따라 맞추고, 비어있지 않은 것만 추가
        if (admin.isNotEmpty) parts.add(admin);
        if (subAdmin.isNotEmpty && !parts.contains(subAdmin)) parts.add(subAdmin);
        if (city.isNotEmpty && !parts.contains(city)) parts.add(city);
        if (district.isNotEmpty && !parts.contains(district)) parts.add(district);

        final combined = parts.join(' ').trim();

        if (combined.isNotEmpty) {
          address = combined;
        }
      }
    } catch (e, st) {
      debugPrint('⚠️ 역지오코딩 실패(주소만 기본값 사용): $e');
      debugPrint('$st');
    }

    return CurrentLocation(
      address: address,
      latitude: position.latitude,
      longitude: position.longitude,
      isAutoDetected: true,
    );
  }



  /// ✅ 현재 GPS → CurrentLocation → 프로필에 저장 (좌표만으로도 동작, 예외 안전)
  Future<UserProfile> _updateCurrentLocationInProfile(
      UserProfile profile) async {
    debugPrint('LOC1: _updateCurrentLocationInProfile 시작');
    // ========== 🎯 데모용: 서초구로 고정 ==========
    final currentLoc = CurrentLocation(
      address: '서울특별시 서초구',
      latitude: 37.4837,  // 서초구 대략적인 좌표
      longitude: 127.0324,
      isAutoDetected: false, // 데모용이므로 false
    );

    final updated = profile.copyWith(
      currentLocation: currentLoc,
    );

    await widget.hiveService.saveProfile(updated);

    debugPrint('LOC3: currentLocation 저장 완료 (데모): $currentLoc');
    return updated;
    try {
      final position = await _determinePosition();
      debugPrint('LOC2: Position 획득: ${position.latitude}, ${position.longitude}');

      // 역지오코딩까지 포함하고 싶으면 아래 한 줄로 교체
      final currentLoc = await _buildCurrentLocationFromPosition(position);


      final updated = profile.copyWith(
        currentLocation: currentLoc,
      );

      await widget.hiveService.saveProfile(updated);

      debugPrint('LOC3: currentLocation 저장 완료: $currentLoc');
      return updated;
    } on TimeoutException {
      debugPrint('LOC_ERR: 위치 조회 타임아웃');
      return profile;
    } catch (e, st) {
      debugPrint('LOC_ERR: 현재 위치 업데이트 중 예외: $e');
      debugPrint('$st');
      return profile;
    }
  }

  // 위도/경도/저장값 → region 문자열 (FCM 등록용)
  Future<String> _getRegionFromLocation() async {
    try {
      // 0) 이미 저장된 프로필의 currentLocation이 있으면 우선 사용
      final savedProfile = widget.hiveService.getProfile() ?? _profile;
      final savedLoc = savedProfile?.currentLocation;
      if (savedLoc != null &&
          savedLoc.address.isNotEmpty &&
          savedLoc.address != '알 수 없는 위치') {
        return savedLoc.address;
      }

      // 1) 좌표 새로 가져오기
      final position = await _determinePosition();

      // 2) Position → CurrentLocation (역지오코딩 포함)
      final currentLoc = await _buildCurrentLocationFromPosition(position);

      if (currentLoc.address.isEmpty ||
          currentLoc.address == '알 수 없는 위치') {
        return '알 수 없는 지역';
      }
      return currentLoc.address;
    } catch (e, st) {
      debugPrint('위치 기반 region 가져오기 실패: $e');
      debugPrint('$st');
      return '알 수 없는 지역';
    }
  }

  // ---------- FCM 관련 ----------

  Future<void> _setupFCM() async {
    final messaging = FirebaseMessaging.instance;

    try {
      final token = await messaging.getToken();

      if (token != null) {
        final region = await _getRegionFromLocation();
        await _registerDevice(region: region, fcmToken: token);
        debugPrint('✅ 디바이스 등록 및 FCM 설정 완료 (region: $region)');
      } else {
        debugPrint('⚠️ FCM 토큰을 가져오지 못했습니다.');
      }
    } catch (e, st) {
      debugPrint('FCM 설정 중 에러: $e');
      debugPrint('$st');
    }

    // 앱이 완전히 꺼져있다가 푸시 클릭
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleMessageClick(message);
      }
    });

    // 백그라운드 상태에서 푸시 클릭
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleMessageClick(message);
    });

    // 포그라운드에서 푸시 수신
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('포그라운드 메시지 도착: ${message.notification?.title}');
      _handleMessageClick(message);
    });
  }

  // FCM + 위치를 안전하게 한 번에 설정
  Future<void> _safeSetupFCMAndLocation(UserProfile profile) async {
    try {
      final hasLocation = await _ensureLocationPermission();
      final hasNotification = await _hasNotificationPermission();

      debugPrint('SAFE_SETUP: hasLocation=$hasLocation, hasNotification=$hasNotification');

      UserProfile finalProfile = profile;

      if (hasLocation) {
        finalProfile = await _updateCurrentLocationInProfile(profile);
        if (mounted) {
          setState(() {
            _profile = finalProfile;
          });
        }
      }

      if (hasNotification) {
        await _setupFCM();
      } else {
        debugPrint('SAFE_SETUP: FCM 설정 스킵 (noti:$hasNotification)');
      }
    } catch (e, st) {
      debugPrint('SAFE_SETUP 에러: $e');
      debugPrint('$st');
    }
  }

  // ---------- 서버에 디바이스 등록 ----------
  Future<void> _registerDevice({
    required String region,
    required String fcmToken,
  }) async {
    try {
      final uri = Uri.parse('$apiBaseUrl/register-device');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'region': region,
          'fcm_token': fcmToken,
        }),
      );
      debugPrint('register-device 응답: ${res.statusCode} ${res.body}');
    } catch (e, st) {
      debugPrint('register-device 에러: $e');
      debugPrint('$st');
    }
  }

  // ---------- 중복 알림 체크 ----------
  Archive? _findRecentSameAlert({
    required String region,
  }) {
    const duplicateWindowMinutes = 60;
    final now = DateTime.now();

    for (final a in archiveList) {
      final isSameRegion = a.location == region;
      final isRecent =
          now.difference(a.created).inMinutes <= duplicateWindowMinutes;

      if (isSameRegion && isRecent) {
        return a;
      }
    }
    return null;
  }

  // ---------- 푸시 클릭 시 처리 ----------
  void _handleMessageClick(RemoteMessage message) {
    final action = message.data['action'];
    if (action != 'go_chatbot') return;

    final region = message.data['region'] ?? '알 수 없는 지역';

    final existing = _findRecentSameAlert(region: region);

    Archive archive;
    if (existing != null) {
      archive = existing;
    } else {
      archive = Archive(
        disasterName: '침수 위험',
        location: region,
        created: DateTime.now(),
        title: 'AI 침수 예측 경보',
        description: '예측 모델이 침수 위험을 감지했습니다.',
      );
      archiveList.insert(0, archive);
    }

    // ✅ 항상 Hive에서 최신 프로필을 우선 사용
    final profileForChatbot = widget.hiveService.getProfile() ?? _profile;

    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => ChatbotInteract(
          archive: archive,
          profile: profileForChatbot,
        ),
>>>>>>> Stashed changes
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