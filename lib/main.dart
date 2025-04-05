import 'package:flutter/material.dart';

import 'splash_screen.dart';
import 'auth_choice_screen.dart';
import 'start_screen.dart';
import 'sign_up_screen.dart';
import 'notification_screen.dart';
import 'find_id_screen.dart';
import 'find_password_screen.dart';
import 'find_account_tab_screen.dart';

void main() {
  runApp(const SoriMoiApp());
}

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

        // 아이디/비밀번호 통합 탭 화면
        '/findAccountTab': (context) => const FindAccountTabScreen(),

        // 개별 화면들 (직접 이동 시)
        '/findId': (context) => const FindIdScreen(),
        '/findPassword': (context) => const FindPasswordScreen(),
      },
    );
  }
}
