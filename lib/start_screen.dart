import 'package:flutter/material.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  bool _saveId = false;

  void _login() {
    final id = _idController.text;
    final pw = _pwController.text;

    if (id == 'test@naver.com' && pw == '1234') {
      Navigator.pushReplacementNamed(context, '/notification');
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('로그인 실패'),
          content: const Text('아이디 또는 비밀번호가 올바르지 않습니다.'),
          actions: [
            TextButton(
              child: const Text('확인'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/logo.png',
                width: 80,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    '기존 회원 로그인',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _idController,
                    decoration: const InputDecoration(
                      hintText: '아이디',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _pwController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'PW',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: _saveId,
                        onChanged: (value) {
                          setState(() => _saveId = value!);
                        },
                      ),
                      const Text('아이디 저장'),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/findId');
                        },
                        child: const Text('아이디 찾기'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/findPassword');
                        },
                        child: const Text('비밀번호 찾기'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('로그인'),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const Text('다른 방법으로 로그인 하기'),
                  const SizedBox(height: 12),
                  _socialLoginButton('카카오 로그인', Colors.yellow, Icons.chat),
                  _socialLoginButton('Google 로그인', Colors.grey, Icons.g_mobiledata),
                  _socialLoginButton('이메일 로그인', Colors.lightBlue, Icons.email),
                  _socialLoginButton('Apple 로그인', Colors.black, Icons.apple),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('소리모이 계정이 없으신가요?'),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: const Text(
                          '가입하기',
                          style: TextStyle(color: Colors.purple),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialLoginButton(String text, Color? color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      width: double.infinity,
      height: 45,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(icon, color: Colors.black),
        label: Text(text, style: const TextStyle(color: Colors.black)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
        ),
      ),
    );
  }
}
