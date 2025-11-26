// Material Design 라이브러리
import 'package:flutter/material.dart';
// 어플리케이션 언어 설정을 위한 localization
import 'package:flutter_localizations/flutter_localizations.dart';
// 온보딩 화면
import 'screens/onboarding_screen.dart';
// Hive 서비스
import 'services/hive_service.dart';

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 초기화
  final hiveService = HiveService();
  await hiveService.initialize();

  // 앱 실행 (HiveService를 전달)
  runApp(MyApp(hiveService: hiveService));
}

class MyApp extends StatelessWidget {
  final HiveService hiveService;

  const MyApp({Key? key, required this.hiveService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      locale: const Locale('ko'), // 기본 언어: 한국어
      supportedLocales: const [Locale('ko'), Locale('en')], // 지원 언어
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // 온보딩 화면을 첫 화면으로 설정
      debugShowCheckedModeBanner: false,
      home: OnboardingScreen(hiveService: hiveService),
    );
  }
}