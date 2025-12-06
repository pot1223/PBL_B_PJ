// ================== 공용 import ==================
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// HTTP
import 'package:http/http.dart' as http;

// 위치
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

// JSON
import 'dart:convert';

// 앱 내부 파일
import 'package:pbl_b_app/screens/onboarding_screen.dart';
import 'package:pbl_b_app/screens/chatbot_interact.dart';
import 'package:pbl_b_app/models/archive.dart';
import 'package:pbl_b_app/models/archive_list.dart';
import 'package:pbl_b_app/models/user_profile.dart';
import 'package:pbl_b_app/models/current_location.dart';
import 'package:pbl_b_app/screens/main_screen.dart';

// 로컬 DB인 Hive 사용
import 'services/hive_service.dart';

// ================== 전역 상수/키 ==================
const String apiBaseUrl = 'http://10.0.2.2:8000';
const String locationTaskName = 'updateLocationTask';

// 전역 네비게이터 (푸시 알림 클릭 시 화면 전환용)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// ================== main() ==================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  final hiveService = HiveService();
  await hiveService.initialize();
  await hiveService.clearAll();
  runApp(MyApp(hiveService: hiveService));
}

// ================== MyApp ==================
class MyApp extends StatefulWidget {
  final HiveService hiveService;

  const MyApp({Key? key, required this.hiveService}) : super(key: key);

  @override
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

    // 1) 완전 일치 우선
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

  // ---------- 위치/지역 처리 공통 유틸 ----------

  Future<Position> _determinePosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('위치 서비스가 꺼져 있습니다.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('위치 권한이 없습니다. 온보딩에서 권한을 허용해주세요.');
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
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

  /// ✅ 공통: Position → CurrentLocation (주소는 best-effort, 실패해도 좌표는 살려둠)
  Future<CurrentLocation> _buildCurrentLocationFromPosition(
      Position position) async {
    String address = '알 수 없는 위치';

    try {
      // geocoding 3.x: 전역 locale 설정
      await setLocaleIdentifier('ko_KR');

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        String city = place.locality ?? '';
        String district = place.subLocality ?? '';

        city = _toKoreanAdminName(city);
        district = _toKoreanAdminName(district);

        final combined = '$city $district'.trim();
        if (combined.isNotEmpty) {
          address = combined;
        }
      }
    } catch (e) {
      // 여기서 나는 에러는 역지오코딩 실패만 의미 (좌표는 이미 있음)
      debugPrint('⚠️ 역지오코딩 실패(주소만 기본값 사용): $e');
    }

    return CurrentLocation(
      address: address,
      latitude: position.latitude,
      longitude: position.longitude,
      isAutoDetected: true,
    );
  }

  // ✅ 현재 GPS → CurrentLocation → 프로필에 저장
  Future<UserProfile> _updateCurrentLocationInProfile(
      UserProfile profile) async {
    try {
      final position = await _determinePosition();
      final currentLoc = await _buildCurrentLocationFromPosition(position);

      final updated = profile.copyWith(
        currentLocation: currentLoc,
      );

      await widget.hiveService.saveProfile(updated);

      debugPrint('✅ currentLocation 업데이트: $currentLoc');
      return updated;
    } catch (e) {
      // 여기까지 오면 진짜로 Position 자체를 못 가져온 케이스
      debugPrint('❌ 현재 위치 업데이트 실패(좌표 획득 실패): $e');
      return profile;
    }
  }

  // 위도/경도 → region 문자열 (FCM 등록용)
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

      // 2) Position → CurrentLocation 공통 로직 재사용
      final currentLoc = await _buildCurrentLocationFromPosition(position);

      if (currentLoc.address.isEmpty ||
          currentLoc.address == '알 수 없는 위치') {
        return '알 수 없는 지역';
      }
      return currentLoc.address;
    } catch (e) {
      debugPrint('위치 기반 region 가져오기 실패: $e');
      return '알 수 없는 지역';
    }
  }

  // ---------- FCM 관련 ----------
  Future<void> _setupFCM() async {
    final messaging = FirebaseMessaging.instance;

    final token = await messaging.getToken();

    if (token != null) {
      final region = await _getRegionFromLocation();
      await _registerDevice(region: region, fcmToken: token);
      debugPrint('디바이스 등록 및 FCM 설정 완료 (region: $region)');
    } else {
      debugPrint('⚠️ FCM 토큰을 가져오지 못했습니다.');
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
    } catch (e) {
      debugPrint('register-device 에러: $e');
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
      ),
    );
  }

  // ---------- 온보딩 완료 처리 ----------
  Future<void> _handleOnboardingFinished(UserProfile profile) async {
    // 이 State가 아직 살아있는지 먼저 확인
    if (!mounted) return;

    // 1) 일단 상태에 저장
    setState(() {
      _onboardingFinished = true;
      _profile = profile;
    });

    // 2) 권한 확인
    final hasLocation = await _hasLocationPermission();
    final hasNotification = await _hasNotificationPermission();

    // await 뒤에서도 여전히 살아있는지 한 번 더 체크
    if (!mounted) return;

    UserProfile finalProfile = profile;

    // 3) 위치 권한이 있으면 currentLocation을 실제로 채워 넣기
    if (hasLocation) {
      finalProfile = await _updateCurrentLocationInProfile(profile);

      // 여기서도 혹시 모를 상황 대비
      if (!mounted) return;

      setState(() {
        _profile = finalProfile;
      });
    }

    // 4) FCM 설정
    if (hasLocation && hasNotification) {
      await _setupFCM();
      // 여기선 setState 안 쓰니까 mounted 체크는 선택 사항
    } else {
      debugPrint('⚠️ 위치/알림 권한 부족으로 FCM 설정을 건너뜁니다.');
      debugPrint(' - 위치 권한: $hasLocation');
      debugPrint(' - 알림 권한: $hasNotification');
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: navigatorKey,
      locale: const Locale('ko'),
      supportedLocales: const [Locale('ko'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      home: _onboardingFinished && _profile != null
          ? MainScreen(
              profile: _profile!,
              hiveService: widget.hiveService,
            )
          : OnboardingScreen(
              hiveService: widget.hiveService,
              onFinished: _handleOnboardingFinished,
            ),
    );
  }
}
