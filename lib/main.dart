import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:pj1/user/find/id/findId.dart';
import 'package:pj1/user/find/password/findPassword.dart';
import 'package:pj1/voice/voice_recognition.dart';
import 'package:pj1/voice/voice_text.dart';

import 'home/loadingScreen.dart';
import 'home/Home.dart';
import 'user/auth/userLogin.dart';
import 'user/auth/userSignup.dart';
import 'notify/notification_screen.dart';
import 'user/find/id/findId.dart';
import 'user/find/password/findPassword.dart';



void main() async{
  await dbConnector();
  runApp(const SoriMoiApp());
}
  Future<void> dbConnector() async {
    print("Connecting to mysql server...");

    try {
      // MySQL 접속 설정
      final conn = await MySQLConnection.createConnection(
        host: '43.200.24.193',
        port: 3306,
        userName: 'sorimoi',
        password: 'Hoseo@12345',
        databaseName: 'sorimoi', // optional
      );

      await conn.connect();

      print("성공");

      await conn.close();
    } catch (e) {
      print("MySQL 연결 실패: $e");
    }
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

        // 개별 화면들 (직접 이동 시)
        '/findId': (context) => const FindIdScreen(),
        '/findPassword': (context) => const FindPasswordScreen(),
        '/voice' : (context) => const VoiceRecognitionScreen(),
        '/voiceText' : (context) => const VoiceTextScreen(),
      },
    );
  }
}
