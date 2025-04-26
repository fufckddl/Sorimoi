import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';

// 📁 화면 import
import 'package:pj1/home/loadingScreen.dart';
import 'package:pj1/home/home.dart';                  // ← 여기 클래스명이 정확히 HomeScreen인지 확인!
import 'package:pj1/empty/userHome2.dart';            // 오늘의 소리 화면
import 'package:pj1/notify/notification_screen.dart'; // 알림 권한 요청
import 'package:pj1/user/auth/userLogin.dart';
import 'package:pj1/user/auth/userSignup.dart';
import 'package:pj1/user/find/id/findId.dart';
import 'package:pj1/user/find/password/findPassword.dart';
import 'package:pj1/empty/voice_text.dart';           // 음성 텍스트 출력
import 'package:pj1/voice/voice_recognition.dart';    // CombinedVoiceScreen
import 'package:pj1/voice/voiceRecording.dart';       // AnalyzingFeedbackScreen
import 'package:pj1/voice/voiceScore.dart';
import 'package:pj1/user/profile/profileHome.dart';
import 'empty/userHome.dart';           // ScriptPracticeScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dbConnector();
  runApp(const SoriMoiApp());
}

// ✅ MySQL 연결
Future<void> dbConnector() async {
  print("Connecting to mysql server...");

  try {
    final conn = await MySQLConnection.createConnection(
      host: '43.200.24.193',
      port: 3306,
      userName: 'sorimoi',
      password: 'Hoseo@12345',
      databaseName: 'sorimoi',
    );

    await conn.connect();
    print("✅ MySQL 연결 성공");
    await conn.close();
  } catch (e) {
    print("❌ MySQL 연결 실패: $e");
  }
}

// 📱 앱 진입점
class SoriMoiApp extends StatelessWidget {
  const SoriMoiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/auth': (context) => const AuthChoiceScreen(),
        '/start': (context) => const StartScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/notification': (context) => const NotificationScreen(),

        // ✅ 클래스명 확인하여 여기에 정확히 입력
        '/home': (context) => const HomeScreen(),       // ← 여기!
        '/userHome': (context) => const HomeScreen(),   // ← 또는 '/home'으로 통일해도 됨
        '/recording': (context) => const RecordingHomeScreen(),

        '/findId': (context) => const FindIdScreen(),
        '/findPassword': (context) => const FindPasswordScreen(),

        '/voice': (context) => const CombinedVoiceScreen(),
        '/voiceRecognition': (context) => const CombinedVoiceScreen(),
        '/voiceText': (context) => const VoiceTextScreen(),
        '/voiceRecording': (context) => const AnalyzingFeedbackScreen(),
        '/scriptPractice': (context) => const ScriptPracticeScreen(),

        '/profileHome': (context) => const ProfileHome(),
      },
    );
  }
}
