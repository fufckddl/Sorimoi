import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart'; // 🔑 키 해시 출력을 위해 추가
import 'package:pj1/audio/practice.dart';
import 'package:pj1/config/app_config.dart';

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
import 'package:pj1/user/profile/profileHome.dart';
import 'audio/audioRecognition.dart';
import 'audio/nowRecord.dart';
import 'userhome/userHome.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pj1/notify/notice_screen.dart';
import 'package:pj1/support/support_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Kakao SDK 초기화
  if (AppConfig.kakaoNativeAppKey.isNotEmpty) {
    KakaoSdk.init(nativeAppKey: AppConfig.kakaoNativeAppKey);

    // 🔑 현재 실행 중인 키 해시 출력
    final keyHash = await KakaoSdk.origin;
    print('🔑 현재 실행 중인 키 해시: $keyHash');
  } else {
    debugPrint('Kakao native app key is not configured.');
  }

  runApp(const SoriMoiApp());
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
      theme: ThemeData(fontFamily: 'NotoSansKR'),
      supportedLocales: const [Locale('ko', 'KR')],
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
        '/voiceText': (context) => const VoiceTextScreen(),
        '/profileHome': (context) => const ProfileHome(),
        '/userLogin': (context) => const StartScreen(),
        '/notice': (context) => const NoticeScreen(),
        '/support': (context) => const SupportScreen(),
        '/nowRecord': (context) => const NowRecordScreen(),
        '/audioRecognition': (context) => const RecogAudio(),
        '/practice': (context) => const PracticeScreen(),
      },
    );
  }
}
