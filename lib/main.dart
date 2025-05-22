import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart'; // 🔑 키 해시 출력을 위해 추가

// 📁 화면 import
import 'package:pj1/home/loadingScreen.dart';
import 'package:pj1/home/home.dart';
import 'package:pj1/userhome/userHome2.dart';
import 'package:pj1/notify/notification_screen.dart';
import 'package:pj1/user/auth/userLogin.dart';
import 'package:pj1/user/auth/userSignup.dart';
import 'package:pj1/user/find/id/findId.dart';
import 'package:pj1/user/find/password/findPassword.dart';
import 'package:pj1/empty/voice_text.dart';
//import 'package:pj1/voice/voice_recognition.dart';
//import 'package:pj1/voice/voiceRecording.dart';
//import 'package:pj1/voice/voiceScore.dart';
import 'package:pj1/user/profile/profileHome.dart';
import 'audio/nowRecord.dart';
import 'userhome/userHome.dart';
//import 'package:pj1/voice/voiceRecord.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pj1/audio/audioRecognition.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Kakao SDK 초기화
  KakaoSdk.init(nativeAppKey: '964933369a9915e23c10a39dc44ca241');

  // 🔑 현재 실행 중인 키 해시 출력
  final keyHash = await KakaoSdk.origin;
  print('🔑 현재 실행 중인 키 해시: $keyHash');

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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
      ],
      locale: const Locale('ko', 'KR'),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/auth': (context) => const AuthChoiceScreen(),
        '/start': (context) => const StartScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/notification': (context) => const NotificationScreen(),
        '/home': (context) => const HomeScreen(),
        '/recording': (context) => const RecordingHomeScreen(),
        '/findId': (context) => const FindIdScreen(),
        '/findPassword': (context) => const FindPasswordScreen(),
        //'/voice': (context) => const CombinedVoiceScreen(),
        //'/voiceRecognition': (context) => const CombinedVoiceScreen(),
        '/voiceText': (context) => const VoiceTextScreen(),
        //'/voiceRecording': (context) => const AnalyzingFeedbackScreen(),
        //'/scriptPractice': (context) => const ScriptPracticeScreen(),
        '/profileHome': (context) => const ProfileHome(),
        //'/voiceScore': (context) => const ScriptPracticeScreen(),
        //'/voiceRecord': (context) => const VoiceRecordScreen(),
        '/userLogin': (context) => const StartScreen(),
        '/audioRecognition': (context) => NowRecordScreen(),
      },
    );
  }
}
