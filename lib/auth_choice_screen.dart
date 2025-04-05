import 'package:flutter/material.dart';
import 'start_screen.dart';

class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경 흰색
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Image.asset(
              'assets/sori_icon.png',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 16),
            const Text(
              '소리 모이',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(flex: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // 회원가입 페이지로 이동할 때
                      Navigator.pushNamed(context, '/signup');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF1EDFB), // 연보라
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '회원가입',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      // 로그인 페이지로 이동할 때
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StartScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '로그인',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}