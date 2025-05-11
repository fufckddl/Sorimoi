import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  bool _saveId = false;

  Future<void> _login() async {
    final id = _idController.text.trim();
    final pw = _pwController.text.trim();

    final url = Uri.parse('http://43.200.24.193:5000/login');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": id,
          "password": pw,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        // 1) 출석 체크 API 호출
        final userId = data['user_id'].toString(); // 백엔드에서 user_id를 반환한다고 가정
        await _markAttendance(userId);

        // 2) 로그인 성공 처리
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
        Navigator.pushReplacementNamed(context, '/notification');
      } else {
        // 로그인 실패
        _showError(data['message'] ?? '서버 오류');
      }
    } catch (e) {
      _showError("네트워크 오류: $e");
    }
  }

  /// 백엔드에 오늘 출석을 기록합니다.
  Future<void> _markAttendance(String userId) async {
    final today = DateTime.now().toIso8601String().split('T').first;
    final url = Uri.parse('http://43.200.24.193:5000/attendance/check');
    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "date": today,
        }),
      );
      if (res.statusCode == 200 ) {
        // 백엔드에서 이미 체크된 경우 등 메시지 처리
        final body = jsonDecode(res.body);
        print("출석체크: ${body['message']}");
      } else {
        print("출석체크 실패: ${res.statusCode}");
      }
    } catch (e) {
      print("출석체크 오류: $e");
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('로그인 실패'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          )
        ],
      ),
    );
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
                'assets/sori_icon.png',
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
                      backgroundColor: Colors.tealAccent,
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
